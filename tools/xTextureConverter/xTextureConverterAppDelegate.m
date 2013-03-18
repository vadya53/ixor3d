//
//  xTextureConverterAppDelegate.m
//  xTextureConverter
//
//  Created by Knightmare on 7/24/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "xTextureConverterAppDelegate.h"
#import <dirent.h>
#import <sys/types.h>

@implementation xTextureConverterAppDelegate

@synthesize window;
@synthesize sourceButton;
@synthesize outputButton;
@synthesize convertButton;
@synthesize sourceField;
@synthesize outputField;
@synthesize imagePreview;
@synthesize copressionButton;
@synthesize formatButton;
@synthesize weightingButton;
@synthesize mipsButton;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[window center];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (IBAction)sourceButtonClick:(id)sender
{
	void (^handler)(NSInteger);
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects: @"png",  @"jpg", @"bmp", 
														  @"xbm",  @"cur", @"ico", 
														  @"BMPf", @"gif", @"jpeg",
														  @"tiff", @"tif", nil]];
	[panel setCanChooseDirectories: YES];
    handler = ^(NSInteger result)
	{
        if(result == NSFileHandlingPanelOKButton)
		{
			[sourceField setStringValue: [[[panel URLs] objectAtIndex:0] path]];
			[imagePreview setImage: [[NSImage alloc] initWithContentsOfFile: [[[panel URLs] objectAtIndex:0] path]]];
			NSString * outputPath = [[[panel URLs] objectAtIndex:0] path];
			BOOL changed = NO;
			for(int i = [outputPath length] - 1; i >= 0; i--)
			{
				if([outputPath characterAtIndex: i] == '.')
				{
					outputPath = [outputPath substringToIndex: i];
					changed = YES;
					break;
				}
			}
			if(changed)
			{
				[outputField setStringValue: [outputPath stringByAppendingString: @".pvr"]];
			}
			else
			{
				[outputField setStringValue: outputPath];
			}
        }
    };
    [panel beginSheetModalForWindow:window completionHandler:handler];
}

- (IBAction)convertButtonClick:(id)sender
{
	if([[sourceField stringValue] isEqual: @""]
	   || [[outputField stringValue] isEqual: @""]) return;
	char buffer[2048];
	bool bpp4    = [copressionButton state];
	bool channel = [weightingButton  state];
	bool format  = [formatButton     state];
	bool mips    = [mipsButton       state];
	BOOL isDirectory = NO;
	DIR * directory = opendir([[sourceField stringValue] UTF8String]);
	if(directory != NULL)
	{
		isDirectory = YES;
		closedir(directory);
	}
	if(!isDirectory)
	{
		sprintf(buffer, "/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/texturetool -e PVRTC %s %s -f %s%s -o %s %s",
				(bpp4    ? "--bits-per-pixel-4" : "--bits-per-pixel-2"),
				(channel ? "--channel-weighting-linear" : "--channel-weighting-perceptual"),
				(format  ? "PVR" : "Raw"),
				(mips    ? " -m" : ""),
				[[outputField stringValue] UTF8String],
				[[sourceField stringValue] UTF8String]);
		if(system(buffer) == 0)
		{
			CFUserNotificationDisplayAlert(0, kCFUserNotificationNoteAlertLevel,
										   NULL, NULL, NULL, CFSTR("Conversion complited"),
										   CFSTR("Texture conversion successfully complited."),
										   NULL, NULL, NULL, kCFUserNotificationDefaultResponse);
		}
		else
		{
			CFUserNotificationDisplayAlert(0, kCFUserNotificationStopAlertLevel,
										   NULL, NULL, NULL, CFSTR("Conversion failed"),
										   CFSTR("Unable to convert texture to PVR. The image provided is required to be a power of two."),
										   NULL, NULL, NULL, kCFUserNotificationDefaultResponse);
		}
	}
	else
	{
		int convertedCount = 0;
		BOOL hasError = NO;
		NSString * errors = @"During the conversion found the following errors:\n";
		NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: [sourceField stringValue]
																			  error: nil];
		for(int i = 0; i < [files count]; i++)
		{
			NSString * path = [[sourceField stringValue] stringByAppendingFormat: @"/%@", [files objectAtIndex: i]];
			NSArray * tokensByDot = [path componentsSeparatedByString: @"."];
			if([tokensByDot count] == 0) continue;
			NSArray * formats = [NSArray arrayWithObjects: @"png",  @"jpg", @"bmp", 
														   @"xbm",  @"cur", @"ico", 
														   @"BMPf", @"gif", @"jpeg",
														   @"tiff", @"tif", nil];
			BOOL supported = NO;
			for(int j = 0; j < [formats count]; j++)
			{
				if([[tokensByDot objectAtIndex: [tokensByDot count] - 1] isEqualToString: [formats objectAtIndex: j]])
				{
					supported = YES;
					break;
				}
			}
			if(!supported) continue;
			NSArray * tokensBySlash = [path componentsSeparatedByString: @"/"];
			if([tokensBySlash count] == 0) continue;
			NSString * outPath = [tokensBySlash objectAtIndex: [tokensBySlash count] - 1];
			for(int j = [outPath length] - 1; j >= 0; j--)
			{
				if([outPath characterAtIndex: j] == '.')
				{
					outPath = [outPath substringToIndex: j];
					break;
				}
			}
			outPath = [[sourceField stringValue] stringByAppendingFormat: @"/%@.pvr", outPath];
			sprintf(buffer, "/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/texturetool -e PVRTC %s %s -f %s%s -o %s %s",
					(bpp4    ? "--bits-per-pixel-4" : "--bits-per-pixel-2"),
					(channel ? "--channel-weighting-linear" : "--channel-weighting-perceptual"),
					(format  ? "PVR" : "Raw"),
					(mips    ? " -m" : ""),
					[outPath UTF8String],
					[path UTF8String]);
			if(system(buffer) == 0)
			{
				convertedCount++;
			}
			else
			{
				hasError = YES;
				errors = [errors stringByAppendingFormat: @"\nUnable to convert file '%@'. The image provided is required to be a power of two.", path];
			}
		}
		if(hasError)
		{
			errors = [errors stringByAppendingFormat: @"\nSuccessfully converted %i textures.", convertedCount];
			CFUserNotificationDisplayAlert(0, kCFUserNotificationCautionAlertLevel,
										   NULL, NULL, NULL, CFSTR("Conversion failed"),
										  CFStringCreateWithFormat(NULL, NULL, CFSTR("%@"), errors),
										   NULL, NULL, NULL, kCFUserNotificationDefaultResponse);
		}
		else
		{
			CFUserNotificationDisplayAlert(0, kCFUserNotificationNoteAlertLevel,
										   NULL, NULL, NULL, CFSTR("Conversion complited"),
										   CFStringCreateWithFormat(NULL, NULL, CFSTR("Folder conversion finished successfully. Total %i textures converted."), convertedCount),
										   NULL, NULL, NULL, kCFUserNotificationDefaultResponse);
		}
	}
}

- (IBAction)outputButtonClick:(id)sender
{
	BOOL isDirectory = NO;
	DIR * directory = opendir([[sourceField stringValue] UTF8String]);
	if(directory != NULL)
	{
		isDirectory = YES;
		closedir(directory);
	}
	if(!isDirectory)
	{
		void (^handler)(NSInteger);
		NSSavePanel * panel = [NSSavePanel savePanel];
		[panel setAllowedFileTypes:[NSArray arrayWithObjects: @"pvr", nil]];
		handler = ^(NSInteger result)
		{
			if(result == NSFileHandlingPanelOKButton)
			{
				[outputField setStringValue: [[panel URL] path]];
			}
		};
		[panel beginSheetModalForWindow:window completionHandler:handler];
	}
	else 
	{
		void (^handler)(NSInteger);
		NSOpenPanel * panel = [NSOpenPanel openPanel];
		[panel setCanChooseFiles: NO];
		[panel setCanChooseDirectories: YES];
		handler = ^(NSInteger result)
		{
			if(result == NSFileHandlingPanelOKButton)
			{
				[outputField setStringValue: [[panel URL] path]];
			}
		};
		[panel beginSheetModalForWindow:window completionHandler:handler];
	}
}

@end
