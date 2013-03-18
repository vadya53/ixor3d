#include "collision.h"

xCollision::xCollision()
{
	time    = 1.0f;
	normal  = xVector(0.0f, 0.0f, 1.0f);
	surface = NULL;
	index   = 0;
}

bool xCollision::Update(const x3DLine &line, float t, const xVector &n)
{
	if(t > time) return false;
	xPlane p(line * t, n);
	if((p.normal.Dot(line.direction)) >= 0.0f) return false;
	if(p.Distance(line.origin) < -X3DEPSILON) return false;
	time   = t;
	normal = n;
	return true;
}

bool xCollision::SphereCollide(const x3DLine &line, float radius, const xVector &dest, float destRadius)
{
	radius += destRadius;
	x3DLine l(line.origin - dest, line.direction);
	float a = l.direction.Dot(l.direction);
	if(!a) return false;
	float b = (l.origin.Dot(l.direction)) * 2.0f;
	float c = (l.origin.Dot(l.origin)) - radius * radius;
	float d = b * b - 4 * a * c;
	if(d < 0) return false;
	float t1 = (-b + sqrt(d)) / (2.0f * a);
	float t2 = (-b - sqrt(d)) / (2.0f * a);
	float t  = t1 < t2 ? t1 : t2;
	if(t > time) return false;
	return Update(line, t, (l * t).Normalized());
}

static bool EdgeTest(const xVector &v0, const xVector &v1, const xVector &pn, const xVector &en, const x3DLine &line, float radius, xCollision * currColl)
{
	xMatrix tm = xMatrix(en, (v1 - v0).Normalized(), pn);
	tm.Transpose();
	xVector sv = tm * (line.origin - v0);
	xVector dv = tm * (line.origin + line.direction - v0);
	x3DLine l(sv, dv - sv);
	float a, b, c, d, t1, t2, t;
	a = (l.direction.x * l.direction.x + l.direction.z * l.direction.z);
	if(!a) return false;
	b = (l.origin.x * l.direction.x + l.origin.z * l.direction.z) * 2.0f;
	c = (l.origin.x * l.origin.x + l.origin.z * l.origin.z) - radius * radius;
	d = b * b - 4 * a * c;
	if(d < 0.0f) return false;
	t1 = (-b + sqrt(d)) / (2.0f * a);
	t2 = (-b - sqrt(d)) / (2.0f * a);
	t  = t1 < t2 ? t1 : t2;
	if(t > currColl->time) return false;
	xVector i = l * t, p;
	if(i.y > v0.Distance(v1)) return false;
	if(i.y >= 0.0f)
	{
		p.y = i.y;
	}
	else
	{
		a = l.direction.Dot(l.direction);
		if(!a) return false;
		b = (l.origin.Dot(l.direction)) * 2.0f;
		c = (l.origin.Dot(l.origin)) - radius * radius;
		d = b * b - 4 * a * c;
		if(d < 0.0f) return false;
		t1 = (-b + sqrt(d)) / (2.0f * a);
		t2 = (-b - sqrt(d)) / (2.0f * a);
		t  = t1 < t2 ? t1 : t2;
		if(t > currColl->time) return false;
		i = l * t;
	}
	sv = i - p;
	sv = tm.Transposed() * sv;
	sv.Normalize();
	return currColl->Update(line, t, sv);
}

bool xCollision::TriangleCollide(const x3DLine &line, float radius, const xVector &v0, const xVector &v1, const xVector &v2)
{
	xPlane p(v0, v1, v2);
	if(isnan(p.d)) return false;
	if((p.normal.Dot(line.direction)) >= 0.0f) return false;
	p.d -= radius;
	float t = p.IntersectTime(line);
	if(t > time) return false;
	xPlane p0(v0 + p.normal, v1, v0), p1(v1 + p.normal, v2, v1), p2(v2 + p.normal, v0, v2);
	xVector i = line * t;
	if(p0.Distance(i) >= 0.0f && p1.Distance(i) >= 0.0f && p2.Distance(i) >= 0.0f)
	{
		return Update(line, t, p.normal);
	}
	if(radius <= 0.0f) return false;
	return EdgeTest(v0, v1, p.normal, p0.normal, line, radius, this) |
		   EdgeTest(v1, v2, p.normal, p1.normal, line, radius, this) |
		   EdgeTest(v2, v0, p.normal, p2.normal, line, radius, this);
}

bool xCollision::BoxCollide(const x3DLine &line, float radius, const xBox &box)
{
	static int quads[] = { 2, 3, 1, 0, 3, 7, 5, 1, 7, 6, 4, 5, 6, 2, 0, 4, 6, 7, 3, 2, 0, 1, 5, 4 };
	bool hit = false;
	for(int n = 0; n < 24; n += 4)
	{
		xVector v0(box.Corner(quads[n + 0])),
			    v1(box.Corner(quads[n + 1])),
			    v2(box.Corner(quads[n + 2])),
			    v3(box.Corner(quads[n + 3]));
		xPlane p(v0, v1, v2);
		if((p.normal.Dot(line.direction)) >= 0.0f) continue;
		p.d -= radius;
		float t = p.IntersectTime(line);
		if(t > time) return false;
		xPlane p0(v0 + p.normal, v1, v0),
			   p1(v1 + p.normal, v2, v1),
			   p2(v2 + p.normal, v3, v2),
			   p3(v3 + p.normal, v0, v3);
		xVector i = line * t;
		if(p0.Distance(i) >= 0.0f && p1.Distance(i) >= 0.0f && p2.Distance(i) >= 0.0f && p3.Distance(i) >= 0.0f)
		{
			hit |= Update(line, t, p.normal);
			continue;
		}
		if(radius <= 0.0f) continue;
		hit |= EdgeTest(v0, v1, p.normal, p0.normal, line, radius, this) |
			   EdgeTest(v1, v2, p.normal, p1.normal, line, radius, this) |
			   EdgeTest(v2, v3, p.normal, p2.normal, line, radius, this) |
			   EdgeTest(v3, v0, p.normal, p3.normal, line, radius, this);
	}
	return hit;
}