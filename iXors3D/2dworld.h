//
//  2dworld.h
//  iXors3D
//
//  Created by Knightmare on 8/2/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "image.h"
#import "IWorld2D.h"

class x2DWorld
{
private:
	struct RenderPair
	{
		IBody2D * body;
		xImage  * image;
		int       order;
		int       frame;
	};
private:
	static x2DWorld          * _instance;
	std::vector<RenderPair*>   _images;
	int                        _cameraX, _cameraY;
private:
	x2DWorld();
	x2DWorld(const x2DWorld & other);
	x2DWorld & operator=(const x2DWorld & other);
	~x2DWorld();
	std::vector<RenderPair*>::iterator FindNode(IBody2D * shape);
public:
	static x2DWorld * Instance();
	void Render();
	void AssignImage(IBody2D * shape, xImage * image, int frame);
	void Clear();
	void SetImageFrame(IBody2D * shape, int frame);
	void SetImageOrder(IBody2D * shape, int order);
	void DeleteBody(IBody2D * shape);
	void SetCameraPosition(int x, int y);
	int GetCameraX();
	int GetCameraY();
};