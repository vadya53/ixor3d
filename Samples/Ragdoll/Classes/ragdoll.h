//
//  ragdoll.h
//  Ragdoll
//
//  Created by Fadeev 'Knightmare' Dmitry on 8/11/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

class Ragdoll
{
public:
	enum RagdollNode
	{
		BodyUp        = 0,
		BodyDown      = 1,
		RightLegUp    = 2,
		RightLegDown  = 3,
		LeftLegUp     = 4,
		LeftLegDown   = 5,
		RightHandUp   = 6,
		RightHandDown = 7,
		LeftHandUp    = 8,
		LeftHandDown  = 9,
		Head          = 10,
		RagdollSize
	};
	enum RagdollJoint
	{
		BodyBody           = 0,
		BodyRightLeg       = 1,
		RightLegRightLeg   = 2,
		BodyLeftLeg        = 3,
		LeftLegLeftLeg     = 4,
		BodyRightHand      = 5,
		RightHandRightHand = 6,
		BodyLeftHand       = 7,
		LeftHandLeftHand   = 8,
		BodyHead           = 9,
		RagdollJointsSize
	};
private:
	int _nodes[RagdollSize];
	int _joints[RagdollJointsSize];
	int _headImage, _nodeImage;
public:
	Ragdoll();
	~Ragdoll();
	bool Create(const char * node, const char * head, int x, int y, int red = 255, int green = 255, int blue = 255);
	int GetNode(RagdollNode nodeID);
	int GetJoint(RagdollJoint jointID);
};