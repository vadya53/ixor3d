//
//  bone.mm
//  iXors3D
//
//  Created by Knightmare on 10.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "bone.h"

#define max(a, b) (a > b ? a : b)

xTransform ** xBone::_transforms = NULL;

xBone::xBone(int boneID, xVector position, xQuaternion rotation, xVector scale)
{
	if(_transforms == NULL) _transforms = new xTransform*[260];
	_bindPosition = position;
	_bindRotation = rotation;
	_bindScale    = scale;
	_type         = ENTITY_BONE;
	_boneID       = boneID;
	SetPosition(position.x, position.y, position.z, false);
	SetScale(scale.x, scale.y, scale.z, false);
	SetQuaternion(rotation, false);
	xRender::Instance()->AddAnimated(this);
}

void xBone::ClearAnimData()
{
	for(int i = 0; i < _animSets.size();   i++) delete _animSets[i];
	for(int i = 0; i < _animTracks.size(); i++) delete _animTracks[i];
}

void xBone::ComputeBindPose()
{
	_bindPose = xTransform(_bindPosition) * xTransform(xMatrix(_bindRotation) * ScaleMatrix(_bindScale));
	if(_parent != NULL && _parent->GetType() == ENTITY_BONE) _bindPose = ((xBone*)_parent)->_bindPose * _bindPose;
	else if(_parent != NULL) _bindPose = _parent->GetWorldTransform() * _bindPose;
	_bindPoseInverse = _bindPose.Inversed();
}

int xBone::ExtractAnimationSet(int startFrame, int endFrame, int setID)
{
	if(setID < 0 || setID >= _animSets.size()) return -1;
	xAnimSet * newSet        = new xAnimSet();
	xKeysArray * newSetKeys  = newSet->GetKeys();
	xKeysArray::iterator itr = _animSets[setID]->GetKeys()->begin();
	while(itr != _animSets[setID]->GetKeys()->end())
	{
		if(itr->frame >= startFrame && itr->frame <= endFrame) newSetKeys->push_back(*itr);
		itr++;
	}
	if(newSetKeys->size() == 0)
	{
		delete newSet;
		return -1;
	}
	float startTime = (*newSetKeys)[0].time;
	float length    = 0.0f;
	for(int i = 0; i < newSetKeys->size(); i++)
	{
		(*newSetKeys)[i].time  -= startTime;
		(*newSetKeys)[i].frame -= startFrame;
		length = (*newSetKeys)[i].time;
	}
	newSet->SetFPS(_animSets[setID]->GetFPS());
	newSet->SetFramesCount(newSetKeys->size());
	newSet->SetLenght(length);
	_animSets.push_back(newSet);
	return _animSets.size() - 1;
}

int xBone::GetBoneID()
{
	return _boneID;
}

void xBone::ComputeFinalTransform()
{
	_resultTransform = GetWorldTransform() * _bindPoseInverse;
	for(int i = 0; i < _childs.size(); i++)
	{
		_childs[i]->ForceUpdate();
		if(_childs[i]->GetType() == ENTITY_BONE) ((xBone*)_childs[i])->ComputeFinalTransform();
	}
}

xTransform ** xBone::GetBonesTransforms(xTransform & entityTForm)
{
	if(_boneID <= 256)
	{
		_bindPose            = entityTForm * _resultTransform;
		_transforms[_boneID] = &_bindPose;
	}
	for(int i = 0; i < _childs.size(); i++)
	{
		if(_childs[i]->GetType() == ENTITY_BONE) ((xBone*)_childs[i])->GetBonesTransforms(entityTForm);
	}
	return _transforms;
}

void xBone::AddAnimationSet(xAnimSet * newSet)
{
	_animSets.push_back(newSet);
}

void xBone::AddToGroup(xBonesGroup & group, bool heirarhy)
{
	group.push_back(this);
	if(heirarhy)
	{
		for(int i = 0; i < _childs.size(); i++)
		{
			if(_childs[i]->GetType() == ENTITY_BONE) ((xBone*)_childs[i])->AddToGroup(group, true);
		}
	}
}

void xBone::DeleteFromGroup(xBonesGroup & group, bool heirarhy)
{
	xBonesGroup::iterator itr = std::find(group.begin(), group.end(), this);
	if(itr != group.end()) group.erase(itr);
	if(heirarhy)
	{
		for(int i = 0; i < _childs.size(); i++)
		{
			if(_childs[i]->GetType() == ENTITY_BONE) ((xBone*)_childs[i])->DeleteFromGroup(group, true);
		}
	}
}

xBone * xBone::Clone(xEntity * parent, bool cloneGeom)
{
	xBone * newBone = new xBone(_boneID, _bindPosition, _bindRotation, _bindScale);
	newBone->ComputeBindPose();
	newBone->_bindPose = _bindPose;
	newBone->_bindPoseInverse = _bindPoseInverse;
	if(cloneGeom)
	{
		newBone->_copiedFrom = this;
		_copies.push_back(newBone);
	}
	newBone->SetParent(parent);
	newBone->_name = _name;
	newBone->_masterBrush.Copy(&_masterBrush);
	newBone->SetPickMode(_pickMode);
	newBone->_needUpdate = true;
	newBone->SetAutoFade(_fadeNear, _fadeFar);
	newBone->_autoFade   = _autoFade;
	newBone->SetOrder(_order);
	for(int i = 0; i < _surfaces.size(); i++)
	{
		newBone->_surfaces.push_back(_surfaces[i]->Clone(cloneGeom));
	}
	for(int i = 0; i < _childs.size(); i++)
	{
		if(_childs[i]->GetType() == ENTITY_BONE)
		{
			((xBone*)_childs[i])->Clone(newBone, cloneGeom);
		}
		else
		{
			_childs[i]->Clone(newBone, cloneGeom);
		}
	}
	for(int i = 0; i < _animSets.size(); i++)
	{
		newBone->_animSets.push_back(_animSets[i]->Clone());
	}
	return newBone;
}

xBone * xBone::FindChildByID(int boneID)
{
	if(_boneID == boneID) return this;
	for(int i = 0; i < _childs.size(); i++)
	{
		if(_childs[i]->GetType() != ENTITY_BONE) continue;
		xBone * result = ((xBone*)_childs[i])->FindChildByID(boneID);
		if(result != NULL) return result;
	}
	return NULL;
}

void xBone::ClearTracks()
{
	std::vector<xAnimTrack*>::iterator i = _animTracks.begin();
	while(i != _animTracks.end())
	{
		if(!(*i)->IsEnabled())
		{
			delete (*i);
			i = _animTracks.erase(i);
		}
		else
		{
			i++;
		}
	}
}

void xBone::UpdateAnimation(float delta)
{
	if(_animTracks.size() == 0) return;
	ClearTracks();
	BlendTracks(delta);
}

void xBone::SetPose(float time)
{
	if(_animTracks.size() == 0)
	{
		xVector     position = GetPosition(false);
		xVector     scale    = GetScale(false);
		xQuaternion rotation = GetQuaternion(false);
		_animSets[0]->GetBoneTransform(fmodf(time, _animSets[0]->GetLenght()), position, scale, rotation);
		SetPosition(position.x, position.y, position.z, false);
		SetQuaternion(rotation, false);
		SetScale(scale.x, scale.y, scale.z, false);
	}
	else
	{
		ClearTracks();
		BlendTracks(0.0f);
	}
	for(int i = 0; i < _childs.size(); i++)
	{
		if(_childs[i]->GetType() == ENTITY_BONE) ((xBone*)_childs[i])->SetPose(time);
	}
}

void xBone::BlendTracks(float delta)
{
	std::vector<xAnimTrack*>::iterator i = _animTracks.begin();
	while(i != _animTracks.end())
	{
		(*i)->Update(delta);
		if(i == _animTracks.begin())
		{
			xVector     position = GetPosition(false);
			xVector     scale    = GetScale(false);
			xQuaternion rotation = GetQuaternion(false);
			(*i)->GetAnimationSet()->GetBoneTransform((*i)->GetTime(), position, scale, rotation);
			SetPosition(position.x, position.y, position.z, false);
            SetQuaternion(rotation, false);
			SetScale(scale.x, scale.y, scale.z, false);
		}
		else
		{
			xVector     position;
			xVector     scale;
			xQuaternion rotation;
			(*i)->GetAnimationSet()->GetBoneTransform((*i)->GetTime(), position, scale, rotation);
			position = GetPosition(false).Lerp(position, (*i)->GetWeight());
			scale    = GetScale(false).Lerp(scale, (*i)->GetWeight());
			rotation = GetQuaternion(false).Slerp(rotation, (*i)->GetWeight());
			SetPosition(position.x, position.y, position.z, false);
            SetQuaternion(rotation, false);
			SetScale(scale.x, scale.y, scale.z, false);
		}
		i++;
	}
}

xAnimTrack * xBone::FindCurrentTrack()
{
	xAnimTrack * currentTrack = NULL;
	std::vector<xAnimTrack*>::iterator i = _animTracks.begin();
	while(i != _animTracks.end())
	{
		if(!(*i)->IsEnded()) currentTrack = (*i);
		i++;
	}
	return currentTrack;
}

void xBone::Animate(int mode, float speed, int setID, float smooth)
{
	if(setID < 0 || setID >= _animSets.size()) return;
	xAnimTrack * lastTrack = NULL;
	std::vector<xAnimTrack*>::iterator i = _animTracks.begin();
	float timeFactor = 0.05f * smooth;
	while(i != _animTracks.end())
	{
		if(smooth < 0.0001f)
		{
			delete (*i);
			i = _animTracks.erase(i);
		}
		else
		{
			if(lastTrack != NULL) lastTrack->EnableTrack(false);
			lastTrack = (*i);
			lastTrack->DeleteAllEvents();
			lastTrack->EndTrack();
			i++;
		}
	}
	xAnimTrack * newTrack = new xAnimTrack();
	newTrack->SetAnimationSet(_animSets[setID]);
	newTrack->SetTrackMode(mode);
	newTrack->SetSpeed(speed);
	newTrack->SetTime(speed >= 0.0f ? 0.0f : _animSets[setID]->GetLenght());
	newTrack->SetTrackLength(_animSets[setID]->GetLenght());
	if(smooth < 0.0001f)
	{
		newTrack->SetWeight(1.0f);
	}
	else
	{
		if(lastTrack != NULL)
		{
			newTrack->SetWeight(1.0f - lastTrack->GetWeight());
			newTrack->AddKeySetWeight(1.0f, timeFactor, true);
		}
		else
		{
			newTrack->SetWeight(1.0f);
		}
	}
	newTrack->EnableTrack(true);
	_animTracks.push_back(newTrack);
}

bool xBone::Animated()
{
	return (FindCurrentTrack() != NULL);
}

void xBone::SetAnimationTime(float time)
{
	xAnimTrack * current = FindCurrentTrack();
	if(current == NULL) return;
	current->SetTime(time);
}

float xBone::GetAnimationTime()
{
	xAnimTrack * current = FindCurrentTrack();
	if(current == NULL) return 0.0f;
	return current->GetTime();
}

void xBone::SetAnimationSpeed(float speed)
{
	xAnimTrack * current = FindCurrentTrack();
	if(current == NULL) return;
	current->SetSpeed(speed);
}

float xBone::GetAnimationSpeed()
{
	xAnimTrack * current = FindCurrentTrack();
	if(current == NULL) return 0.0f;
	return current->GetSpeed();
}

float xBone::GetAnimationLength()
{
	xAnimTrack * current = FindCurrentTrack();
	if(current == NULL) return 0.0f;
	return current->GetTrackLength();
}

int xBone::GetAnimationSet()
{
	xAnimTrack * current = FindCurrentTrack();
	if(current == NULL) return -1;
	for(int i = 0; i < _animSets.size(); i++)
	{
		if(current->GetAnimationSet() == _animSets[i]) return i;
	}
	return -1;
}

LoaderNode * xBone::FindNodeInFile(LoaderNode * rootNode)
{
	if(rootNode->_name == _name) return rootNode;
	for(int i = 0; i < rootNode->_subNodes.size(); i++)
	{
		LoaderNode * result = FindNodeInFile(rootNode->_subNodes[i]);
		if(result != NULL) return result;
	}
	return NULL;
}

int xBone::ExtractAnimationSetFromFile(LoaderNode * rootNode)
{
	LoaderNode * node = FindNodeInFile(rootNode);
	if(node == NULL) return -1;
	if(node->_animKeys.size() == 0) return -1;
	xAnimSet * newSet = new xAnimSet();
	_animSets.push_back(newSet);
	if(node->_animations.size() == 0)
	{
		int frames = 0;
		for(int i = 0; i < node->_animKeys.size(); i++) frames = max(frames, node->_animKeys[i]._frame);
		LoaderAnimation newAnimation;
		newAnimation._fps        = 30.0f;
		newAnimation._startFrame = 0;
		newAnimation._endFrame   = frames;
		node->_animations.push_back(newAnimation);
	}
	if(node->_animations[0]._fps == 0.0f) node->_animations[0]._fps = 30.0f;
	newSet->SetFPS(node->_animations[0]._fps);
	for(int i = 0; i < node->_animKeys.size(); i++)
	{
		float time           = float(node->_animKeys[i]._frame) / newSet->GetFPS();
		xVector position     =  node->_position;
		xVector scale        =  node->_scale;
		xQuaternion rotation = -node->_rotation;
		int type             = 0;
		if(node->_animKeys[i]._flag & 1)
		{
			position = node->_animKeys[i]._position;
			type += 1;
		}
		if(node->_animKeys[i]._flag & 2)
		{
			scale = node->_animKeys[i]._scale;
			type += 4;
		}
		if(node->_animKeys[i]._flag & 4)
		{
			rotation = -node->_animKeys[i]._rotation;
			type += 2;
		}
		newSet->AddAnimationKey(time, node->_animKeys[i]._frame, position, scale, rotation, type);
	}
	newSet->SetFramesCount(node->_animations[0]._endFrame - node->_animations[0]._startFrame);
	newSet->SetLenght(float(node->_animations[0]._endFrame - node->_animations[0]._startFrame) / node->_animations[0]._fps);
	return _animSets.size() - 1;
}