//
//  GCPlayer.h
//  iXors3D
//
//  Created by Fadeev 'Knightmare' Dmitry on 2/16/11.
//  Copyright 2011 XorsTeam. All rights reserved.
//

//#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR

#import <Foundation/Foundation.h>
#import <string>
#import <vector>

@interface GCPlayerHandler : NSObject
{
}

- (void)authenticationChanged;

@end

struct GCPlayer
{
	std::string name;
	std::string playerID;
	GCPlayer()
	{
		name     = "";
		playerID = "";
	}
};

class xPlayerManager
{
private:
	static xPlayerManager * _instance;
	bool                    _gcSupported;
	GCPlayerHandler       * _playerHandler;
	bool                    _logedIn;
	bool                    _userChanged;
	GCPlayer                _player;
	std::vector<GCPlayer>   _friends;
private:
	xPlayerManager();
	~xPlayerManager();
	xPlayerManager(const xPlayerManager & other);
	xPlayerManager & operator=(const xPlayerManager & other);
public:
	static xPlayerManager * Instance();
	bool IsGCSupported();
	bool Authenticate();
	void LoadLocalPlayer();
	bool IsLogedIn();
	GCPlayer GetPlayerInfo();
	int GetFriendsCount();
	GCPlayer GetFriendInfo(int index);
};

//#endif