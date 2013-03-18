//
//  psystem.mm
//  iXors3D
//
//  Created by Knightmare on 06.12.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "psystem.h"

xParticleSystem::xParticleSystem(bool is2D)
{
	_texture             = NULL;
	_emitPositionMin     = xVector(0.0f,   0.0f,   0.0f);
	_emitPositionMax     = xVector(0.0f,   0.0f,   0.0f);
	_emitDirectionMin    = xVector(0.0f,   0.0f,   0.0f);
	_emitDirectionMax    = xVector(360.0f, 360.0f, 360.0f);
	_emitColorMin        = xVector(255.0f, 255.0f, 255.0f);
	_emitColorMax        = xVector(255.0f, 255.0f, 255.0f);
	_emitFrameMin        = 0;
	_emitFrameMax        = 0;
	_emitAlphaMin        = 1.0f;
	_emitAlphaMax        = 1.0f;
	_emiterLifeTimeMin   = 0;
	_emiterLifeTimeMax   = 0;
	_particleLifeTimeMin = 1000;
	_particleLifeTimeMax = 1000;
	_emitFrequencyMin    = 1;
	_emitFrequencyMax    = 1;
	_emitCountMin        = 1000;
	_emitCountMax        = 1000;
	_maxParticles        = 100;
	_is2D                = is2D;
	_alignedQuads        = false;
}

void xParticleSystem::SetEmitPosition(xVector start, xVector end)
{
	_emitPositionMin = start;
	_emitPositionMax = end;
}

xVector xParticleSystem::GetEmitPositionStart()
{
	return _emitPositionMin;
}

xVector xParticleSystem::GetEmitPositionEnd()
{
	return _emitPositionMax;
}

void xParticleSystem::SetEmitDirection(xVector start, xVector end)
{
	_emitDirectionMin = start;
	_emitDirectionMax = end;
}

xVector xParticleSystem::GetEmitDirectionStart()
{
	return _emitDirectionMin;
}

xVector xParticleSystem::GetEmitDirectionEnd()
{
	return _emitDirectionMax;
}

void xParticleSystem::SetEmitColor(xVector start, xVector end)
{
	_emitColorMin = start;
	_emitColorMax = end;
}

xVector xParticleSystem::GetEmitColorStart()
{
	return _emitColorMin;
}

xVector xParticleSystem::GetEmitColorEnd()
{
	return _emitColorMax;
}

void xParticleSystem::SetEmitTextureFrame(int start, int end)
{
	_emitFrameMin = start;
	_emitFrameMax = end;
}

int xParticleSystem::GetEmitTextureFrameStart()
{
	return _emitFrameMin;
}

int xParticleSystem::GetEmitTextureFrameEnd()
{
	return _emitFrameMax;
}

void xParticleSystem::SetEmitAlpha(float start, float end)
{
	_emitAlphaMin = start;
	_emitAlphaMax = end;
}

float xParticleSystem::GetEmitAlphaStart()
{
	return _emitAlphaMin;
}

float xParticleSystem::GetEmitAlphaEnd()
{
	return _emitAlphaMax;
}

void xParticleSystem::SetEmiterLifeTime(int start, int end)
{
	_emiterLifeTimeMin = start;
	_emiterLifeTimeMax = end;
}

int xParticleSystem::GetEmiterLifeTimeStart()
{
	return _emiterLifeTimeMin;
}

int xParticleSystem::GetEmiterLifeTimeEnd()
{
	return _emiterLifeTimeMax;
}

void xParticleSystem::SetParticleLifeTime(int start, int end)
{
	_particleLifeTimeMin = start;
	_particleLifeTimeMax = end;
}

int xParticleSystem::GetParticleLifeTimeStart()
{
	return _particleLifeTimeMin;
}

int xParticleSystem::GetParticleLifeTimeEnd()
{
	return _particleLifeTimeMax;
}

void xParticleSystem::SetEmitFrequency(int start, int end)
{
	_emitFrequencyMin = start;
	_emitFrequencyMax = end;
}

int xParticleSystem::GetEmitFrequencyStart()
{
	return _emitFrequencyMin;
}

int xParticleSystem::GetEmitFrequencyEnd()
{
	return _emitFrequencyMax;
}

void xParticleSystem::SetEmitCount(int start, int end)
{
	_emitCountMin = start;
	_emitCountMax = end;
}

int xParticleSystem::GetEmitCountStart()
{
	return _emitCountMin;
}

int xParticleSystem::GetEmitCountEnd()
{
	return _emitCountMax;
}

void xParticleSystem::SetMaxParticleCount(int maxCount)
{
	_maxParticles = maxCount;
}

int xParticleSystem::GetMaxParticleCount()
{
	return _maxParticles;
}

bool xParticleSystem::Is2DSystem()
{
	return _is2D;
}

void xParticleSystem::SetTexture(xTexture * texture)
{
	_texture = texture;
}

xTexture * xParticleSystem::GetTexture()
{
	return _texture;
}

void xParticleSystem::SetQuadAlign(bool aligned)
{
	_alignedQuads = aligned;
}

bool xParticleSystem::GetQuadAlign()
{
	return _alignedQuads;
}
