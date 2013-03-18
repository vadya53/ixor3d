//
//  box.h
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vector.h"
#import "line.h"

class xBox
{
public:
	xVector min, max;
public:
	xBox();
	xBox(const xVector &vector);
	xBox(const xVector &_min, const xVector &_max);
	xBox(const x3DLine &line);
	void Clear();
	bool Empty() const;
	xVector Centre() const;
	xVector Corner(int mask) const;
	void Update(const xVector &vector);
	void Update(const xBox &other);
	bool Overlaps(const xBox &other) const;
	void Expand(float scale);
	float Width() const;
	float Height() const;
	float Depth() const;
	bool Contains(const xVector &vector);
};