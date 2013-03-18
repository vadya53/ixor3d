//
//  xAtlasGeneratorAppDelegate.m
//  xAtlasGenerator
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/7/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "xAtlasGeneratorAppDelegate.h"
#import <vector>
#import <iostream>
#import <stdio.h>

@implementation xAtlasGeneratorAppDelegate

@synthesize window;
@synthesize addButton;
@synthesize removeButton;
@synthesize texturesList;
@synthesize pathField;
@synthesize nameField;
@synthesize widthField;
@synthesize heightField;
@synthesize framesField;
@synthesize pathButton;
@synthesize framesStepper;
@synthesize atlasPreview;
@synthesize exportItem;
@synthesize previewPanel;
@synthesize previewPanelView;
@synthesize getNameButton;

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
	// center window
	[window center];
	// disable table view features
	[texturesList setAllowsColumnResizing: NO];
	[texturesList setAllowsColumnReordering: NO];
	[texturesList setAllowsColumnSelection: NO];
	[texturesList setAllowsEmptySelection: NO];
	// set table view delegate
	texturesDelegate = [[TexturesTableDelegate alloc] init: self];
	[texturesList setDelegate: texturesDelegate];
	// create table holder object
	texturesTable = [[TexturesTableView alloc] init];
	activeItem = -1;
	// register observers for text fields editing notifications
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(textDidChange:)
												 name: NSControlTextDidChangeNotification 
											   object: nameField];
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(textDidChange:)
												 name: NSControlTextDidChangeNotification 
											   object: widthField];
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(textDidChange:)
												 name: NSControlTextDidChangeNotification 
											   object: heightField];
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(textDidChange:)
												 name: NSControlTextDidChangeNotification 
											   object: framesField];
	// create atlas
	atlas = new xTextureAtlas();
	// set current project path
	currentProject = @"";
	[exportItem setEnabled: NO];
	framesStepper.intValue = 1;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (IBAction)stepperClicked:(NSStepper*)button
{
	// check active item index
	if(activeItem < 0) return;
	// getting item from holder
	TextureItem * item = [texturesTable getItem: activeItem];
	[item setFrames: [button intValue]];
	[framesField setStringValue: [NSString stringWithFormat: @"%i", [item frames]]];
	// reload data to the table view
	[texturesList setDataSource: texturesTable];
	[texturesList reloadData];
}

- (void)textDidChange:(NSNotification*)notification
{
	// check active item index
	if(activeItem < 0) return;
	// getting item from holder
	TextureItem * item = [texturesTable getItem: activeItem];
	// if image name edited
	if([notification object] == nameField)
	{
		[item setImageName: [[notification object] stringValue]];
	}
	// if frame width edited
	else if([notification object] == widthField)
	{
		// save value if entered text is number
		if([self validateString: [[notification object] stringValue]])
		{
			[item setFrameWidth: [[[notification object] stringValue] intValue]];
		}
		// revert to saved values otherwise
		else
		{
			[[notification object] setStringValue: [NSString stringWithFormat: @"%i", [item frameWidth]]];
		}
	}
	// if frame height edited
	else if([notification object] == heightField)
	{
		// save value if entered text is number
		if([self validateString: [[notification object] stringValue]])
		{
			[item setFrameHeight: [[[notification object] stringValue] intValue]];
		}
		// revert to saved values otherwise
		else
		{
			[[notification object] setStringValue: [NSString stringWithFormat: @"%i", [item frameHeight]]];
		}
	}
	// if frames count edited
	else if([notification object] == framesField)
	{
		printf("frames changed!\n");
		// save value if entered text is number
		if([self validateString: [[notification object] stringValue]])
		{
			[item setFrames: [[[notification object] stringValue] intValue]];
			framesStepper.intValue = [[[notification object] stringValue] intValue];
		}
		// revert to saved values otherwise
		else
		{
			[[notification object] setStringValue: [NSString stringWithFormat: @"%i", [item frames]]];
		}
	}
	// reload data to the table view
	[texturesList setDataSource: texturesTable];
	[texturesList reloadData];
}

- (BOOL)validateString:(NSString*)string
{
	// convert string to integer
	int value = [string intValue];
	// convert integer value back to string and compare with original
	return [string isEqualToString: [NSString stringWithFormat: @"%i", value]];
}

- (IBAction)clickGenerate:(NSButton*)button
{
	// alert if here is no any image in the list
	if([texturesTable count] == 0)
	{
		CFUserNotificationDisplayAlert(0, kCFUserNotificationCautionAlertLevel,
									   NULL, NULL, NULL, CFSTR("Atlas generation"),
									   CFSTR("No images found in the list."),
									   NULL, NULL, NULL, NULL);
		return;
	}
	// find images with empty texture paths
	BOOL hasEmpty = NO;
	for(int i = 0; i < [texturesTable count]; i++)
	{
		TextureItem * item = [texturesTable getItem: i];
		if([[item fileName] isEqualToString: @""])
		{
			hasEmpty = YES;
			break;
		}
	}
	// question if images with empty textures paths founded
	if(hasEmpty)
	{
		CFOptionFlags result;
		CFUserNotificationDisplayAlert(0, kCFUserNotificationCautionAlertLevel,
									   NULL, NULL, NULL, CFSTR("Atlas generation"),
									   CFSTR("Images with empty file paths founded in the list.\nContinue anyway? All empty textures will be lost."),
									   CFSTR("No"), CFSTR("Yes"), NULL, &result);
		if(result == kCFUserNotificationDefaultResponse) return;
	}
	// reset atlas
	atlas->Initialize();
	// array for CGImages instances
	std::vector<CGImageRef> cgImagesArray;
	// loop around all images in the list
	for(int i = 0; i < [texturesTable count]; i++)
	{
		// getting item from holder
		TextureItem * item = [texturesTable getItem: i];
		// clear frames image data for item
		[item clearImages];
		// if item has valid file name
		if([[item fileName] isEqualToString: @""] == NO)
		{
			// load NSImage from the file
			NSImage * image = [[NSImage alloc] initWithContentsOfFile: [item fileName]];
			// if image loading failed
			if(image == NULL)
			{
				CFUserNotificationDisplayAlert(0, kCFUserNotificationStopAlertLevel,
											   NULL, NULL, NULL, CFSTR("Atlas generation"),
											   CFStringCreateWithFormat(NULL, NULL, CFSTR("Unable to open image from the file '%@'.\nAtlas generation cancelled."), [item fileName]),
											   NULL, NULL, NULL, NULL);
				return;
			}
			// convert NSImage to CGImage
			CGImageRef cgImageFull = [image CGImageForProposedRect: NULL context: NULL hints: NULL];
			// in conversion failed
			if(cgImageFull == NULL)
			{
				CFUserNotificationDisplayAlert(0, kCFUserNotificationStopAlertLevel,
											   NULL, NULL, NULL, CFSTR("Atlas generation"),
											   CFStringCreateWithFormat(NULL, NULL, CFSTR("Unable to convert image to CGImage for the file '%@'.\nAtlas generation cancelled."), [item fileName]),
											   NULL, NULL, NULL, NULL);
				return;
			}
			// compute frames in image strip
			int framesInStrip = CGImageGetWidth(cgImageFull) / [item frameWidth];
			// extract all frames from the image
			for(int j = 0; j < [item frames]; j++)
			{
				// compute coordinates
				int x = (j % framesInStrip) * [item frameWidth];
				int y = (j / framesInStrip) * [item frameHeight];
				// create frame rect
				CGRect rect = CGRectMake(x, y, [item frameWidth], [item frameHeight]);
				// extract rect from the image
				CGImageRef cgImage = CGImageCreateWithImageInRect(cgImageFull, rect);
				// if extraction failed
				if(cgImage == NULL)
				{
					CFUserNotificationDisplayAlert(0, kCFUserNotificationStopAlertLevel,
												   NULL, NULL, NULL, CFSTR("Atlas generation"),
												   CFStringCreateWithFormat(NULL, NULL, CFSTR("Unable to exctarct image frame %i for the file '%@'.\nAtlas generation cancelled."), j + 1, [item fileName]),
												   NULL, NULL, NULL, NULL);
					return;
				}
				// add image to the array, atlas and item frames list
				cgImagesArray.push_back(cgImage);
				if(!atlas->AddTexture(cgImage, j))
				{
					CFUserNotificationDisplayAlert(0, kCFUserNotificationStopAlertLevel,
												   NULL, NULL, NULL, CFSTR("Atlas generation"),
												   CFStringCreateWithFormat(NULL, NULL, CFSTR("Unable to add image frame %i for the file '%@' into the atlas.\nAtlas generation cancelled."), j + 1, [item fileName]),
												   NULL, NULL, NULL, NULL);
					return;
				}
				[item addImage: cgImage];
			}
			// release image
			CGImageRelease(cgImageFull);
		}
	}
	// getting result atlas image
	CGImageRef resultTexture = atlas->GetTexture();
	// convert it to the NSImage
	NSSize size;
	size.width  = CGImageGetWidth(resultTexture);
	size.height = CGImageGetHeight(resultTexture);
	NSImage * preview = [[NSImage alloc] initWithCGImage: resultTexture size: size];
	// set to preview
	[atlasPreview setImage: preview];
	[previewPanelView setImage: preview];
	// release all CGImages
	for(int i = 0; i < cgImagesArray.size(); i++)
	{
		CGImageRelease(cgImagesArray[i]);
	}
}

- (IBAction)clickPreview:(NSButton*)button
{
	// check atlas image
	if([atlasPreview image] == nil) return;
	// resize preview frame
	NSRect rect;
	rect.origin.x    = 0;
	rect.origin.y    = 0;
	rect.size.width  = atlas->GetWidth();
	rect.size.height = atlas->GetHeight();
	[previewPanel setFrame: rect display: YES];
	// center it
	[previewPanel center];
	// show
	[previewPanel makeKeyAndOrderFront: self];
}

- (IBAction)clickGetName:(NSButton*)button
{
	if(activeItem < 0) return;
	// getting file path
	NSString * path = [pathField stringValue];
	// validate it
	if(path == nil || [path isEqualToString: @""]) return;
	// split by '/' token
	NSArray * tokens = [path componentsSeparatedByString: @"/"];
	if([tokens count] == 0) return;
	// set image name
	path = [tokens objectAtIndex: [tokens count] - 1];
	for(int i = [path length] - 1; i >= 0; i--)
	{
		if([path characterAtIndex: i] == '.')
		{
			path = [path substringToIndex: i];
			break;
		}
	}
	[nameField setStringValue: path];
	TextureItem * item = [texturesTable getItem: activeItem];
	[item setImageName: path];
	// reload data to the table view
	[texturesList setDataSource: texturesTable];
	[texturesList reloadData];
}

- (IBAction)clickAdd:(NSButton*)button
{
	// creates new item in the table
	[texturesTable addItem];
	// reload data to the table view
	[texturesList setDataSource: texturesTable];
	[texturesList reloadData];
	// set added row as active
	[self changeItem: [texturesList numberOfRows] - 1];
	// enable 'remove' button
	[removeButton setEnabled: YES];
	// open file selection dialog
	[self clickPath: nil];
}

- (IBAction)clickRemove:(NSButton*)button
{
	// delete item from table
	if(activeItem >= 0)
	{
		[texturesTable removeItem: activeItem];
		// reload data to the table view
		[texturesList setDataSource: texturesTable];
		[texturesList reloadData];
	}
	// if it was a last row
	if([texturesList numberOfRows] == 0)
	{
		// set selection to nothing
		[self changeItem: -1];
		// disable 'remove' button
		[removeButton setEnabled: NO];
	}
	else
	{
		// getting new selected row index
		int index = (activeItem >= [texturesList numberOfRows] ? [texturesList numberOfRows] - 1 : activeItem);
		// set it
		[texturesList selectRowIndexes: [NSIndexSet indexSetWithIndex: index]
				  byExtendingSelection: NO];
		[self changeItem: index];
	}
}

- (IBAction)clickPath:(NSButton*)button
{
	if(activeItem < 0) return;
	// open file panel for images
	void (^handler)(NSInteger);
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects: @"png",  @"jpg", @"bmp", 
														  @"xbm",  @"cur", @"ico", 
														  @"BMPf", @"gif", @"jpeg",
														  @"tiff", @"tif", nil]];
	// open file panel handler
	handler = ^(NSInteger result)
	{
		// if OK button pressed
        if(result == NSFileHandlingPanelOKButton)
		{
			// getting item from holder
			TextureItem * item  = [texturesTable getItem: activeItem];
			// getting path from panel
			NSString    * path  = [[[panel URLs] objectAtIndex: 0] path];
			// load image for the path
			NSImage     * image = [[NSImage alloc] initWithContentsOfFile: path];
			// if image loaded successfully
			if(image != NULL)
			{
				// convert NSImage to CGImage
				CGImageRef cgImage = [image CGImageForProposedRect: NULL context: NULL hints: NULL];
				// if converted successfully
				if(cgImage != NULL)
				{
					// getting file path
					NSString * imageName = [NSString stringWithString: path];
					// split by '/' token
					NSArray * tokens = [imageName componentsSeparatedByString: @"/"];
					if([tokens count] == 0) return;
					// set image name
					imageName = [tokens objectAtIndex: [tokens count] - 1];
					for(int i = [imageName length] - 1; i >= 0; i--)
					{
						if([imageName characterAtIndex: i] == '.')
						{
							imageName = [imageName substringToIndex: i];
							break;
						}
					}
					// set item's fields
					[item setFileName: path];
					[item setImageName: imageName];
					[item setFrameWidth: CGImageGetWidth(cgImage)];
					[item setFrameHeight: CGImageGetHeight(cgImage)];
					[item setFrames: 1];
					framesStepper.intValue = 1;
					// set editing form's fields
					[pathField setStringValue: path];
					[nameField setStringValue: imageName];
					[widthField setStringValue: [NSString stringWithFormat: @"%i", [item frameWidth]]];
					[heightField setStringValue: [NSString stringWithFormat: @"%i", [item frameHeight]]];
					[framesField setStringValue: [NSString stringWithFormat: @"%i", [item frames]]];
				}
			}
			// reload data to the table view
			[texturesList setDataSource: texturesTable];
			[texturesList reloadData];
        }
    };
	// show open file panel
    [panel beginSheetModalForWindow: window completionHandler: handler];
}

- (void)changeItem:(int)index
{
	// copy index for the active item
	activeItem = index;
	// if anything selected
	if(index >= 0)
	{
		// getting item from the holder
		TextureItem * item = [texturesTable getItem: index];
		// set editiong form's fields by item's fields value
		[pathField setStringValue: [item fileName]];
		[nameField setStringValue: [item imageName]];
		[widthField setStringValue: [NSString stringWithFormat: @"%i", [item frameWidth]]];
		[heightField setStringValue: [NSString stringWithFormat: @"%i", [item frameHeight]]];
		[framesField setStringValue: [NSString stringWithFormat: @"%i", [item frames]]];
		framesStepper.intValue = [item frames];
		// enable form's elements
		[pathField setEnabled: YES];
		[nameField setEnabled: YES];
		[widthField setEnabled: YES];
		[heightField setEnabled: YES];
		[framesField setEnabled: YES];
		[pathButton setEnabled: YES];
		[framesStepper setEnabled: YES];
		[getNameButton setEnabled: YES];
		// select item in table view
		[texturesList selectRowIndexes: [NSIndexSet indexSetWithIndex: index]
				  byExtendingSelection: NO];
	}
	// if nothing selected
	else
	{
		// reset fields values
		[pathField setStringValue: @""];
		[nameField setStringValue: @""];
		[widthField setStringValue: @""];
		[heightField setStringValue: @""];
		[framesField setStringValue: @""];
		framesStepper.intValue = 1;
		// disable form's elements
		[pathField setEnabled: NO];
		[nameField setEnabled: NO];
		[widthField setEnabled: NO];
		[heightField setEnabled: NO];
		[framesField setEnabled: NO];
		[pathButton setEnabled: NO];
		[framesStepper setEnabled: NO];
		[getNameButton setEnabled: NO];
		// deselect item in table view
		[texturesList deselectAll: self];
	}
}

- (IBAction)saveDocument:(NSMenuItem*)item
{
	// if no active project path - open 'Save As...' panel
	if(currentProject == nil || [currentProject isEqualToString: @""])
	{
		[self saveDocumentAs: item];
		return;
	}
	// save project by current path
	[self saveProject: currentProject];
}

- (IBAction)saveDocumentAs:(NSMenuItem*)item
{
	// save file panel for project files
	void (^handler)(NSInteger);
    NSSavePanel * panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes: [NSArray arrayWithObjects: @"xaproj", nil]];
    // save file panel handler
	handler = ^(NSInteger result)
	{
		// if OK button pressed
        if(result == NSFileHandlingPanelOKButton)
		{
			// set panel path as active project path
			currentProject = [[panel URL] path];
			[currentProject retain];
			// save project
			[self saveProject: currentProject];
		}
    };
	// show save file panel
    [panel beginSheetModalForWindow:window completionHandler:handler];
}

- (void)saveProject:(NSString*)path
{
	// check path
	if(path == nil) return;
	if([path isEqualToString: @""]) return;
	// open file to write project
	FILE * output = fopen([path UTF8String], "wb");
	if(output == NULL)
	{
		CFUserNotificationDisplayAlert(0, kCFUserNotificationStopAlertLevel,
									   NULL, NULL, NULL, CFSTR("Save project"),
									   CFStringCreateWithFormat(NULL, NULL, CFSTR("Unable to save project to the file '%@'."), path),
									   NULL, NULL, NULL, NULL);
		return;
	}
	// write format identifier
	fwrite("XAPJ", 1, 4, output);
	// write imges count
	int itemsCount = [texturesTable count];
	fwrite(&itemsCount, 4, 1, output);
	// write all images
	for(int i = 0; i < itemsCount; i++)
	{
		// gettin item from the holder
		TextureItem * item = [texturesTable getItem: i];
		// getting item data
		int width  = [item frameWidth];
		int height = [item frameHeight];
		int frames = [item frames];
		// write item data to the file
		fwrite([[item fileName] UTF8String], 1, [[item fileName] length] + 1, output);
		fwrite([[item imageName] UTF8String], 1, [[item imageName] length] + 1, output);
		fwrite(&width,  4, 1, output);
		fwrite(&height, 4, 1, output);
		fwrite(&frames, 4, 1, output);
	}
	// close file
	fclose(output);
	// add file to 'Open recent' menu
	[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL: [NSURL fileURLWithPath: path]];
}

- (void)loadProject:(NSString*)path
{
	// checkpath
	if(path == nil) return;
	if([path isEqualToString: @""]) return;
	// clear current project
	[self clearProject];
	// open project file
	FILE * input = fopen([path UTF8String], "rb");
	if(input == NULL)
	{
		CFUserNotificationDisplayAlert(0, kCFUserNotificationStopAlertLevel,
									   NULL, NULL, NULL, CFSTR("Load project"),
									   CFStringCreateWithFormat(NULL, NULL, CFSTR("Unable to load project from the file '%@'."), path),
									   NULL, NULL, NULL, NULL);
		return;
	}
	// read and check format identifier
	char header[4];
	fread(header, 1, 4, input);
	if(header[0] != 'X' || header[1] != 'A' || header[2] != 'P' || header[3] != 'J') return;
	// read images count
	int countImages = 0;
	fread(&countImages, 4, 1, input);
	// read all images
	for(int i = 0; i < countImages; i++)
	{
		// add new item to the table
		[texturesTable addItem];
		// getting new item
		TextureItem * item = [texturesTable getItem: i];
		// rad items data from the file
		[item setFileName: [self readString: input]];
		[item setImageName: [self readString: input]];
		int width, height, frames;
		fread(&width,  4, 1, input);
		fread(&height, 4, 1, input);
		fread(&frames, 4, 1, input);
		[item setFrameWidth: width];
		[item setFrameHeight: height];
		[item setFrames: frames];
	}
	// close file
	fclose(input);
	// change active project path
	currentProject = path;
	[currentProject retain];
	// reload data to the table view
	[texturesList setDataSource: texturesTable];
	[texturesList reloadData];
	// add file to 'Open recent' menu
	[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL: [NSURL fileURLWithPath: path]];
}

- (NSString*)readString:(void*)file
{
	// cast pointer fo FILE*
	FILE * input = (FILE*)file;
	// string array
	std::vector<char> string;
	// read first char
	char symbol = fgetc(input);
	// while readed char is not a '\0'
	while(symbol != '\0')
	{
		// add char to the array
		string.push_back(symbol);
		// read next char
		symbol = fgetc(input);
	}
	// add '\0' sybmol to the array
	string.push_back('\0');
	// create new NSString with an array data
	return [NSString stringWithUTF8String: &string[0]];
}

- (void)clearProject
{
	// delete all items
	[texturesTable clear];
	// reload data to the table view
	[texturesList setDataSource: texturesTable];
	[texturesList reloadData];
	// reset active project path
	currentProject = @"";
	[currentProject retain];
	// deselect item in the table
	[self changeItem: -1];
}

- (IBAction)newDocument:(NSMenuItem*)item
{
	// clear project
	[self clearProject];
}

- (IBAction)openDocument:(NSMenuItem*)item
{
	// open file panel for project files
	void (^handler)(NSInteger);
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects: @"xaproj", nil]];
    // open file panel handler
	handler = ^(NSInteger result)
	{
		// if OJ button pressed
        if(result == NSFileHandlingPanelOKButton)
		{
			// save panel path as active project path
			currentProject = [[[panel URLs] objectAtIndex: 0] path];
			[currentProject retain];
			// load project from the file
			[self loadProject: currentProject];
			// select first item in the table
			if([texturesTable count] > 0) 
			{
				[self changeItem: 0];
				[removeButton setEnabled: YES];
			}
		}
    };
	// show open file panel
    [panel beginSheetModalForWindow: window completionHandler: handler];
}

- (IBAction)generateAtlas:(NSMenuItem*)item
{
	// if atlas image exists
	if([atlasPreview image] == nil) return;
	// save file panel for atlas files
	void (^handler)(NSInteger);
    NSSavePanel * panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes: [NSArray arrayWithObjects: @"atls", nil]];
    // save file panel handler
	handler = ^(NSInteger result)
	{
		// if OK button pressed
        if(result == NSFileHandlingPanelOKButton)
		{
			// sve atlas to panel path
			[self saveAtlas:[[panel URL] path]];
		}
    };
	// show save file panel
    [panel beginSheetModalForWindow:window completionHandler:handler];
}

- (IBAction)revertDocument:(NSMenuItem*)item
{
	// validate active project path
	if(currentProject == nil || [currentProject isEqualToString: @""]) return;
	// load project from active project patht
	[self loadProject: currentProject];
	// select first item in the table
	if([texturesTable count] > 0)
	{
		[self changeItem: 0];
		[removeButton setEnabled: YES];
	}
}

- (void)saveAtlas:(NSString*)path
{
	// alidate atlas image and path
	if([atlasPreview image] == nil || path == nil) return;
	if([path isEqualToString: @""]) return;
	// count valid images in atlas
	int imagesCount = 0;
	for(int i = 0; i < [texturesTable count]; i++)
	{
		TextureItem * item = [texturesTable getItem: i];
		if([item countImages] > 0) imagesCount++;
	}
	// getting atla image data TIFF representation
	NSData * imageData = [[atlasPreview image] TIFFRepresentation];
    NSBitmapImageRep * rep = [NSBitmapImageRep imageRepWithData: imageData];
	// convert it to the PNG file
	NSData * pngData = [rep representationUsingType: NSPNGFileType 
										 properties: nil];
	// open file for atlas
	FILE * output = fopen([path UTF8String], "wb");
	if(output == NULL)
	{
		CFUserNotificationDisplayAlert(0, kCFUserNotificationStopAlertLevel,
									   NULL, NULL, NULL, CFSTR("Export atlas"),
									   CFStringCreateWithFormat(NULL, NULL, CFSTR("Unable to export atlas to the file '%@'."), path),
									   NULL, NULL, NULL, NULL);
		return;
	}
	// write format identifier
	fputs("X3DA", output);
	// write images count
	fwrite(&imagesCount, 4, 1, output);
	// write all images
	for(int i = 0; i < [texturesTable count]; i++)
	{
		// getting item from the holder
		TextureItem * item = [texturesTable getItem: i];
		// if itm contain any frame
		if([item countImages] > 0)
		{
			// gettin item data
			int width  = [item frameWidth];
			int height = [item frameHeight];
			int frames = [item countImages];
			// write it to the file
			fwrite([[item imageName] UTF8String], 1, [[item imageName] length] + 1, output);
			fwrite(&width,  4, 1, output);
			fwrite(&height, 4, 1, output);
			fwrite(&frames, 4, 1, output);
			// write all frames data
			for(int j = 0; j < [item countImages]; j++)
			{
				// gettin frame image pointer
				CGImageRef image = [item getImage: j];
				// getting frame region in atlas
				xTextureAtlas::xAtlasRegion region = atlas->GetTextureRegion(image, j);
				// write in coordinates to the file
				region.y = atlas->GetHeight() - region.y - height;
				fwrite(&region.x, 4, 1, output);
				fwrite(&region.y, 4, 1, output);
			}
		}
	}
	// write PNG data to the file
	fwrite([pngData bytes], 1, [pngData length], output);
	// close file
	fclose(output);
}

- (BOOL)application:(NSApplication*)application openFile:(NSString*)path
{
	// load project from the file
	[self loadProject: path];
	// select first item in the table
	if([texturesTable count] > 0) 
	{
		[self changeItem: 0];
		[removeButton setEnabled: YES];
	}
	return YES;
}

@end
