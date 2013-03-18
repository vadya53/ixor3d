//
//  netclient.h
//  iXors3D
//
//  Created by Knightmare on 13.03.10.
//  Copyright 2010 Xors3D Team. All rights reserved.
//

#import <string>

class xNetClient
{
public:
	unsigned int identifier;
	std::string  address;
	std::string  name;
	int          socket;
public:
	xNetClient();
	~xNetClient();
};