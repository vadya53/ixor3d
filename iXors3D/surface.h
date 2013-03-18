//
//  surface.h
//  iXors3D
//
//  Created by Knightmare on 31.08.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ogles.h"
#import "x3dmath.h"
#import "render.h"
#import "brush.h"

class xCamera;

struct xVertex
{
	GLfloat x, y, z;
	GLfloat nx, ny, nz;
	GLfloat tu1, tv1, tu2, tv2;
	GLuint  color;
	unsigned char bone1, bone2, bone3, bone4;
	float weight1, weight2, weight3, weight4;
	xVertex();
};

struct xGeomBuffer
{
	xVertex * _vertices;
	xVertex * _origVertices;
	ushort  * _triangles;
	int       _counter;
	int       _vertsCount;
	int       _trisCount;
	int       _vertsArraySize;
	int       _trisArraySize;
	int       _alphaVerts;
	bool      _needBVUpdate;
	xBox      _boundingBox;
	xVector   _boundingSphereCenter;
	float     _boundingSphereRadius;
	xGeomBuffer()
	{
		_vertices       = NULL;
		_origVertices   = NULL;
		_triangles      = NULL;
		_counter        = 1;
		_vertsCount     = 0;
		_trisCount      = 0;
		_vertsArraySize = 0;
		_trisArraySize  = 0;
		_alphaVerts     = 0;
		_needBVUpdate   = false;
	}
};

class xSurface
{
private:
	xGeomBuffer    * _gbuffer;
	xVector          _color;
	float            _alpha;
	float            _shininess;
	int              _blend;
	int              _FX;
	BrushTexture   * _textures;
	xBrush         * _creationBrush;
	int              _alphaFunc;
	float            _alphaRef;
	bool             _changes;
private:
	void CalculateNormal(xVector & normal, xVector p0, xVector p1, xVector p2);
	bool IntersectBox(xVector & position, xVector & direction, float * distance);
	bool IntersectTriangle(const xVector & position, const xVector & direction, xVector & v0, xVector & v1, xVector & v2, float * distance);
public:
	xSurface(xBrush * brush, xGeomBuffer * gbuffer = NULL);
	xBrush * GetBrush();
	xBrush * GetCreationBrush();
	void Release();
	void ApplyBrush(xBrush * brush);
	int AddVertex(float x, float y, float z, float tu, float tv);
	int AddTriangle(ushort v0, ushort v1, ushort v2);
	void Draw();
	void VertexCoords(int index, float x, float y, float z);
	void VertexNormal(int index, float x, float y, float z);
	void VertexColor(int index, int red, int greed, int blue, float alpha);
	void VertexTexCoords(int index, float tu, float tv, float tw, int setNum);
	xVector GetVertexCoords(int index);
	xVector GetVertexNormal(int index);
	xVector GetVertexTexCoords(int index, int setNum);
	xVector GetVertexColor(int index);
	float GetVertexAlpha(int index);
	int CountVertices();
	int CountTriangles();
	int TriangleVertex(int index, int corner);
	void Clear(bool vertices, bool triangles);
	bool NeedAlphaBlend();
	void SetColor(int red, int green, int blue);
	void SetAlpha(float alpha);
	void SetShininess(float shininess);
	void SetBlendMode(int mode);
	void SetFX(int fx);
	int GetFX();
	void SetTexture(int index, xTexture * texture, int frame);
	xSurface * Clone(bool cloneGeom);
	void FlipTriangles();
	void PositionVertices(float x, float y, float z);
	void RotateVertices(float pitch, float yaw, float roll);
	void ScaleVertices(float x, float y, float z);
	void TransformVertices(xTransform transform);
	void GenerateNormals();
	void UpdateBoundingVolumes();
	xBox GetBoundingBox();
	void SetBoundingBox(const xBox & bbox);
	xVector GetBoundingSphereCenter();
	float GetBoundingSphereRadius();
	bool InView(xTransform transform, xCamera * camera);
	void SetAlphaVertexCount(int count);
	xVertex * AllocateVB(int size);
	ushort * AllocateIB(int size);
	void AllocateSkinnedVB();
	xVertex * GetVB();
	xVertex * GetBindPoseVB();
	ushort * GetIB();
	bool Pick(xEntity * entity, xVector position, xVector direction);
	bool GetChangesState();
	void SetChangesState(bool state);
	void SetData(xVertex * vertices, int vetsCount, ushort * triangles, int trisCount);
	void SetAlphaFunc(int func);
	void SetAlphaRef(float reference);
	int GetAlphaFunc();
	float GetAlphaRef();
};