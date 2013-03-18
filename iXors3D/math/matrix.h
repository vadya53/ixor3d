//
//  matrix.h
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vector.h"
#import "quaternion.h"

class xMatrix
{
public:
	xVector i, j, k;
public:
	xMatrix();
	xMatrix(const xVector &_i, const xVector &_j, const xVector &_k);
	xMatrix(const xQuaternion &quat);
	xMatrix(const xVector &axis, float angle);
	xMatrix Transposed() const;
	void Transpose();
	float Determinant() const;
	xMatrix Inversed() const;
	void Inverse();
	xMatrix Cofactor() const;
	bool operator==(const xMatrix &other) const;
	bool operator!=(const xMatrix &other) const;
	xVector operator*(const xVector &vector) const;
	xMatrix operator*(const xMatrix &other) const;
	void Orthogonalize();
	xMatrix Orthogonalized() const;
};