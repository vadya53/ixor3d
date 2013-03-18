//
//  frustum.mm
//  iXors3D
//
//  Created by Knightmare on 04.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "frustum.h"
#import "ogles.h"

#define GetElement(matrix, x, y) matrix[y * 4 + x]

void xFrustum::Update(float * viewMatrix)
{
	float matrix[16];
	glGetFloatv(GL_PROJECTION_MATRIX, matrix);
	glMatrixMode(GL_PROJECTION_MATRIX);
	glPushMatrix();
	glLoadMatrixf(matrix);
	glMultMatrixf(viewMatrix);
	glGetFloatv(GL_PROJECTION_MATRIX, matrix);
	glPopMatrix();
	planes[0].normal.x = GetElement(matrix, 3, 0) - GetElement(matrix, 0, 0);
	planes[0].normal.y = GetElement(matrix, 3, 1) - GetElement(matrix, 0, 1);
	planes[0].normal.z = GetElement(matrix, 3, 2) - GetElement(matrix, 0, 2);
	planes[0].d        = GetElement(matrix, 3, 3) - GetElement(matrix, 0, 3);
	planes[0].Normalize();
	planes[1].normal.x = GetElement(matrix, 3, 0) + GetElement(matrix, 0, 0);
	planes[1].normal.y = GetElement(matrix, 3, 1) + GetElement(matrix, 0, 1);
	planes[1].normal.z = GetElement(matrix, 3, 2) + GetElement(matrix, 0, 2);
	planes[1].d        = GetElement(matrix, 3, 3) + GetElement(matrix, 0, 3);
	planes[1].Normalize();
	planes[2].normal.x = GetElement(matrix, 3, 0) + GetElement(matrix, 1, 0);
	planes[2].normal.y = GetElement(matrix, 3, 1) + GetElement(matrix, 1, 1);
	planes[2].normal.z = GetElement(matrix, 3, 2) + GetElement(matrix, 1, 2);
	planes[2].d        = GetElement(matrix, 3, 3) + GetElement(matrix, 1, 3);
	planes[2].Normalize();
	planes[3].normal.x = GetElement(matrix, 3, 0) - GetElement(matrix, 1, 0);
	planes[3].normal.y = GetElement(matrix, 3, 1) - GetElement(matrix, 1, 1);
	planes[3].normal.z = GetElement(matrix, 3, 2) - GetElement(matrix, 1, 2);
	planes[3].d        = GetElement(matrix, 3, 3) - GetElement(matrix, 1, 3);
	planes[3].Normalize();
	planes[4].normal.x = GetElement(matrix, 3, 0) - GetElement(matrix, 2, 0);
	planes[4].normal.y = GetElement(matrix, 3, 1) - GetElement(matrix, 2, 1);
	planes[4].normal.z = GetElement(matrix, 3, 2) - GetElement(matrix, 2, 2);
	planes[4].d        = GetElement(matrix, 3, 3) - GetElement(matrix, 2, 3);
	planes[4].Normalize();
	planes[5].normal.x = GetElement(matrix, 3, 0) + GetElement(matrix, 2, 0);
	planes[5].normal.y = GetElement(matrix, 3, 1) + GetElement(matrix, 2, 1);
	planes[5].normal.z = GetElement(matrix, 3, 2) + GetElement(matrix, 2, 2);
	planes[5].d        = GetElement(matrix, 3, 3) + GetElement(matrix, 2, 3);
	planes[5].Normalize();
}

bool xFrustum::SphereInFrustum(xVector center, float radius)
{
	for(int i = 0; i < 6; i++)
	{
		if(planes[i].Distance(center) <= -radius) return false;
	}
	return true;
}

bool xFrustum::BoxInFrustum(xBox box)
{
	xVector c1 = xVector(box.min.x, box.min.y, box.min.z);
	xVector c2 = xVector(box.max.x, box.min.y, box.min.z);
	xVector c3 = xVector(box.min.x, box.max.y, box.min.z);
	xVector c4 = xVector(box.max.x, box.max.y, box.min.z);
	xVector c5 = xVector(box.min.x, box.min.y, box.max.z);
	xVector c6 = xVector(box.max.x, box.min.y, box.max.z);
	xVector c7 = xVector(box.min.x, box.max.y, box.max.z);
	xVector c8 = xVector(box.max.x, box.max.y, box.max.z);
	for(int i = 0; i < 6; i++)
	{
		if(planes[i].Distance(c1) > 0.0f) continue;
		if(planes[i].Distance(c2) > 0.0f) continue;
		if(planes[i].Distance(c3) > 0.0f) continue;
		if(planes[i].Distance(c4) > 0.0f) continue;
		if(planes[i].Distance(c5) > 0.0f) continue;
		if(planes[i].Distance(c6) > 0.0f) continue;
		if(planes[i].Distance(c7) > 0.0f) continue;
		if(planes[i].Distance(c8) > 0.0f) continue;
		return false;		
	}
	return true;
}

bool xFrustum::PointInFrustum(xVector point)
{
	for(int i = 0; i < 6; i++)
	{
		if(planes[i].Distance(point) <= 0.0f) return false;
	}
	return true;
}
