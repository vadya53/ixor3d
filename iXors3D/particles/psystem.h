//
//  psystem.h
//  iXors3D
//
//  Created by Knightmare on 06.12.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "x3dmath.h"
#import "texture.h"

class xParticleSystem
{
private:
	xTexture * _texture;
	xVector    _emitPositionMin, _emitPositionMax;
	xVector    _emitDirectionMin, _emitDirectionMax;
	xVector    _emitColorMin, _emitColorMax;
	int        _emitFrameMin, _emitFrameMax;
	float      _emitAlphaMin, _emitAlphaMax;
	int        _emiterLifeTimeMin, _emiterLifeTimeMax;
	int        _particleLifeTimeMin, _particleLifeTimeMax;
	int        _emitFrequencyMin, _emitFrequencyMax;
	int        _emitCountMin, _emitCountMax;
	int        _maxParticles;
	bool       _is2D;
	bool       _alignedQuads;
public:
	xParticleSystem(bool is2D = false);
	void SetEmitPosition(xVector start, xVector end);
	xVector GetEmitPositionStart();
	xVector GetEmitPositionEnd();
	void SetEmitDirection(xVector start, xVector end);
	xVector GetEmitDirectionStart();
	xVector GetEmitDirectionEnd();
	void SetEmitColor(xVector start, xVector end);
	xVector GetEmitColorStart();
	xVector GetEmitColorEnd();
	void SetEmitTextureFrame(int start, int end);
	int GetEmitTextureFrameStart();
	int GetEmitTextureFrameEnd();
	void SetEmitAlpha(float start, float end);
	float GetEmitAlphaStart();
	float GetEmitAlphaEnd();
	void SetEmiterLifeTime(int start, int end);
	int GetEmiterLifeTimeStart();
	int GetEmiterLifeTimeEnd();
	void SetParticleLifeTime(int start, int end);
	int GetParticleLifeTimeStart();
	int GetParticleLifeTimeEnd();
	void SetEmitFrequency(int start, int end);
	int GetEmitFrequencyStart();
	int GetEmitFrequencyEnd();
	void SetEmitCount(int start, int end);
	int GetEmitCountStart();
	int GetEmitCountEnd();
	void SetMaxParticleCount(int maxCount);
	int GetMaxParticleCount();
	bool Is2DSystem();
	void SetTexture(xTexture * texture);
	xTexture * GetTexture();
	void SetQuadAlign(bool aligned);
	bool GetQuadAlign();
};