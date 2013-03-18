//
//  transform.h
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "matrix.h"
#import "box.h"
#import "line.h"

class xTransform
{
public:
	xMatrix matrix;
	xVector position;
public:
	xTransform();
	xTransform(const xMatrix &_matrix);
	xTransform(const xVector &_position);
	xTransform(const xMatrix &_matrix, const xVector &_position);
	xTransform Inversed() const;
	void Inverse();
	xTransform Transposed() const;
	void Transpose();
	xVector operator*(const xVector &vector) const;
	x3DLine operator*(const x3DLine &line) const;
	xBox operator*(const xBox &box) const;
	xTransform operator*(const xTransform &other) const;
	bool operator==(const xTransform &other) const;
	bool operator!=(const xTransform &other) const;
};