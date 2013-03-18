#import "x3dmath.h"

struct xCollision
{
	float            time;
	xVector          normal;
	void           * surface;
	unsigned short   index;
	xCollision();
	bool Update(const x3DLine &line, float time, const xVector &normal);
	bool SphereCollide(const x3DLine &srcLine, float srcRadius, const xVector &dest, float destRadius);
	bool SphereCollide(const x3DLine &line, float radius, const xVector &dest, const xVector &radii);
	bool TriangleCollide(const x3DLine &srcLine, float srcRadius, const xVector &v0, const xVector &v1, const xVector &v2);
	bool BoxCollide(const x3DLine &srcLine, float srcRadius, const xBox &box);
};