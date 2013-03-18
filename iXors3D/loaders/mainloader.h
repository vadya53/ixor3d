#ifndef _MAINLOADER_H_
#define _MAINLOADER_H_

#import "nodes.h"
#import "materials.h"
#import "textures.h"

class MainLoader
{
	public:
		virtual bool LoadFile(const char * path, LoaderNode ** rootNode,
					  TexturesArray * textures,
					  MaterialsArray * materials) = 0;
};

#endif