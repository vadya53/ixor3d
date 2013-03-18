#import "3dsloader.h"
#import "filesystem.h"

xVector GetVector(float x, float y, float z)
{
	return xVector(x, z, y);
}

Color3DS Loader3DS::ReadColor()
{
	Color3DS color;
	// read header and validate chunk
	ushort id = ReadWord(_meshFile);
	ReadInt(_meshFile);
	// read chunk body
	switch(id)
	{
		case 0x0010: // float RGB
		case 0x0013: // float RGB gamma corrected
		{
			color.red   = ReadFloat(_meshFile);
			color.green = ReadFloat(_meshFile);
			color.blue  = ReadFloat(_meshFile);
		}
		break;
		case 0x0011: // byte RGB
		case 0x0012: // byte RGB gamma corrected
		{
			color.red   = float(ReadByte(_meshFile)) / 255.0f;
			color.green = float(ReadByte(_meshFile)) / 255.0f;
			color.blue  = float(ReadByte(_meshFile)) / 255.0f;
		}
		break;
	}
	return color;
}

float Loader3DS::ReadPercent()
{
	float precent = 0.0f;
	// read header and validate chunk
	ushort id = ReadWord(_meshFile);
	ReadInt(_meshFile);
	// read chunk body
	switch(id)
	{
		case 0x0030: // word percent
		{
			precent = float(ReadWord(_meshFile)) / 100.0f;
		}
		break;
		case 0x0031: // float percent
		{
			precent = ReadFloat(_meshFile);
		}
		break;
	}
	return precent;
}

xQuaternion MakeQuaternion(float x, float y, float z, float w);

void Loader3DS::ReadChunk(LoaderNode * rootNode, TexturesArray * textures,
						  MaterialsArray * materials)
{
	// read header and validate chunk
	ushort id    = ReadWord(_meshFile);
	int length = ReadInt(_meshFile) - 6;
	if(_meshFile->size - _meshFile->offset < length)
	{
		_result = false;
		return;
	}
	// get end of chunk
	int chunkEnd = _meshFile->offset + length;
	// read chunk body
	switch(id)
	{
		case 0x0010: // float RGB
		case 0x0013: // float RGB gamma corrected
		{
			Color3DS color;
			color.red   = ReadFloat(_meshFile);
			color.green = ReadFloat(_meshFile);
			color.blue  = ReadFloat(_meshFile);
			_colors.push_back(color);
		}
		break;
		case 0x0011: // byte RGB
		case 0x0012: // byte RGB gamma corrected
		{
			Color3DS color;
			color.red   = float(ReadByte(_meshFile)) / 255.0f;
			color.green = float(ReadByte(_meshFile)) / 255.0f;
			color.blue  = float(ReadByte(_meshFile)) / 255.0f;
			_colors.push_back(color);
		}
		break;
		case 0x0030: // word percent
		{
			_percents.push_back(float(ReadWord(_meshFile)) / 100.0f);
		}
		break;
		case 0x0031: // float percent
		{
			_percents.push_back(ReadFloat(_meshFile));
		}
		break;
		case 0x4D4D: // main chunk
		{
		}
		break;
		case 0x3D3D: // 3ds editor chunk
		{
		}
		break;
		case 0x4000: // object chunk
		{
			// create new node
			LoaderNode * newNode = new LoaderNode();
			rootNode->_subNodes.push_back(newNode);
			rootNode = newNode;
			// read name
			rootNode->_name = ReadString(_meshFile);
		}
		break;
		case 0x4100: // mesh chunk
		{
			rootNode->_surfaces.push_back(LoaderSurface());
		}
		break;
		case 0x4110: // vertices chunk
		{
			if(rootNode->_surfaces[0]._vertices == NULL)
			{
				rootNode->_surfaces[0]._vertices = new std::vector<xVertex>();
			}
			ushort count = ReadWord(_meshFile);
			xVertex vertex = InitializeVertex();
			for(int i = 0; i < count; i++)
			{
				vertex.x = ReadFloat(_meshFile);
				vertex.z = ReadFloat(_meshFile);
				vertex.y = ReadFloat(_meshFile);
				rootNode->_surfaces[0]._vertices->push_back(vertex);
			}
		}
		break;
		case 0x4120: // triangles chunk
		{
			ushort count = ReadWord(_meshFile);
			LoaderSurface::Triangle triangle;
			for(int i = 0; i < count; i++)
			{
				triangle._v0 = ReadWord(_meshFile);
				triangle._v1 = ReadWord(_meshFile);
				triangle._v2 = ReadWord(_meshFile);
				rootNode->_surfaces[0]._triangles->push_back(triangle);
				ReadWord(_meshFile);
			}
		}
		break;
		case 0x4140: // UV coords chunk
		{
			ushort count = ReadWord(_meshFile);
			for(int i = 0; i < count; i++)
			{
				(*rootNode->_surfaces[0]._vertices)[i].tu1 = ReadFloat(_meshFile);
				(*rootNode->_surfaces[0]._vertices)[i].tv1 = 1.0f - ReadFloat(_meshFile);
				(*rootNode->_surfaces[0]._vertices)[i].tu2 = (*rootNode->_surfaces[0]._vertices)[i].tu1;
				(*rootNode->_surfaces[0]._vertices)[i].tv2 = (*rootNode->_surfaces[0]._vertices)[i].tv1;
			}
		}
		break;
		case 0x4160: // local coords chunk
		{
			float x, y, z;
			x = ReadFloat(_meshFile);
			y = ReadFloat(_meshFile);
			z = ReadFloat(_meshFile);
			xVector x1 = GetVector(x, y, z);
			x = ReadFloat(_meshFile);
			y = ReadFloat(_meshFile);
			z = ReadFloat(_meshFile);
			xVector x2 = GetVector(x, y, z);
			x = ReadFloat(_meshFile);
			y = ReadFloat(_meshFile);
			z = ReadFloat(_meshFile);
			xVector x3 = GetVector(x, y, z);
			x = ReadFloat(_meshFile);
			y = ReadFloat(_meshFile);
			z = ReadFloat(_meshFile);
			xVector o  = GetVector(x, y, z);
			xMatrix rotation(x1, x2, x3);
			rotation.Inverse();
			rootNode->_position = xVector(o.y, o.x, -o.z);
			rootNode->_rotation = MatrixToQuaternion(rotation);
			rootNode->_rotation = MakeQuaternion(rootNode->_rotation.x, rootNode->_rotation.y, rootNode->_rotation.z, rootNode->_rotation.w);
		}
		break;
		case 0x4130: // faces material chunk
		{
			// create new surface
			LoaderSurface newSurface;
			newSurface._vertices = rootNode->_surfaces[0]._vertices;
			// read material name
			newSurface._materialID = _matNames.size();
			_matNames.push_back(ReadString(_meshFile));
			// read count of faces
			ushort count = ReadWord(_meshFile);
			// put faces to list
			for(int i = 0; i < count; i++)
			{
				ushort index = ReadWord(_meshFile);
				newSurface._triangles->push_back((*rootNode->_surfaces[0]._triangles)[index]);
			}
			// put surface to list
			rootNode->_surfaces.push_back(newSurface);
		}
		break;
		case 0xAFFF: // material
		{
			LoaderMaterial newMaterial;
			materials->push_back(newMaterial);
		}
		break;
		case 0xA000: // material name
		{
			(*materials)[materials->size() - 1]._name = ReadString(_meshFile);
		}
		break;
		case 0xA020: // material diffuse
		{
			Color3DS color = ReadColor();
			(*materials)[materials->size() - 1]._red   = color.red;
			(*materials)[materials->size() - 1]._green = color.green;
			(*materials)[materials->size() - 1]._blue  = color.blue;
		}
		break;
		case 0xA040: // material shininess
		{
			(*materials)[materials->size() - 1]._shininess = ReadPercent();
		}
		break;
		case 0xA200: // material texture
		{
			LoaderTexture newTexture;
			newTexture._flags = 1 + 8;
			(*materials)[materials->size() - 1]._textures[0] = textures->size();
			textures->push_back(newTexture);
		}
		break;
		case 0xA300: // texture filename
		{
			(*textures)[textures->size() - 1]._filename = ReadString(_meshFile); 
			int slashPos = (*textures)[textures->size() - 1]._filename.find_last_of("/"); 
			if(slashPos == (*textures)[textures->size() - 1]._filename.npos) slashPos = (*textures)[textures->size() - 1]._filename.find_last_of("\\");
			if(slashPos != (*textures)[textures->size() - 1]._filename.npos) (*textures)[textures->size() - 1]._filename = (*textures)[textures->size() - 1]._filename.substr(slashPos + 1);
		}
		break;
		case 0xA356: // texture U scale
		{
			(*textures)[textures->size() - 1]._scaleX = ReadFloat(_meshFile);
		}
		break;
		case 0xA354: // texture V scale
		{
			(*textures)[textures->size() - 1]._scaleY = ReadFloat(_meshFile);
		}
		break;
		case 0xA358: // texture U offset
		{
			(*textures)[textures->size() - 1]._posX = ReadFloat(_meshFile);
		}
		break;
		case 0xA35A: // texture V offset
		{
			(*textures)[textures->size() - 1]._posY = ReadFloat(_meshFile);
		}
		break;
		case 0xA35C: // texture angle
		{
			(*textures)[textures->size() - 1]._rotation = ReadFloat(_meshFile);
		}
		break;
		default:
			_meshFile->offset += length;
	}
	// read sub-chunks
	while(_meshFile->offset < chunkEnd && _result) ReadChunk(rootNode, textures, materials);
	if(id == 0x4100)
	{
		if(rootNode->_surfaces.size() > 0)
		{
			xVector position;
			xTransform local(xMatrix(rootNode->_rotation), rootNode->_position);
			local.Inverse();
			if(rootNode->_surfaces[0]._vertices != NULL)
			{
				for(int i = 0; i < rootNode->_surfaces[0]._vertices->size(); i++)
				{
					position = local * xVector((*rootNode->_surfaces[0]._vertices)[i].x, (*rootNode->_surfaces[0]._vertices)[i].y, -(*rootNode->_surfaces[0]._vertices)[i].z);
					(*rootNode->_surfaces[0]._vertices)[i].x = position.x;
					(*rootNode->_surfaces[0]._vertices)[i].y = position.y;
					(*rootNode->_surfaces[0]._vertices)[i].z = position.z;
				}
			}
		}
		if(rootNode->_surfaces.size() > 1)
		{
			delete rootNode->_surfaces[0]._triangles;
			rootNode->_surfaces.erase(rootNode->_surfaces.begin());
		}
	}
}

void Loader3DS::SetMaterialID(LoaderNode * rootNode, MaterialsArray * materials)
{
	for(int i = 0; i < rootNode->_surfaces.size(); i++)
	{
		if(rootNode->_surfaces[i]._materialID >= 0)
		{
			std::string name = _matNames[rootNode->_surfaces[i]._materialID];
			rootNode->_surfaces[i]._materialID = -1;
			for(int j = 0; j < materials->size(); j++)
			{
				if(name == (*materials)[j]._name)
				{
					rootNode->_surfaces[i]._materialID = j;
					break;
				}
			}
		}
	}
	for(int i = 0; i < rootNode->_subNodes.size(); i++)
	{
		SetMaterialID(rootNode->_subNodes[i], materials);
	}
}

bool Loader3DS::LoadFile(const char * path, LoaderNode ** rootNode,
					     TexturesArray * textures,
					     MaterialsArray * materials)
{
	NSString * realPath = [NSString stringWithUTF8String: xFileSystem::Instance()->GetRealPath(path).c_str()];
	FILE * input = fopen([realPath UTF8String], "rb");
	if(input == NULL)
	{
		printf("ERROR(%s:%i): Unable to open file '%s'.\n", __FILE__, __LINE__, path);
		return false;
	}
	_meshFile = new RAMFile(input);
	fclose(input);
	_result = true;
	*rootNode          = new LoaderNode();
	(*rootNode)->_name = "X3DRootNode";
	while(_meshFile->offset < _meshFile->size && _result) ReadChunk(*rootNode, textures, materials);
	if(_result) SetMaterialID(*rootNode, materials);
	_meshFile->Release();
	return _result;
}