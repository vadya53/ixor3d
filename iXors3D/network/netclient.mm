//
//  netclient.mm
//  iXors3D
//
//  Created by Knightmare on 13.03.10.
//  Copyright 2010 Xors3D Team. All rights reserved.
//

#import "netclient.h"
#import <sys/socket.h>

xNetClient::xNetClient()
{
	identifier = 0;
	address    = "0.0.0.0";
	name       = "";
	socket     = -1;
}

xNetClient::~xNetClient()
{
	if(socket >= 0) close(socket);
	identifier = 0;
	address    = "0.0.0.0";
	name       = "";
	socket     = -1;
}
