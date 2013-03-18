#import "helpers.h"
#import <Foundation/Foundation.h>

RAMFile::RAMFile(FILE * file)
{
	offset = 0;
	fseek(file, 0, SEEK_END);
	size = ftell(file);
	fseek(file, 0, SEEK_SET);
	data = new unsigned char[size];
	fread(data, 1, size, file);
}

void RAMFile::Release()
{
	delete [] data;
}

int ReadInt(RAMFile * f)
{
	int rInt = *(int*)&f->data[f->offset];
	f->offset += 4;
	return rInt;
}

ushort ReadWord(RAMFile * f)
{
	ushort rInt = *(ushort*)&f->data[f->offset];
	f->offset += 2;
	return rInt;
}

unsigned char ReadByte(RAMFile * f)
{
	unsigned char rInt = *(unsigned char*)&f->data[f->offset];
	f->offset += 1;
	return rInt;
}

float ReadFloat(RAMFile * f)
{
	float rFloat = *(float*)&f->data[f->offset];
	f->offset += 4;
	return rFloat;
}

void ReadData(RAMFile * f, void * data, unsigned int length)
{
	memcpy(data, &f->data[f->offset], length);
	f->offset += length;
}

std::string ReadString(RAMFile * f, int l)
{
	std::string rString;
	if(l <= 0)
	{
		char buff = f->data[f->offset++];
		while(buff != '\0')
		{
			rString += buff;
			buff = f->data[f->offset++];
		}
	}
	else
	{
		rString.resize(l);
		memcpy(&rString[0], (void*)&f->data[f->offset], l);
		f->offset += l;
	}
	return rString;
}

xVertex InitializeVertex()
{
	xVertex vert;
	vert.color    = 0xffffff;
	vert.nx       = 0.0f;
	vert.ny       = 0.0f;
	vert.nz       = 1.0f;
	vert.x        = 0.0f;
	vert.y        = 0.0f;
	vert.z        = 0.0f;
	vert.tu1      = 0.0f;
	vert.tu2      = 0.0f;
	vert.tv1      = 0.0f;
	vert.tv2      = 0.0f;
	vert.weight1  = 0.0f;
	vert.weight2  = 0.0f;
	vert.weight3  = 0.0f;
	vert.bone1    = 0;
	vert.bone2    = 0;
	vert.bone3    = 0;
	vert.bone4    = 0;
	return vert;
}

ModelFileType IdentifyFileType(const char * path)
{
	//Test B3D file...
	std::string filePath = "";
	std::string fileName = path;
	int slashPos = fileName.find_last_of('/');
	if(slashPos != fileName.npos)
	{
		filePath = fileName.substr(0, slashPos);
		fileName = fileName.substr(slashPos + 1);
	}
	NSString * realPath = [[NSBundle mainBundle] pathForResource: [NSString stringWithUTF8String: fileName.c_str()] ofType: nil inDirectory: (filePath.length() == 0 ? nil : [NSString stringWithUTF8String: filePath.c_str()])];
	FILE * f = fopen([realPath UTF8String], "rb");
	if(f == NULL)
	{
		printf("Unable to open file '%s'\n", path);
		return UNKNOWNFILE;
	}
	std::string header;
	header.resize(4);
	fread(&header[0], 1, 4, f);
	fclose(f);
	if(header == "BB3D") return B3DFILE;
	f = fopen([realPath UTF8String], "rb");
	int md2Ident;
	fread(&md2Ident, 1, 4, f);
	fclose(f);
	int md2Req = (('2' << 24) + ('P' << 16) + ('D' << 8) + 'I');
	if(md2Ident == md2Req) return MD2FILE;
	f = fopen([realPath UTF8String], "rb");
	ushort id;
	fread(&id, 2, 1, f);
	fclose(f);
	if(id == 0x4D4D) return _3DSFILE;
	//Unknown file type
	return UNKNOWNFILE;
}