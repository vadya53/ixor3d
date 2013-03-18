//
//  httpresponse.h
//  iXors3D
//
//  Created by Knightmare on 09.03.10.
//  Copyright 2010 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "httprequest.h"

enum xHTTPRequestState
{
	STATE_UNKNOWN = 0,
	STATE_GETTING = 1,
	STATE_DONE    = 2,
	STATE_IDLE    = 3,
	STATE_ERROR   = 4
};

class xHTTPResponse
{
public:
	NSURLConnection   * connection;
	xHTTPRequestState   state;
	unsigned int        lenght;
	std::string         mimeType;
	void              * data;
	int                 errorCode;
	std::string         errorText;
public:
	xHTTPResponse(xHTTPRequest * request, bool async);
	~xHTTPResponse();
};