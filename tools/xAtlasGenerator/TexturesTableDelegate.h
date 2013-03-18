//
//  TexturesTableDelegate.h
//  xAtlasGenerator
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/8/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TexturesTableDelegate : NSObject<NSTableViewDelegate>
{
	id applicationDelegate;
}

- (id)init:(id)appDelegate;
- (BOOL)tableView:(NSTableView*)aTableView shouldEditTableColumn:(NSTableColumn*)aTableColumn row:(NSInteger)rowIndex;
- (BOOL)tableView:(NSTableView*)aTableView shouldSelectRow:(NSInteger)rowIndex;

@end
