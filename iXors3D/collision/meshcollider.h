#import "x3dmath.h"
#import <vector>
#import "collision.h"

class xMeshCollider
{
	public:
		struct Triangle
		{
			void * surface;
			int    verts[3];
			int    index;
		};
	private:
		std::vector<xVector>  _vertices;
		std::vector<Triangle> _triangles;
	private:
		struct TNode
		{
			xBox               box;
			TNode            * left;
			TNode            * right;
			std::vector<int>   triangles;
			TNode() : left(0), right(0)
			{
			}
			~TNode()
			{
				delete left;
				delete right;
			}
		};
	private:
		TNode *             _tree;
		std::vector<TNode*> _leaves;
	private:
		xBox NodeBox(const std::vector<int> & tris);
		TNode * CreateLeaf(const std::vector<int> & tris);
		TNode * CreateNode(const std::vector<int> & tris);
		bool Collide(const xBox & box, const x3DLine & line, float radius, const xTransform & tform, xCollision * currColl, TNode * node);
	public:
		xMeshCollider(const std::vector<xVector> & verts, const std::vector<Triangle> & tris);
		~xMeshCollider();
		bool Collide(const x3DLine & line, float radius, xCollision * currColl, const xTransform & tform);
};