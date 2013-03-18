//
//  light.mm
//  iXors3D
//
//  Created by Knightmare on 07.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "light.h"
#import "camera.h"

xLight::xLight(int type)
{
	_lightData = xVector(0.0f, 45.0f, 1000.0f);
	_number    = -1;
	_lightType = type;
	_type      = ENTITY_LIGHT;
}

void xLight::SetNumber(int number)
{
	_number = number;
}

void xLight::SetRange(float range)
{
	_lightData.z = range;
}

void xLight::SetAngles(float inner, float outer)
{
	_lightData.x = inner;
	_lightData.y = outer;
}

void xLight::SetLight()
{
	if(_number >= 0 && _visible)
	{
		glMatrixMode(GL_MODELVIEW);
		//glLoadIdentity();
		xRender::Instance()->GetActiveCamera()->SetLightMatrix();
		glEnable(GL_LIGHT0 + _number);
		// diffuse light
		GLfloat value[4];
		xVector vector = GetColor();
		value[0] = vector.x / 255.0f;
		value[1] = vector.y / 255.0f;
		value[2] = vector.z / 255.0f;
		value[3] = 1.0f;
		glLightfv(GL_LIGHT0 + _number, GL_DIFFUSE, value);
		// specular light
		value[0] = 0.0f;
		value[1] = 0.0f;
		value[2] = 0.0f;
		value[3] = 1.0f;
		glLightfv(GL_LIGHT0 + _number, GL_SPECULAR, value);
		// light position
		if(_lightType == 1 || _lightType == 2)
		{
			vector   = GetPosition(true);
			value[0] = vector.x;
			value[1] = vector.y;
			value[2] = vector.z;
			value[3] = 1.0f;
		}
		else
		{
			vector = GetQuaternion(true) * xVector(0.0f, 0.0f, 1.0f);
			vector.Normalize();
			value[0] = vector.x;
			value[1] = vector.y;
			value[2] = vector.z;
			value[3] = 0.0f;
		}
		glLightfv(GL_LIGHT0 + _number, GL_POSITION, value);
		// light direction
		if(_lightType == 1)
		{
			vector = GetQuaternion(true) * xVector(0.0f, 0.0f, 1.0f);
			vector.Normalize();
			value[0] = vector.x;
			value[1] = vector.y;
			value[2] = vector.z;
			value[3] = 1.0f;
			glLightfv(GL_LIGHT0 + _number, GL_SPOT_DIRECTION, value);
		}
		// set spot cuttof
		if(_lightType == 1)
		{
			glLightf(GL_LIGHT0 + _number, GL_SPOT_CUTOFF, _lightData.y);
		}
		else
		{
			glLightf(GL_LIGHT0 + _number, GL_SPOT_CUTOFF, 180.0f);
		}
		// set range attenuation
		glLightf(GL_LIGHT0 + _number, GL_CONSTANT_ATTENUATION, 1.0f);
		if(_lightType == 1 || _lightType == 2)
		{
			glLightf(GL_LIGHT0 + _number, GL_LINEAR_ATTENUATION, 1.0f / _lightData.z);
		}
		else
		{
			glLightf(GL_LIGHT0 + _number, GL_LINEAR_ATTENUATION, 0.0f);
		}
	}
}
