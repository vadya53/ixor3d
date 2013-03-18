//
//  ogles.h
//  iXors3D
//
//  Created by Knightmare on 26.08.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>
#else
#import <OpenGL/OpenGL.h>
#import <AppKit/AppKit.h>
#endif