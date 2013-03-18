#import "meshcollider.h"
#import <map>
#import <iostream>

static const int MAX_COLL_TRIS = 16;
static std::vector<xVector> tri_centres;

xMeshCollider::xMeshCollider(const std::vector<xVector> & verts, const std::vector<Triangle> & tris) : _vertices(verts), _triangles(tris)
{
	std::vector<int> ts;
	tri_centres.clear();
	for(int k = 0; k < _triangles.size(); ++k)
	{
		const xMeshCollider::Triangle &t = _triangles[k];
		const xVector &v0 = _vertices[t.verts[0]];
		const xVector &v1 = _vertices[t.verts[1]];
		const xVector &v2 = _vertices[t.verts[2]];
		tri_centres.push_back((v0 + v1 + v2) / 3.0f);
		ts.push_back(k);
	}
	_tree = CreateNode(ts);
}

xMeshCollider::~xMeshCollider()
{
	delete _tree;
}

bool xMeshCollider::Collide(const x3DLine & line, float radius, xCollision * currColl, const xTransform &t)
{
	if(!_tree) return false;
	xBox box(line);
	box.Expand(radius);
	xTransform t2 = t.Inversed();
	xBox localBox(t2 * box.Corner(0));
	for(int k = 1; k < 8; ++k) localBox.Update(t2 * box.Corner(k));
	return Collide(localBox, line, radius, t, currColl, _tree);
}

bool xMeshCollider::Collide(const xBox & line_box, const x3DLine & line, float radius, const xTransform & tform, xCollision * currColl, xMeshCollider::TNode * node)
{
	if(!line_box.Overlaps(node->box)) return false;
	bool hit = false;
	if(!node->triangles.size())
	{
		if(node->left)  hit |= Collide(line_box, line, radius, tform, currColl, node->left);
		if(node->right) hit |= Collide(line_box, line, radius, tform, currColl, node->right);
		return hit;
	}
	for(int k = 0; k < node->triangles.size(); ++k)
	{
		const Triangle &tri = _triangles[node->triangles[k]];
		const xVector &t_v0 = _vertices[tri.verts[0]];
		const xVector &t_v1 = _vertices[tri.verts[1]];
		const xVector &t_v2 = _vertices[tri.verts[2]];
		xBox tri_box(t_v0);
		tri_box.Update(t_v1);
		tri_box.Update(t_v2);
		if(!tri_box.Overlaps(line_box)) continue;
		xVector v0 = tform * t_v0;
		xVector v1 = tform * t_v1;
		xVector v2 = tform * t_v2;
		if(!currColl->TriangleCollide(line, radius, v0, v1, v2)) continue;
		currColl->surface = tri.surface;
		currColl->index   = tri.index;
		hit = true;
	}
	return hit;
}

xBox xMeshCollider::NodeBox(const std::vector<int> & tris)
{
	xBox box;
	for(int k = 0; k < tris.size(); ++k)
	{
		const Triangle &t = _triangles[tris[k]];
		for(int j = 0; j < 3; ++j) box.Update(_vertices[t.verts[j]]);
	}
	return box;
}

xMeshCollider::TNode * xMeshCollider::CreateLeaf(const std::vector<int> & tris)
{
	TNode * c    = new TNode;
	c->box       = NodeBox(tris);
	c->triangles = tris;
	_leaves.push_back(c);
	return c;
}

xMeshCollider::TNode * xMeshCollider::CreateNode(const std::vector<int> & tris)
{
	if(tris.size() <= MAX_COLL_TRIS) return CreateLeaf(tris);
	TNode * c = new TNode;
	c->box = NodeBox(tris);
	float max = c->box.Width();
	if(c->box.Height() > max) max = c->box.Height();
	if(c->box.Depth()  > max) max = c->box.Depth();
	int axis = 0;
	if(max == c->box.Height())     axis = 1;
	else if(max == c->box.Depth()) axis = 2;
	int k;
	std::multimap<float, int> axis_map;
	for(k = 0; k < tris.size(); ++k)
	{
		std::pair<float, int> p(((float*)&tri_centres[tris[k]])[axis], tris[k]);
		axis_map.insert(p);
	}
	std::vector<int> new_tris;
	std::multimap<float, int>::iterator it = axis_map.begin();
	for(k = axis_map.size() / 2; k--; ++it) new_tris.push_back(it->second);
	c->left = CreateNode(new_tris);
	new_tris.clear();
	for(; it != axis_map.end(); ++it) new_tris.push_back(it->second);
	c->right = CreateNode(new_tris);
	return c;
}