//
//  light.h
//  iXors3D
//
//  Created by Knightmare on 07.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "entity.h"

class xLight : public xEntity
{
private:
	xVector _lightData;
	int     _number;
	int     _lightType;
public:
	xLight(int type);
	void SetNumber(int number);
	void SetLight();
	void SetRange(float range);
	void SetAngles(float inner, float outer);
};