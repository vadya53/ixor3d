#ifndef _HELPERS_H_
#define _HELPERS_H_

#import <iostream>
#import "surface.h"

struct RAMFile
{
	unsigned char * data;
	unsigned long   offset;
	unsigned long   size;
	RAMFile(FILE * file);
	void Release();
};

#define COLOR_ARGB(a, r, g, b) ((uint)((((r)&0xff))|(((g)&0xff)<<8)|((b)&0xff)<<16)|((a)&0xff)<<24)
#define COLOR_RGBA(r, g, b, a) COLOR_ARGB(a, r, g, b)
#define COLORVALUE(r, g, b, a) COLOR_ARGB((uint)(a * 255.0f), (uint)(r * 255.0f), (uint)(g * 255.0f), (uint)(b * 255.0f))

int ReadInt(RAMFile * f);
float ReadFloat(RAMFile * f);
ushort ReadWord(RAMFile * f);
unsigned char ReadByte(RAMFile * f);
std::string ReadString(RAMFile * f, int l = -1);
xVertex InitializeVertex();
void ReadData(RAMFile * f, void * data, unsigned int length);

enum ModelFileType
{
	B3DFILE,
	MD2FILE,
	_3DSFILE,
	UNKNOWNFILE
};

ModelFileType IdentifyFileType(const char * path);

#endif