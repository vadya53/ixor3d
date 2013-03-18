#import "entity.h"
#import "render.h"

class xSimulator
{
private:
	struct xCollideInfo
	{
		int destType;
		int method;
		int response;
	};
	std::vector<xCollideInfo>        _collideInfo[1000];
	std::vector<xEntity*>            _objectsByType[1000];
	std::vector<xEntityCollision*>   _freeCollisions;
	std::vector<xEntityCollision*>   _usedCollisions;
	static xSimulator              * _instance;
private:
	xSimulator();
	xSimulator(const xSimulator & other);
	xSimulator & operator=(const xSimulator & other);
	~xSimulator();
	void Collide(xEntity * src);
	bool HitTest(const x3DLine &line, float radius, xEntity * obj, const xTransform &tf, int method, xCollision * currColl);
	xEntityCollision * AllocObjColl(xEntity * with, const xVector &coords, const xCollision &coll);
	void Collided(xEntity * src, xEntity * dest, const x3DLine &line, const xCollision &coll, float yScale);
public:
	static xSimulator * Instance();
	void AddCollision(int srcType, int destType, int method, int response);
	void ClearCollisions();
	void Update(float elapsed);
};