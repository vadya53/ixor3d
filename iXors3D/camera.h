//
//  camera.h
//  iXors3D
//
//  Created by Knightmare on 01.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "entity.h"
#import "frustum.h"

#define PROJ_DISABLE     0
#define PROJ_PERSPECTIVE 1
#define PROJ_ORTHO       2

class xCamera : public xEntity
{
private:
	GLfloat  _near, _far;
	int      _viewPortX, _viewPortY, _viewPortWidth, _viewPortHeight;
	int      _projMode;
	float    _viewMatrix[16];
	float    _viewMatrixDraw[16];
	GLfloat  _cred, _cgreen, _cblue;
	bool     _clearColor, _clearZBuffer;
	float    _zoom;
	xFrustum _frustum;
	int      _fogMode;
	float    _fogStart, _fogEnd;
	GLfloat  _fogColor[4];
	bool     _defaultVP;
private:
	void SetProjMatrix();
	void ApplyViewport();
	void MakeViewMatrix();
	void SetFog();
public:
	xCamera();
	void SetViewMatrix();
	void SetLightMatrix();
	bool SetActive();
	void SetProjMode(int mode);
	void SetViewport(int x, int y, int width, int height);
	void SetClearColor(int red, int green, int blue);
	void SetClearMode(bool clearColor, bool clearZBuffer);
	void Cls();
	void SetRange(float nearValue, float farValue);
	void SetZoom(float zoom);
	int GetProjMode();
	void SetFogMode(int mode);
	int GetFogMode();
	void SetFogRange(float fogStart, float fogEnd);
	void SetFogColor(int red, int green, int blue);
	bool UsedDefaultVP();
	void GetViewport(int * x, int * y, int * width, int * height);
	void GetRange(float * nearValue, float * farValue);
	float GetZoom();
	void GetProjectionMatrix(float * matrix);
	xFrustum * GetFrustum();
	xEntity * Pick(int x, int y);
};