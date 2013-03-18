//
//  frustum.h
//  iXors3D
//
//  Created by Knightmare on 04.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "x3dmath.h"

struct xFrustum
{
	xPlane planes[6];
	void Update(float * viewMatrix);
	bool SphereInFrustum(xVector center, float radius);
	bool BoxInFrustum(xBox);
	bool PointInFrustum(xVector point);
};