//
//  httpdelegate.h
//  iXors3D
//
//  Created by Knightmare on 09.03.10.
//  Copyright 2010 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "httpresponse.h"

@interface xHTTPDelegate : NSObject
{
}

+(xHTTPDelegate*)Instance;
-(void)connection: (NSURLConnection*)connection didFailWithError: (NSError*)error;
-(void)connectionDidFinishLoading: (NSURLConnection*)connection;
-(void)connection: (NSURLConnection*)connection didReceiveResponse: (NSURLResponse*)response;
-(void)connection: (NSURLConnection*)connection didReceiveData: (NSData*)data;
-(void)connection: (NSURLConnection*)connection didSendBodyData: (NSInteger)bytesWritten totalBytesWritten: (NSInteger)totalBytesWritten totalBytesExpectedToWrite: (NSInteger)totalBytesExpectedToWrite;
-(NSURLRequest*)connection: (NSURLConnection*)connection  willSendRequest: (NSURLRequest*)request redirectResponse: (NSURLResponse*)redirectResponse;
-(NSCachedURLResponse*)connection: (NSURLConnection*)connection  willCacheResponse: (NSCachedURLResponse*)cachedResponse;

@end
