//
//  GCPlayer.mm
//  iXors3D
//
//  Created by Fadeev 'Knightmare' Dmitry on 2/16/11.
//  Copyright 2011 XorsTeam. All rights reserved.
//

#import "GCPlayer.h"

//#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR

#import <GameKit/GameKit.h>

@implementation GCPlayerHandler

- (void)authenticationChanged
{
	if([GKLocalPlayer localPlayer].isAuthenticated)
	{
		xPlayerManager::Instance()->LoadLocalPlayer();
	}
	else
	{
	}
}

@end

xPlayerManager * xPlayerManager::_instance = NULL;

xPlayerManager::xPlayerManager()
{
	// check if Game Center supported
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    BOOL osVersionSupported = ([[[UIDevice currentDevice] systemVersion] compare: @"4.1" options: NSNumericSearch] != NSOrderedAscending);
    _gcSupported = (gcClass && osVersionSupported);
	// create player handler
	_playerHandler = [[GCPlayerHandler alloc] init];
	//
	_logedIn     = false;
	_userChanged = false;
}

xPlayerManager::~xPlayerManager()
{
}

xPlayerManager::xPlayerManager(const xPlayerManager & other)
{
}

xPlayerManager & xPlayerManager::operator=(const xPlayerManager & other)
{
	return *this;
}

xPlayerManager * xPlayerManager::Instance()
{
	if(_instance == NULL) _instance = new xPlayerManager();
	return _instance;
}

bool xPlayerManager::IsGCSupported()
{
	return _gcSupported;
}

void xPlayerManager::LoadLocalPlayer()
{
	if(!_gcSupported) return;
	static GKPlayer * currFriend = NULL;
	static GCPlayer newFriend;
	GKLocalPlayer * player = [GKLocalPlayer localPlayer];
	if(player.authenticated)
	{
		_logedIn         = true;
		_player.name     = [player.alias UTF8String];
		_player.playerID = [player.playerID UTF8String];
		_friends.clear();
		[player loadFriendsWithCompletionHandler: ^(NSArray * friends, NSError * error)
		{
			if(error == nil)
			{
				[GKPlayer loadPlayersForIdentifiers: friends withCompletionHandler: ^(NSArray * players, NSError * error)
				{
					if(error == nil)
					{
						for(currFriend in players)
						{
							newFriend.name     = [currFriend.alias UTF8String];
							newFriend.playerID = [currFriend.playerID UTF8String];
							_friends.push_back(newFriend);
						}
					}
				}
				];
			}
		}];
	}
	else
	{
		_logedIn         = false;
		_player.name     = "";
		_player.playerID = "";
		_friends.clear();
	}
}

bool xPlayerManager::Authenticate()
{
	if(!_gcSupported) return false;
	static bool authSuccess = false;
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler: ^(NSError * error)
	{
		if (error == nil)
		{
			// register your changing
			[[NSNotificationCenter defaultCenter] addObserver: _playerHandler
													 selector: @selector(authenticationChanged)
														 name: GKPlayerAuthenticationDidChangeNotificationName
													   object: nil];
			// loads player info
			LoadLocalPlayer();
			authSuccess = true;
		}
		else
		{
			authSuccess = false;
		}
	}];
	return authSuccess;
}

bool xPlayerManager::IsLogedIn()
{
	return _logedIn;
}

GCPlayer xPlayerManager::GetPlayerInfo()
{
	return _player;
}

int xPlayerManager::GetFriendsCount()
{
	return _friends.size();
}

GCPlayer xPlayerManager::GetFriendInfo(int index)
{
	if(index < 0 || index >= _friends.size()) return GCPlayer();
	return _friends[index];
}

//#endif