//
//  netmanager.h
//  iXors3D
//
//  Created by Knightmare on 30.12.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "httprequest.h"
#import "httpresponse.h"
#import <vector>
#import "netclient.h"

class xNetworkManager
{
private:
	NSObject                    * _mutex;
	static xNetworkManager      * _instance;
	std::vector<xHTTPResponse*>   _connections;
	std::string                   _serverName;
	xNetClient                  * _connectionCS;
	std::vector<xNetClient*>      _clients;
	uint                          _lastClient;
private:
	xNetworkManager();
	xNetworkManager(const xNetworkManager & other);
	xNetworkManager & operator=(const xNetworkManager & other);
	~xNetworkManager();
public:
	static xNetworkManager * Instance();
	xHTTPResponse * SendHTTPRequest(xHTTPRequest * request, bool async = true);
	xHTTPResponse * FindResponse(NSURLConnection * connection);
	void ClearResponses();
	void DeleteResponse(xHTTPResponse * response);
	bool CreateServer(int port, int protocol, const char * serverName, const char * userName);
	void CloseConnection();
};