#ifndef _3DSLOADER_H_
#define _3DSLOADER_H_

#import "mainloader.h"
#import "helpers.h"
#import "animations.h"
#import "animkeys.h"
#import "bones.h"
#import "materials.h"
#import "nodes.h"
#import "surfaces.h"
#import "textures.h"

struct Color3DS
{
	float red, green, blue;
};

class Loader3DS : public MainLoader
{
	private:
		std::vector<Color3DS>      _colors;
		std::vector<float>         _percents;
		std::vector<std::string>   _matNames;
		bool                       _result;
		RAMFile                  * _meshFile;
	private:
		void ReadChunk(LoaderNode * rootNode, TexturesArray * textures,
						MaterialsArray * materials);
		Color3DS ReadColor();
		float ReadPercent();
		void SetMaterialID(LoaderNode * rootNode, MaterialsArray * materials);
	public:
		bool LoadFile(const char * path, LoaderNode ** rootNode,
					  TexturesArray * textures,
					  MaterialsArray * materials);
};

#endif