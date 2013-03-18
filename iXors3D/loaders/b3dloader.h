#ifndef _B3DLOADER_H_
#define _B3DLOADER_H_

#import "mainloader.h"
#import "helpers.h"

class B3DLoader : public MainLoader
{
	private:
		struct Header
		{
			std::string _headerText;
			int         _lenght;
		};
		int _b3dVersion;
		int _lastBone;
		std::string _path;
		Header ReadHeader(RAMFile * f);
		LoaderTexture ReadTexture(RAMFile * f);
		LoaderMaterial ReadMaterial(RAMFile * f, int texs);
		LoaderNode * ReadNode(RAMFile * f, long lenght, LoaderNode * parent);
		LoaderBone ReadBone(RAMFile * f, LoaderNode * parent);
		SurfacesArray ReadMesh(RAMFile * f, long lenght, int * brush);
		xVertex ReadVertex(RAMFile * f, int flag, int tcs, int tcss);
		LoaderAnimKey ReadKey(RAMFile * f, int flag);
		LoaderAnimation ReadAnimation(RAMFile * f, int flag);
	public:
		bool LoadFile(const char * path, LoaderNode ** rootNode,
					  TexturesArray * textures,
					  MaterialsArray * materials);
};

#endif