//
//  httpdelegate.mm
//  iXors3D
//
//  Created by Knightmare on 09.03.10.
//  Copyright 2010 Xors3D Team. All rights reserved.
//

#import "httpdelegate.h"
#import "netmanager.h"

xHTTPDelegate * delegateInstance = nil;

@implementation xHTTPDelegate

+(xHTTPDelegate*)Instance
{
	if(delegateInstance == nil) delegateInstance = [[xHTTPDelegate alloc] init];
	return delegateInstance;
}

-(void)connection: (NSURLConnection*)connection didFailWithError: (NSError*)error
{
	xHTTPResponse * response = xNetworkManager::Instance()->FindResponse(connection);
	if(response == NULL) return;
	response->state     = STATE_ERROR;
	response->errorCode = [error code];
	response->errorText = [[error localizedDescription] UTF8String];
	response->lenght    = 0;
	response->mimeType  = "";
	response->data      = NULL;
}

-(void)connectionDidFinishLoading: (NSURLConnection*)connection
{
	xHTTPResponse * response = xNetworkManager::Instance()->FindResponse(connection);
	if(response == NULL) return;
	response->state = STATE_DONE;
}

-(void)connection: (NSURLConnection*)connection didReceiveResponse: (NSURLResponse*)response
{
	xHTTPResponse * xresponse = xNetworkManager::Instance()->FindResponse(connection);
	if(xresponse == NULL) return;
	if(response != nil) xresponse->mimeType = [[response MIMEType] UTF8String];
}

-(void)connection: (NSURLConnection*)connection didReceiveData: (NSData*)data
{
	xHTTPResponse * response = xNetworkManager::Instance()->FindResponse(connection);
	if(response == NULL) return;
	char * newData = new char[data.length + response->lenght];
	if(response->data != NULL) memcpy(newData, response->data, response->lenght);
	memcpy(&newData[response->lenght], data.bytes, data.length);
	if(response->data != NULL) free(response->data);
	response->data = newData;
}

-(void)connection: (NSURLConnection*)connection didSendBodyData: (NSInteger)bytesWritten totalBytesWritten: (NSInteger)totalBytesWritten totalBytesExpectedToWrite: (NSInteger)totalBytesExpectedToWrite
{
}

-(NSURLRequest*)connection: (NSURLConnection*)connection  willSendRequest: (NSURLRequest*)request redirectResponse: (NSURLResponse*)redirectResponse
{
	return request;
}

-(NSCachedURLResponse*)connection: (NSURLConnection*)connection  willCacheResponse: (NSCachedURLResponse*)cachedResponse
{
	return cachedResponse;
}

@end
