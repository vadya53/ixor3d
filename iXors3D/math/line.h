//
//  line.h
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vector.h"

class x3DLine
{
public:
	xVector origin;
	xVector direction;
public:
	x3DLine();
	x3DLine(const xVector &_origin, const xVector &_direction);
	x3DLine operator+(const xVector &vector) const;
	x3DLine operator-(const xVector &vector) const;
	xVector operator*(float scale) const;
	xVector Nearest(const xVector &vector) const;
};