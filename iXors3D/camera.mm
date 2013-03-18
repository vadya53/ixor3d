//
//  camera.m
//  iXors3D
//
//  Created by Knightmare on 01.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "camera.h"
#import "render.h"

xCamera::xCamera()
{
	_near           = 1.0f;
	_far            = 1000.0f;
	_viewPortX      = 0;
	_viewPortY      = 0;
	_viewPortWidth  = xRender::Instance()->GraphicsWidth();
	_viewPortHeight = xRender::Instance()->GraphicsHeight();
	_projMode       = PROJ_PERSPECTIVE;
	_cred           = 0.0f;
	_cgreen         = 0.0f;
	_cblue          = 0.0f;
	_clearColor     = true;
	_clearZBuffer   = true;
	_zoom           = 1.0f;
	_fogMode        = 0;
	_fogStart       = 1.0f;
	_fogEnd         = 1000.0f;
	_fogColor[0]    = 0.0f;
	_fogColor[1]    = 0.0f;
	_fogColor[2]    = 0.0f;
	_fogColor[3]    = 0.0f;
	_type           = ENTITY_CAMERA;
	_defaultVP      = true;
	xRender::Instance()->AddCamera(this);
}

bool xCamera::UsedDefaultVP()
{
	return _defaultVP;
}

void xCamera::GetViewport(int * x, int * y, int * width, int * height)
{
	*x      = _viewPortX;
	*y      = _viewPortY;
	*width  = _viewPortWidth;
	*height = _viewPortHeight;
}

void xCamera::GetRange(float * nearValue, float * farValue)
{
	*nearValue = _near;
	*farValue  = _far;
}

float xCamera::GetZoom()
{
	return _zoom;
}

void xCamera::MakeViewMatrix()
{
	xTransform viewTransform = GetWorldTransform().Inversed();
	_viewMatrix[0]  = viewTransform.matrix.i.x;
	_viewMatrix[1]  = viewTransform.matrix.i.y;
	_viewMatrix[2]  = viewTransform.matrix.i.z;
	_viewMatrix[3]  = 0.0f;
	_viewMatrix[4]  = viewTransform.matrix.j.x;
	_viewMatrix[5]  = viewTransform.matrix.j.y;
	_viewMatrix[6]  = viewTransform.matrix.j.z;
	_viewMatrix[7]  = 0.0f;
	_viewMatrix[8]  = viewTransform.matrix.k.x;
	_viewMatrix[9]  = viewTransform.matrix.k.y;
	_viewMatrix[10] = viewTransform.matrix.k.z;
	_viewMatrix[11] = 0.0f;
	_viewMatrix[12] = viewTransform.position.x;
	_viewMatrix[13] = viewTransform.position.y;
	_viewMatrix[14] = viewTransform.position.z;
	_viewMatrix[15] = 1.0f;
	glMatrixMode(GL_MODELVIEW);
	glLoadMatrixf(xRender::Instance()->GetScreenRotateMatrix());
	glMultMatrixf(_viewMatrix);
	glGetFloatv(GL_MODELVIEW_MATRIX, &_viewMatrixDraw[0]);
}

void xCamera::SetViewMatrix()
{
	glMatrixMode(GL_MODELVIEW);
	glLoadMatrixf(_viewMatrixDraw);
}

void xCamera::SetLightMatrix()
{
	glMatrixMode(GL_MODELVIEW);
	glLoadMatrixf(_viewMatrixDraw);
}

int xCamera::GetProjMode()
{
	return _projMode;
}

void xCamera::SetFogMode(int mode)
{
	_fogMode = mode;
}

int xCamera::GetFogMode()
{
	return _fogMode;
}

void xCamera::SetFogRange(float fogStart, float fogEnd)
{
	_fogStart = fogStart;
	_fogEnd   = fogEnd;
}

void xCamera::SetFogColor(int red, int green, int blue)
{
	_fogColor[0] = float(red)   / 255.0f;
	_fogColor[1] = float(green) / 255.0f;
	_fogColor[2] = float(blue)  / 255.0f;
}

void xCamera::GetProjectionMatrix(float * matrix)
{
	if(_projMode == PROJ_PERSPECTIVE)
	{
		GLfloat range     = _near * atan(0.5f / _zoom);
		GLfloat aspect    = (float)_viewPortWidth / (float)_viewPortHeight;
		GLfloat m11       = (2.0f * _near) / (range * aspect - (-range * aspect));
		GLfloat m31       = (range * aspect + (-range * aspect)) / (range * aspect - (-range * aspect));
		GLfloat m22       = (2.0f * _near) / (range - (-range));
		GLfloat m33       = -((_far + _near) / (_far - _near));
		GLfloat m43       = -((2.0f * _far * _near) / (_far - _near));
		GLfloat matrix1[] = { m11,  0.0f, 0.0f,  0.0f,
							  0.0f, m22,  0.0f,  0.0f,
							  m31,  0.0f, m33,  -1.0f, 
							  0.0f, 0.0f, m43,   0.0f };
		memcpy(matrix, matrix1, 16 * sizeof(float));
	}
	else
	{
		GLfloat m11       =  2.0f /  (float)_viewPortWidth  * _zoom;
		GLfloat m22       =  2.0f / -(float)_viewPortHeight * _zoom;
		GLfloat m33       = -2.0f /  (_far - _near);
		GLfloat m43       = -((_far + _near) / (_far - _near));
		GLfloat matrix1[] = {  m11,  0.0f, 0.0f, 0.0f,
							   0.0f, m22,  0.0f, 0.0f,
							   0.0f, 0.0f, m33,  0.0f,
							  -1.0f, 1.0f, m43,  1.0f };
		memcpy(matrix, matrix1, 16 * sizeof(float));
	}
}

void xCamera::SetProjMatrix()
{
	glMatrixMode(GL_PROJECTION);
	xPoint viewPort = xRender::Instance()->RotateSize(xPoint(_viewPortWidth, _viewPortHeight));
	if(_projMode == PROJ_PERSPECTIVE)
	{
		float devider   = 2.0f;
		int orientation = xRender::Instance()->GetDeviceOrientation();
		if(orientation == 1 || orientation == 3) devider = 1.6f;
		GLfloat range    = _near * atan(1.0f / devider / _zoom);
		//GLfloat range    = _near * tan((45.0f * _zoom / devider) * (3.1415f / 180.0f));
		GLfloat aspect   = (float)viewPort.x / (float)viewPort.y;
		GLfloat m11      = (2.0f * _near) / (range * aspect - (-range * aspect));
		GLfloat m31      = (range * aspect + (-range * aspect)) / (range * aspect - (-range * aspect));
		GLfloat m22      = (2.0f * _near) / (range - (-range));
		GLfloat m33      = -((_far + _near) / (_far - _near));
		GLfloat m43      = -((2.0f * _far * _near) / (_far - _near));
		GLfloat matrix[] = { m11,  0.0f, 0.0f,  0.0f,
							 0.0f, m22,  0.0f,  0.0f,
							 m31,  0.0f, m33,  -1.0f, 
							 0.0f, 0.0f, m43,   0.0f };
		glLoadMatrixf(matrix);
	}
	else
	{
		GLfloat m11      =  2.0f /  (float)viewPort.x * _zoom;
		GLfloat m22      =  2.0f / -(float)viewPort.y * _zoom;
		GLfloat m33      = -2.0f /  (_far - _near);
		GLfloat m43      = -((_far + _near) / (_far - _near));
		GLfloat matrix[] = {  m11,  0.0f, 0.0f, 0.0f,
							  0.0f, m22,  0.0f, 0.0f,
							  0.0f, 0.0f, m33,  0.0f,
							 -1.0f, 1.0f, m43,  1.0f };
		glLoadMatrixf(matrix);
	}
}

void xCamera::ApplyViewport()
{
	glEnable(GL_SCISSOR_TEST);
	xPoint viewPortPos  = xRender::Instance()->RotatePoint(xPoint(_viewPortX, _viewPortY), 
														   xPoint(_viewPortWidth, _viewPortHeight));
	xPoint viewPortSize = xRender::Instance()->RotateSize(xPoint(_viewPortWidth, _viewPortHeight));
	glViewport(viewPortPos.x, viewPortPos.y, viewPortSize.x, viewPortSize.y);
	glScissor(viewPortPos.x, viewPortPos.y, viewPortSize.x, viewPortSize.y);
}

void xCamera::SetFog()
{
	if(_fogMode == 0)
	{
		glDisable(GL_FOG);
	}
	else if(_fogMode == 1)
	{
		glEnable(GL_FOG);
		glFogf(GL_FOG_MODE,   GL_LINEAR);
		glFogf(GL_FOG_START,  _fogStart);
		glFogf(GL_FOG_END,    _fogEnd);
		glFogfv(GL_FOG_COLOR, _fogColor);
	}
}

bool xCamera::SetActive()
{
	if(!IsVisible() || _projMode == PROJ_DISABLE) return false;
	SetFog();
	ApplyViewport();
	MakeViewMatrix();
	SetProjMatrix();
	_frustum.Update(_viewMatrixDraw);
	Cls();
	xRender::Instance()->SetActiveCamera(this);
	return true;
}

xFrustum * xCamera::GetFrustum()
{
	return &_frustum;
}

void xCamera::SetProjMode(int mode)
{
	_projMode = mode;
}

void xCamera::SetViewport(int x, int y, int width, int height)
{
	_defaultVP      = false;
	_viewPortX      = x;
	_viewPortY      = y;
	_viewPortWidth  = width;
	_viewPortHeight = height;
	if(x == 0 && y == 0
	   && width == xRender::Instance()->GraphicsWidth()
	   && height == xRender::Instance()->GraphicsHeight())
	{
		_defaultVP = true;
	}
}

void xCamera::SetClearColor(int red, int green, int blue)
{
	_cred   = (float)red   / 255.0f;
	_cgreen = (float)green / 255.0f;
	_cblue  = (float)blue  / 255.0f;
}

void xCamera::SetClearMode(bool clearColor, bool clearZBuffer)
{
	_clearColor   = clearColor;
	_clearZBuffer = clearZBuffer;
}

void xCamera::Cls()
{
	glClearColor(_cred, _cgreen, _cblue, 1.0f);
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	glClearDepthf(1.0f);
#else
	glClearDepth(1.0f);
#endif
	uint mask = (_clearColor ? GL_COLOR_BUFFER_BIT : 0) | (_clearZBuffer ? GL_DEPTH_BUFFER_BIT : 0);
    glClear(mask);
}

void xCamera::SetRange(float nearValue, float farValue)
{
	_near = nearValue;
	_far  = farValue;
}

void xCamera::SetZoom(float zoom)
{
	_zoom = zoom;
}

xEntity * xCamera::Pick(int x, int y)
{
	if(x < _viewPortX || x > _viewPortX + _viewPortWidth || y < _viewPortY || y > _viewPortY + _viewPortHeight) return false;
	xVector vec;
	float m11;
	float m22;
	if(_projMode == 1)
	{
		float devider   = 2.0f;
		int orientation = xRender::Instance()->GetDeviceOrientation();
		if(orientation == 1 || orientation == 3) devider = 2.5f;
		GLfloat range = _near * atan(1.0f / devider / _zoom);
		//float range  = _near * tan((45.0f * _zoom / devider) * (3.1415f / 180.0f));
		float aspect = (float)_viewPortWidth / (float)_viewPortHeight;
		m11 = (2.0f * _near) / (range * aspect - (-range * aspect));
		m22 = (2.0f * _near) / (range - (-range));
	}
	else
	{
		m11 =  2.0f /  (float)_viewPortWidth  * _zoom;
		m22 =  2.0f / -(float)_viewPortHeight * _zoom;
	}
	vec.x =  (((2.0f * (x - _viewPortX)) / _viewPortWidth)  - 1.0f) / m11;
    vec.y = -(((2.0f * (y - _viewPortY)) / _viewPortHeight) - 1.0f) / m22;
    vec.z = -1.0f;
	xTransform world  = GetWorldTransform();
	xVector direction = world.matrix * vec;
	return xRender::Instance()->LinePick(world.position, direction, FLT_MAX);
}