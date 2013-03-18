#import "b3dloader.h"
#import "filesystem.h"

xQuaternion MakeQuaternion(float x, float y, float z, float w)
{
	xMatrix rotate = xMatrix(xQuaternion(x, y, z, w));
	rotate.i.z = -rotate.i.z;
	rotate.j.z = -rotate.j.z;
	rotate.k.x = -rotate.k.x;
	rotate.k.y = -rotate.k.y;
	return MatrixToQuaternion(rotate);
}

B3DLoader::Header B3DLoader::ReadHeader(RAMFile * f)
{
	Header newHeader;
	newHeader._headerText = ReadString(f, 4);
	newHeader._lenght     = ReadInt(f);
	return newHeader;
}

LoaderTexture B3DLoader::ReadTexture(RAMFile * f)
{
	LoaderTexture texture;
	texture._filename = ReadString(f);
	int slashPos = texture._filename.find_last_of("/"); 
	if(slashPos == texture._filename.npos) slashPos = texture._filename.find_last_of("\\");
	if(slashPos != texture._filename.npos) texture._filename = texture._filename.substr(slashPos + 1);
	texture._flags    = ReadInt(f);
	texture._blend    = ReadInt(f);
	texture._posX     = ReadFloat(f);
	texture._posY     = ReadFloat(f);
	texture._scaleX   = ReadFloat(f);
	texture._scaleY   = ReadFloat(f);
	texture._rotation = ReadFloat(f);
	return texture;
}

LoaderMaterial B3DLoader::ReadMaterial(RAMFile * f, int texs)
{
	LoaderMaterial material;
	material._name      = ReadString(f);
	material._red       = ReadFloat(f);
	material._green     = ReadFloat(f);
	material._blue      = ReadFloat(f);
	material._alpha     = ReadFloat(f);
	material._shininess = ReadFloat(f);
	material._blend     = ReadInt(f);
	material._FX        = ReadInt(f);
	for(int i = 0; i < texs; i++) material._textures[i] = ReadInt(f);
	return material;
}

int GetBoneNumber(xVertex * vertex, int index)
{
    switch(index)
    {
        case 0: return vertex->bone1;
        case 1: return vertex->bone2;
        case 2: return vertex->bone3;
        case 3: return vertex->bone4;
    }
    return 0;
}

float GetBoneWeight(xVertex * vertex, int index)
{
    switch(index)
    {
        case 0: return vertex->weight1;
        case 1: return vertex->weight2;
        case 2: return vertex->weight3;
        case 3: return vertex->weight4;
    }
    return 0;
}

void SetBoneNumber(xVertex * vertex, int index, int value)
{
    switch(index)
    {
        case 0: vertex->bone1 = value; break;
        case 1: vertex->bone2 = value; break;
        case 2: vertex->bone3 = value; break;
        case 3: vertex->bone4 = value; break;
    }
}

void SetBoneWeight(xVertex * vertex, int index, float value)
{
    switch(index)
    {
        case 0: vertex->weight1 = value; break;
        case 1: vertex->weight2 = value; break;
        case 2: vertex->weight3 = value; break;
        case 3: vertex->weight4 = value; break;
    }
}

LoaderBone B3DLoader::ReadBone(RAMFile * f, LoaderNode * parent)
{
	LoaderBone bone;
	bone._vertexID = ReadInt(f);
	bone._weight   = ReadFloat(f);
	for(int s = 0; s < parent->_surfaces.size(); s++)
	{
        xVertex * vertex = &(*parent->_surfaces[s]._vertices)[bone._vertexID];
        int i;
        for(i = 0; i < 4; ++i)
        {
            if(GetBoneNumber(vertex, i) == 0 || bone._weight > GetBoneWeight(vertex, i))
            {
                break;
            }
        }
        if(i == 4)
        {
            return bone;
        }
        for(int k = 3; k > i; --k)
        {
            SetBoneNumber(vertex, k, GetBoneNumber(vertex, k - 1));
            SetBoneWeight(vertex, k, GetBoneWeight(vertex, k - 1));
        }
        SetBoneNumber(vertex, i, _lastBone);
        SetBoneWeight(vertex, i, bone._weight);
	}
    return bone;
}

xVertex B3DLoader::ReadVertex(RAMFile * f, int flag, int tcs, int tcss)
{
	xVertex vertex = InitializeVertex();
	vertex.x =  ReadFloat(f);
	vertex.y =  ReadFloat(f);
	vertex.z =  ReadFloat(f);
	vertex.z = -vertex.z;
	if(flag & 1)
	{
		vertex.nx =  ReadFloat(f);
		vertex.ny =  ReadFloat(f);
		vertex.nz =  ReadFloat(f);
		vertex.nz = -vertex.nz;
	}
	if(flag & 2)
	{
		float r = ReadFloat(f);
		float g = ReadFloat(f);
		float b = ReadFloat(f);
		float a = ReadFloat(f);
		vertex.color = COLORVALUE(r, g, b, a);
	}
	else vertex.color = COLORVALUE(1.0f, 1.0f, 1.0f, 1.0f);
	for(int i = 0; i < tcs; i++)
	{
		switch(i)
		{
			case 0:
				for(int j = 0; j < tcss; j++)
				{
					switch(j)
					{
						case 0:
							vertex.tu1 = ReadFloat(f);
						break;
						case 1:
							vertex.tv1 = ReadFloat(f);
						break;
					}
				}
			break;
			case 1:
				for(int j = 0; j < tcss; j++)
				{
					switch(j)
					{
						case 0:
							vertex.tu2 = ReadFloat(f);
						break;
						case 1:
							vertex.tv2 = ReadFloat(f);
						break;
					}
				}
			break;
		}
	}
	return vertex;
}

SurfacesArray B3DLoader::ReadMesh(RAMFile * f, long lenght, int * brush)
{
     int a0, a1, a2;
     int v0, v1, v2;
     int flag;
     long curPos = f->offset;
     SurfacesArray surf;
     std::vector<xVertex> * vertices = new std::vector<xVertex>();
     *brush = ReadInt(f);
     Header header  = ReadHeader(f);
     if(header._headerText == "VRTS")
     {
          long curPos2 = f->offset;
          flag = ReadInt(f);
          int tcs  = ReadInt(f);
          int tcss = ReadInt(f);
		  int vertSize = 12 + tcs * tcss * 4;
		  if(flag & 1) vertSize += 12;
		  if(flag & 2) vertSize += 16;
		  int count = (header._lenght - 12) / vertSize;
		  vertices->resize(count);
		  count = 0;
          while(f->offset != curPos2 + header._lenght)
          {
				(*vertices)[count++] = ReadVertex(f, flag, tcs, tcss);
          }
     }
     else
     {
		 f->offset -= 8;
		 return SurfacesArray();
     }
     while(f->offset != curPos + lenght)
     {
         Header header  = ReadHeader(f);
         if(header._headerText == "TRIS")
         {
               long curPos2 = f->offset;
               surf.push_back(LoaderSurface());
               int sBrush = ReadInt(f);
               if(sBrush == -1) sBrush = *brush;
               surf[surf.size() - 1]._materialID = sBrush;
               surf[surf.size() - 1]._vertices   = vertices;
               surf[surf.size() - 1]._cntAlphaVertex = 0;
			   surf[surf.size() - 1]._flags = flag;
			   int count = (header._lenght - 4) / 12;
			   surf[surf.size() - 1]._triangles->resize(count);
			   count = 0;
			   LoaderSurface * surface = &surf[surf.size() - 1];
               while(f->offset != curPos2 + header._lenght)
               {
                    v0 = ReadInt(f);
                    v1 = ReadInt(f);
                    v2 = ReadInt(f);
                    (*surface->_triangles)[count++] = LoaderSurface::Triangle(v2, v1, v0);
                    a0 = ((*vertices)[v0].color >> 24) & 0xff; 
                    a1 = ((*vertices)[v1].color >> 24) & 0xff; 
                    a2 = ((*vertices)[v2].color >> 24) & 0xff; 
                    if(((a0 < 255) || (a1 < 255) || (a2 < 255)) && (flag & 2)) surface->_cntAlphaVertex++;
               }
          }
          else
          {
               f->offset += header._lenght;
          }
     }
     return surf;
}

LoaderAnimKey B3DLoader::ReadKey(RAMFile * f, int flag)
{
	LoaderAnimKey key;
	key._flag  = flag;
	key._frame = ReadInt(f);
	if(flag & 1)
	{
		float x = ReadFloat(f);
		float y = ReadFloat(f);
		float z = ReadFloat(f);
		key._position = xVector(x, y, -z);
	}
	if(flag & 2)
	{
		float x = ReadFloat(f);
		float y = ReadFloat(f);
		float z = ReadFloat(f);
		key._scale = xVector(x, y, z);
	}
	if(flag & 4)
	{
		float w = ReadFloat(f);
		float x = ReadFloat(f);
		float y = ReadFloat(f);
		float z = ReadFloat(f);
		key._rotation = MakeQuaternion(x, y, z, w);
	}
	return key;
}

LoaderAnimation B3DLoader::ReadAnimation(RAMFile * f, int flag)
{
	LoaderAnimation anim;
	anim._flag       = flag;
	anim._startFrame = ReadInt(f);
	anim._endFrame   = ReadInt(f);
	anim._fps        = ReadFloat(f);
	return anim;
}

LoaderNode * B3DLoader::ReadNode(RAMFile * f, long lenght, LoaderNode * parent)
{
	long curPos = f->offset;
	LoaderNode * node = new LoaderNode();
	node->_boneID = 0;
	node->_name   = ReadString(f);
	float x = ReadFloat(f);
	float y = ReadFloat(f);
	float z = ReadFloat(f);
	float w = 0.0f;
	node->_position = xVector(x, y, -z);
	x = ReadFloat(f);
	y = ReadFloat(f);
	z = ReadFloat(f);
	node->_scale = xVector(x, y, z);
	w = ReadFloat(f);
	x = ReadFloat(f);
	y = ReadFloat(f);
	z = ReadFloat(f);
	node->_rotation = MakeQuaternion(x, y, z, w);
	int lastBone = _lastBone;
	if(node->_boneID == 0)
	{
		_lastBone = 1;
	}
	while(f->offset != curPos + lenght)
	{
		Header header  = ReadHeader(f);
		if(header._headerText == "MESH")
		{
			node->_surfaces = ReadMesh(f, header._lenght, &node->_brushID);
		}
		else if(header._headerText == "BONE")
		{
			_lastBone = lastBone;
			long curPos2   = f->offset;
			node->_boneID   = _lastBone;
			while(f->offset != curPos2 + header._lenght)
			{
				node->_bones.push_back(ReadBone(f, parent));
			}
			_lastBone++;
		}
		else if(header._headerText == "NODE")
		{
			if(node->_boneID == 0)
			{
				node->_subNodes.push_back(ReadNode(f, header._lenght, node));
			}
			else
			{
				node->_subNodes.push_back(ReadNode(f, header._lenght, parent));
			}
		}
		else if(header._headerText == "KEYS")
		{
			long curPos2 = f->offset;
			int flag = ReadInt(f);
			while(f->offset != curPos2 + header._lenght)
			{
				node->_animKeys.push_back(ReadKey(f, flag));
			}
		}
		else if(header._headerText == "ANIM")
		{
			if(_b3dVersion == 1)
			{
				LoaderAnimation anim;
				anim._flag       = ReadInt(f);
				anim._startFrame = 0;
				anim._endFrame   = ReadInt(f) - 1;
				anim._fps        = ReadFloat(f);
				node->_animations.push_back(anim);
			}
			else if(_b3dVersion == 2)
			{
				int flag = ReadInt(f);
				long curPos2 = f->offset;
				while(f->offset != curPos2 + header._lenght)
				{
					node->_animations.push_back(ReadAnimation(f, flag));
				}
			}
		}
		else
		{
			f->offset += header._lenght;
		}
	}
	if(node->_boneID == 0)
	{
		int rootBones = 0;
		for(int i = 0; i < node->_subNodes.size(); i++)
		{
			if(node->_subNodes[i]->_boneID > 0) rootBones++;
		}
		if(rootBones > 1)
		{
			LoaderNode * newRoot = new LoaderNode();
			newRoot->_boneID   = 300;
			newRoot->_name     = "loaderRootBone";
			newRoot->_scale    = xVector(1.0f, 1.0f, 1.0f);
			newRoot->_rotation = xQuaternion();
			for(int i = 0; i < node->_subNodes.size(); i++)
			{
				if(node->_subNodes[i]->_boneID > 0)
				{
					newRoot->_subNodes.push_back(node->_subNodes[i]);
				}
			}
			if(node->_subNodes.size() > 1)
			{
				std::vector<LoaderNode*> subNodes;
				for(int i = 0; i < node->_subNodes.size(); i++)
				{
					if(node->_subNodes[i]->_boneID == 0)
					{
						subNodes.push_back(node->_subNodes[i]);
					}
				}
				subNodes.push_back(newRoot);
				node->_subNodes.clear();
				node->_subNodes = subNodes;
			}
		}
	}
	if(parent != NULL)
	{
		if(node->_animations.size() == 0 && parent->_animations.size() != 0)
		{
			for(int i = 0; i < parent->_animations.size(); i++)
			{
				node->_animations.push_back(parent->_animations[i]);
			}
		}
	}
	return node;
}

bool B3DLoader::LoadFile(const char * path, LoaderNode ** rootNode,
					  TexturesArray * textures,
					  MaterialsArray * materials)
{
	NSString * realPath = [NSString stringWithUTF8String: xFileSystem::Instance()->GetRealPath(path).c_str()];
	FILE * input = fopen([realPath UTF8String], "rb");
	if(input == NULL)
	{
		printf("ERROR(%s:%i): Unable to open file '%s'.\n", __FILE__, __LINE__, _path.c_str());
		return false;
	}
	RAMFile * file = new RAMFile(input);
	fclose(input);
	Header mainHeader = ReadHeader(file);
	if(mainHeader._headerText != "BB3D")
	{
		printf("ERROR(%s:%i): Unable to open file '%s'. It's not a D3D mesh file.\n", __FILE__, __LINE__, _path.c_str());
		return false;
	}
	_b3dVersion = ReadInt(file);
	Header header;
	while(file->offset != file->size)
	{
		header = ReadHeader(file);
		if(header._headerText == "TEXS")
		{
			long curPos = file->offset;
			while(file->offset != curPos + header._lenght)
			{
				textures->push_back(ReadTexture(file));
			}
		}
		else if(header._headerText == "BRUS")
		{
			long curPos = file->offset;
			int texs = ReadInt(file);
			while(file->offset != curPos + header._lenght)
			{
				materials->push_back(ReadMaterial(file, texs));
			}
		}
		else if(header._headerText == "NODE")
		{
			_lastBone = 1;
			(*rootNode) = ReadNode(file, header._lenght, NULL);
		}
		else
		{
			file->offset += header._lenght;
		}
	}
	file->Release();
	return true;
}