//
//  ragdoll.mm
//  Ragdoll
//
//  Created by Fadeev 'Knightmare' Dmitry on 8/11/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "ragdoll.h"
#import "xors3d.h"

Ragdoll::Ragdoll()
{
	for(int i = 0; i < RagdollSize; i++)
	{
		_nodes[i] = 0;
	}
	for(int i = 0; i < RagdollJointsSize; i++)
	{
		_joints[i] = 0;
	}
	_headImage = 0;
	_nodeImage = 0;
}

Ragdoll::~Ragdoll()
{
	for(int i = 0; i < RagdollJointsSize; i++)
	{
		xFree2DJoint(_joints[i]);
	}
	for(int i = 0; i < RagdollSize; i++)
	{
		xDelete2DShape(_nodes[i]);
	}
	xFreeImage(_headImage);
	xFreeImage(_nodeImage);
}

bool Ragdoll::Create(const char * node, const char * head, int x, int y, int red, int green, int blue)
{
	// body
	_nodeImage = xLoadImage(node);
	if(_nodeImage == 0) return false;
	xImageColor(_nodeImage, red, green, blue);
	xMidHandle(_nodeImage);
	_nodes[BodyUp] = xCreateBox2DShape(xImageWidth(_nodeImage), xImageHeight(_nodeImage), 1.0f);
	xPosition2DShape(_nodes[BodyUp], x, y);
	x2DShapeAssignImage(_nodes[BodyUp], _nodeImage, 0);
	_nodes[BodyDown] = xCreateBox2DShape(xImageWidth(_nodeImage), xImageHeight(_nodeImage), 1.0f);
	xPosition2DShape(_nodes[BodyDown], x, y + 32);
	x2DShapeAssignImage(_nodes[BodyDown], _nodeImage, 0);
	_joints[BodyBody] = xCreateRevolute2DJointWithAxis(_nodes[BodyUp], _nodes[BodyDown], 0, 16, false);
	xSet2DJointHingeLimit(_joints[BodyBody], true, -45, 45);
	// right leg
	_nodes[RightLegUp] = xCreateBox2DShape(xImageWidth(_nodeImage), xImageHeight(_nodeImage), 1.0f);
	xPosition2DShape(_nodes[RightLegUp], x + 16, y + 64);
	xRotate2DShape(_nodes[RightLegUp], -30);
	x2DShapeAssignImage(_nodes[RightLegUp], _nodeImage, 0);	
	_joints[BodyRightLeg] = xCreateRevolute2DJointWithAxis(_nodes[BodyDown], _nodes[RightLegUp], 16, 16, false);
	xSet2DJointHingeLimit(_joints[BodyRightLeg], true, -120, -15);
	_nodes[RightLegDown] = xCreateBox2DShape(xImageWidth(_nodeImage), xImageHeight(_nodeImage), 1.0f);
	xPosition2DShape(_nodes[RightLegDown], x + 24, y + 96);
	x2DShapeAssignImage(_nodes[RightLegDown], _nodeImage, 0);
	_joints[RightLegRightLeg] = xCreateRevolute2DJointWithAxis(_nodes[RightLegUp], _nodes[RightLegDown], 0, 16, false);
	xSet2DJointHingeLimit(_joints[RightLegRightLeg], true, -45, 45);
	// left leg
	_nodes[LeftLegUp] = xCreateBox2DShape(xImageWidth(_nodeImage), xImageHeight(_nodeImage), 1.0f);
	xPosition2DShape(_nodes[LeftLegUp], x - 16, y + 64);
	xRotate2DShape(_nodes[LeftLegUp], 30);
	x2DShapeAssignImage(_nodes[LeftLegUp], _nodeImage, 0);	
	_joints[BodyLeftLeg] = xCreateRevolute2DJointWithAxis(_nodes[BodyDown], _nodes[LeftLegUp], -16, 16, false);
	xSet2DJointHingeLimit(_joints[BodyLeftLeg], true, 15, 60);
	_nodes[LeftLegDown] = xCreateBox2DShape(xImageWidth(_nodeImage), xImageHeight(_nodeImage), 1.0f);
	xPosition2DShape(_nodes[LeftLegDown], x - 24, y + 96);
	x2DShapeAssignImage(_nodes[LeftLegDown], _nodeImage, 0);
	_joints[LeftLegLeftLeg] = xCreateRevolute2DJointWithAxis(_nodes[LeftLegUp], _nodes[LeftLegDown], 0, 16, false);
	xSet2DJointHingeLimit(_joints[LeftLegLeftLeg], true, -45, 45);
	// right hand
	_nodes[RightHandUp] = xCreateBox2DShape(xImageWidth(_nodeImage), xImageHeight(_nodeImage), 1.0f);
	xPosition2DShape(_nodes[RightHandUp], x + 32, y - 16);
	xRotate2DShape(_nodes[RightHandUp], -90);
	x2DShapeAssignImage(_nodes[RightHandUp], _nodeImage, 0);	
	_joints[BodyRightLeg] = xCreateRevolute2DJointWithAxis(_nodes[BodyUp], _nodes[RightHandUp], 16, -16, false);
	xSet2DJointHingeLimit(_joints[BodyRightLeg], true, -90, 90);
	_nodes[RightHandDown] = xCreateBox2DShape(xImageWidth(_nodeImage), xImageHeight(_nodeImage), 1.0f);
	xPosition2DShape(_nodes[RightHandDown], x + 64, y - 16);
	xRotate2DShape(_nodes[RightHandDown], -90);
	x2DShapeAssignImage(_nodes[RightHandDown], _nodeImage, 0);
	_joints[RightLegRightLeg] = xCreateRevolute2DJointWithAxis(_nodes[RightHandUp], _nodes[RightHandDown], 0, 16, false);
	xSet2DJointHingeLimit(_joints[RightLegRightLeg], true, -90, 0);
	// left hand
	_nodes[LeftHandUp] = xCreateBox2DShape(xImageWidth(_nodeImage), xImageHeight(_nodeImage), 1.0f);
	xPosition2DShape(_nodes[LeftHandUp], x - 32, y - 16);
	xRotate2DShape(_nodes[LeftHandUp], 90);
	x2DShapeAssignImage(_nodes[LeftHandUp], _nodeImage, 0);	
	_joints[BodyLeftLeg] = xCreateRevolute2DJointWithAxis(_nodes[BodyUp], _nodes[LeftHandUp], -16, -16, false);
	xSet2DJointHingeLimit(_joints[BodyLeftLeg], true, -90, 90);
	_nodes[LeftHandDown] = xCreateBox2DShape(xImageWidth(_nodeImage), xImageHeight(_nodeImage), 1.0f);
	xPosition2DShape(_nodes[LeftHandDown], x - 64, y - 16);
	xRotate2DShape(_nodes[LeftHandDown], 90);
	x2DShapeAssignImage(_nodes[LeftHandDown], _nodeImage, 0);
	_joints[LeftLegLeftLeg] = xCreateRevolute2DJointWithAxis(_nodes[LeftHandUp], _nodes[LeftHandDown], 0, 16, false);
	xSet2DJointHingeLimit(_joints[LeftLegLeftLeg], true, 0, 90);
	// head
	_headImage = xLoadImage("head.png");
	if(_headImage == 0) return false;
	xImageColor(_headImage, red, green, blue);
	xMidHandle(_headImage);
	_nodes[Head] = xCreateCircle2DShape(23, 1.0f);
	xPosition2DShape(_nodes[Head], x, y - 44);
	x2DShapeAssignImage(_nodes[Head], _headImage, 0);	
	_joints[BodyHead] = xCreateRevolute2DJointWithAxis(_nodes[BodyUp], _nodes[Head], 0, -32, false);
	xSet2DJointHingeLimit(_joints[BodyHead], true, -20, 20);
	// all ok
	return true;
}

int Ragdoll::GetNode(RagdollNode nodeID)
{
	return _nodes[nodeID];
}

int Ragdoll::GetJoint(RagdollJoint jointID)
{
	return _joints[jointID];
}