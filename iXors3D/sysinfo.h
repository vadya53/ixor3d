//
//  sysinfo.h
//  iXors3D
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/12/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

class xSysInfo
{
private:
	static xSysInfo * _instance;
	unsigned int      _userTicks, _sysTicks, _idleTicks, _totalTicks;
private:
	xSysInfo();
	~xSysInfo();
	xSysInfo(const xSysInfo & other);
	xSysInfo & operator=(const xSysInfo & other);
public:
	static xSysInfo * Instance();
	float GetFreeMemory();
	float GetUsedMemory();
	float GetInactiveMemory();
	float GetTotalMemory();
	float GetCPUUserTime();
	float GetCPUSysTime();
	float GetCPUIdleTime();
};