//
//  netmanager.mm
//  iXors3D
//
//  Created by Knightmare on 30.12.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "netmanager.h"
#import <algorithm>
#import <sys/socket.h>
#import <netinet/in.h>

xNetworkManager * xNetworkManager::_instance = NULL;

xNetworkManager::xNetworkManager()
{
	_mutex        = [[NSObject alloc] init];
	_serverName   = "";
	_connectionCS = NULL;
	_lastClient   = 1;
}

xNetworkManager::xNetworkManager(const xNetworkManager & other)
{
}

xNetworkManager & xNetworkManager::operator=(const xNetworkManager & other)
{
	return *this;
}

xNetworkManager::~xNetworkManager()
{
}

xNetworkManager * xNetworkManager::Instance()
{
	if(_instance == NULL) _instance = new xNetworkManager();
	return _instance;
}

xHTTPResponse * xNetworkManager::FindResponse(NSURLConnection * connection)
{
	@synchronized(_mutex)
	{
		std::vector<xHTTPResponse*>::iterator itr = _connections.begin();
		while(itr != _connections.end())
		{
			if((*itr)->connection == connection) return (*itr);
			itr++;
		}
		return NULL;
	}
	return NULL;
}

xHTTPResponse * xNetworkManager::SendHTTPRequest(xHTTPRequest * request, bool async)
{
	@synchronized(_mutex)
	{
		xHTTPResponse * newResponse = new xHTTPResponse(request, async);
		_connections.push_back(newResponse);
		return newResponse;
	}
	return NULL;
}

void xNetworkManager::ClearResponses()
{
	@synchronized(_mutex)
	{
		std::vector<xHTTPResponse*>::iterator itr = _connections.begin();
		while(itr != _connections.end())
		{
			delete (*itr);
			itr++;
		}
		_connections.clear();
	}
}

void xNetworkManager::DeleteResponse(xHTTPResponse * response)
{
	@synchronized(_mutex)
	{
		std::vector<xHTTPResponse*>::iterator itr = std::find(_connections.begin(), _connections.end(), response);
		if(itr != _connections.end()) _connections.erase(itr);
		delete response;
	}
}

void xNetworkManager::CloseConnection()
{
}

bool xNetworkManager::CreateServer(int port, int protocol, const char * serverName, const char * userName)
{
	if(_connectionCS != NULL) CloseConnection();
	_lastClient               = 1;
	_serverName               = serverName;
	_connectionCS             = new xNetClient();
	_connectionCS->identifier = _lastClient++;
	_connectionCS->name       = userName;
	_connectionCS->address    = "127.0.0.1";
	_connectionCS->socket     = socket(AF_INET, protocol == 1 ? SOCK_DGRAM : SOCK_STREAM, 0);
	if(_connectionCS->socket < 0)
	{
		printf("ERROR(%s:%i): Unable to create socket for server.", __FILE__, __LINE__);
		CloseConnection();
		return false;
	}
	sockaddr_in address;
	address.sin_family      = AF_INET;
    address.sin_port        = htons(port);
    address.sin_addr.s_addr = htonl(INADDR_ANY);
    if(bind(_connectionCS->socket, (struct sockaddr *)&address, sizeof(address)) < 0)
	{
		printf("ERROR(%s:%i): Unable to bind socket for server.", __FILE__, __LINE__);
		CloseConnection();
		return false;
	}
	if(listen(_connectionCS->socket, 16) < 0)
	{
		printf("ERROR(%s:%i): Unable to listen socket for server.", __FILE__, __LINE__);
		CloseConnection();
		return false;
	}
	return true;
}