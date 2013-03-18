//
//  sysinfo.mm
//  iXors3D
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/12/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "sysinfo.h"
#import <mach/mach.h>
#import <mach/mach_host.h>

xSysInfo * xSysInfo::_instance = NULL;

xSysInfo::xSysInfo()
{
	_userTicks  = 0;
	_sysTicks   = 0;
	_idleTicks  = 0;
	_totalTicks = 0;
	natural_t              cpuCount;
	processor_info_array_t infoArray;
	mach_msg_type_number_t infoCount;
	if(host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &cpuCount, &infoArray, &infoCount) != KERN_SUCCESS)
	{
		printf("ERROR(%s:%i): Failed to fetch CPU load statistics.\n", __FILE__, __LINE__);
	}
	processor_cpu_load_info_data_t * cpuLoadInfo = (processor_cpu_load_info_data_t*)infoArray;
	for(int cpu = 0; cpu < cpuCount; cpu++)
	{
		for(int state = 0; state < CPU_STATE_MAX; state++) 
		{
			if(state == 0) _userTicks += cpuLoadInfo[cpu].cpu_ticks[state];
			if(state == 1) _sysTicks  += cpuLoadInfo[cpu].cpu_ticks[state];
			if(state == 2) _idleTicks += cpuLoadInfo[cpu].cpu_ticks[state];
			_totalTicks += cpuLoadInfo[cpu].cpu_ticks[state];
		}
	}
	vm_deallocate(mach_task_self(), (vm_address_t)infoArray, infoCount);
}

xSysInfo::~xSysInfo()
{
}

xSysInfo::xSysInfo(const xSysInfo & other)
{
}

xSysInfo & xSysInfo::operator=(const xSysInfo & other)
{
	return *this;
}

xSysInfo * xSysInfo::Instance()
{
	if(_instance == NULL) _instance = new xSysInfo();
	return _instance;
}

float xSysInfo::GetFreeMemory()
{
	mach_port_t hostPort = mach_host_self();
	mach_msg_type_number_t hostSize = sizeof(vm_statistics_data_t) / sizeof(integer_t);
	vm_size_t pageSize;
	host_page_size(hostPort, &pageSize);
	vm_statistics_data_t vmStat;
	if(host_statistics(hostPort, HOST_VM_INFO, (host_info_t)&vmStat, &hostSize) != KERN_SUCCESS)
	{
		printf("ERROR(%s:%i): Failed to fetch memory statistics.\n", __FILE__, __LINE__);
		return 0.0f;
	}
	return float(vmStat.free_count * pageSize) / float(1024 * 1024);
}

float xSysInfo::GetUsedMemory()
{
	mach_port_t hostPort = mach_host_self();
	mach_msg_type_number_t hostSize = sizeof(vm_statistics_data_t) / sizeof(integer_t);
	vm_size_t pageSize;
	host_page_size(hostPort, &pageSize);
	vm_statistics_data_t vmStat;
	if(host_statistics(hostPort, HOST_VM_INFO, (host_info_t)&vmStat, &hostSize) != KERN_SUCCESS)
	{
		printf("ERROR(%s:%i): Failed to fetch memory statistics.\n", __FILE__, __LINE__);
		return 0.0f;
	}
	return float(vmStat.active_count * pageSize) / float(1024 * 1024);
}

float xSysInfo::GetInactiveMemory()
{
	mach_port_t hostPort = mach_host_self();
	mach_msg_type_number_t hostSize = sizeof(vm_statistics_data_t) / sizeof(integer_t);
	vm_size_t pageSize;
	host_page_size(hostPort, &pageSize);
	vm_statistics_data_t vmStat;
	if(host_statistics(hostPort, HOST_VM_INFO, (host_info_t)&vmStat, &hostSize) != KERN_SUCCESS)
	{
		printf("ERROR(%s:%i): Failed to fetch memory statistics.\n", __FILE__, __LINE__);
		return 0.0f;
	}
	return float(vmStat.inactive_count * pageSize) / float(1024 * 1024);
}

float xSysInfo::GetTotalMemory()
{
	mach_port_t hostPort = mach_host_self();
	mach_msg_type_number_t hostSize = sizeof(vm_statistics_data_t) / sizeof(integer_t);
	host_basic_info hostStat;
	if(host_info(hostPort, HOST_BASIC_INFO, (host_info_t)&hostStat, &hostSize) != KERN_SUCCESS)
	{
		printf("ERROR(%s:%i): Failed to fetch memory statistics.\n", __FILE__, __LINE__);
		return 0.0f;
	}
	return float(hostStat.memory_size) / float(1024 * 1024);
}

float xSysInfo::GetCPUUserTime()
{
	natural_t              cpuCount;
	processor_info_array_t infoArray;
	mach_msg_type_number_t infoCount;
	if(host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &cpuCount, &infoArray, &infoCount) != KERN_SUCCESS)
	{
		printf("ERROR(%s:%i): Failed to fetch CPU load statistics.\n", __FILE__, __LINE__);
		return 0.0f;
	}
	processor_cpu_load_info_data_t * cpuLoadInfo = (processor_cpu_load_info_data_t*)infoArray;
	unsigned long totalTicks = 0;
	unsigned long paramTicks = 0;
	for(int cpu = 0; cpu < cpuCount; cpu++)
	{
		paramTicks += cpuLoadInfo[cpu].cpu_ticks[0];
		for(int state = 0; state < CPU_STATE_MAX; state++) totalTicks += cpuLoadInfo[cpu].cpu_ticks[state];
	}
	vm_deallocate(mach_task_self(), (vm_address_t)infoArray, infoCount);
	return float(double(paramTicks - _userTicks) / double(totalTicks - _totalTicks));
}

float xSysInfo::GetCPUSysTime()
{
	natural_t              cpuCount;
	processor_info_array_t infoArray;
	mach_msg_type_number_t infoCount;
	if(host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &cpuCount, &infoArray, &infoCount) != KERN_SUCCESS)
	{
		printf("ERROR(%s:%i): Failed to fetch CPU load statistics.\n", __FILE__, __LINE__);
		return 0.0f;
	}
	processor_cpu_load_info_data_t * cpuLoadInfo = (processor_cpu_load_info_data_t*)infoArray;
	unsigned long totalTicks = 0;
	unsigned long paramTicks = 0;
	for(int cpu = 0; cpu < cpuCount; cpu++)
	{
		paramTicks += cpuLoadInfo[cpu].cpu_ticks[1];
		for(int state = 0; state < CPU_STATE_MAX; state++) totalTicks += cpuLoadInfo[cpu].cpu_ticks[state];
	}
	vm_deallocate(mach_task_self(), (vm_address_t)infoArray, infoCount);
	return float(double(paramTicks - _sysTicks) / double(totalTicks - _totalTicks));
}

float xSysInfo::GetCPUIdleTime()
{
	natural_t              cpuCount;
	processor_info_array_t infoArray;
	mach_msg_type_number_t infoCount;
	if(host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &cpuCount, &infoArray, &infoCount) != KERN_SUCCESS)
	{
		printf("ERROR(%s:%i): Failed to fetch CPU load statistics.\n", __FILE__, __LINE__);
		return 0.0f;
	}
	processor_cpu_load_info_data_t * cpuLoadInfo = (processor_cpu_load_info_data_t*)infoArray;
	unsigned long totalTicks = 0;
	unsigned long paramTicks = 0;
	for(int cpu = 0; cpu < cpuCount; cpu++)
	{
		paramTicks += cpuLoadInfo[cpu].cpu_ticks[2];
		for(int state = 0; state < CPU_STATE_MAX; state++) totalTicks += cpuLoadInfo[cpu].cpu_ticks[state];
	}
	vm_deallocate(mach_task_self(), (vm_address_t)infoArray, infoCount);
	return float(double(paramTicks - _idleTicks) / double(totalTicks - _totalTicks));
}