//
//  font.mm
//  iXors3D
//
//  Created by Knightmare on 18.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "font.h"
#import <string>
#import "render.h"
#import <iostream>
#import <cwchar>
#import "filesystem.h"

#define max(a, b) (a > b ? a : b)

xFont::xFont()
{
	_fontTexture = NULL;
	_height      = 0;
	_symbols     = 0;
	_red         = 255;
	_green       = 255;
	_blue        = 255;
	_width       = 0;
	_colorFont   = false;
	_offsetx     = 0;
	_offsety     = 0;
	_scalex      = 1.0f;
	_scaley      = 1.0f;
	_angle       = 0;
	_alpha       = 1.0f;
	_blend       = 3;
	_chars.clear();
}

void xFont::Release()
{
	if(_fontTexture != NULL) 
	{
		_fontTexture->ForceRelease();
		delete _fontTexture;
	}
	_fontTexture = NULL;
	_height      = 0;
	_symbols     = 0;
	_chars.clear();
}

bool xFont::Load(const char * path)
{
	// getting file paths
	std::string fontPath    = "";
	std::string fontName    = path;
	std::string texturePath = path;
	int dotPos = fontName.find_last_of('.');
	if(dotPos != fontName.npos)
	{
		texturePath = fontName.substr(0, dotPos) + ".png";
	}
	else
	{
		fontName    += ".font";
		texturePath += ".png";
	}
	int slashPos = fontName.find_last_of('/');
	if(slashPos != fontName.npos)
	{
		fontPath = fontName.substr(0, slashPos);
		fontName = fontName.substr(slashPos + 1);
	}
	// load texture
	_fontTexture = new xTexture();
	if(!_fontTexture->Load(texturePath.c_str(), 1)) return false;
	//_fontTexture->DeletePixels();
	// load font file
	NSString * realPath = [[NSBundle mainBundle] pathForResource: [NSString stringWithUTF8String: fontName.c_str()] ofType: nil inDirectory: (fontPath.length() == 0 ? nil : [NSString stringWithUTF8String: fontPath.c_str()])];
	FILE * input = fopen([realPath UTF8String], "rb");
	if(input == NULL)
	{
		printf("ERROR(%s:%i): Unable to load font description file '%s'.\n", __FILE__, __LINE__, fontPath.c_str());
		return false;
	}
	// check magic number
	char magic[3];
	fread(magic, 1, 3, input);
	if(strncmp(magic, "FNT", 3) != 0)
	{
		fclose(input);
		printf("ERROR(%s:%i): '%s' is not a font description file.\n", __FILE__, __LINE__, fontPath.c_str());
		return false;
	}
	// read version and symbol height
	unsigned char version;
	fread(&version,  1, 1, input);
	fread(&_symbols, 4, 1, input);
	fread(&_height,  4, 1, input);
	// load all symbols
	float height = float(_height) / float(_fontTexture->GetHeight());
	for(int i = 0; i < _symbols; i++)
	{
		int code, x, y, width;
		fread(&code,  4, 1, input);
		fread(&x,     4, 1, input);
		fread(&y,     4, 1, input);
		fread(&width, 4, 1, input);
		xCharacter newChar;
		newChar.x     = float(x) / float(_fontTexture->GetWidth());
		newChar.y     = float(y) / float(_fontTexture->GetHeight());
		newChar.dx    = float(x + width) / float(_fontTexture->GetWidth());
		newChar.dy    = newChar.y + height;
		newChar.width = width;
		_width        = max(_width, width);
		_chars[code]  = newChar;
	}
	// close file
	fclose(input);
	// all done
	return true;
}

void xFont::EnableTextureColor(bool state)
{
	_colorFont = state;
}

void xFont::SetColor(int r, int g, int b)
{
	_red=r;
	_green=g;
	_blue=b;
}


void xFont::SetBlend(int blend)
{
	_blend = blend;
}

void xFont::SetAlpha(float alpha)
{
	_alpha = alpha;
}

void xFont::SetHandle(int x, int y)
{
	_offsetx = x;
	_offsety = y;
}

void xFont::SetRotate(float angle)
{
	_angle = angle;
}

void xFont::SetScale(float x, float y)
{
	_scalex = x;
	_scaley = y;
}

struct TextWord
{
	int         width;
	int         position;
	std::string text;
	TextWord(int _width, int _position, const char * _text)
	{
		width    = _width;
		position = _position;
		text     = _text;
	}
};
struct TextColor
{
	int position;
	int red, green, blue;
};

void xFont::DrawTextEx(const char * text, int x, int y, int width)
{
	std::vector<TextColor> colors;
	int lastColor = 0;
	std::string input = text;
	std::string output;
	for(int i = 0; i < input.length(); i++)
	{
		if(input[i] == '<')
		{
			int match = 0;
			for(int j = i + 1; j < input.length(); j++)
			{
				if(input[j] == ' ') continue;
				if(input[j] == '>') 
				{
					match++;
					break;
				}
				if(tolower(input[j]) == 'c' && tolower(input[j + 1]) == 'o' 
				    && tolower(input[j + 2]) == 'l'  && tolower(input[j + 3]) == 'o' 
				    && tolower(input[j + 4]) == 'r'  && (tolower(input[j + 5]) == '=' || tolower(input[j + 5]) == ' '))
				{
					match = 1;
				}
			}
			if(match > 1)
			{
				TextColor newColor;
				newColor.position = output.length();
				int equal  = 0;
				int comma1 = 0;
				int comma2 = 0;
				for(int j = i + 1; j < input.length(); j++)
				{
					if(input[j] == '=' && equal == 0) equal = j;
					else if(input[j] == ',' && comma1 == 0) comma1 = j;
					else if(input[j] == ',' && comma1 != 0 && comma2 == 0) comma2 = j;
					if(input[j] == '>')
					{
						i = j;
						break;
					}
				}
				std::string valueRed;
				for(int j = equal + 1; j < comma1; j++)
				{
					if(input[j] != ' ') valueRed += input[j];
				}
				std::string valueGreen;
				for(int j = comma1 + 1; j < comma2; j++)
				{
					if(input[j] != ' ') valueGreen += input[j];
				}
				std::string valueBlue;
				for(int j = comma2 + 1; j < i; j++)
				{
					if(input[j] != ' ') valueBlue += input[j];
				}
				newColor.red   = atoi(valueRed.c_str());
				newColor.green = atoi(valueGreen.c_str());
				newColor.blue  = atoi(valueBlue.c_str());
				colors.push_back(newColor);
			}
			else 
			{
				output += input[i];
			}
		}
		else
		{
			output += input[i];
		}
	}
	xVector oldColor = xRender::Instance()->GetColor();
	std::vector<std::vector<TextWord> > wordList;
	NSString * textString = [[NSString alloc] initWithUTF8String: output.c_str()];
	NSArray  * lines      = [textString componentsSeparatedByString: @"\n"];
	int        lineWidth  = 0;
	int        searchPos  = 0;
	for(NSString * line in lines)
	{
		searchPos = output.find_first_of([line UTF8String], searchPos);
		int lineNumber = wordList.size();
		wordList.push_back(std::vector<TextWord>());
		NSArray * words = [line componentsSeparatedByString: @" "];
		for(NSString * word in words)
		{
			int stringWidth = GetStringWidth([word UTF8String]);
			if(lineWidth + stringWidth + 5 >= width)
			{
				lineWidth  = 0;
				lineNumber = wordList.size();
				wordList.push_back(std::vector<TextWord>());
			}
			searchPos = output.find_first_of([word UTF8String], searchPos);
			wordList[lineNumber].push_back(TextWord(stringWidth, searchPos, [word UTF8String]));
			searchPos += [word length];
			lineWidth += stringWidth + 5;
		}
		wordList[lineNumber].push_back(TextWord(0, 0, "\n"));
		lineWidth = 0;
	}
	[textString release];
	int totalHeight = 0;
	for(int i = 0; i < wordList.size(); i++)
	{
		int space       = -1;
		int totalWidth  = 0;
		bool newLine    = false;
		for(int j = 0; j < wordList[i].size(); j++)
		{
			if(wordList[i][j].text == "\n") space = _height / 2;
			totalWidth += wordList[i][j].width;
		}
		if(space < 0 && wordList[i].size()  > 1)      space = (width - totalWidth) / (wordList[i].size() - 1);
		else if(space < 0 && wordList[i].size() <= 1) space = 0;
		totalWidth = 0;
		for(int j = 0; j < wordList[i].size(); j++) 
		{
			if(wordList[i][j].text != "\n")
			{
				if(lastColor < colors.size() && wordList[i][j].position >= colors[lastColor].position)
				{
					xRender::Instance()->Color(colors[lastColor].red, colors[lastColor].green, colors[lastColor].blue);
					lastColor++;
				}
				//DrawText(wordList[i][j].text.c_str(), x + totalWidth, y, false, false);
				AddWord(wordList[i][j].text.c_str(), totalWidth, totalHeight);
				totalWidth += wordList[i][j].width + space;
				newLine = false;
			}
			else
			{
				totalHeight += _height;
				newLine = true;
			}

		}
		if(!newLine) totalHeight += _height;
		//if(y >= xRender::Instance()->GraphicsHeight()) break;
	}
	// render buffers
	xRender::Instance()->AddDIP();
	float globalOffsetx = xRender::Instance()->GetGlobalHandle().x;
	float globalOffsety = xRender::Instance()->GetGlobalHandle().y;
	float globalScalex  = xRender::Instance()->GetGlobalScale().x;
	float globalScaley  = xRender::Instance()->GetGlobalScale().y;
	float globalAngle   = xRender::Instance()->GetGlobalRotate();
	int   globalBlend   = xRender::Instance()->GetGlobalBlend();
	// set pointer to vertices
	xRender::Instance()->Prepare2D();
	glVertexPointer(2, GL_FLOAT, sizeof(TextVertex), &_textWords[0].x);
	glEnableClientState(GL_VERTEX_ARRAY);
	// set pointer to colors
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(TextVertex), &_textWords[0].red);
	glEnableClientState(GL_COLOR_ARRAY);
	// disable texture coords
	glTexCoordPointer(2, GL_FLOAT, sizeof(TextVertex), &_textWords[0].tu);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	// set texture
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, _fontTexture->GetTextureID(0));
	glEnable(GL_TEXTURE_2D);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_ALPHA, GL_TEXTURE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_ALPHA, GL_PREVIOUS);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);//GL_REPLACE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_PREVIOUS);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_TEXTURE);
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, _colorFont ? GL_MODULATE : GL_REPLACE);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();
	// disable second texture layer
	glActiveTexture(GL_TEXTURE1);
	glDisable(GL_TEXTURE_2D);
	// draw rect
	glEnable(GL_BLEND);
	switch(globalBlend == 0 ? _blend : globalBlend)
	{
		case 1: // disable
		{
			glDisable(GL_BLEND);
			glDisable(GL_ALPHA_TEST);
		}
			break;
		case 2: // masked
		{
			glDisable(GL_BLEND);
			glEnable(GL_ALPHA_TEST);
			glAlphaFunc(GL_GREATER, 0.0f);
		}
			break;
		case 3:  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); break; // alpha
		case 4:  glBlendFunc(GL_SRC_ALPHA, GL_ONE);                 break; // light
		case 5:  glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);      break; // shader
		default: glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
	// set transform
	glMatrixMode(GL_MODELVIEW);
	glTranslatef(x, y, 0.0f);
	glRotatef(globalAngle + _angle, 0.0f, 0.0f, 1.0f);
	glScalef(globalScalex * _scalex, globalScaley * _scaley, 1.0f);
	glTranslatef(-(globalOffsetx + _offsetx), -(globalOffsety + _offsety), 0.0f);
	// draw rect
	glDrawArrays(GL_TRIANGLES, 0, _textWords.size());
	// reset transform
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glDisable(GL_BLEND);
	glDisable(GL_ALPHA_TEST);
	// free buffers	
	_textWords.clear();
	xRender::Instance()->Color(oldColor.x, oldColor.y, oldColor.z);
}

void xFont::AddWord(const char * text, int x, int y)
{
	float globalRed     = xRender::Instance()->GetGlobalColor().x;
	float globalGreen   = xRender::Instance()->GetGlobalColor().y;
	float globalBlue    = xRender::Instance()->GetGlobalColor().z;
	float globalAlpha   = xRender::Instance()->GetGlobalAlpha();
	// getting 2D rendering color
	xVector color = xRender::Instance()->GetColor();
	_red          = color.x;
	_green        = color.y;
	_blue         = color.z;
	// create buffers for all symbols
	NSString * textString = [[NSString alloc] initWithUTF8String: text];
	int symbolsInString = [textString length];
	if(symbolsInString == 0) return;
	// compute buffers
	//int symbolCount = 0;
	int xoffset     = x;
	int yoffset     = y;
	// compute color
	int red   = float(_red)   * globalRed;
	int green = float(_green) * globalGreen;
	int blue  = float(_blue)  * globalBlue;
	//int alpha = 255.0f      * globalAlpha;
	int alpha = _alpha*255.0f * globalAlpha;  //Set FontAlpha
	
	for(int i = 0; i < symbolsInString; i++)
	{
		if(yoffset >= xRender::Instance()->GraphicsHeight()) break;
		unichar symb = [textString characterAtIndex: i];
		if(symb == '\n')
		{
			yoffset += _height;
			xoffset  = x;
			continue;
		}
		if(symb == ' ')
		{
			xoffset += _height / 2;
			continue;
		}
		std::map<int, xCharacter>::iterator itr = _chars.find(symb);
		if(itr == _chars.end()) itr = _chars.find('?');
		TextVertex newVertex;
		newVertex.red   = red;
		newVertex.green = green;
		newVertex.blue  = blue;
		newVertex.alpha = alpha;
		// vertex #1
		newVertex.x  = xoffset;
		newVertex.y  = yoffset;
		newVertex.tu = itr->second.x;
		newVertex.tv = itr->second.y;
		_textWords.push_back(newVertex);
		// vertex #2
		newVertex.x  = xoffset + itr->second.width;
		newVertex.y  = yoffset;
		newVertex.tu = itr->second.dx;
		newVertex.tv = itr->second.y;
		_textWords.push_back(newVertex);
		// vertex #3
		newVertex.x  = xoffset;
		newVertex.y  = yoffset + _height;
		newVertex.tu = itr->second.x;
		newVertex.tv = itr->second.dy;
		_textWords.push_back(newVertex);
		// vertex #4
		newVertex.x  = xoffset + itr->second.width;
		newVertex.y  = yoffset;
		newVertex.tu = itr->second.dx;
		newVertex.tv = itr->second.y;
		_textWords.push_back(newVertex);
		// vertex #5
		newVertex.x  = xoffset + itr->second.width;
		newVertex.y  = yoffset + _height;
		newVertex.tu = itr->second.dx;
		newVertex.tv = itr->second.dy;
		_textWords.push_back(newVertex);
		// vertex #6
		newVertex.x  = xoffset;
		newVertex.y  = yoffset + _height;
		newVertex.tu = itr->second.x;
		newVertex.tv = itr->second.dy;
		_textWords.push_back(newVertex);
		//symbolCount++;
		xoffset += itr->second.width;
	}
	// free buffers
	[textString release];
}

void xFont::DrawText(const char * text, int x, int y, bool centerx, bool centery)
{
	float globalOffsetx = xRender::Instance()->GetGlobalHandle().x;
	float globalOffsety = xRender::Instance()->GetGlobalHandle().y;
	float globalScalex  = xRender::Instance()->GetGlobalScale().x;
	float globalScaley  = xRender::Instance()->GetGlobalScale().y;
	float globalAngle   = xRender::Instance()->GetGlobalRotate();
	float globalRed     = xRender::Instance()->GetGlobalColor().x;
	float globalGreen   = xRender::Instance()->GetGlobalColor().y;
	float globalBlue    = xRender::Instance()->GetGlobalColor().z;
	float globalAlpha   = xRender::Instance()->GetGlobalAlpha();
	int   globalBlend   = xRender::Instance()->GetGlobalBlend();
	// getting 2D rendering color
	xVector color = xRender::Instance()->GetColor();
	_red          = color.x;
	_green        = color.y;
	_blue         = color.z;
	// create buffers for all symbols
	NSString * textString = [[NSString alloc] initWithUTF8String: text];
	int symbolsInString = [textString length];
	if(symbolsInString == 0) return;
	GLfloat * positions = new GLfloat[symbolsInString * 12];
	GLfloat * texCoords = new GLfloat[symbolsInString * 12];
	GLubyte * colors    = new GLubyte[symbolsInString * 24];
	// compute buffers
	int symbolCount = 0;
	int xoffset     = (centerx ? -(GetLineWidth(text)    / 2) : 0);
	int yoffset     = (centery ? -(GetStringHeight(text) / 2) : 0);
	// compute color
	int red   = float(_red)   * globalRed;
	int green = float(_green) * globalGreen;
	int blue  = float(_blue)  * globalBlue;
	//int alpha = 255.0f        * globalAlpha;
	int alpha = _alpha*255.0f * globalAlpha;  //Set FontAlpha
	for(int i = 0; i < symbolsInString; i++)
	{
		if(yoffset >= xRender::Instance()->GraphicsHeight()) break;
		unichar symb = [textString characterAtIndex: i];
		if(symb == '\n')
		{
			yoffset += _height;
			xoffset  = (centerx ? -(GetLineWidth(&text[i + 1]) / 2) : 0);
			continue;
		}
		if(symb == ' ')
		{
			xoffset += _height / 2;
			continue;
		}
		std::map<int, xCharacter>::iterator itr = _chars.find(symb);
		if(itr == _chars.end()) itr = _chars.find('?');
		// vertex #1
		positions[symbolCount * 12 + 0] = xoffset;
		positions[symbolCount * 12 + 1] = yoffset;
		texCoords[symbolCount * 12 + 0] = itr->second.x;
		texCoords[symbolCount * 12 + 1] = itr->second.y;
		colors[symbolCount * 24 + 0]    = red;
		colors[symbolCount * 24 + 1]    = green;
		colors[symbolCount * 24 + 2]    = blue;
		colors[symbolCount * 24 + 3]    = alpha;
		// vertex #2
		positions[symbolCount * 12 + 2] = xoffset + itr->second.width;
		positions[symbolCount * 12 + 3] = yoffset;
		texCoords[symbolCount * 12 + 2] = itr->second.dx;
		texCoords[symbolCount * 12 + 3] = itr->second.y;
		colors[symbolCount * 24 + 4]    = red;
		colors[symbolCount * 24 + 5]    = green;
		colors[symbolCount * 24 + 6]    = blue;
		colors[symbolCount * 24 + 7]    = alpha;
		// vertex #3
		positions[symbolCount * 12 + 4] = xoffset;
		positions[symbolCount * 12 + 5] = yoffset + _height;
		texCoords[symbolCount * 12 + 4] = itr->second.x;
		texCoords[symbolCount * 12 + 5] = itr->second.dy;
		colors[symbolCount * 24 + 8]    = red;
		colors[symbolCount * 24 + 9]    = green;
		colors[symbolCount * 24 + 10]   = blue;
		colors[symbolCount * 24 + 11]   = alpha;
		// vertex #4
		positions[symbolCount * 12 + 6] = xoffset + itr->second.width;
		positions[symbolCount * 12 + 7] = yoffset;
		texCoords[symbolCount * 12 + 6] = itr->second.dx;
		texCoords[symbolCount * 12 + 7] = itr->second.y;
		colors[symbolCount * 24 + 12]   = red;
		colors[symbolCount * 24 + 13]   = green;
		colors[symbolCount * 24 + 14]   = blue;
		colors[symbolCount * 24 + 15]   = alpha;
		// vertex #5
		positions[symbolCount * 12 + 8] = xoffset + itr->second.width;
		positions[symbolCount * 12 + 9] = yoffset + _height;
		texCoords[symbolCount * 12 + 8] = itr->second.dx;
		texCoords[symbolCount * 12 + 9] = itr->second.dy;
		colors[symbolCount * 24 + 16]   = red;
		colors[symbolCount * 24 + 17]   = green;
		colors[symbolCount * 24 + 18]   = blue;
		colors[symbolCount * 24 + 19]   = alpha;
		// vertex #6
		positions[symbolCount * 12 + 10] = xoffset;
		positions[symbolCount * 12 + 11] = yoffset + _height;
		texCoords[symbolCount * 12 + 10] = itr->second.x;
		texCoords[symbolCount * 12 + 11] = itr->second.dy;
		colors[symbolCount * 24 + 20]    = red;
		colors[symbolCount * 24 + 21]    = green;
		colors[symbolCount * 24 + 22]    = blue;
		colors[symbolCount * 24 + 23]    = alpha;
		symbolCount++;
		xoffset += itr->second.width;
	}
	xRender::Instance()->AddDIP();
	// render buffers
	// set pointer to vertices
	xRender::Instance()->Prepare2D();
	glVertexPointer(2, GL_FLOAT, 0, positions);
	glEnableClientState(GL_VERTEX_ARRAY);
	// set pointer to colors
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glEnableClientState(GL_COLOR_ARRAY);
	// disable texture coords
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	// set texture
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, _fontTexture->GetTextureID(0));
	glEnable(GL_TEXTURE_2D);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_ALPHA, GL_TEXTURE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_ALPHA, GL_PREVIOUS);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);//GL_REPLACE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_PREVIOUS);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_TEXTURE);
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, _colorFont ? GL_MODULATE : GL_REPLACE);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();
	// disable second texture layer
	glActiveTexture(GL_TEXTURE1);
	glDisable(GL_TEXTURE_2D);
	// draw rect
	glEnable(GL_BLEND);
	switch(globalBlend == 0 ? _blend : globalBlend)
	{
		case 1: // disable
		{
			glDisable(GL_BLEND);
			glDisable(GL_ALPHA_TEST);
		}
		break;
		case 2: // masked
		{
			glDisable(GL_BLEND);
			glEnable(GL_ALPHA_TEST);
			glAlphaFunc(GL_GREATER, 0.0f);
		}
		break;
		case 3:  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); break; // alpha
		case 4:  glBlendFunc(GL_SRC_ALPHA, GL_ONE);                 break; // light
		case 5:  glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);      break; // shader
		default: glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
	// set transform
	glMatrixMode(GL_MODELVIEW);
	glTranslatef(x, y, 0.0f);
	glRotatef(globalAngle + _angle, 0.0f, 0.0f, 1.0f);
	glScalef(globalScalex * _scalex, globalScaley * _scaley, 1.0f);
	glTranslatef(-(globalOffsetx + _offsetx), -(globalOffsety + _offsety), 0.0f);
	// draw rect
	glDrawArrays(GL_TRIANGLES, 0, symbolCount * 6);
	// reset transform
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glDisable(GL_BLEND);
	glDisable(GL_ALPHA_TEST);
	// free buffers
	[textString release];
	delete [] positions;
	delete [] texCoords;
	delete [] colors;
}

int xFont::GetFontHeight()
{
	return _height;
}

int xFont::GetFontWidth()
{
	return _width;
}

int xFont::GetStringHeight(const char * text)
{
	NSString * textString = [[NSString alloc] initWithUTF8String: text];
	int symbols = [textString length];
	int lines   = 1;
	for(int i = 0; i < symbols; i++)
	{
		unichar symb = [textString characterAtIndex: i];
		if(symb == '\n') lines++;
	}
	[textString release];
	return lines * _height;
}

int xFont::GetStringWidth(const char * text)
{
	NSString * textString = [[NSString alloc] initWithUTF8String: text];
	int symbols   = [textString length];
	int width     = 0;
	int tempWidth = 0;
	for(int i = 0; i < symbols; i++)
	{
		unichar symb = [textString characterAtIndex: i];
		if(symb == '\n')
		{
			width = max(width, tempWidth);
			tempWidth = 0;
		}
		else if(symb == ' ')
		{
			tempWidth += _height / 2;
		}
		else
		{
			std::map<int, xCharacter>::iterator itr = _chars.find(symb);
			if(itr == _chars.end()) itr = _chars.find('?');			
			tempWidth += itr->second.width;
		}
	}
	[textString release];
	return max(width, tempWidth);
}

int xFont::GetLineWidth(const char * text)
{
	NSString * textString = [[NSString alloc] initWithUTF8String: text];
	int symbols = [textString length];
	int width   = 0;
	for(int i = 0; i < symbols; i++)
	{
		unichar symb = [textString characterAtIndex: i];
		std::map<int, xCharacter>::iterator itr = _chars.find(symb);
		if(itr == _chars.end()) itr = _chars.find('?');			
		width += itr->second.width;
		if(symb == '\n') return width;
	}
	[textString release];
	return width;
}
