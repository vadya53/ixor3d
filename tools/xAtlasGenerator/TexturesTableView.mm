//
//  TexturesTableView.m
//  xAtlasGenerator
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/8/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "TexturesTableView.h"
#import "xAtlasGeneratorAppDelegate.h"

@implementation TexturesTableView

- (id)init;
{
	[super init];
	itemsList = [[NSMutableArray alloc] init];
	index     = 1;
	return self;
}

- (void)addItem
{
	TextureItem * item = [[TextureItem alloc] init];
	[item setImageName: [NSString stringWithFormat: @"Image%i", index]];
	[itemsList addObject: item];
	index++;
}

- (void)removeItem:(int)itemIndex
{
	[itemsList removeObjectAtIndex: itemIndex];
}

- (int)numberOfRowsInTableView:(NSTableView*)tableView
{
	return [itemsList count];
}

- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)tableColumn row:(int)row
{
	if([[tableColumn identifier] isEqualToString: @"idIndex"])
	{
		return [NSString stringWithFormat: @"%i", row + 1];
	}
	else if([[tableColumn identifier] isEqualToString: @"idFileName"])
	{
		NSString * path = [[itemsList objectAtIndex: row] fileName];
		NSArray * tokens = [path componentsSeparatedByString: @"/"];
		if([tokens count] == 0) return @"";
		return [tokens objectAtIndex: [tokens count] - 1];
	}
	else if([[tableColumn identifier] isEqualToString: @"idImageName"])
	{
		return [[itemsList objectAtIndex: row] imageName];
	}
	return @"";
}

- (TextureItem*)getItem:(int)itemIndex
{
	return [itemsList objectAtIndex: itemIndex];
}

- (int)count
{
	return [itemsList count];
}

- (void)clear
{
	[itemsList removeAllObjects];
	index = 0;
}

@end
