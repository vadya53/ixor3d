//
//  bone.h
//  iXors3D
//
//  Created by Knightmare on 10.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "entity.h"
#import "animset.h"
#import "animtrack.h"

class xBone;
typedef std::vector<xBone*> xBonesGroup;

class xBone : public xEntity
{
private:
	static xTransform     ** _transforms;
	xTransform               _bindPose;
	xTransform               _bindPoseInverse;
	xTransform               _resultTransform;
	int                      _boneID;
	xVector                  _bindPosition;
	xVector                  _bindScale;
	xQuaternion              _bindRotation;
	std::vector<xAnimSet*>   _animSets;
	std::vector<xAnimTrack*> _animTracks;
private:
	void ClearTracks();
	void BlendTracks(float delta);
	xAnimTrack * FindCurrentTrack();
	LoaderNode * FindNodeInFile(LoaderNode * rootNode);
public:
	xBone(int boneID, xVector position, xQuaternion rotation, xVector scale);
	void ComputeBindPose();
	int GetBoneID();
	void ComputeFinalTransform();
	xTransform ** GetBonesTransforms(xTransform & entityTForm);
	void AddToGroup(xBonesGroup & group, bool heirarhy);
	void DeleteFromGroup(xBonesGroup & group, bool heirarhy);
	xBone * Clone(xEntity * parent, bool cloneGeom);
	xBone * FindChildByID(int boneID);
	void UpdateAnimation(float delta);
	void Animate(int mode, float speed, int setID, float smooth);
	bool Animated();
	void SetAnimationTime(float time);
	float GetAnimationTime();
	void SetAnimationSpeed(float speed);
	float GetAnimationSpeed();
	float GetAnimationLength();
	int GetAnimationSet();
	void AddAnimationSet(xAnimSet * newSet);
	int ExtractAnimationSet(int startFrame, int endFrame, int setID);
	int ExtractAnimationSetFromFile(LoaderNode * rootNode);
	void ClearAnimData();
	void SetPose(float time);
};