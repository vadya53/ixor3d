#ifndef _MATERIALS_H_
#define _MATERIALS_H_

struct LoaderMaterial
{
	LoaderMaterial()
	{
		_name      = "";
		_red       = 1.0f;
		_green     = 1.0f;
		_blue      = 1.0f;
		_alpha     = 1.0f;
		_shininess = 0.0f;
		_blend     = 1;
		_FX        = 0;
		for(int i = 0; i < 8; i++)
		{
			_textures[i] = -1;
		}
	}
	std::string   _name;
	float         _red;
	float         _green;
	float         _blue;
	float         _alpha;
	float         _shininess;
	int           _blend;
	float         _FX;
	int           _textures[8];
};

typedef std::vector<LoaderMaterial> MaterialsArray;

#endif