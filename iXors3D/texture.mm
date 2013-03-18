//
//  texture.m
//  iXors3D
//
//  Created by Knightmare on 26.08.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "texture.h"
#import "render.h"
#import "filesystem.h"
#import "texturemanager.h"

struct xPVRTextureHeader
{
    uint32_t headerLength;
    uint32_t height;
    uint32_t width;
    uint32_t numMipmaps;
    uint32_t flags;
    uint32_t dataLength;
    uint32_t bpp;
    uint32_t bitmaskRed;
    uint32_t bitmaskGreen;
    uint32_t bitmaskBlue;
    uint32_t bitmaskAlpha;
    uint32_t pvrTag;
    uint32_t numSurfs;
};

#define PVR_TEXTURE_FLAG_TYPE_MASK  0xff

enum
{
    kPVRTextureFlagTypePVRTC_2 = 24,
    kPVRTextureFlagTypePVRTC_4
};

static unsigned int NextPOT(unsigned int x)
{
    x = x - 1;
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >> 16);
    return x + 1;
}

xTexture::TextureBuffer::TextureBuffer()
{
	_textureID        = NULL;
	_width            = 0;
	_height           = 0;
	_origWidth        = 0;
	_origHeight       = 0;
	_flags            = 0;
	_frames           = 0;
	_path             = "";
	_pixels           = NULL;
	_lockedPixels     = NULL;
	_counter          = 1; 
	_created          = false;
	_renderTargets    = NULL;
}

xTexture::TextureBuffer::~TextureBuffer()
{
	_textureID    = NULL;
	_width        = 0;
	_height       = 0;
	_origWidth    = 0;
	_origHeight   = 0;
	_flags        = 0;
	_frames       = 0;
	_path         = "";
	_pixels       = NULL;
	_lockedPixels = NULL;
	_created      = false;
}

xTexture::xTexture()
{
	_buffer = NULL;
	/*
	_textureID        = NULL;
	_width            = 0;
	_height           = 0;
	_origWidth        = 0;
	_origHeight       = 0;
	_flags            = 0;
	_frames           = 0;
	_path             = "";
	_pixels           = NULL;
	_lockedPixels     = NULL;
	_counter          = 1; 
	_created          = false;
	*/
	_needMatrix       = false;
	_uscale           = 1.0f;
	_vscale           = 1.0f;
	_angle            = 0.0f;
	_uoffset          = 0.0f;
	_voffset          = 0.0f;
	_blendMode        = 2;
	_textureCoordsSet = 0;
	_counter          = 1;
	UpdateMatrix();
}

xTexture::xTexture(xTexture::TextureBuffer * buffer)
{
	_buffer           = buffer;
	_needMatrix       = false;
	_uscale           = 1.0f;
	_vscale           = 1.0f;
	_angle            = 0.0f;
	_uoffset          = 0.0f;
	_voffset          = 0.0f;
	_blendMode        = 2;
	_textureCoordsSet = 0;
	_counter          = 1;
	UpdateMatrix();
}

xTexture::~xTexture()
{
	/*
	_textureID    = NULL;
	_width        = 0;
	_height       = 0;
	_origWidth    = 0;
	_origHeight   = 0;
	_flags        = 0;
	_frames       = 0;
	_path         = "";
	_pixels       = NULL;
	_lockedPixels = NULL;
	*/
}

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
bool xTexture::CheckPVR(const char * path)
{
	NSString * realPath = [NSString stringWithUTF8String: xFileSystem::Instance()->GetRealPath(path).c_str()];
	static char PVRIdentifier[5] = "PVR!";
	NSData * data = [NSData dataWithContentsOfFile: realPath];
	if(data == nil) return false;
	xPVRTextureHeader * header = (xPVRTextureHeader*)[data bytes];
    uint32_t            pvrTag = CFSwapInt32LittleToHost(header->pvrTag);
    if(PVRIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
	   PVRIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
	   PVRIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
	   PVRIdentifier[3] != ((pvrTag >> 24) & 0xff))
    {
        return false;
    }
	return true;
}

bool xTexture::LoadPVR(const char * path, int loadFlags)
{
	NSString          * realPath    = [NSString stringWithUTF8String: xFileSystem::Instance()->GetRealPath(path).c_str()];
	NSData            * data        = [NSData dataWithContentsOfFile: realPath];
	xPVRTextureHeader * header      = (xPVRTextureHeader*)[data bytes];
	uint32_t            flags       = CFSwapInt32LittleToHost(header->flags);
    uint32_t            formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;
	if(formatFlags == kPVRTextureFlagTypePVRTC_4 || formatFlags == kPVRTextureFlagTypePVRTC_2)
    {
		_buffer = new TextureBuffer();
		GLenum internalFormat;
		if(formatFlags == kPVRTextureFlagTypePVRTC_4)
		{
            internalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
		}
        else if(formatFlags == kPVRTextureFlagTypePVRTC_2)
		{
            internalFormat = GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
		}
		uint32_t dataOffset   = 0;
		uint32_t width        = CFSwapInt32LittleToHost(header->width);
        uint32_t height       = CFSwapInt32LittleToHost(header->height);
        _buffer->_width       = CFSwapInt32LittleToHost(header->width);
        _buffer->_height      = CFSwapInt32LittleToHost(header->height);
		_buffer->_origWidth   = CFSwapInt32LittleToHost(header->width);
        _buffer->_origHeight  = CFSwapInt32LittleToHost(header->height);
        bool hasAlpha         = false;
        uint32_t   dataLength = CFSwapInt32LittleToHost(header->dataLength);
        uint8_t  * bytes      = ((uint8_t*)[data bytes]) + sizeof(xPVRTextureHeader);
		_buffer->_textureID   = (GLuint*)malloc(sizeof(GLuint));
		_buffer->_frames      = 1;
		if(CFSwapInt32LittleToHost(header->bitmaskAlpha)) hasAlpha = true;
		// create texture
		xRender::Instance()->SetContext();
		glActiveTexture(GL_TEXTURE0);
		glEnable(GL_TEXTURE_2D);
        glGenTextures(1, &_buffer->_textureID[0]);
        glBindTexture(GL_TEXTURE_2D, _buffer->_textureID[0]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		// set texture clamping
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, (loadFlags & 16 ? GL_CLAMP_TO_EDGE : GL_REPEAT));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, (loadFlags & 32 ? GL_CLAMP_TO_EDGE : GL_REPEAT));
		// enable/disable mipmaps
		glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_FALSE);
		_buffer->_flags = loadFlags & 0xFFFFFFF7;
		if(header->numMipmaps > 1) _buffer->_flags += 8;
		int mipLevel = 0;
		glGetError();
		glGetError();
		while(dataOffset < dataLength)
        {
			uint32_t blockSize;
			uint32_t widthBlocks;
			uint32_t heightBlocks;
			uint32_t bpp;
            if(formatFlags == kPVRTextureFlagTypePVRTC_4)
            {
                blockSize    = 4 * 4;
                widthBlocks  = width  / 4;
                heightBlocks = height / 4;
                bpp          = 4;
            }
            else
            {
                blockSize    = 8 * 4;
                widthBlocks  = width  / 8;
                heightBlocks = height / 4;
                bpp          = 2;
            }
            if(widthBlocks  < 2) widthBlocks  = 2;
            if(heightBlocks < 2) heightBlocks = 2;
            uint32_t dataSize = widthBlocks * heightBlocks * ((blockSize  * bpp) / 8);
			glCompressedTexImage2D(GL_TEXTURE_2D, mipLevel, internalFormat, 
								   width, height, 0, dataSize, bytes + dataOffset);
			GLenum error = glGetError();
			if(error != GL_NO_ERROR)
			{
				NSLog(@"Error uploading compressed texture level %d. glError: 0x%04X", mipLevel, error);
			}
            dataOffset += dataSize;
            width       = MAX(width  >> 1, 1);
            height      = MAX(height >> 1, 1);
			mipLevel++;
        }
		_buffer->_pixels          = (GLuint**)malloc(sizeof(GLuint*));
		_buffer->_pixels[0]       = NULL;
		_buffer->_lockedPixels    = (GLuint**)malloc(sizeof(GLuint*));
		_buffer->_lockedPixels[0] = nil;
		return true;
	}
	printf("ERROR(%s:%i): Unable to load texture from file '%s'. Unable to read PVR texture.\n", __FILE__, __LINE__, path);
	return false;
}
#endif

bool xTexture::CreatedTexture()
{
	return _buffer->_created;
}

bool xTexture::AnimatedTexture()
{
	return _buffer->_frames > 1;
}

bool xTexture::Load(const char * path, int flags)
{
	_buffer = new TextureBuffer();
	// save flags & txture file name
	_buffer->_flags = flags;
	_buffer->_path  = path;
	// check pvr texture
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	if(CheckPVR(path)) return LoadPVR(path, flags);
#endif
	// load CG image from file
	NSString * realPath = [NSString stringWithUTF8String: xFileSystem::Instance()->GetRealPath(path).c_str()];
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	CGImageRef cgImage = [UIImage imageWithContentsOfFile: realPath].CGImage;
#else
	NSImage          * image   = [[NSImage alloc] initWithContentsOfFile: realPath];
	CGImageSourceRef   source  = CGImageSourceCreateWithData((CFDataRef)[image TIFFRepresentation], NULL);
	CGImageRef         cgImage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
	[image release];
#endif
	if(!cgImage)
	{
		printf("ERROR(%s:%i): Unable to load texture from file '%s'. Unable to read file.\n", __FILE__, __LINE__, path);
		return false;
	}
	// rescale image if needed
	_buffer->_origWidth       = CGImageGetWidth(cgImage);
	_buffer->_origHeight      = CGImageGetHeight(cgImage);
    _buffer->_width           = NextPOT(_buffer->_origWidth);
    _buffer->_height          = NextPOT(_buffer->_origHeight);
	_buffer->_pixels          = (GLuint**)malloc(sizeof(GLuint*));
	_buffer->_lockedPixels    = (GLuint**)malloc(sizeof(GLuint*));
	_buffer->_lockedPixels[0] = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_buffer->_pixels[0]  = (GLuint*)malloc(_buffer->_height * _buffer->_width * 4);
	CGContextRef context = CGBitmapContextCreate(_buffer->_pixels[0], _buffer->_width, _buffer->_height, 8, 4 * _buffer->_width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	CGContextClearRect(context, CGRectMake(0, 0, _buffer->_width, _buffer->_height));
	CGContextDrawImage(context, CGRectMake(0, 0, _buffer->_width, _buffer->_height), cgImage);
	CGColorSpaceRelease(colorSpace);
	if(CGImageGetAlphaInfo(cgImage) != kCGImageAlphaNone
	   && CGImageGetAlphaInfo(cgImage) != kCGImageAlphaNoneSkipLast
	   && CGImageGetAlphaInfo(cgImage) != kCGImageAlphaNoneSkipFirst) FixRGBA(_buffer->_pixels[0], _buffer->_width, _buffer->_height);
	// mask image
	if((flags & 2) && (CGImageGetAlphaInfo(cgImage) == kCGImageAlphaNone
		|| CGImageGetAlphaInfo(cgImage) == kCGImageAlphaNoneSkipLast
		|| CGImageGetAlphaInfo(cgImage) == kCGImageAlphaNoneSkipFirst)) ComputeAlpha((uint32_t *)_buffer->_pixels[0]);
	if(flags & 4) Mask((uint32_t *)_buffer->_pixels[0], 0, 0, 0);
	// check max texture size
	GLint maxTextureSize;
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
	if(_buffer->_width <= maxTextureSize && _buffer->_height <= maxTextureSize)
    {
		// allocate texture frames array
		_buffer->_textureID = (GLuint*)malloc(sizeof(GLuint));
		_buffer->_frames    = 1;
		// create texture
		glActiveTexture(GL_TEXTURE0);
        glGenTextures(1, &_buffer->_textureID[0]);
        glBindTexture(GL_TEXTURE_2D, _buffer->_textureID[0]);
		// set filtering
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, (flags & 8 ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, (flags & 8 ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR));
		// set texture clamping
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, (flags & 16 ? GL_CLAMP_TO_EDGE : GL_REPEAT));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, (flags & 32 ? GL_CLAMP_TO_EDGE : GL_REPEAT));
		// enable/disable mipmaps
		glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, (flags & 8 ? GL_TRUE : GL_FALSE));
		// write pixels
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _buffer->_width, _buffer->_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, _buffer->_pixels[0]);
    }
	else
	{
		printf("ERROR(%s:%i): Unable to load texture from file '%s'. Unsupported texture size.\n", __FILE__, __LINE__, path);
		return false;
	}
    // delete temp array
	CGContextRelease(context);
	// release CG image data
    //CGImageRelease(cgImage); // WTF? Can't load same image if it previously released, CG bug may be
	if(xRender::Instance()->GetAutoDeletePixels()) DeletePixels();
	// all done
	return true;
}

void xTexture::FixRGBA(uint32_t * pixels, int width, int height)
{
	for(int x = 0; x < width; x++)
	{
		for(int y = 0; y < height; y++)
		{
			float red   = float(pixels[y * width + x] & 0xFF);
			float green = float((pixels[y * width + x] >> 8) & 0xFF);
			float blue  = float((pixels[y * width + x] >> 16) & 0xFF);
			float alpha = 1.0f / (float((pixels[y * width + x] >> 24) & 0xFF) / 255.0f);
			int fixedBlue = (blue * alpha);
			if(fixedBlue < 0) fixedBlue = 0;
			if(fixedBlue > 255) fixedBlue = 255;
			int fixedGreen = (green * alpha);
			if(fixedGreen < 0) fixedGreen = 0;
			if(fixedGreen > 255) fixedGreen = 255;
			int fixedRed = (red * alpha);
			if(fixedRed < 0) fixedRed = 0;
			if(fixedRed > 255) fixedRed = 255;
			int rgba = (pixels[y * width + x] & 0xFF000000) + (fixedBlue << 16) + (fixedGreen << 8) + fixedRed;
			pixels[y * width + x] = rgba;
		}
	}
}

bool xTexture::CreateWithBytes(void * data, unsigned int length)
{
	_buffer = new TextureBuffer();
	// save flags & txture file name
	_buffer->_flags = 1;
	_buffer->_path  = "";
	// load CG image from file
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, length, NULL);
	CGImageRef image = CGImageCreateWithPNGDataProvider(provider, NULL, NO, kCGRenderingIntentDefault);
	if(image == NULL) return false;
	// rescale image if needed
	_buffer->_origWidth       = CGImageGetWidth(image);
	_buffer->_origHeight      = CGImageGetHeight(image);
    _buffer->_width           = _buffer->_origWidth;
    _buffer->_height          = _buffer->_origHeight;
	_buffer->_pixels          = (GLuint**)malloc(sizeof(GLuint*));
	_buffer->_lockedPixels    = (GLuint**)malloc(sizeof(GLuint*));
	_buffer->_lockedPixels[0] = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_buffer->_pixels[0]  = (GLuint*)malloc(_buffer->_height * _buffer->_width * 4);
	CGContextRef context = CGBitmapContextCreate(_buffer->_pixels[0], _buffer->_width, _buffer->_height, 8, 4 * _buffer->_width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGContextClearRect(context, CGRectMake(0, 0, _buffer->_width, _buffer->_height));
	CGContextDrawImage(context, CGRectMake(0, 0, _buffer->_width, _buffer->_height), image);
	FixRGBA(_buffer->_pixels[0], _buffer->_width, _buffer->_height);
	// check max texture size
	GLint maxTextureSize;
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
	if(_buffer->_width <= maxTextureSize && _buffer->_height <= maxTextureSize)
    {
		// allocate texture frames array
		_buffer->_textureID = (GLuint*)malloc(sizeof(GLuint));
		_buffer->_frames    = 1;
		// create texture
		glActiveTexture(GL_TEXTURE0);
        glGenTextures(1, &_buffer->_textureID[0]);
        glBindTexture(GL_TEXTURE_2D, _buffer->_textureID[0]);
		// set filtering
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		// set texture clamping
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		// enable/disable mipmaps
		glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
		// write pixels
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _buffer->_width, _buffer->_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, _buffer->_pixels[0]);
    }
	else
	{
		printf("ERROR(%s:%i): Unable to load texture from UIImage. Unsupported texture size.\n", __FILE__, __LINE__);
		return false;
	}
    // delete 
	CGDataProviderRelease(provider);
    CGImageRelease(image);
	if(xRender::Instance()->GetAutoDeletePixels()) DeletePixels();
	// all done
	return true;
}

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
bool xTexture::CreateWithUIImage(UIImage * image)
{
	_buffer = new TextureBuffer();
	// save flags & txture file name
	_buffer->_flags = 1 + 8;
	_buffer->_path  = "";
	// load CG image from file
	// rescale image if needed
	_buffer->_origWidth       = CGImageGetWidth(image.CGImage);
	_buffer->_origHeight      = CGImageGetHeight(image.CGImage);
    _buffer->_width           = NextPOT(_buffer->_origWidth);
    _buffer->_height          = NextPOT(_buffer->_origHeight);
	_buffer->_pixels          = (GLuint**)malloc(sizeof(GLuint*));
	_buffer->_lockedPixels    = (GLuint**)malloc(sizeof(GLuint*));
	_buffer->_lockedPixels[0] = nil;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_buffer->_pixels[0]  = (GLuint*)malloc(_buffer->_height * _buffer->_width * 4);
	CGContextRef context = CGBitmapContextCreate(_buffer->_pixels[0], _buffer->_width, _buffer->_height, 8, 4 * _buffer->_width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGContextClearRect(context, CGRectMake(0, 0, _buffer->_width, _buffer->_height));
	CGContextDrawImage(context, CGRectMake(0, 0, _buffer->_width, _buffer->_height), image.CGImage);
	// check max texture size
	GLint maxTextureSize;
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
	if(_buffer->_width <= maxTextureSize && _buffer->_height <= maxTextureSize)
    {
		// allocate texture frames array
		_buffer->_textureID = (GLuint*)malloc(sizeof(GLuint));
		_buffer->_frames    = 1;
		// create texture
		glActiveTexture(GL_TEXTURE0);
        glGenTextures(1, &_buffer->_textureID[0]);
        glBindTexture(GL_TEXTURE_2D, _buffer->_textureID[0]);
		// set filtering
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		// set texture clamping
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		// enable/disable mipmaps
		glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
		// write pixels
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _buffer->_width, _buffer->_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, _buffer->_pixels[0]);
    }
	else
	{
		printf("ERROR(%s:%i): Unable to load texture from UIImage. Unsupported texture size.\n", __FILE__, __LINE__);
		return false;
	}
    // delete temp array
	CGContextRelease(context);
	// release CG image data
    //CGImageRelease(cgImage); // WTF? Can't load same image if it previously released, CG bug may be
	if(xRender::Instance()->GetAutoDeletePixels()) DeletePixels();
	// all done
	return true;
}
#endif

bool xTexture::LoadAnimated(const char * path, int flags, int frameWidth, int frameHeight, int firstFrame, int frames)
{
	_buffer = new TextureBuffer();
	// save flags & txture file name
	_buffer->_flags = flags;
	_buffer->_path  = path;
	// load CG image from file
	NSString * realPath = [NSString stringWithUTF8String: xFileSystem::Instance()->GetRealPath(path).c_str()];
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	CGImageRef cgImage = [UIImage imageWithContentsOfFile: realPath].CGImage;
#else
	NSImage          * image   = [[NSImage alloc] initWithContentsOfFile: realPath];
	CGImageSourceRef   source  = CGImageSourceCreateWithData((CFDataRef)[image TIFFRepresentation], NULL);
	CGImageRef         cgImage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
	[image release];
#endif
	if(!cgImage)
	{
		printf("ERROR(%s:%i): Unable to load animated texture from file '%s'. Unable to read file.\n", __FILE__, __LINE__, path);
		return false;
	}
	// extract all frames
	_buffer->_textureID  = (GLuint*)malloc(sizeof(GLuint) * frames);
	_buffer->_frames     = frames;
	_buffer->_origWidth  = frameWidth;
	_buffer->_origHeight = frameHeight;
	_buffer->_width      = NextPOT(_buffer->_origWidth);
    _buffer->_height     = NextPOT(_buffer->_origHeight);
	// get frames in imge strip
	int framesInStrip = CGImageGetWidth(cgImage) / frameWidth;
	if(framesInStrip < 1)
	{
		printf("ERROR(%s:%i): Unable to load animated texture from file '%s'. Image too small for extracting farmes.\n", __FILE__, __LINE__, path);
		return false;
	}
	// check max texture size
	GLint maxTextureSize;
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
	if(_buffer->_width > maxTextureSize || _buffer->_height > maxTextureSize)
    {
		printf("ERROR(%s:%i): Unable to load animated texture from file '%s'. Unsupported frame size.\n", __FILE__, __LINE__, path);
		return false;
	}
	// create context
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	GLuint * pixels      = (GLuint*)malloc(_buffer->_height * _buffer->_width * 4);
	CGContextRef context = CGBitmapContextCreate(pixels, _buffer->_width, _buffer->_height, 8, 4 * _buffer->_width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	_buffer->_pixels       = (GLuint**)malloc(sizeof(GLuint*) * _buffer->_frames);
	_buffer->_lockedPixels = (GLuint**)malloc(sizeof(GLuint*) * _buffer->_frames);
	for(int i = 0; i < frames; i++)
	{
		// getting frame rect
		int x = ((firstFrame + i) % framesInStrip) * _buffer->_origWidth;
		int y = ((firstFrame + i) / framesInStrip) * _buffer->_origHeight;
		if(x < 0 || y < 0 || (x + _buffer->_origWidth) > CGImageGetWidth(cgImage) || (y + _buffer->_origHeight) > CGImageGetHeight(cgImage))
		{
			printf("ERROR(%s:%i): Unable to load animated texture from file '%s'. Image too small for extracting frame #%i.\n", __FILE__, __LINE__, path, i);
			return false;
		}
		// allocate pixels array
		_buffer->_pixels[i]       = (GLuint*)malloc(_buffer->_height * _buffer->_width * 4);
		_buffer->_lockedPixels[i] = nil;
		CGRect frameRect = CGRectMake(x, y, _buffer->_origWidth, _buffer->_origHeight);
		// copy original image rect to new image
		CGImageRef tempImage = CGImageCreateWithImageInRect(cgImage, frameRect);
		// render image to context
		CGContextSetBlendMode(context, kCGBlendModeCopy);
		CGContextClearRect(context, CGRectMake(0, 0, _buffer->_width, _buffer->_height));
		CGContextDrawImage(context, CGRectMake(0, 0, _buffer->_width, _buffer->_height), tempImage);
		// copy pixels
		memcpy(_buffer->_pixels[i], pixels, _buffer->_height * _buffer->_width * 4);
		if(CGImageGetAlphaInfo(cgImage) != kCGImageAlphaNone
		   && CGImageGetAlphaInfo(cgImage) != kCGImageAlphaNoneSkipLast
		   && CGImageGetAlphaInfo(cgImage) != kCGImageAlphaNoneSkipFirst) FixRGBA(_buffer->_pixels[i], _buffer->_width, _buffer->_height);
		if((flags & 2) && (CGImageGetAlphaInfo(cgImage) == kCGImageAlphaNone
			|| CGImageGetAlphaInfo(cgImage) == kCGImageAlphaNoneSkipLast
			|| CGImageGetAlphaInfo(cgImage) == kCGImageAlphaNoneSkipFirst)) ComputeAlpha((uint32_t *)_buffer->_pixels[i]);
		if(flags & 4) Mask((uint32_t *)_buffer->_pixels[i], 0, 0, 0);
		// create texture
		glActiveTexture(GL_TEXTURE0);
        glGenTextures(1, &_buffer->_textureID[i]);
        glBindTexture(GL_TEXTURE_2D, _buffer->_textureID[i]);
		// set filtering
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, (flags & 8 ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, (flags & 8 ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR));
		// set texture clamping
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, (flags & 16 ? GL_CLAMP_TO_EDGE : GL_REPEAT));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, (flags & 32 ? GL_CLAMP_TO_EDGE : GL_REPEAT));
		// enable/disable mipmaps
		glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, (flags & 8 ? GL_TRUE : GL_FALSE));
		// write pixels
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _buffer->_width, _buffer->_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, _buffer->_pixels[i]);
		// release temp image
		CGImageRelease(tempImage);
	}
	// delete temp array
	CGContextRelease(context);
	if(pixels) free(pixels);
	if(xRender::Instance()->GetAutoDeletePixels()) DeletePixels();
	// release CG image data
    //CGImageRelease(cgImage); // WTF? Can't load same image if it previously released, CG bug may be
	// all done
	return true;
}

bool xTexture::Create(int flags, int frameWidth, int frameHeight, int frames)
{
	_buffer = new TextureBuffer();
	// save flags & txture file name
	_buffer->_flags   = flags;
	_buffer->_path    = "";
	_buffer->_created = true;
	// create all frames
	_buffer->_textureID  = (GLuint*)malloc(sizeof(GLuint) * frames);
	_buffer->_frames     = frames;
	_buffer->_origWidth  = frameWidth;
	_buffer->_origHeight = frameHeight;
	_buffer->_width      = NextPOT(_buffer->_origWidth);
    _buffer->_height     = NextPOT(_buffer->_origHeight);
	// check max texture size
	GLint maxTextureSize;
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
	if(_buffer->_width > maxTextureSize || _buffer->_height > maxTextureSize)
    {
		printf("ERROR(%s:%i): Unable to create texture. Unsupported frame size.\n", __FILE__, __LINE__);
		return false;
	}
	// create frames
	_buffer->_pixels       = (GLuint**)malloc(sizeof(GLuint*) * _buffer->_frames);
	_buffer->_lockedPixels = (GLuint**)malloc(sizeof(GLuint*) * _buffer->_frames);
	for(int i = 0; i < frames; i++)
	{
		// allocate pixels array
		_buffer->_pixels[i]       = (GLuint*)malloc(_buffer->_height * _buffer->_width * 4);
		_buffer->_lockedPixels[i] = nil;
#if !TARGET_OS_EMBEDDED
		for(int x = 0; x < _buffer->_width; x++)
		{
			for(int y = 0; y < _buffer->_height; y++)
			{
				_buffer->_pixels[i][y * _buffer->_width + x] = 0x00000000;
			}
		}
#endif
		// create texture
		glActiveTexture(GL_TEXTURE0);
        glGenTextures(1, &_buffer->_textureID[i]);
        glBindTexture(GL_TEXTURE_2D, _buffer->_textureID[i]);
		// set filtering
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, (flags & 8 ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, (flags & 8 ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR));
		// set texture clamping
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, (flags & 16 ? GL_CLAMP_TO_EDGE : GL_REPEAT));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, (flags & 32 ? GL_CLAMP_TO_EDGE : GL_REPEAT));
		// enable/disable mipmaps
		glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, (flags & 8 ? GL_TRUE : GL_FALSE));
		// write pixels
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _buffer->_width, _buffer->_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, _buffer->_pixels[i]);
	}
	if(xRender::Instance()->GetAutoDeletePixels()) DeletePixels();
	// all done
	return true;
}

int xTexture::GetWidth()
{
	return _buffer->_origWidth;
}

int xTexture::GetHeight()
{
	return _buffer->_origHeight;
}

GLuint xTexture::GetTextureID(int frame)
{
	if(frame < 0 || frame >= _buffer->_frames) return 0;
	if(_buffer->_lockedPixels[frame] != NULL) Unlock(frame);
	return _buffer->_textureID[frame];
}

xTexture * xTexture::Clone()
{
	if(_buffer->_pixels[0] == NULL) return NULL;
	// allocate new texture
	xTexture * newTexture = new xTexture();
	newTexture->_buffer = new TextureBuffer();
	// clone params
	newTexture->_buffer->_flags        = _buffer->_flags;
	newTexture->_buffer->_path         = _buffer->_path;
	newTexture->_buffer->_frames       = _buffer->_frames;
	newTexture->_buffer->_origWidth    = _buffer->_origWidth;
	newTexture->_buffer->_origHeight   = _buffer->_origHeight;
	newTexture->_buffer->_width        = _buffer->_width;
    newTexture->_buffer->_height       = _buffer->_height;
	// clone pixels arrays
	newTexture->_buffer->_pixels       = (GLuint**)malloc(sizeof(GLuint*) * newTexture->_buffer->_frames);
	newTexture->_buffer->_lockedPixels = (GLuint**)malloc(sizeof(GLuint*) * newTexture->_buffer->_frames);
	// clone textures
	newTexture->_buffer->_textureID    = (GLuint*)malloc(sizeof(GLuint) * newTexture->_buffer->_frames);
	for(int i = 0; i < newTexture->_buffer->_frames; i++)
	{
		newTexture->_buffer->_lockedPixels[i] = NULL;
		// clone pixels array
		newTexture->_buffer->_pixels[i] = (GLuint*)malloc(newTexture->_buffer->_width * newTexture->_buffer->_height * 4);
		memcpy(newTexture->_buffer->_pixels[i], _buffer->_pixels[i], newTexture->_buffer->_width * newTexture->_buffer->_height * 4);
		// create texture
		glActiveTexture(GL_TEXTURE0);
        glGenTextures(1, &newTexture->_buffer->_textureID[i]);
        glBindTexture(GL_TEXTURE_2D, newTexture->_buffer->_textureID[i]);
		// set filtering
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, (newTexture->_buffer->_flags & 8 ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, (newTexture->_buffer->_flags & 8 ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR));
		// set texture clamping
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, (newTexture->_buffer->_flags & 16 ? GL_CLAMP_TO_EDGE : GL_REPEAT));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, (newTexture->_buffer->_flags & 32 ? GL_CLAMP_TO_EDGE : GL_REPEAT));
		// enable/disable mipmaps
		glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, (newTexture->_buffer->_flags & 8 ? GL_TRUE : GL_FALSE));
		// write pixels
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, newTexture->_buffer->_width, newTexture->_buffer->_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, newTexture->_buffer->_pixels[i]);
	}
	// return new texture
	return newTexture;
}

void xTexture::Lock(int frame)
{
	if(frame < 0 || frame >= _buffer->_frames) return;
	if(_buffer->_lockedPixels[frame] != NULL) return;
	if(_buffer->_pixels[frame] == NULL) return;
	if(_buffer->_origWidth != _buffer->_width || _buffer->_origHeight != _buffer->_height)
	{
		// create data provider with pixel data
		CGDataProviderRef data = CGDataProviderCreateWithData(NULL, _buffer->_pixels[frame], _buffer->_width * _buffer->_height * 4, nil);
		// create temp image
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGImageRef tempImage = CGImageCreate(_buffer->_width, _buffer->_height, 8, 32, 4 * _buffer->_width,
											 colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big,
											 data, NULL, false, kCGRenderingIntentDefault);
		// rescale image to original size
		_buffer->_lockedPixels[frame] = (GLuint*)malloc(_buffer->_origHeight * _buffer->_origWidth * 4);
		CGContextRef context = CGBitmapContextCreate(_buffer->_lockedPixels[frame], _buffer->_origWidth, _buffer->_origHeight, 8, 4 * _buffer->_origWidth, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		CGContextClearRect(context, CGRectMake(0, 0, _buffer->_origWidth, _buffer->_origHeight));
		CGContextDrawImage(context, CGRectMake(0, 0, _buffer->_origWidth, _buffer->_origHeight), tempImage);
		//FixRGBA(_lockedPixels[frame], _origWidth, _origHeight);
		// destory temp context
		CGContextRelease(context);
		// destroy temp image
		CGImageRelease(tempImage);
		// destroy data provider
		CGDataProviderRelease(data);
	}
	else
	{
		_buffer->_lockedPixels[frame] = _buffer->_pixels[frame];
	}	
}

uint * xTexture::GetPixels(int frame)
{
	if(frame < 0 || frame >= _buffer->_frames) return NULL;
	if(_buffer->_pixels[frame] == NULL) return NULL;
	if(_buffer->_origWidth != _buffer->_width || _buffer->_origHeight != _buffer->_height)
	{
		// create data provider with pixel data
		CGDataProviderRef data = CGDataProviderCreateWithData(NULL, _buffer->_pixels[frame], _buffer->_width * _buffer->_height * 4, nil);
		// create temp image
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGImageRef tempImage = CGImageCreate(_buffer->_width, _buffer->_height, 8, 32, 4 * _buffer->_width,
											 colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big,
											 data, NULL, false, kCGRenderingIntentDefault);
		// rescale image to original size
		uint * pixels = (uint*)malloc(_buffer->_origHeight * _buffer->_origWidth * 4);
		CGContextRef context = CGBitmapContextCreate(pixels, _buffer->_origWidth, _buffer->_origHeight, 8, 4 * _buffer->_origWidth, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		CGContextClearRect(context, CGRectMake(0, 0, _buffer->_origWidth, _buffer->_origHeight));
		CGContextDrawImage(context, CGRectMake(0, 0, _buffer->_origWidth, _buffer->_origHeight), tempImage);
		//FixRGBA(pixels, _origWidth, _origHeight);
		// destory temp context
		CGContextRelease(context);
		// destroy temp image
		CGImageRelease(tempImage);
		// destroy data provider
		CGDataProviderRelease(data);
		return pixels;
	}
	else
	{
		uint * pixels = (uint*)malloc(_buffer->_origHeight * _buffer->_origWidth * 4);
		memcpy((void*)pixels, (void*)_buffer->_pixels[frame], _buffer->_origHeight * _buffer->_origWidth * 4);
		return pixels;
	}
}

void xTexture::Unlock(int frame)
{
	if(frame < 0 || frame >= _buffer->_frames) return;
	if(_buffer->_lockedPixels[frame] == NULL) return;
	if(_buffer->_pixels[frame] == NULL) return;
	if(_buffer->_origWidth != _buffer->_width || _buffer->_origHeight != _buffer->_height)
	{
		// create data provider with pixel data
		CGDataProviderRef data = CGDataProviderCreateWithData(NULL, _buffer->_lockedPixels[frame], _buffer->_origWidth * _buffer->_origHeight * 4, NULL);
		// create temp image
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGImageRef tempImage = CGImageCreate(_buffer->_origWidth, _buffer->_origHeight, 8, 32, 4 * _buffer->_origWidth,
											 colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big,
											 data, NULL, false, kCGRenderingIntentDefault);
		// rescale image back
		CGContextRef context = CGBitmapContextCreate(_buffer->_pixels[frame], _buffer->_width, _buffer->_height, 8, 4 * _buffer->_width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		CGContextClearRect(context, CGRectMake(0, 0, _buffer->_width, _buffer->_height));
		CGContextDrawImage(context, CGRectMake(0, 0, _buffer->_width, _buffer->_height), tempImage);
		//FixRGBA(_pixels[frame], _width, _height);
		// destroy temp pixels
		free(_buffer->_lockedPixels[frame]);
		_buffer->_lockedPixels[frame] = NULL;
		// destory temp context
		CGContextRelease(context);
		// destroy temp image
		CGImageRelease(tempImage);
		// destroy data provider
		CGDataProviderRelease(data);
	}
	else
	{
		_buffer->_lockedPixels[frame] = NULL;
	}
	// recreate texture pixels
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, _buffer->_textureID[frame]);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _buffer->_width, _buffer->_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, _buffer->_pixels[frame]);
}

void xTexture::ApplyMask(int red, int green, int blue)
{
	for(int i = 0; i < _buffer->_frames; i++)
	{
		if(_buffer->_pixels[i] == NULL) continue;
		Mask((uint32_t *)_buffer->_pixels[i], red, green, blue);
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, _buffer->_textureID[i]);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _buffer->_width, _buffer->_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, _buffer->_pixels[i]);
	}
}

GLuint xTexture::ReadPixel(int x, int y, int frame)
{
	if(frame < 0 || frame >= _buffer->_frames) return 0;
	if(x < 0 || y < 0 || x >= _buffer->_origWidth || y >= _buffer->_origHeight) return 0;
	if(_buffer->_pixels[frame] == NULL) return 0;
	BOOL locked = true;
	if(_buffer->_lockedPixels[frame] == NULL)
	{
		Lock(frame);
		locked = false;
	}
	GLuint result = _buffer->_lockedPixels[frame][y * _buffer->_origWidth + x];
	if(!locked) Unlock(frame);
	// ABGR -> RGBA
	return (result & 0xFF00FF00) + ((result & 255) << 16) + ((result >> 16) & 255);;
}

void xTexture::WritePixel(int x, int y, GLuint color, int frame)
{
	if(frame < 0 || frame >= _buffer->_frames) return;
	if(x < 0 || y < 0 || x >= _buffer->_origWidth || y >= _buffer->_origHeight) return;
	if(_buffer->_pixels[frame] == NULL) return;
	BOOL locked = true;
	if(_buffer->_lockedPixels[frame] == NULL)
	{
		Lock(frame);
		locked = false;
	}
	_buffer->_lockedPixels[frame][y * _buffer->_origWidth + x] = (color & 0xFF00FF00) + ((color & 255) << 16) + ((color >> 16) & 255);
	if(!locked) Unlock(frame);
}

bool xTexture::IsLocked(int frame)
{
	return (_buffer->_lockedPixels[frame] != NULL);
}

void xTexture::DeletePixels()
{
	for(int i = 0; i < _buffer->_frames; i++)
	{
		if(_buffer->_lockedPixels[i] != NULL) Unlock(i);
		if(_buffer->_pixels[i] != NULL) free(_buffer->_pixels[i]);
		_buffer->_pixels[i] = NULL;
	}
}

void xTexture::TextureBuffer::Release()
{
	_counter--;
	if(_counter < 1)
	{
		if(_textureID != NULL)
		{
			for(int i = 0; i < _frames; i++)
			{
				glDeleteTextures(1, &_textureID[i]);
				if(_pixels[i] != NULL) free(_pixels[i]);
				if(_origWidth != _width || _origHeight != _height)
				{
					if(_lockedPixels[i] != NULL) free(_lockedPixels[i]);
				}
			}
			free(_pixels);
			free(_lockedPixels);
			free(_textureID);
		}
		if(_renderTargets != NULL)
		{
			for(int i = 0; i < _frames; i++)
			{
				GLuint depthBuffer;
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
				glGetFramebufferAttachmentParameterivOES(_renderTargets[i], GL_DEPTH_ATTACHMENT_OES, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME_OES, (GLint*)&depthBuffer);
				glDeleteFramebuffersOES(1, &_renderTargets[i]);
				glDeleteRenderbuffersOES(1, &depthBuffer);
#else
				glGetFramebufferAttachmentParameterivEXT(_renderTargets[i], GL_DEPTH_ATTACHMENT_EXT, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME_EXT, (GLint*)&depthBuffer);
				glDeleteFramebuffersEXT(1, &_renderTargets[i]);
				glDeleteRenderbuffersEXT(1, &depthBuffer);
#endif
			}
			delete [] _renderTargets;
			_renderTargets = NULL;
		}
	}
}

void xTexture::Release()
{
	_counter--;
	if(_counter > 0) return;
	_buffer->Release();
	if(_buffer->_counter < 1)
	{
		xTextureManager::Instance()->ReleaseBuffer(_buffer);
		delete _buffer;
		_buffer = NULL;
	}
}

void xTexture::ForceRelease()
{
	while(_buffer != NULL) Release();
}

xTexture::TextureBuffer * xTexture::GetBufferObject()
{
	return _buffer;
}

void xTexture::Retain()
{
	_counter++;
}

void xTexture::TextureBuffer::Retain()
{
	_counter++;
}

int xTexture::GetCounter()
{
	return _counter;
}

int xTexture::GetFlags()
{
	return _buffer->_flags;
}

void xTexture::SetFlags(int flags)
{
	_buffer->_flags = flags;
}

void xTexture::Mask(uint32_t * pixels, int red, int green, int blue)
{
	for(int x = 0; x < _buffer->_width; x++)
	{
		for(int y = 0; y < _buffer->_height; y++)
		{
			uint color = pixels[y * _buffer->_width + x];
			int cred   = color & 255;
			int cgreen = (color >> 8) & 255;
			int cblue  = (color >> 16)  & 255;
			if(red == cred && green == cgreen && blue == cblue) pixels[y * _buffer->_width + x] = cred | (cgreen << 8) | (cblue << 16);
		}
	}
}

void xTexture::ComputeAlpha(uint32_t * pixels)
{
	for(int x = 0; x < _buffer->_width; x++)
	{
		for(int y = 0; y < _buffer->_height; y++)
		{
			uint color = pixels[y * _buffer->_width + x];
			int cred   = color & 255;
			int cgreen = (color >> 8) & 255;
			int cblue  = (color >> 16)  & 255;
			int alpha  = (cred + cgreen + cblue) / 3;
			pixels[y * _buffer->_width + x] = cred | (cgreen << 8) | (cblue << 16) | ((alpha & 255) << 24);
		}
	}
}

void xTexture::UpdateMatrix()
{
	xMatrix matrix = ScaleMatrix(1.0f / _uscale, 1.0f / _vscale, 1.0f) * RollMatrix(_angle);
	_matrix[0]     = matrix.i.x;
	_matrix[1]     = matrix.i.y;
	_matrix[2]     = 0.0f;
	_matrix[3]     = 0.0f;
	_matrix[4]     = matrix.j.x;
	_matrix[5]     = matrix.j.y;
	_matrix[6]     = 0.0f;
	_matrix[7]     = 0.0f;
	_matrix[8]     = 0.0f;
	_matrix[9]     = 0.0f;
	_matrix[10]    = 1.0f;
	_matrix[11]    = 0.0f;
	_matrix[12]    = -_uoffset;
	_matrix[13]    = -_voffset;
	_matrix[14]    = 0.0f;
	_matrix[15]    = 1.0f;
	_needMatrix    = true;
}

int xTexture::FramesCount()
{
	return _buffer->_frames;
}

void xTexture::SetScale(float u, float v)
{
	_uscale = u;
	_vscale = v;
	UpdateMatrix();
}

void xTexture::SetOffset(float u, float v)
{
	_uoffset = u;
	_voffset = v;
	UpdateMatrix();
}

void xTexture::SetRotation(float angle)
{
	_angle = angle;
	UpdateMatrix();
}

void xTexture::SetMatrix(int layer)
{
	glActiveTexture(GL_TEXTURE0 + layer);
	glMatrixMode(GL_TEXTURE);
	glLoadMatrixf(_matrix);
}

int xTexture::GetBlendMode()
{
	return _blendMode;
}

void xTexture::SetBlendMode(int mode)
{
	_blendMode = mode;
}

void xTexture::SetCoordsSet(int setNum)
{
	_textureCoordsSet = setNum;
}

int xTexture::GetCoordsSet()
{
	return _textureCoordsSet;
}

const char * xTexture::GetPath()
{
	return _buffer->_path.c_str();
}

void xTexture::SetTarget(int frame)
{
	if(frame < 0 || frame >= _buffer->_frames) return;
	if(_buffer->_renderTargets == NULL)
	{
		_buffer->_renderTargets = new GLuint[_buffer->_frames];
		for(int i = 0; i < _buffer->_frames; i++) _buffer->_renderTargets[i] = 0;
	}
	if(_buffer->_renderTargets[frame] == 0)
	{
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
		glGenFramebuffersOES(1, &_buffer->_renderTargets[frame]);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, _buffer->_renderTargets[frame]);
		glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, _buffer->_textureID[frame], 0);
		GLuint depthBuffer;
		glGenRenderbuffersOES(1, &depthBuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthBuffer);
		glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, _buffer->_width, _buffer->_height);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthBuffer);
		if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
		{
			printf("ERROR(%s:%i): Failed to make framebuffer object %x.\n", __FILE__, __LINE__, glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
			return;
		}
#else
		glGenFramebuffersEXT(1, &_buffer->_renderTargets[frame]);
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _buffer->_renderTargets[frame]);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, _buffer->_textureID[frame], 0);
		GLuint depthBuffer;
		glGenRenderbuffersEXT(1, &depthBuffer);
		glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, depthBuffer);
		glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT24, _buffer->_width, _buffer->_height);
		glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, depthBuffer);
		if(glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT) != GL_FRAMEBUFFER_COMPLETE_EXT)
		{
			printf("ERROR(%s:%i): Failed to make framebuffer object %x.\n", __FILE__, __LINE__, glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT));
			return;
		}
#endif
		xRender::Instance()->SetFrameBuffer();
	}
	xRender::Instance()->SetActiveBuffer(_buffer->_renderTargets[frame]);
}