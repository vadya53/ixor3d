//
//  httprequest.h
//  iXors3D
//
//  Created by Knightmare on 07.03.10.
//  Copyright 2010 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <string>
#import <vector>

enum xRequestMethod
{
	REQUEST_UNKNOWN = 0,
	REQUEST_GET     = 1,
	REQUEST_POST    = 2
};

class xHTTPRequest
{
private:
	struct HTTPCookie
	{
		std::string name;
		std::string value;
		HTTPCookie(const char * _name, const char * _value)
		{
			name  = _name;
			value = _value;
		}
	};
	struct HTTPField
	{
		std::string name;
		std::string value;
		HTTPField(const char * _name, const char * _value)
		{
			name  = _name;
			value = _value;
		}
	};
private:
	NSMutableURLRequest     * _systemRequest;
	bool                      _enableHTTPAuth, _enableReferer, _enableUserAgent;
	std::string               _URL, _userID, _userPassword, _referer, _userAgent;
	std::vector<HTTPCookie>   _cookies;
	std::vector<HTTPField>    _formFileds;
private:
	std::vector<HTTPCookie>::iterator FindCookie(const char * name);
	std::vector<HTTPField>::iterator FindFormFiled(const char * name);
public:
	xHTTPRequest();
	void Create(const char * url, int timeout = 60, bool cacheble = false);
	void SetTimeoutInterval(int timeout);
	int GetTimeoutInterval();
	void EnableCaching();
	void DisableCaching();
	bool IsCachable();
	const char * GetURL();
	void SetMethod(xRequestMethod method);
	xRequestMethod GetMethod();
	void EnableCookies();
	void DisableCookies();
	bool IsHandleCookies();
	void SetAuthenticationData(const char * userName, const char * password);
	void SetReferer(const char * referer);
	void SetUserAgent(const char * userAgent);
	void AddCookie(const char * name, const char * value);
	void DeleteCookie(const char * name);
	void ClearCookies();
	void AddFromField(const char * name, const char * value);
	void DeleteFormField(const char * name);
	void ClearFormFields();
	void UpdateHTTPHeaders();
	NSMutableURLRequest * GetSystemRequest();
};