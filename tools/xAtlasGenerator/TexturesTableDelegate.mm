//
//  TexturesTableDelegate.m
//  xAtlasGenerator
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/8/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "TexturesTableDelegate.h"
#import "xAtlasGeneratorAppDelegate.h"

@implementation TexturesTableDelegate

- (id)init:(id)appDelegate
{
	[super init];
	applicationDelegate = appDelegate;
	return self;
}

- (BOOL)tableView:(NSTableView*)aTableView shouldEditTableColumn:(NSTableColumn*)aTableColumn row:(NSInteger)rowIndex
{
	return NO;
}

- (BOOL)tableView:(NSTableView*)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	[((xAtlasGeneratorAppDelegate*)applicationDelegate) changeItem: rowIndex];
	return YES;
}

@end
