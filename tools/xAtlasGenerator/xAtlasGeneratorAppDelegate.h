//
//  xAtlasGeneratorAppDelegate.h
//  xAtlasGenerator
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/7/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TexturesTableView.h"
#import "TexturesTableDelegate.h"
#import "textureatlas.h"

@interface xAtlasGeneratorAppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow              * window;
	NSButton              * addButton;
	NSButton              * removeButton;
	NSTableView           * texturesList;
	TexturesTableView     * texturesTable;
	TexturesTableDelegate * texturesDelegate;
	int                     activeItem;
	NSTextField           * pathField;
	NSTextField           * nameField;
	NSTextField           * widthField;
	NSTextField           * heightField;
	NSTextField           * framesField;
	NSButton              * pathButton;
	NSStepper             * framesStepper;
	NSImageView           * atlasPreview;
	xTextureAtlas         * atlas;
	NSMenuItem            * exportItem;
	NSString              * currentProject;
	NSPanel               * previewPanel;
	NSImageView           * previewPanelView;
	NSButton              * getNameButton;
}

@property (assign) IBOutlet NSWindow    * window;
@property (assign) IBOutlet NSButton    * addButton;
@property (assign) IBOutlet NSButton    * removeButton;
@property (assign) IBOutlet NSTableView * texturesList;
@property (assign) IBOutlet NSTextField * pathField;
@property (assign) IBOutlet NSTextField * nameField;
@property (assign) IBOutlet NSTextField * widthField;
@property (assign) IBOutlet NSTextField * heightField;
@property (assign) IBOutlet NSTextField * framesField;
@property (assign) IBOutlet NSButton    * pathButton;
@property (assign) IBOutlet NSStepper   * framesStepper;
@property (assign) IBOutlet NSImageView * atlasPreview;
@property (assign) IBOutlet NSMenuItem  * exportItem;
@property (assign) IBOutlet NSPanel     * previewPanel;
@property (assign) IBOutlet NSImageView * previewPanelView;
@property (assign) IBOutlet NSButton    * getNameButton;

- (IBAction)clickGenerate:(NSButton*)button;
- (IBAction)clickAdd:(NSButton*)button;
- (IBAction)clickRemove:(NSButton*)button;
- (IBAction)clickPath:(NSButton*)button;
- (IBAction)clickPreview:(NSButton*)button;
- (IBAction)clickGetName:(NSButton*)button;
- (void)changeItem:(int)index;
- (void)textDidChange:(NSNotification*)notification;
- (BOOL)validateString:(NSString*)string;
- (IBAction)saveDocument:(NSMenuItem*)item;
- (IBAction)saveDocumentAs:(NSMenuItem*)item;
- (IBAction)newDocument:(NSMenuItem*)item;
- (IBAction)openDocument:(NSMenuItem*)item;
- (IBAction)generateAtlas:(NSMenuItem*)item;
- (IBAction)revertDocument:(NSMenuItem*)item;
- (void)saveAtlas:(NSString*)path;
- (void)saveProject:(NSString*)path;
- (void)loadProject:(NSString*)path;
- (void)clearProject;
- (NSString*)readString:(void*)file;
- (BOOL)application:(NSApplication*)application openFile:(NSString*)path;
- (IBAction)stepperClicked:(NSStepper*)button;

@end
