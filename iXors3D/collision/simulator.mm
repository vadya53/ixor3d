#import "simulator.h"
#import "render.h"

xSimulator * xSimulator::_instance = NULL;

xSimulator::xSimulator()
{
}

xSimulator::xSimulator(const xSimulator & other)
{
}

xSimulator & xSimulator::operator=(const xSimulator & other)
{
	return *this;
}

xSimulator::~xSimulator()
{
}

xSimulator * xSimulator::Instance()
{
	if(_instance == NULL) _instance = new xSimulator();
	return _instance;
}

void xSimulator::AddCollision(int srcType, int destType, int method, int response)
{
	std::vector<xCollideInfo> &info = _collideInfo[srcType];
	for(unsigned int k = 0; k < info.size(); ++k)
	{
		xCollideInfo &t = info[k];
		if(destType == t.destType)
		{
			t.method   = method;
			t.response = response;
			return;
		}
	}
	xCollideInfo co = {destType, method, response};
	info.push_back(co);
}

void xSimulator::ClearCollisions()
{
	for(int k = 0; k < 1000; ++k) _collideInfo[k].clear();
}

void xSimulator::Update(float elapsed)
{
	for(; _usedCollisions.size() > 0; _usedCollisions.pop_back())
	{
		_freeCollisions.push_back(_usedCollisions.back());
	}
	std::vector<xEntity*> * entities = xRender::Instance()->GetEntitiesArray();
	std::vector<xEntity*>::const_iterator it;
	for(it = entities->begin(); it != entities->end(); ++it)
	{
		xEntity * entity = *it;
		int n = entity->GetCollisionType();
		if(n > 0 && entity->IsVisible())
		{
			_objectsByType[n].push_back(entity);
		}
	}
	for(it = entities->begin(); it != entities->end(); ++it)
	{
		xEntity * entity = *it;
		if(entity->GetCollisionType())
		{
			entity->UpdateWorldTransform();
			entity->ClearCollisions();
			if(entity->IsVisible()) Collide(entity);
			entity->SavePervTransform();
		}
	}
	for(int k = 0; k < 1000; ++k)
	{
		_objectsByType[k].clear();
	}
}

void xSimulator::Collide(xEntity * src)
{
	static const int MAX_HITS = 10;
	xVector dv = src->GetWorldTransform().position;
	xVector sv = src->GetWorldTransformPrev().position;
	if(sv == dv)
	{
		if(dv.x != sv.x || dv.y != sv.y || dv.z != sv.z)
		{
			src->SetPosition(sv.x, sv.y, sv.z, true);
		}
		return;
	}
	xTransform transform;
	xVector panic = sv;
	const xVector &radii = src->GetCollisionRadii();
	float radius    = radii.x;
	float invYScale = 1.0f;
	float yScale    = 1.0f;
	if(radii.x != radii.y)
	{
		yScale = transform.matrix.j.y = radius / radii.y;
		invYScale = 1.0f / yScale;
		sv.y *= yScale;
		dv.y *= yScale;
	}
	int hitCounter = 0;
	xPlane planes[2];
	x3DLine collideLine(sv, dv - sv);
	xVector direction = collideLine.direction;
	float td = collideLine.direction.Length();
	float td_xz = xVector(collideLine.direction.x, 0.0f, collideLine.direction.z).Length();
	const std::vector<xCollideInfo> & collinfos = _collideInfo[src->GetCollisionType()];
	int hits = 0;
	for(;;)
	{
		xCollision collide;
		xEntity * collidedEntity = NULL;
		std::vector<xCollideInfo>::const_iterator coll_it, coll_info;
		for(coll_it = collinfos.begin(); coll_it != collinfos.end(); ++coll_it)
		{
			std::vector<xEntity*>::const_iterator dst_it;
			const std::vector<xEntity*> &dst_objs = _objectsByType[coll_it->destType];
			for(dst_it = dst_objs.begin(); dst_it != dst_objs.end(); ++dst_it)
			{
				xEntity * dst = *dst_it;
				if(src == dst) continue;
				const xTransform dst_tform = dst->GetWorldTransformPrev();
				if(yScale == 1.0f)
				{
					if(HitTest(collideLine, radius, dst, dst_tform, coll_it->method, &collide))
					{
						collidedEntity = dst;
						coll_info      = coll_it;
					}
				}
				else
				{
					if(HitTest(collideLine, radius, dst, transform * dst_tform, coll_it->method, &collide))
					{
						collidedEntity = dst;
						coll_info      = coll_it;
					}
				}
			}
		}
		if(!collidedEntity) break;
		if(++hits >= MAX_HITS) break;
		Collided(src, collidedEntity, collideLine, collide, invYScale);
		if(coll_info->response == 4) break;
		xPlane coll_plane(collideLine * collide.time, collide.normal);
		coll_plane.d -= X3DEPSILON;
		collide.time  = coll_plane.IntersectTime(collideLine);
		if(collide.time > 0.0f)
		{
			sv     = collideLine * collide.time;
			td    *= 1.0f - collide.time;
			td_xz *= 1.0f - collide.time;
		}
		if(coll_info->response == 1)
		{
			dv = sv;
			break;
		}
		xVector nv = coll_plane.Nearest(dv);
		if(hitCounter == 0)
		{
			dv = nv;
		}
		else if(hitCounter == 1)
		{
			if(planes[0].Distance(nv) >= 0.0f)
			{
				dv         = nv;
				hitCounter = 0;
			}
			else if(fabs((planes[0].normal.Dot(coll_plane.normal))) < 1.0f - X3DEPSILON)
			{
				dv = coll_plane.Intersect(planes[0]).Nearest(dv);
			}
			else
			{
				hits = MAX_HITS;
				break;
			}
		}
		else if(planes[0].Distance(nv) >= 0.0f && planes[1].Distance(nv) >= 0.0f)
		{
			dv         = nv;
			hitCounter = 0;
		}
		else
		{
			dv = sv;
			break;
		}
		xVector dd(dv - sv);
		if((dd.Dot(direction)) <= 0.0f)
		{
			dv = sv;
			break;
		}
		if(coll_info->response == 2)
		{
			float d = dd.Length();
			if(d <= X3DEPSILON)
			{
				dv = sv;
				break;
			}
			if(d > td) dd *= td / d;
		}
		else if(coll_info->response == 3)
		{
			float d = xVector(dd.x, 0.0f, dd.z).Length();
			if(d <= X3DEPSILON)
			{
				dv = sv;
				break;
			}
			if(d > td_xz) dd *= td_xz / d;
		}
		collideLine.origin    = sv;
		collideLine.direction = dd;
		dv = sv + dd;
		planes[hitCounter++] = coll_plane;
	}
	if(hits)
	{
		if(hits < MAX_HITS)
		{
			dv.y *= invYScale;
			src->SetPosition(dv.x, dv.y, dv.z, true);
		}
		else
		{
			src->SetPosition(panic.x, panic.y, panic.z, true);
		}
	}
}

bool xSimulator::HitTest(const x3DLine &line, float radius, xEntity * obj, const xTransform &tf, int method, xCollision * currColl)
{
	switch(method)
	{
		case 1:
			return currColl->SphereCollide(line, radius, tf.position, obj->GetCollisionRadii().x);
		case 2:
			return obj->Collide(line, radius, currColl, tf);
		case 3:
			xVector o = tf.Inversed() * line.origin;
			xVector d = tf.Inversed() * (line.origin + line.direction);
			if(currColl->BoxCollide(x3DLine(o, d - o), radius, obj->GetCollisionBox()))
			{
				currColl->normal = tf.matrix.Cofactor() * currColl->normal;
				currColl->normal.Normalize();
				return true;
			}
	}
	return false;
}

xEntityCollision * xSimulator::AllocObjColl(xEntity * with, const xVector &coords, const xCollision &coll)
{
	xEntityCollision * c;
	if(_freeCollisions.size())
	{
		c = _freeCollisions.back();
		_freeCollisions.pop_back();
	}
	else
	{
		c = new xEntityCollision();
	}
	_usedCollisions.push_back(c);
	c->with      = with;
	c->coords    = coords;
	c->collision = coll;
	return c;
}

void xSimulator::Collided(xEntity * src, xEntity * dest, const x3DLine &line, const xCollision &coll, float yScale)
{
	xEntityCollision * c;
	const xVector &coords = line * coll.time - coll.normal * src->GetCollisionRadii().x;
	c = AllocObjColl(dest, coords, coll);
	c->coords.y *= yScale;
	src->AddCollision(c);
	c = AllocObjColl(src, coords, coll);
	c->coords.y *= yScale;
	dest->AddCollision(c);
}