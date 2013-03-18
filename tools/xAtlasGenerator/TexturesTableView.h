//
//  TexturesTableView.h
//  xAtlasGenerator
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/8/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextureItem.h"

@interface TexturesTableView : NSObject<NSTableViewDataSource>
{
	NSMutableArray * itemsList;
	int              index;
}

- (id)init;
- (void)addItem;
- (void)removeItem:(int)itemIndex;
- (int)numberOfRowsInTableView:(NSTableView*)tableView;
- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)tableColumn row:(int)row;
- (TextureItem*)getItem:(int)itemIndex;
- (int)count;
- (void)clear;

@end
