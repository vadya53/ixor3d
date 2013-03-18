//
//  xTextureConverterAppDelegate.h
//  xTextureConverter
//
//  Created by Knightmare on 7/24/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface xTextureConverterAppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSWindow     * window;
	IBOutlet NSButton     * sourceButton;
	IBOutlet NSButton     * outputButton;
	IBOutlet NSButton     * convertButton;
	IBOutlet NSTextField  * sourceField;
	IBOutlet NSTextField  * outputField;
	IBOutlet NSImageView  * imagePreview;
	IBOutlet NSButtonCell * copressionButton;
	IBOutlet NSButtonCell * formatButton;
	IBOutlet NSButtonCell * weightingButton;
	IBOutlet NSButton     * mipsButton;
}

@property (nonatomic, retain) IBOutlet NSWindow     * window;
@property (nonatomic, retain) IBOutlet NSButton     * convertButton;
@property (nonatomic, retain) IBOutlet NSButton     * sourceButton;
@property (nonatomic, retain) IBOutlet NSButton     * outputButton;
@property (nonatomic, retain) IBOutlet NSTextField  * sourceField;
@property (nonatomic, retain) IBOutlet NSTextField  * outputField;
@property (nonatomic, retain) IBOutlet NSImageView  * imagePreview;
@property (nonatomic, retain) IBOutlet NSButtonCell * copressionButton;
@property (nonatomic, retain) IBOutlet NSButtonCell * formatButton;
@property (nonatomic, retain) IBOutlet NSButtonCell * weightingButton;
@property (nonatomic, retain) IBOutlet NSButton     * mipsButton;

- (IBAction)sourceButtonClick:(id)sender;
- (IBAction)convertButtonClick:(id)sender;
- (IBAction)outputButtonClick:(id)sender;

@end
