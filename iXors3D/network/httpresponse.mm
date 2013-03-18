//
//  httpresponse.mm
//  iXors3D
//
//  Created by Knightmare on 09.03.10.
//  Copyright 2010 Xors3D Team. All rights reserved.
//

#import "httpresponse.h"
#import "httpdelegate.h"

xHTTPResponse::xHTTPResponse(xHTTPRequest * request, bool async)
{
	connection = nil;
	state      = STATE_UNKNOWN;
	lenght     = 0;
	mimeType   = "";
	data       = NULL;
	errorCode  = 0;
	errorText  = "";
	request->UpdateHTTPHeaders();
	if(async)
	{
		state      = STATE_GETTING;
		connection = [NSURLConnection connectionWithRequest: request->GetSystemRequest()
												   delegate: [xHTTPDelegate Instance]];
	}
	else
	{
		NSURLResponse * response;
		NSData * nsdata = [NSURLConnection sendSynchronousRequest: request->GetSystemRequest()
												returningResponse: &response 
															error: nil];
		if(nsdata == nil) 
		{
			printf("ERROR(%s:%i): Unable to get data from URL: '%s'\n", __FILE__, __LINE__, request->GetURL());
			return;
		}
		connection = nil;
		state      = STATE_DONE;
		lenght     = [nsdata length];
		if(response != nil) mimeType   = [[response MIMEType] UTF8String];
		data       = new char[lenght];
		memcpy(data, [nsdata bytes], [nsdata length]);
	}
}

xHTTPResponse::~xHTTPResponse()
{
	free(data);
}