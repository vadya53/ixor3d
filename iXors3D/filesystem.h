//
//  filesystem.h
//  iXors3D
//
//  Created by Knightmare on 15.10.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <iostream>
#import <string>

class xFileSystem
{
private:
#if !TARGET_OS_EMBEDDED && !TARGET_IPHONE_SIMULATOR
	std::string          _filesDirectory;
#endif
	std::string          _homeDirectory;
	std::string          _currentDirectory;
	std::string          _currentAppDirectory;
	static xFileSystem * _instance;
private:
	xFileSystem();
	xFileSystem(const xFileSystem & other);
	xFileSystem & operator=(const xFileSystem & other);
	~xFileSystem();
public:
	static xFileSystem * Instance();
	size_t ReadDirectory(const char * path);
	void CloseDirectory(size_t directory);
	const char * NextFile(size_t directory);
	bool CreateDirectory(const char * path);
	bool DeleteDirectory(const char * path);
	const char * GetCurrentDirectory(bool appDirectory);
	void SetDirectory(const char * path);
	size_t OpenFile(const char * path);
	size_t ReadFile(const char * path);
	size_t WriteFile(const char * path);
	void CloseFile(size_t fileHandle);
	unsigned int GetFilePosition(size_t fileHandle);
	void SeekFile(size_t fileHandle, unsigned int offset);
	int GetFileType(const char * path);
	unsigned int GetFileSize(const char * path);
	bool DeleteFile(const char * path);
	bool CopyFile(const char * pathOriginal, const char * pathNew);
	bool IsEndOfFile(size_t fileHandle);
	unsigned char ReadByte(size_t fileHandle);
	short ReadShort(size_t fileHandle);
	int ReadInt(size_t fileHandle);
	float ReadFloat(size_t fileHandle);
	const char * ReadString(size_t fileHandle);
	const char * ReadLine(size_t fileHandle);
	void * ReadBytes(size_t fileHandle, unsigned int size);
	void WriteByte(size_t fileHandle, unsigned char value);
	void WriteShort(size_t fileHandle, short value);
	void WriteInt(size_t fileHandle, int value);
	void WriteFloat(size_t fileHandle, float value);
	void WriteString(size_t fileHandle, const char * value);
	void WriteLine(size_t fileHandle, const char * value);
	void WriteBytes(size_t fileHandle, void * value, unsigned int size);
	std::string GetRealPath(const char * path);
};