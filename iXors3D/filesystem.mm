//
//  filesystem.mm
//  iXors3D
//
//  Created by Knightmare on 15.10.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "filesystem.h"
#import <Foundation/Foundation.h>
#import <dirent.h>
#import <sys/stat.h>

xFileSystem * xFileSystem::_instance = NULL;

std::string tempString;

xFileSystem::xFileSystem()
{
	_homeDirectory       = [NSHomeDirectory() UTF8String];
	_currentDirectory    = "/";
	_currentAppDirectory = "/";
#if !TARGET_OS_EMBEDDED && !TARGET_IPHONE_SIMULATOR
	NSString * supportFolder = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
	supportFolder = [[supportFolder stringByAppendingPathComponent:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleName"]] retain];
	_filesDirectory = [supportFolder UTF8String];
	if(![[NSFileManager defaultManager] fileExistsAtPath: supportFolder])
	{
		if(![[NSFileManager defaultManager] createDirectoryAtPath: supportFolder
													   attributes: nil])
		{
			printf("ERROR(%s:%i): Unable to create application support directory.\n", __FILE__, __LINE__);
		}
	}
	_filesDirectory += "/";
#endif
}

xFileSystem::xFileSystem(const xFileSystem & other)
{
}

xFileSystem & xFileSystem::operator=(const xFileSystem & other)
{
	return *this;
}

xFileSystem::~xFileSystem()
{
}

xFileSystem * xFileSystem::Instance()
{
	if(_instance == NULL) _instance = new xFileSystem();
	return _instance;
}

std::string xFileSystem::GetRealPath(const char * path)
{
	std::string realPath = path;
	if(realPath.substr(0, 7) == "file://")
	{
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
		realPath = _homeDirectory + std::string("/Documents") + _currentDirectory + realPath.substr(7);
#else
		realPath = _filesDirectory + _currentDirectory + realPath.substr(7);
#endif
	}
	else if(realPath.substr(0, 6) == "app://")
	{
		std::string filePath = "";
		std::string fileName = _currentAppDirectory + realPath.substr(6);
		int slashPos = fileName.find_last_of('/');
		if(slashPos != fileName.npos)
		{
			filePath = fileName.substr(0, slashPos);
			fileName = fileName.substr(slashPos + 1);
		}
		NSString * nsPath = [[NSBundle mainBundle] pathForResource: [NSString stringWithUTF8String: fileName.c_str()] 
															ofType: nil
													   inDirectory: (filePath.length() == 0 ? nil : [NSString stringWithUTF8String: filePath.c_str()])];
		if(nsPath == nil)
        {
            return realPath;
        }
		realPath = std::string([nsPath UTF8String]);
	}
    else if(realPath.substr(0, 6) == "tmp://")
	{
        realPath = _homeDirectory + std::string("/tmp") + _currentDirectory + realPath.substr(6);
	}
    else if(realPath.substr(0, 8) == "cache://")
	{
        realPath = _homeDirectory + std::string("/Library/Caches") + _currentDirectory + realPath.substr(8);
	}
	else
	{
		if(realPath[0] == '/') realPath = realPath.substr(1);
		std::string filePath = "";
		std::string fileName = _currentAppDirectory + realPath;
		int slashPos = fileName.find_last_of('/');
		if(slashPos != fileName.npos)
		{
			filePath = fileName.substr(0, slashPos);
			fileName = fileName.substr(slashPos + 1);
		}
		NSString * nsPath = [[NSBundle mainBundle] pathForResource: [NSString stringWithUTF8String: fileName.c_str()] 
															ofType: nil
													   inDirectory: (filePath.length() == 0 ? nil : [NSString stringWithUTF8String: filePath.c_str()])];
		if(nsPath == nil)
        {
            return realPath;
        }
		realPath = std::string([nsPath UTF8String]);		
	}
	return realPath;
}

size_t xFileSystem::ReadDirectory(const char * path)
{
	DIR * directory = opendir(GetRealPath(path).c_str());
	return (size_t)directory;
}

void xFileSystem::CloseDirectory(size_t directory)
{
	closedir((DIR*)directory);
}

const char * xFileSystem::NextFile(size_t directory)
{
	dirent * entry = readdir((DIR*)directory);
	return (entry == NULL ? "" : entry->d_name);
}

const char * xFileSystem::GetCurrentDirectory(bool appDirectory)
{
	return (appDirectory ? _currentAppDirectory.c_str() : _currentDirectory.c_str());
}

void xFileSystem::SetDirectory(const char * path)
{
	_currentDirectory = path;
	if(_currentDirectory.substr(0, 7) == "file://")
	{
		_currentDirectory = _currentDirectory.substr(6);
	}
	else if(_currentDirectory.substr(0, 6) == "app://")
	{
		_currentAppDirectory = _currentDirectory.substr(5);
	}
    else if(_currentDirectory.substr(0, 6) == "tmp://")
	{
		_currentAppDirectory = _currentDirectory.substr(5);
	}
    else if(_currentDirectory.substr(0, 8) == "cache://")
	{
		_currentAppDirectory = _currentDirectory.substr(7);
	}
}

bool xFileSystem::CreateDirectory(const char * path)
{
	return mkdir(GetRealPath(path).c_str(), S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH) == 0;
}

bool xFileSystem::DeleteDirectory(const char * path)
{
	return rmdir(GetRealPath(path).c_str()) == 0;
}

size_t xFileSystem::OpenFile(const char * path)
{
	return (size_t)fopen(GetRealPath(path).c_str(), "ab");
}

size_t xFileSystem::ReadFile(const char * path)
{
	return (size_t)fopen(GetRealPath(path).c_str(), "rb");
}

size_t xFileSystem::WriteFile(const char * path)
{
	return (size_t)fopen(GetRealPath(path).c_str(), "wb");
}

void xFileSystem::CloseFile(size_t fileHandle)
{
	fclose((FILE*)fileHandle);
}

unsigned int xFileSystem::GetFilePosition(size_t fileHandle)
{
	return ftell((FILE*)fileHandle);
}

void xFileSystem::SeekFile(size_t fileHandle, unsigned int offset)
{
	fseek((FILE*)fileHandle, offset, SEEK_SET);
}

int xFileSystem::GetFileType(const char * path)
{
	FILE * fileHandle;
	DIR  * directoryHandle;
	if((fileHandle = fopen(GetRealPath(path).c_str(), "rb")) != NULL)
	{
		fclose(fileHandle);
		return 1;
	}
	else if((directoryHandle = opendir(GetRealPath(path).c_str())) != NULL)
	{
		closedir(directoryHandle);
		return 2;
	}
	return 0;
}

unsigned int xFileSystem::GetFileSize(const char * path)
{
	FILE * fileHandle = fopen(GetRealPath(path).c_str(), "rb");
	if(fileHandle == NULL) return 0;
	fseek(fileHandle, 0, SEEK_END);
	unsigned int size = ftell(fileHandle);
	fclose(fileHandle);
	return size;
}

bool xFileSystem::DeleteFile(const char * path)
{
	return remove(GetRealPath(path).c_str()) == 0;
}

bool xFileSystem::CopyFile(const char * pathOriginal, const char * pathNew)
{
	FILE         * finput  = fopen(GetRealPath(pathOriginal).c_str(), "rb");
	FILE         * foutput = fopen(GetRealPath(pathNew).c_str(),      "wb");
	unsigned int   amount  = 0;
	unsigned int   written = 0;
	bool           result  = true;
	char         * buffer  = new char[16000];
	if(finput == NULL || foutput == NULL)
	{
		result = false;
		if(finput  != NULL) fclose(finput);
		if(foutput != NULL) fclose(foutput);
	}
	if(result == true)
	{
		do
		{
			amount = fread(buffer, sizeof(char), 16000, finput);
			if(amount)
			{
				written = fwrite(buffer, sizeof(char), amount, foutput);
				if(written != amount) result = false;
			}
		}
		while(result == true && amount == 16000);
		fclose(finput);
		fclose(foutput);
	}
	delete [] buffer;
	return result;
}

bool xFileSystem::IsEndOfFile(size_t fileHandle)
{
	return feof((FILE*)fileHandle);
}

unsigned char xFileSystem::ReadByte(size_t fileHandle)
{
	unsigned char buffer;
	int amount = fread(&buffer, 1, 1, (FILE*)fileHandle);
	return (amount == 1 ? buffer : 0);
}

short xFileSystem::ReadShort(size_t fileHandle)
{
	short buffer;
	int amount = fread(&buffer, 2, 1, (FILE*)fileHandle);
	return (amount == 1 ? buffer : 0);
}

int xFileSystem::ReadInt(size_t fileHandle)
{
	int buffer;
	int amount = fread(&buffer, 4, 1, (FILE*)fileHandle);
	return (amount == 1 ? buffer : 0);
}

float xFileSystem::ReadFloat(size_t fileHandle)
{
	float buffer;
	int amount = fread(&buffer, 4, 1, (FILE*)fileHandle);
	return (amount == 1 ? buffer : 0.0f);
}

const char * xFileSystem::ReadString(size_t fileHandle)
{
	int size;
	int amount = fread(&size, 4, 1, (FILE*)fileHandle);
	if(amount != 1) return "";
	tempString.resize(size + 1);
	amount = fread(&tempString[0], 1, size, (FILE*)fileHandle);
	if(amount != size) return "";
	tempString[size] = '\0';
	return tempString.c_str();
}

const char * xFileSystem::ReadLine(size_t fileHandle)
{
	tempString = "";
	char buffer;
	int amount = fread(&buffer, 1, 1, (FILE*)fileHandle);
	if(amount != 1) return "";
	while(buffer != '\n' && buffer != '\0')
	{
		tempString += buffer;
		amount = fread(&buffer, 1, 1, (FILE*)fileHandle);
		if(amount != 1) return tempString.c_str();
	}
	return tempString.c_str();
}

void * xFileSystem::ReadBytes(size_t fileHandle, unsigned int size)
{
	char * buffer = new char[size];
	int amount = fread(buffer, 1, size, (FILE*)fileHandle);
	if(amount != size)
	{
		delete [] buffer;
		return NULL;
	}
	return buffer;
}

void xFileSystem::WriteByte(size_t fileHandle, unsigned char value)
{
	fwrite(&value, 1, 1, (FILE*)fileHandle);
}

void xFileSystem::WriteShort(size_t fileHandle, short value)
{
	fwrite(&value, 2, 1, (FILE*)fileHandle);
}

void xFileSystem::WriteInt(size_t fileHandle, int value)
{
	fwrite(&value, 4, 1, (FILE*)fileHandle);
}

void xFileSystem::WriteFloat(size_t fileHandle, float value)
{
	fwrite(&value, 4, 1, (FILE*)fileHandle);
}

void xFileSystem::WriteString(size_t fileHandle, const char * value)
{
	int size = strlen(value);
	fwrite(&size, 4, 1, (FILE*)fileHandle);
	fwrite(value, 1, size, (FILE*)fileHandle);
}

void xFileSystem::WriteLine(size_t fileHandle, const char * value)
{
	fwrite(value, 1, strlen(value), (FILE*)fileHandle);
	char endOfLine = '\n';
	fwrite(&endOfLine, 1, 1, (FILE*)fileHandle);
}

void xFileSystem::WriteBytes(size_t fileHandle, void * value, unsigned int size)
{
	fwrite(value, 1, size, (FILE*)fileHandle);
}
