//
//  httprequest.mm
//  iXors3D
//
//  Created by Knightmare on 07.03.10.
//  Copyright 2010 Xors3D Team. All rights reserved.
//

#import "httprequest.h"

// BASE64 implementation
static const char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
char * BASE64OutputString  = NULL;

void EncodeBlock(unsigned char input[3], unsigned char output[4], int length)
{
	output[0] = base64[input[0] >> 2];
	output[1] = base64[((input[0] & 0x03) << 4) | ((input[1] & 0xf0) >> 4)];
	output[2] = (unsigned char)(length > 1 ? base64[((input[1] & 0x0f) << 2) | ((input[2] & 0xc0) >> 6)] : '=');
	output[3] = (unsigned char)(length > 2 ? base64[input[2] & 0x3f] : '=');
}

const char * BASE64Encode(const char * inputString)
{
	if(BASE64OutputString = NULL) delete [] BASE64OutputString;
	BASE64OutputString = new char[strlen(inputString) * 4 / 3 + 7];
	unsigned char input[3];
	unsigned char output[4];
    int length    = 0;
	int symbol    = 0;
	int outSymbol = 0;
    while(inputString[symbol] != '\0')
	{
        length = 0;
        for(int i = 0; i < 3; i++)
		{
            if(inputString[symbol] != '\0')
			{
				input[i] = (unsigned char)inputString[symbol++];
                length++;
            }
            else
			{
                input[i] = 0;
            }
        }
        if(length)
		{
            EncodeBlock(input, output, length);
            for(int i = 0; i < 4; i++) BASE64OutputString[outSymbol++] = output[i];
        }
	}
	BASE64OutputString[outSymbol] = '\0';
	return BASE64OutputString;
}

// =====================

// URLEncode implementation

const char * URLEncode(const char * url)
{
	std::string       result     = "";
	std::string       temp       = "";
	const std::string validChars = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz:/.?=_-$(){}~&";
	if(url != NULL && strlen(url) > 0)
	{
		for(int i = 0; i < strlen(url); i++)
		{
			temp = url[i];
			if(validChars.find_first_of(url[i]) == validChars.npos)
			{
				char buff[8];
				sprintf(buff, "%X", (uint)url[i]);
				temp = buff;
				if(temp == "20")
				{
					temp = "+";
				}
				else if(temp.length() == 1)
				{
					temp = "%0" + temp;
				}
				else
				{
					temp = "%" + temp;
				}
			}
			result += temp;
		}
		return result.c_str();
	}
	return "";
}

// =====================

xHTTPRequest::xHTTPRequest()
{
	_systemRequest   = nil;
	_enableHTTPAuth  = false;
	_enableReferer   = false;
	_enableUserAgent = false;
	_URL             = "";
	_userID          = "";
	_userPassword    = "";
	_referer         = "";
	_userAgent       = "";
}

void xHTTPRequest::Create(const char * url, int timeout, bool cacheble)
{
	_URL = URLEncode(url);
	NSURL * sytemURL = [NSURL URLWithString: [NSString stringWithUTF8String: _URL.c_str()]];
	_systemRequest   = [NSMutableURLRequest requestWithURL:  sytemURL 
										    cachePolicy:     (cacheble ? NSURLRequestReturnCacheDataElseLoad : NSURLRequestReloadIgnoringCacheData)
										    timeoutInterval: timeout];
}

void xHTTPRequest::SetTimeoutInterval(int timeout)
{
	if(_systemRequest == nil) return;
	[_systemRequest setTimeoutInterval: timeout];
}

int xHTTPRequest::GetTimeoutInterval()
{
	if(_systemRequest == nil) return 0;
	return [_systemRequest timeoutInterval];
}

void xHTTPRequest::EnableCaching()
{
	if(_systemRequest == nil) return;
	[_systemRequest setCachePolicy: NSURLRequestReturnCacheDataElseLoad];
}

void xHTTPRequest::DisableCaching()
{
	if(_systemRequest == nil) return;
	[_systemRequest setCachePolicy: NSURLRequestReloadIgnoringCacheData];
}

bool xHTTPRequest::IsCachable()
{
	if(_systemRequest == nil) return false;
	return ([_systemRequest cachePolicy] == NSURLRequestReturnCacheDataElseLoad);
}

const char * xHTTPRequest::GetURL()
{
	if(_systemRequest == nil) return NULL;
	return _URL.c_str();
}

void xHTTPRequest::SetMethod(xRequestMethod method)
{
	if(_systemRequest == nil) return;
	switch(method)
	{
		case REQUEST_GET:  [_systemRequest setHTTPMethod: @"GET"];  break;
		case REQUEST_POST: [_systemRequest setHTTPMethod: @"POST"]; break;
	}
}

xRequestMethod xHTTPRequest::GetMethod()
{
	if(_systemRequest == nil) return REQUEST_UNKNOWN;
	NSString * method = [_systemRequest HTTPMethod];
	if([method compare: @"GET" options: NSCaseInsensitiveSearch] == NSOrderedSame)
	{
		return REQUEST_GET;
	}
	else if([method compare: @"POST" options: NSCaseInsensitiveSearch] == NSOrderedSame)
	{
		return REQUEST_POST;
	}
	return REQUEST_UNKNOWN;
}

void xHTTPRequest::EnableCookies()
{
	if(_systemRequest == nil) return;
	[_systemRequest setHTTPShouldHandleCookies: TRUE];
}

void xHTTPRequest::DisableCookies()
{
	if(_systemRequest == nil) return;
	[_systemRequest setHTTPShouldHandleCookies: FALSE];
}

bool xHTTPRequest::IsHandleCookies()
{
	if(_systemRequest == nil) return false;
	return [_systemRequest HTTPShouldHandleCookies];
}

void xHTTPRequest::SetAuthenticationData(const char * userName, const char * password)
{
	if(userName == NULL || password == NULL)
	{
		_enableHTTPAuth = false;
		return;
	}
	_userID         = userName;
	_userPassword   = password;
	_enableHTTPAuth = _userID.length() > 0;
}

void xHTTPRequest::SetReferer(const char * referer)
{
	if(referer == NULL)
	{
		_enableReferer = false;
		return;
	}
	_referer       = referer;
	_enableReferer = _referer.length() > 0;
}

void xHTTPRequest::SetUserAgent(const char * userAgent)
{
	if(userAgent == NULL)
	{
		_enableUserAgent = false;
		return;
	}
	_userAgent       = userAgent;
	_enableUserAgent = _userAgent.length() > 0;
}

std::vector<xHTTPRequest::HTTPCookie>::iterator xHTTPRequest::FindCookie(const char * name)
{
	std::vector<HTTPCookie>::iterator itr = _cookies.begin();
	while(itr != _cookies.end())
	{
		if((*itr).name == name) return itr;
		itr++;
	}
	return _cookies.end();
}

void xHTTPRequest::AddCookie(const char * name, const char * value)
{
	if(name == NULL || value == NULL) return;
	std::vector<HTTPCookie>::iterator itr = FindCookie(name);
	if(itr != _cookies.end())
	{
		(*itr).value = value;
	}
	else
	{
		_cookies.push_back(HTTPCookie(name, value));
	}
}

void xHTTPRequest::DeleteCookie(const char * name)
{
	if(name == NULL) return;
	std::vector<HTTPCookie>::iterator itr = FindCookie(name);
	if(itr != _cookies.end()) _cookies.erase(itr);
}

void xHTTPRequest::ClearCookies()
{
	_cookies.clear();
}

std::vector<xHTTPRequest::HTTPField>::iterator xHTTPRequest::FindFormFiled(const char * name)
{
	std::vector<HTTPField>::iterator itr = _formFileds.begin();
	while(itr != _formFileds.end())
	{
		if((*itr).name == name) return itr;
		itr++;
	}
	return _formFileds.end();
}

void xHTTPRequest::AddFromField(const char * name, const char * value)
{
	if(name == NULL || value == NULL) return;
	std::vector<HTTPField>::iterator itr = FindFormFiled(name);
	if(itr != _formFileds.end())
	{
		(*itr).value = value;
	}
	else
	{
		_formFileds.push_back(HTTPField(name, value));
	}
}

void xHTTPRequest::DeleteFormField(const char * name)
{
	if(name == NULL) return;
	std::vector<HTTPField>::iterator itr = FindFormFiled(name);
	if(itr != _formFileds.end()) _formFileds.erase(itr);
}

void xHTTPRequest::ClearFormFields()
{
	_formFileds.clear();
}

void xHTTPRequest::UpdateHTTPHeaders()
{
	// HTTP Authorization
	if(_enableHTTPAuth)
	{
		std::string authData = _userID + ":" + _userPassword;
		authData = std::string("Basic ") + BASE64Encode(authData.c_str());
		NSString * fieldValue = [NSString stringWithUTF8String: authData.c_str()];
		[_systemRequest setValue: fieldValue forHTTPHeaderField: @"Authorization"];
	}
	else
	{
		[_systemRequest setValue: @"" forHTTPHeaderField: @"Authorization"];
	}
	// Referer page
	if(_enableReferer)
	{
		NSString * fieldValue = [NSString stringWithUTF8String: _referer.c_str()];
		[_systemRequest setValue: fieldValue forHTTPHeaderField: @"Referer"];
	}
	else
	{
		[_systemRequest setValue: @"" forHTTPHeaderField: @"Referer"];
	}
	// User agent
	if(_enableUserAgent)
	{
		NSString * fieldValue = [NSString stringWithUTF8String: _userAgent.c_str()];
		[_systemRequest setValue: fieldValue forHTTPHeaderField: @"User-Agent"];
	}
	else
	{
		[_systemRequest setValue: @"" forHTTPHeaderField: @"User-Agent"];
	}
	// Cookies
	std::string value = "";
	for(int i = 0; i < _cookies.size(); i++)
	{
		if(i == 0)
		{
			value = _cookies[i].name + "=" + _cookies[i].value;
		}
		else
		{
			value += "; " + _cookies[i].name + "=" + _cookies[i].value;
		}
	}
	NSString * fieldValue = [NSString stringWithUTF8String: value.c_str()];
	[_systemRequest setValue: fieldValue forHTTPHeaderField: @"Cookie"];
	// Form data
	if(_formFileds.size() > 0)
	{
		xRequestMethod method = GetMethod();
		if(method == REQUEST_GET)
		{
			std::string url  = _URL;
			bool fieldsInURL = url.find_last_of('?') != url.npos;
			for(int i = 0; i < _formFileds.size(); i++)
			{
				if(i == 0 && !fieldsInURL)
				{
					url += "?" + _formFileds[i].name + "=" + _formFileds[i].value;
				}
				else
				{
					url += "&" + _formFileds[i].name + "=" + _formFileds[i].value;
				}
			}
			url = URLEncode(url.c_str());
			[_systemRequest setURL: [NSURL URLWithString: [NSString stringWithUTF8String: url.c_str()]]];
		}
		else if(method == REQUEST_POST)
		{
			static std::string borderValue = "110F1BE7D467ABEF0A5";
			std::string body = "";
			for(int i = 0; i < _formFileds.size(); i++)
			{
				body += "--" + borderValue + "\r\n";
				body += "Content-Disposition: form-data; name=\"" + _formFileds[i].name + "\"\r\n\r\n";
				body += _formFileds[i].value + "\r\n";
			}
			body += "--" + borderValue + "--\r\n";
			char buff[32];
			sprintf(buff, "%i", (int)body.length());
			[_systemRequest setValue: @"multipart/form-data; boundary=110F1BE7D467ABEF0A5" forHTTPHeaderField: @"Content-Type"];
			[_systemRequest setValue: [NSString stringWithUTF8String: buff] forHTTPHeaderField: @"Content-Length"];
			[[_systemRequest HTTPBody] release];
			[_systemRequest setHTTPBody: [NSData dataWithBytes: &body[0] length: body.length()]];
		}
	}
}

NSMutableURLRequest * xHTTPRequest::GetSystemRequest()
{
	return _systemRequest;
}