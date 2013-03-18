/********************************************************
 *                                                      *
 *                    iXors3D Engine                    *
 *               Xors3D Engine for iPhone               *
 *                                                      *
 *  Copyright 2009-2011 XorsTeam. All rights reserved.  *
 *  WWW: http://xors3d.com E-Mail: support@xors3d.com   *
 *                                                      *
 ********************************************************/

#import <Foundation/Foundation.h>
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

/*! \mainpage
 * iXors3D Engine is a game development tool. This engine can be used for development
 * of games for Apple iPhone, Apple iPod & Apple iPad. Using iXors3D you're able 
 * to construct game of any genre. It combines simplicity, flexibility and power.
 *
 * Documentation is partly based on original Blitz3D help.
 *
 * For iXors3D Engine 1.1.108 6 Aug 2010
 */

// Group defines
/*! \defgroup comref Command reference*/
/*! \defgroup maincommands Core functions
 \ingroup comref*/
/*! \defgroup inputcommands Input
 \ingroup comref*/
/*! \defgroup textcommands Text drawing
 \ingroup comref*/
/*! \defgroup imagecommands Images
 \ingroup comref*/
/*! \defgroup videopbcommands Video playback
 \ingroup comref*/
/*! \defgroup texcommands Textures
 \ingroup comref*/
/*! \defgroup brushcommands Brushes
 \ingroup comref*/
/*! \defgroup meshcommands Meshes
 \ingroup comref*/
/*! \defgroup surfcommands Surfaces
 \ingroup comref*/
/*! \defgroup camcommands Cameras
 \ingroup comref*/
/*! \defgroup rccommands Ray casting
 \ingroup comref*/
/*! \defgroup lightcommands Lights
 \ingroup comref*/
/*! \defgroup sprcommands Sprites
 \ingroup comref*/
/*! \defgroup psyscommands Particle systems
 \ingroup comref*/
/*! \defgroup terrcommands Terrains
 \ingroup comref*/
/*! \defgroup audiocommands Audio
 \ingroup comref*/
/*! \defgroup emcommands Entity movement
 \ingroup comref*/
/*! \defgroup eacommands Entity animation
 \ingroup comref*/
/*! \defgroup eccommands Entity control
 \ingroup comref*/
/*! \defgroup escommands Entity state
 \ingroup comref*/
/*! \defgroup ecolcommands Entity collision
 \ingroup comref*/
/*! \defgroup mathcommands 3D maths
 \ingroup comref*/
/*! \defgroup fscommands File system
 \ingroup comref*/
/*! \defgroup netcommands Network
 \ingroup comref*/
/*! \defgroup pxcommands Physics
 \ingroup comref*/
/*! \defgroup px2dcommands 2D Physics
 \ingroup comref*/
/*! \defgroup imgatlascommands Images atlases
 \ingroup comref*/
/*! \defgroup sysinfocommands System Info
 \ingroup comref*/

// lighting types
/*! \defgroup lighttypes Light types*/
/*@{*/
//! Directional light works like a sun. It has not a position or a range, it has
//! a direction of light rays and a light color only.
#define LIGHT_DIRECTIONAL				1
//! Point (omni) light works like a light bulb. It has a position, a range and a color,
//! but has not a direction.
#define LIGHT_POINT						2
//! Spot light is a cone of light. It starts with an inner angle of light,
//! and then extends towards an outer angle of light (cone angles you may
//! specify by xLightConeAngles() command). This light type has a position,
//! a direction, a range and a color.
#define LIGHT_SPOT						3
/*@}*/

// Camera fog mode
/*! \defgroup fogtypes Fog types*/
/*@{*/
//! Fog is disabled.
//!
#define FOG_NONE						0
//! Linear fog is used. Fog is computed using the following equation:
//! f = (end - d) / (end - start), where
//! 'start' is the distance at which fog effects begin,
//! 'end' is the distance at which fog effects no longer increase,
//! 'd' represents depth, or the distance from the viewpoint.
//! Specify 'start' and 'end' with xCameraFogRange() command.
#define FOG_LINEAR						1
/*@}*/

// camera projection mode
/*! \defgroup projtypes Camera projection types*/
/*@{*/
//! Camera is disabled. Using this projection mode, nothing is displayed on the screen,
//! and this is the fastest method of hiding a camera.
//!
#define PROJ_DISABLE					0
//! Perspective projection matrix is used. The two most characteristic
//! features of perspective are that objects are drawn:
//! - Smaller as their distance from the observer increases
//! - Foreshortened: the size of an object's dimensions along the line of
//! sight are relatively shorter than dimensions across the line of sight
#define PROJ_PERSPECTIVE				1
//! Orthographic projection matrix is used. Orthographic projection
//! corresponds to a perspective projection with a hypothetical viewpoint --
//! e.g., one where the camera lies an infinite distance away from the object
//! and has an infinite focal length, or "zoom".
#define PROJ_ORTHOGRAPHIC				2
/*@}*/

// Entity FX flags
/*! \defgroup fxflags Entity FX flags*/
/*@{*/
//! No effects are applied to an entity.
//!
#define FX_NOTHING						0 
//! Lights don't affect the entity.
//!
#define FX_FULLBRIGHT					1
//! Vertex diffuse color is used instead of material diffuse color
//! (set by xEntityColor() command).
#define FX_VERTEXCOLOR					2
//! In the flat shading mode, the rendering pipeline renders a polygon, using
//! the color of the polygon material at its first vertex as the color
//! for the entire polygon. 3D objects that are rendered with flat shading have
//! visibly sharp edges between polygons if they are not coplanar.
#define FX_FLATSHEDED					4
//! Fog doesn't affect the entity.
//!
#define FX_DISABLEFOG					8
//! Entity is rendered without backface culling (two-sided triangles).
//!
#define FX_DISABLECULLING				16
/*@}*/

// entity blend types
/*! \defgroup entblendtypes Entity blending modes*/
/*@{*/
//! Entity is blended in respect to its aplha value using the following equation:
//! RGBr = (As * RGBs) + ((1.0 - As) * RGBd), where
//! 'RGBr' - result color,
//! 'RGBs' - source pixel color (from rendered entity),
//! 'RGBd' - destination pixel color (from rendering buffer),
//! 'As' - source alpha value (set by xEntityAlpha() command).
#define BLEND_ALPHA						1
//! Entity is multiplied with rendering buffer using the following equation:
//! RGBr = RGBs * RGBd, where
//! 'RGBr' - result color,
//! 'RGBs' - source pixel color (from rendered entity),
//! 'RGBd' - destination pixel color (from rendering buffer).
#define BLEND_MULTIPLY					2
//! Entity color multiplied by an alpha value is added to rendering buffer.
//! RGBr = (RGBs * As) + RGBd, where
//! 'RGBr' - result color,
//! 'RGBs' - source pixel color (from rendered entity),
//! 'RGBd' - destination pixel color (from rendering buffer),
//! 'As' - source alpha value (set by xEntityAlpha() command).
#define BLEND_ADD						3	
/*@}*/

// axis defines
/*! \defgroup axistypes Axis*/
/*@{*/
//! x-axis is used (from left to right).
//!
#define AXIS_X							1
//! y-axis is used (from bottom to top).
//!
#define AXIS_Y							2
//! z-axis is used (from back to front).
//!
#define AXIS_Z							3
/*@}*/

// Texture loading flags
/*! \defgroup tlflags Texture loading flags*/
/*@{*/
//! Texture will be loaded with color channels.
//!
#define FLAGS_COLOR						1
//! Texture will be loaded with alpha channel.
//!
#define FLAGS_ALPHA						2
//! All black pixels (0xFF000000 color) will be transparent.
//!
#define FLAGS_MASKED					4
//! Mip-map levels for texture will be generated.
//!
#define FLAGS_MIPMAPPED					8
//! Any part of a texture that lies outsides the U coordinates of range
//! [0; 1] will not be drawn. Prevents texture-wrapping. 
//!
#define FLAGS_CLAMPU					16
//! Any part of a texture that lies outsides the V coordinates of range
//! [0; 1] will not be drawn. Prevents texture-wrapping. 
//!
#define FLAGS_CLAMPV					32
#if !TARGET_OS_EMBEDDED && !TARGET_IPHONE_SIMULATOR
//! Spherical environment map - a form of environment mapping. This works by 
//! taking a single image, and then applying it to a 3D mesh in such a way that 
//! the image appears to be reflected. When used with a texture that contains 
//! light sources, it can give some meshes such as a teapot a shiny appearance. 
//! 
//! This flag available only on MacOSX version of the engine.
#define FLAGS_SPHEREMAP					64
#endif
/*@}*/

// texture blending modes
/*! \defgroup texblendtypes Texture blending types*/
/*@{*/
//! Texture will not be blended with other layers.
//!
#define TEXBLEND_NONE					0
//! Higher order texture is blended with a texture below (or polygon)
//! in respect to its alpha value.
#define TEXBLEND_ALPHA					1	
//! Pixel colors of higher order texture and lower order texture (or polygon) are multiplied.
//!
#define TEXBLEND_MULTIPLY				2
//! Pixel colors of higher order texture and lower order texture (or polygon) are added.
//!
#define TEXBLEND_ADD					3
//! Emulates DOT3 bump-mapping. Modulates the components of each argument as
//! signed components, adds their products; then replicates the sum to all
//! color channels, including alpha. This operation is supported for color
//! and alpha operations. 
#define TEXBLEND_DOT3					4
//! Pixel colors of higher order texture and lower order texture (or polygon) are multiplied. //! Then the products are shifted left 1 bit (effectively multiplying them by 2)
//! for brightening. Used for lightmaps.
#define TEXBLEND_LIGHTMAP				5
//! Higher order texture is blended with another one in respect to alpha value
//! of lower order texture.
//! E.g. you can set diffuse maps on layers #0 and #2 and separate them with alpha-map
//! (set texture with alpha channel on layer #1). It is useful if you need to
//! blend tiled textures, but you don't need an alpha channel to be tiled.
#define TEXBLEND_SEPARATEALPHA			6
/*@}*/

// image blending modes
/*! \defgroup imgblendtypes Image blending types*/
/*@{*/
//! For global blending type only. Will use local image blending type
//!
#define IMGBLEND_LOCAL					0
//! Image pixels overwrite existing backbuffer pixels
//!
#define IMGBLEND_NONE					1
//! Image pixels are drawn only if their alpha component is greater than 0.0
//!
#define IMGBLEND_MASK					2	
//! Image pixels are alpha blended with existing backbuffer pixels
//!
#define IMGBLEND_ALPHA					3
//! Image pixel colors are added to backbuffer pixel colors, giving a 'lighting' effect
//!
#define IMGBLEND_LIGHT					4
//! Image pixel colors are multiplied with backbuffer pixel colors, giving a 'shading' effect
//!
#define IMGBLEND_SHADE					5
/*@}*/

// Entity Animation types
/*! \defgroup animtypes Animation playback types*/
/*@{*/
//! Stop animation.
//!
#define ANIMATION_STOP					0
//! Loop animation (default).
//!
#define ANIMATION_LOOP					1
//! Ping-pong animation (from first to last, from last to first and so on)
//!
#define ANIMATION_PINGPONG				2
//! One-shot animation.
//!
#define ANIMATION_ONE					3
/*@}*/

// Collision types
/*! \defgroup colltypes Collision types*/
/*@{*/
//! Sphere-to-sphere collision check.
//!
#define SPHERETOSHPHERE					1
//! Sphere-to-box collision check.
//!
#define SPHERETOBOX						3
//! Sphere-to-triangle-mesh collision check.
//! mesh.
#define SPHERETOTRIMESH					2
/*@}*/

// collision response types
/*! \defgroup resptypes Response types*/
/*@{*/
//! Object stops moving if collision occurs.
//!
#define RESPONSE_STOP					1
//! Object slides if collision occurs.
//!
#define RESPONSE_SLIDING				2
//! Object slides if collision occurs,
//! but sliding down the slope is prevented.
#define RESPONSE_SLIDING_DOWNLOCK		3
//! Only collision check for object, 
//! without any response
#define RESPONSE_TRIGGER   		        4
/*@}*/

// entities picking modes
/*! \defgroup picktypes Entity picking types*/
/*@{*/
//! Unpickable object.
//!
#define PICK_NONE						0
//! Bounding sphere is used for picking.
//!
#define PICK_SPHERE						1
//! Triangle mesh is used for picking.
//!
#define PICK_TRIMESH					2
//! Entity box is used for picking.
//!
#define PICK_BOX						3
//! Bounding box for every entity's surface is used for picking.
//!
#define PICK_BOUNDINGBOX				4
/*@}*/

// Sprite view modes
/*! \defgroup sviewmodes Sprite view modes*/
/*@{*/
//! Sprite is always aligned to camera (like a billboard).
//! It changes its pitch and yaw values to face camera, but it doesn't roll. 
#define SPRITE_FIXED					1
//! Sprite is not aligned to camera.
//! It does not change either its pitch, yaw or roll values. 
#define SPRITE_FREE						2
//! Sprite is always aligned to camera.
//! It changes its yaw and pitch to face camera, and changes
//! its roll value to match cameras.
#define SPRITE_FREEROLL					3
//! Sprite is always aligned to camera in y-axis only.
//! It changes its yaw value to face camera, but not its pitch value.
//! Its roll value is changed to match cameras. 
#define SPRITE_FIXEDYAW					4
/*@}*/

// Touch phases
/*! \defgroup touchphases Touch phases*/
/*@{*/
//! Returned for invalid touch index.
//! 
#define TOUCH_NONE						0
//! Returned if touch has begun in this cycle.
//!  
#define TOUCH_BEGAN						1
//! Returned if touch has moved since the last check.
//! 
#define TOUCH_MOVE						2
//! Returned if touch hasn't moved since the last check.
//! 
#define TOUCH_PRESSED					3
//! Returned if touch has been released since last check.
//! 
#define TOUCH_RELEASED					4
/*@}*/
	
// Track repeat modes
/*! \defgroup repeatmodes Track repeat modes*/
/*@{*/
//! Default repeat mode, specified in iPod.
//! 
#define REPEAT_DEFAULT				0
//! Repeat is disabled.
//!  
#define REPEAT_NONE					1
//! Repeat is enabled only for current track.
//! 
#define REPEAT_ONE					2
//! Repeat is enabled only for all tracks in the playlist.
//! 
#define REPEAT_ALL					3
/*@}*/

// Track shuffle modes
/*! \defgroup shufflemodes Track shuffle modes*/
/*@{*/
//! Default shuffle mode, specified in iPod.
//! 
#define SHUFFLE_DEFAULT				0
//! Shuffle is disabled.
//!  
#define SHUFFLE_OFF					1
//! Shuffle songs in the playlist.
//! 
#define SHUFFLE_SONGS				2
//! Shuffle albums in the playlist.
//! 
#define SHUFFLE_ALBUMS				3
/*@}*/

// Media item types
/*! \defgroup mediaitemtypes Media item types*/
/*@{*/
//! Current item is a music file.
//! 
#define MEDIA_MUSIC				0
//! Current item is a podcast file.
//!  
#define MEDIA_PODCAST			1
//! Current item is an audiobook file.
//! 
#define MEDIA_AUDIOBOOK			2
//! No type specified for current item.
//! 
#define MEDIA_UNKNOWN			3
/*@}*/

// Media items states
/*! \defgroup mediaitemstate Media item states*/
/*@{*/
//! Current item is stopped.
//! 
#define MEDIA_STOPED			0
//! Current item is playing now.
//!  
#define MEDIA_PLAYING			1
//! Current item is paused.
//! 
#define MEDIA_PAUSED			2
//! Current item playback was interrupted (e.g. incoming call).
//! 
#define MEDIA_INTERRUPTED		3
/*@}*/

// HTTP request methods
/*! \defgroup httpreqmethods HTTP request methods*/
/*@{*/
//! Unsupported request method.
//! 
#define HTTPREQUEST_UNKNOWN		0
//! GET request method.
//!  
#define HTTPREQUEST_GET			1
//! POST request method.
//! 
#define HTTPREQUEST_POST		2
/*@}*/

// HTTP response states
/*! \defgroup httpresptypes HTTP response states*/
/*@{*/
//! Unknown response state.
//! 
#define HTTPRESPONSE_UNKNOWN	0
//! Request is in progress now.
//!  
#define HTTPREQUEST_GETTING		1
//! Request is finished successfully.
//! 
#define HTTPREQUEST_DONE		2
//! Request is waiting for connection.
//! 
#define HTTPREQUEST_IDLE		3
//! Request has failed with an error.
//! 
#define HTTPREQUEST_ERROR		4
/*@}*/

// Device orientations
/*! \defgroup devorient Device orientation flags*/
/*@{*/
//! Portrait orientation
//! 
#define DEVICE_PORTRAIT	1
//! Right landscape orientation
//!  
#define DEVICE_LANDSCAPE_RIGHT 2
//! Upside down portrait orientation
//! 
#define DEVICE_PORTRAIT_UPSIDEDOWN 4
//! Left landscape orientation
//! 
#define DEVICE_LANDSCAPE_LEFT 8
/*@}*/

// Alpha test-functions
/*! \defgroup atestfuncs Alpha-test functions*/
/*@{*/
//! Pixel never pass alpha-test
//! 
#define ALPHA_NEVER                          0
//! Pixel pass alpha-test if its alpha less than reference value
//! 
#define ALPHA_LESS                           1
//! Pixel pass alpha-test if its alpha equal to reference value
//! 
#define ALPHA_EQUAL                          2
//! Pixel pass alpha-test if its alpha less or equal to reference value
//! 
#define ALPHA_LEQUAL                         3
//! Pixel pass alpha-test if its alpha greater than reference value
//! 
#define ALPHA_GREATER                        4
//! Pixel pass alpha-test if its alpha not equal to reference value
//! 
#define ALPHA_NOTEQUAL                       5
//! Pixel pass alpha-test if its alpha great or equal to reference value
//! 
#define ALPHA_GEQUAL                         6
//! Pixel always pass alpha-test
//! 
#define ALPHA_ALWAYS                         7
/*@}*/

// types of joints
/*! \defgroup jointtypes Joint types
 \ingroup constref*/
/*@{*/
//! Point to point joint limits the translation so that the local pivot points of 2 rigid bodies
//! match in worldspace. A chain of rigid bodies can be connected using this joint.
//! \image html p2p.png "Point to point joint"
//!
#define JOINT_POINT2POINT   0
//! This generic joint can emulate a variety of standard joints, by configuring each of the 6 
//! degrees of freedom (dof). The first 3 dof axis are linear axis, which represent translation of rigid bodies, 
//! and the latter 3 dof axis represent the angular motion. Each axis can be either locked, free or limited. 
//! On construction of a new joint of this type, all axis are locked. Afterwards the axis can 
//! be reconfigured. Note that several combinations that include free and/or limited angular degrees of 
//! freedom are undefined.
//! \image html unknown.png "Image is temporary unavailable"
//!
#define JOINT_6DOF			1
//! This is a generic 6 DOF joint that allows to set spring motors to any translational and rotational DOF
//! DOF index used in xJoint6dofSpringParam() means:
//! 0 : translation X
//! 1 : translation Y
//! 2 : translation Z
//! 3 : rotation X, range [-PI+epsilon, PI-epsilon]
//! 4 : rotation Y, range [-PI/2+epsilon, PI/2-epsilon]
//! 5 : rotation Z, range [-PI+epsilon, PI-epsilon]
//! \image html unknown.png "Image is temporary unavailable"
//!
#define JOINT_6DOFSPRING	2
//! Hinge joint restricts two additional angular degrees of freedom, so the body
//! can only rotate around one axis, the hinge axis. This can be useful to represent doors or wheels 
//! rotating around one axis. The user can specify limits and motor for the hinge. 
//! \image html hinge.png "Hinge joint"
//!
#define JOINT_HINGE			3
/*@}*/

#if !TARGET_OS_EMBEDDED && !TARGET_IPHONE_SIMULATOR
// Scancodes for keyboard and mouse
const int MOUSE_LEFT        = 1;
const int MOUSE_RIGHT       = 2;
const int MOUSE_MIDDLE      = 3;
const int MOUSE4            = 4;
const int MOUSE5            = 5;
const int MOUSE6            = 6;
const int MOUSE7            = 7;
const int MOUSE8            = 8;
const int KEY_ESCAPE        = 1;
const int KEY_1             = 2;
const int KEY_2             = 3;
const int KEY_3             = 4;
const int KEY_4             = 5;
const int KEY_5             = 6;
const int KEY_6             = 7;
const int KEY_7             = 8;
const int KEY_8             = 9;
const int KEY_9             = 10;
const int KEY_0             = 11;
const int KEY_MINUS         = 12;
const int KEY_EQUALS        = 13;
const int KEY_BACK          = 14;
const int KEY_TAB           = 15;
const int KEY_Q             = 16;
const int KEY_W             = 17;
const int KEY_E             = 18;
const int KEY_R             = 19;
const int KEY_T             = 20;
const int KEY_Y             = 21;
const int KEY_U             = 22;
const int KEY_I             = 23;
const int KEY_O             = 24;
const int KEY_P             = 25;
const int KEY_LBRACKET      = 26;
const int KEY_RBRACKET      = 27;
const int KEY_RETURN        = 28;
const int KEY_LCONTROL      = 29;
const int KEY_RCONTROL      = 157;
const int KEY_A             = 30;
const int KEY_S             = 31;
const int KEY_D             = 32;
const int KEY_F             = 33;
const int KEY_G             = 34;
const int KEY_H             = 35;
const int KEY_J             = 36;
const int KEY_K             = 37;
const int KEY_L             = 38;
const int KEY_SEMICOLON     = 39;
const int KEY_APOSTROPHE    = 40;
const int KEY_GRAVE         = 41;
const int KEY_LSHIFT        = 42;
const int KEY_BACKSLASH     = 43;
const int KEY_Z             = 44;
const int KEY_X             = 45;
const int KEY_C             = 46;
const int KEY_V             = 47;
const int KEY_B             = 48;
const int KEY_N             = 49;
const int KEY_M             = 50;
const int KEY_COMMA         = 51;
const int KEY_PERIOD        = 52;
const int KEY_SLASH         = 53;
const int KEY_RSHIFT        = 54;
const int KEY_MULTIPLY      = 55;
const int KEY_MENU          = 56;
const int KEY_SPACE         = 57;
const int KEY_F1            = 59;
const int KEY_F2            = 60;
const int KEY_F3            = 61;
const int KEY_F4            = 62;
const int KEY_F5            = 63;
const int KEY_F6            = 64;
const int KEY_F7            = 65;
const int KEY_F8            = 66;
const int KEY_F9            = 67;
const int KEY_F10           = 68;
const int KEY_NUMLOCK       = 69;
const int KEY_SCROLL        = 70;
const int KEY_NUMPAD7       = 71;
const int KEY_NUMPAD8       = 72;
const int KEY_NUMPAD9       = 73;
const int KEY_SUBTRACT      = 74;
const int KEY_NUMPAD4       = 75;
const int KEY_NUMPAD5       = 76;
const int KEY_NUMPAD6       = 77;
const int KEY_ADD           = 78;
const int KEY_NUMPAD1       = 79;
const int KEY_NUMPAD2       = 80;
const int KEY_NUMPAD3       = 81;
const int KEY_NUMPAD0       = 82;
const int KEY_DECIMAL       = 83;
const int KEY_TILD          = 86;
const int KEY_F11           = 87;
const int KEY_F12           = 88;
const int KEY_NUMPADENTER   = 156;
const int KEY_RMENU         = 221;
const int KEY_PAUSE         = 197;
const int KEY_HOME          = 199;
const int KEY_UP            = 200;
const int KEY_PRIOR         = 201;
const int KEY_LEFT          = 203;
const int KEY_RIGHT         = 205;
const int KEY_END           = 207;
const int KEY_DOWN          = 208;
const int KEY_NEXT          = 209;
const int KEY_INSERT        = 210;
const int KEY_DELETE        = 211;
const int KEY_LWIN          = 219;
const int KEY_RWIN          = 220;
const int KEY_BACKSPACE     = 14;
const int KEY_NUMPADSTAR    = 55;
const int KEY_LALT          = 184;
const int KEY_CAPSLOCK      = 58;
const int KEY_NUMPADMINUS   = 74;
const int KEY_NUMPADPLUS    = 78;
const int KEY_NUMPADPERIOD  = 83;
const int KEY_DIVIDE        = 181;
const int KEY_NUMPADSLASH   = 181;
const int KEY_RALT          = 56;
const int KEY_UPARROW       = 200;
const int KEY_PGUP          = 201;
const int KEY_LEFTARROW     = 203;
const int KEY_RIGHTARROW    = 205;
const int KEY_DOWNARROW     = 208;
const int KEY_PGDN          = 209;
#endif

#ifdef __cplusplus
extern "C" {
#endif
	
// Main graphics commands
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
//! \brief Initializes iXors3D Engine and returns pointer to engine's UIView object.
//! \details This command must be executed before any other 3D command,
//! otherwise programm will return an error. 
//! \param orientation Device orientation: 0 - portrait, 1 - right aligned landscape,
//! 2 - upside down portrait, 3 - left aligned landscape.
//! \param retinaSupport Enables or disables Retina display support (have no effect on old generation devices, only for 4G)
//! \param window Rendering window pointer.
//! \ingroup maincommands
UIView * xGraphics3D(int orientation, bool retinaSupport, UIWindow * window);
#else
//! \brief Initializes iXors3D Engine and returns pointer to engine's NSView object.
//! \ingroup maincommands
NSView * xGraphics3D(int width, int height, int depth, bool fullScreen);
	
//! \brief Sets window caption for application
//! \param title Window caption
//! \ingroup maincommands
void xAppTitle(const char * title);
	
//! \brief Hide render window
//! \details You should call this method in application's delegate applicationDidResignActive method
//! to switch between applications in fullscreen
//! \ingroup maincommands
void xHideWindow();

//! \brief Show render window
//! \details You should call this method in application's delegate applicationDidBecomeActive method
//! to switch between applications in fullscreen
//! \ingroup maincommands
void xShowWindow();
#endif
	
//! \brief Recreates a framebuffer.
//! 
bool xResetGraphics();
	
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
//! \brief Enable or disble device orientations for automatical screen rotation
//! \param mask Combination of \ref devorient (0 by default)
//! \ingroup maincommands
void xEnableOrientations(int mask);

//! \brief Returns mask that contains enabled device orientation
//! \ingroup maincommands
int xOrientationsMask();

//! \brief Sets device orientation
//! \param orientation Device orientation: 0 - portrait, 1 - right aligned landscape,
//! 2 - upside down portrait, 3 - left aligned landscape.
//! \ingroup maincommands
void xSetOrientation(int orientation);

//! \brief Returns current screen orientation
//! \ingroup maincommands
int xGetOrientation();

//! \brief Returns current physical device orientation
//! \ingroup maincommands
int xDeviceOrientation();
	
//! \brief Enables or disables device screen locking
//! \details If an iPhone OS–based device does not receive touch events for
//! a specified period of time, it turns off the screen and disables the
//! touch sensor. Locking the screen in this way is an important way to save
//! power. As a result, you should leave this feature enabled except when
//! absolutely necessary to prevent unintended behavior in your application.
//! For example, you might disable screen locking if your application does
//! not receive screen events regularly but instead uses other features (such
//! as the accelerometers) for input. Screen lock enabled by default.
//! \param state Screen locking state
//! \ingroup maincommands
void xScreenLocking(bool state);
#endif
	
//! \brief Clears rendering buffer.
//! \details This command wipes the current drawing buffer clean of any
//! graphics or text present and resets the drawing buffer back to the color
//! defined by the xClsColor() command.
//! \ingroup maincommands
void xCls();

//! \brief Switches the front buffer and back buffer. 
//! \details This command should be used if you are using double buffering.
//! Double buffering is a technique used to ensure that screen updates are
//! not visible to the user. If you draw directly to the front buffer, the
//! display may appear flickery as the updates are drawn directly to the
//! screen. If you draw to the back buffer, the updates are drawn in memory.
//! xFlip() is then used to make the back buffer the front buffer, and
//! hence show the updates on screen in one go. At the same time, the
//! front buffer becomes the back buffer, allowing you to draw the next
//! screen update on the back buffer before flipping again.
//! \ingroup maincommands
void xFlip();

//! \brief Sets a clear color for xCls() command.
//! \details This function changes the color and transparency for subsequent xCls() calls.
//! Use this command if you need xCls() to 'clear' the screen with some other color
//! than black.
//! \param red Red clear color value [0; 255].
//! \param green Green clear color value [0; 255].
//! \param blue Blue clear color value [0; 255].
//! \ingroup maincommands
void xClsColor(int red, int green, int blue);

//! \brief Returns width of current rendering buffer.
//! \ingroup maincommands
int xGraphicsWidth();

//! \brief Returns height of current rendering buffer.
//! \ingroup maincommands
int xGraphicsHeight();

//! \brief Sets a viewport for 2D rendering.
//! \param x x-coordinate of top left corner of viewport.
//! \param y y-coordinate of top left corner of viewport.
//! \param width Width of viewport.
//! \param height Height of viewport.
//! \ingroup maincommands
void xViewport(int x, int y, int width, int height);
	
//! \brief Resets a viewport for 2D rendering to default values.
//! \ingroup maincommands
void xDefaultViewport();
	
//! \brief Draws a line in the current drawing color.
//! \param x Starting x location of the line.
//! \param y Starting y location of the line.
//! \param dx Ending x location of the line.
//! \param dy Ending y location of the line.
//! \ingroup maincommands
void xLine(int x, int y, int dx, int dy);

//! \brief This command sets the drawing color (using RGB values) for all
//! subsequent drawing commands (xLine(), xRect(), xText(), etc.)
//! \param red Red value of drawing color [0; 255].
//! \param green Green value of drawing color [0; 255].
//! \param blue Blue value of drawing color [0; 255].
//! \ingroup maincommands
void xColor(int red, int green, int blue);

//! \brief Draws a rectangle in the current drawing color starting at the
//! specified location.
//! \param x x coordinate to begin drawing the rectangle.
//! \param y y coordinate to begin drawing the rectangle.
//! \param width How wide to make the rectangle in pixels.
//! \param height How tall to make the rectangle in pixels.
//! \param solid False for unfilled and true for filled.
//! \ingroup maincommands
void xRect(int x, int y, int width, int height, bool solid);

//! \brief Draws an oval shape at the screen coordinates of your choice.
//! \details You can make the oval solid or hollow. 
//! \param x x coordinate on the screen to draw the oval.
//! \param y y coordinate on the screen to draw the oval.
//! \param width How wide to make the oval.
//! \param height How high to make the oval.
//! \param solid True to make the oval solid, false for hollow.
//! \ingroup maincommands
void xOval(int x, int y, int width, int height, bool solid);

//! \brief Used to put a pixel on the screen defined by its x, y
//! location in the current drawing color defined by the xColor() command 
//! \details You can make the oval solid or hollow. 
//! \param x x coordinate on the screen to draw the pixel.
//! \param y y coordinate on the screen to draw the pixel.
//! \ingroup maincommands
void xPlot(int x, int y);

//! \brief Returns a backbuffer handle.
//! \details This is a value usually used with xSetBuffer() to denote the
//! secondary non-visible drawing buffer called the Back Buffer. In MOST
//! gaming situations, you will want to be using the xBackBuffer() for
//! drawing operations then using xFlip() to bring that buffer to the
//! front buffer where it can be seen. There are other uses for the command,
//! but this is the biggie. See xSetBuffer() for more info. Once again - if
//! you set drawing operations to the xBackBuffer() you will NOT see any of
//! them until you call xFlip().
//! \ingroup maincommands
int xBackBuffer();

//! \brief Sets the current drawing buffer.
//! \details If not used the default buffer, back buffer is used. iXors3D Engine
//! currently supports rendering in back buffer only.
//! \param buffer Buffer handle.
//! \ingroup maincommands
void xSetBuffer(int buffer);

//! \brief Locks a specified buffer.
//! \details You must xUnlockBuffer() before using other graphics commands or
//! API calls, and you are advised to only keep the buffer locked for as
//! long as it is needed.
//! \param buffer Buffer handle.
//! \ingroup maincommands	
void xLockBuffer(int buffer);

//! \brief Unlocks a locked buffer.
//! \param buffer Buffer handle.
//! \ingroup maincommands
void xUnlockBuffer(int buffer);

//! \brief Reads a color value from either the current buffer or the
//! specified buffer.
//! \details The returned colour value is in the form of an integer that
//! contains the alpha, red, green and blue values of the pixel (in RGBA format). 
//! You can use this command on a locked buffer for a slight speed-up. See
//! xLockBuffer()
//! \param x x coordinate of pixel.
//! \param y y coordinate of pixel.
//! \param buffer Handle of buffer to read colour value from.
//! \ingroup maincommands
int xReadPixel(int x, int y, int buffer);

//! \brief Writes a color value to either the current buffer or the 
//! specified buffer. 
//! \details You can use this command on a locked buffer for a slight
//! speed-up. 
//! \param x x-coordinate of pixel.
//! \param y y-coordinate of pixel.
//! \param color RGBA color value of pixel (red, green, blue, alpha) [0; 255].
//! \param buffer Buffer handle.
//! \ingroup maincommands
void xWritePixel(int x, int y, int color, int buffer);

//! \brief Writes a color value to either the current buffer or the 
//! specified buffer. 
//! \details You must use this command on a locked buffer, otherwise the
//! command will fail .
//! \param x x-coordinate of pixel.
//! \param y y-coordinate of pixel.
//! \param color RGBA color value of pixel (red, green, blue, alpha) [0; 255].
//! \param buffer Buffer handle.
//! \ingroup maincommands
void xWritePixelFast(int x, int y, int color, int buffer);

//! \brief Reads a color value from either the current buffer or the
//! specified buffer. 
//! \details The returned colour value is in the form of an integer that
//! contains the alpha, red, green and blue values of the pixel (in RGBA format). 
//! You must use this command on a locked buffer, otherwise the command
//! will fail. See xLockBuffer()
//! \param x x coordinate of pixel.
//! \param y y coordinate of pixel.
//! \param buffer Handle of buffer to read colour value from.
//! \ingroup maincommands
int xReadPixelFast(int x, int y, int buffer);

//! \brief Copies pixel from source buffer to destination buffer
//! \param sourceX x coordinate of pixel in source buffer
//! \param sourceY y coordinate of pixel in source buffer
//! \param sourceBuff Handle of buffer to read color value
//! \param destX x coordinate of pixel in destination buffer
//! \param destY y coordinate of pixel in destination buffer
//! \param destBuff Handle of buffer for write color value
//! \ingroup maincommands
void xCopyPixel(int sourceX, int sourceY, int sourceBuff, int destX, int destY, int destBuff);
	
//! \brief Copies a rectangle of graphics from one buffer to another.
//! \param sourceX Source top left x location to begin copying from 
//! \param sourceY Source top left y location to begin copying from 
//! \param rectWidth Width of area to copy 
//! \param rectHeight Height of area to copy 
//! \param destX Destination top left x location to copy to 
//! \param destY Destination top left y location to copy to
//! \param sourceBuff handle to the source buffer
//! \param destBuff handle to the destination buffer
//! \ingroup maincommands
void xCopyRect(int sourceX, int sourceY, int rectWidth, int rectHeight, int destX, int destY, int sourceBuff, int destBuff);
	
//! \brief Renders the current scene to the current rendering buffer onto
//! the rectangle defined by xCameraViewport() for each camera.
//! \details Every camera not hidden by xHideEntity() or with a 
//! xCameraProjMode() greater than 0 is rendered.
//! \param tween Tweening value
//! \ingroup maincommands
void xRenderWorld(float tween);
	
//! \brief Captures the properties (position, rotation, scale, alpha) of 
//! each entity in the 3D world. 
//! \details This is then used in conjunction with the xRenderWorld()
//! tween parameter in order to render an interpolated frame between the
//! captured state of each entity and the current state of each entity. 
//! \ingroup maincommands
void xCaptureWorld();

//! \brief Sets the ambient lighting colour.
//! \details Ambient light is a light source that affects all points on a
//! 3D object equally. So with ambient light only, all 3D objects will
//! appear flat, as there will be no shading. 
//! Ambient light is useful for providing a certain level of light, before
//! adding other lights to provide a realistic lighting effect. 
//! An ambient light level of (0, 0, 0) will result in no ambient light
//! being displayed.
//! \param red Red ambient light value [0; 255].
//! \param green Green ambient light value [0; 255].
//! \param blue Blue ambient light value [0; 255].
//! \ingroup maincommands
void xAmbientLight(int red, int green, int blue);

//! \brief Animates all entities in the world and performs collision checking. 
//! The speed parameter allows you affect the animation speed of all
//! entities at once. A value of 1.0 will animate entities at their usual
//! animation speed, a value of 2.0 will animate entities at double their
//! animation speed, and so on. 
//! For best results use this command once per main loop, just before
//! calling xRenderWorld(). 
//! \param speed A master control for animation speed.
//! \ingroup maincommands
void xUpdateWorld(float speed);

//! \brief Returns a value of FPS (frames per second) counter.
//! \ingroup maincommands
int xFPSCounter();

//! \brief Returns the number of triangles rendered during last rendering cycle.
//! \ingroup maincommands
int xTrisRendered();
	
//! \brief Returns the number of draw primitive calls during last rendering cycle.
//! \ingroup maincommands
int xDIPCalls();
	
// Image commands
//! \brief This command loads an image.
//! \details Use the xDrawImage() command to display the graphics later.
//! \param path String containing a filename of image file.
//! \ingroup imagecommands
size_t xLoadImage(const char * path);

//! \brief Loads an animated image.
//! \details While similar to xLoadImage(), the xLoadAnimImage() loads a
//! single image that is made up of 'frames' of seperate images (presumably
//! to be used as frames of a graphic animation). 
//! The imagestrip itself consists of 2 or more frames, arranged in a single
//! graphic image. There is no spaces between the frames, and each frame
//! must be the same width and height. When loaded, the frames will be
//! indexed in a left-to-right, top-to-bottom fashion, starting in the top
//! left corner.
//! When drawing the image to the screen with the xDrawImage() command, you
//! specify which frame to draw with the frame parameter. 
//! To actually make your image animate, you'll need to cycle through the
//! frames (like a flip book, cartoon, or any other video) quickly to give
//! the illusion of motion.
//! \param path String designating full path and filename to image.
//! \param frameWidth Width in pixels of each frame in the image.
//! \param frameHeight Height in pixels of each frame in the image.
//! \param firstFrame The frame to start with (usually 0).
//! \param frames How many frames you are using of the imagestrip.
//! \ingroup imagecommands	
size_t xLoadAnimImage(const char * path, int frameWidth, int frameHeight, int firstFrame, int frames);

//! \brief Creates a new image with a single frame or multiple frames for
//! animation.
//! \param frameWidth Width of the new image.
//! \param frameHeight Height of the new image.
//! \param frames Number of frames. Set 1 to create an image with a single frame.
//! \ingroup imagecommands
size_t xCreateImage(int frameWidth, int frameHeight, int frames);

//! \brief Draws a previously loaded image.
//! \details This command draws both single image graphics (loaded with the
//! xLoadImage() command) as well as animated images (loaded with the
//! xLoadAnimImage() command). 
//! You specify where on the screen you wish the image to appear. You can
//! actually 'draw' off the screen as well by using negative values or
//! positive values that are not visible 'on the screen'. 
//! Finally, if you are using an animated image (loaded with the 
//! xLoadAnimImage()), you can specify which frame of the imagestrip is
//! displayed with the xDrawImage() command. 
//! \param x_image Image handle
//! \param x The x location of the screen to display the image.
//! \param y The y location of the screen to display the image.
//! \param frame The frame number of the animated image to display.
//! \ingroup imagecommands	
void xDrawImage(size_t x_image, float x, float y, int frame);

//! \brief Draws a rectangular portion of a previously loaded image.
//! \details This command draws both single image graphics (loaded with the
//! xLoadImage() command) as well as animated images (loaded with the
//! xLoadAnimImage() command). 
//! You specify where on the screen you wish the image to appear. You can
//! actually 'draw' off the screen as well by using negative values or
//! positive values that are not visible 'on the screen'. 
//! Finally, if you are using an animated image (loaded with the 
//! xLoadAnimImage()), you can specify which frame of the imagestrip is
//! displayed with the xDrawImageRect() command. 
//! \param x_image Image handle
//! \param x The x location of the screen to display the image.
//! \param y The y location of the screen to display the image.
//! \param rectX Starting x location within the image to draw.
//! \param rectY Starting y location within the image to draw.
//! \param rectWidth The width of the area to draw.
//! \param rectHeight The height of the area to draw.
//! \param frame The frame number of the animated image to display.
//! \ingroup imagecommands	
void xDrawImageRect(size_t x_image, int x, int y, int rectX, int rectY, int rectWidth, int rectHeight, int frame);
	
//! \brief Draws a previously loaded image's block.
//! \details This is similar to the xDrawImage() command except that any transparency 
//! or xMaskImage() is ignored and the entire image (including masked colors) is drawn.
//! \param x_image Image handle
//! \param x The x location of the screen to display the image.
//! \param y The y location of the screen to display the image.
//! \param frame The frame number of the animated image to display.
//! \ingroup imagecommands	
void xDrawBlock(size_t x_image, int x, int y, int frame);

//! \brief Draws a rectangular portion of a previously loaded image's block.
//! \details This is similar to the xDrawImageRect() command except that any transparency 
//! or xMaskImage() is ignored and the entire image (including masked colors) is drawn. 
//! \param x_image Image handle
//! \param x The x location of the screen to display the image.
//! \param y The y location of the screen to display the image.
//! \param rectX Starting x location within the image to draw.
//! \param rectY Starting y location within the image to draw.
//! \param rectWidth The width of the area to draw.
//! \param rectHeight The height of the area to draw.
//! \param frame The frame number of the animated image to display.
//! \ingroup imagecommands	
void xDrawBlockRect(size_t x_image, int x, int y, int rectX, int rectY, int rectWidth, int rectHeight, int frame);
	
//! \brief Rotates an image.
//! \details The purpose of this command is to rotate an image a specified
//! number of degrees. You can use it in realtime.
//! \param x_image Image handle.
//! \param angle An integer number from 0 to 360 degrees.
//! \ingroup imagecommands
void xRotateImage(size_t x_image, float angle);

//! \brief Sets drawing handle position for an image.
//! \details When an image is loaded with xLoadImage(), the image handle (the
//! location within the image where the image is 'drawn from') is always
//! defaulted to the top left corner (coordinates 0, 0). This means if you
//! draw an image that is 50x50 pixels at screen location 200, 200, the
//! image will begin to be drawn at 200, 200 and extend to 250, 250. 
//! This command moves the image handle from the 0, 0 coordinate of the
//! image to the specified x and y location in the image. You can retrieve
//! an image's current location handle using the xImageXHandle() and
//! xImageYHandle(). Finally, you can make all images automatically load
//! with the image handle set to middle using the xAutoMidHandle() command. 
//! \param x_image Image handle.
//! \param x x-coordinate of the new image drawing handle location.
//! \param y y-coordinate of the new image drawing handle location.
//! \ingroup imagecommands
void xHandleImage(size_t x_image, int x, int y);

//! \brief Resizes an image to a new size using a floating point percentage.
//! \details Use of a negative value performs image flipping. You can use it
//! in realtime.
//! \param x_image Image handle.
//! \param x The amount to scale the image horizontally.
//! \param y The amount to scale the image vertically.
//! \ingroup imagecommands
void xScaleImage(size_t x_image, float x, float y);

//! \brief Similar to xScaleImage(), but uses pixel values instead of percentages. Use
//! this command to resize an image previously loaded with xLoadImage() or xLoadAnimImage().
//! \param x_image Image handle.
//! \param width New width in pixels.
//! \param height New height in pixels.
//! \ingroup imagecommands
void xResizeImage(size_t x_image, int width, int height);

	
	
float xImageAngle(size_t x_image);
	
	
	
//! \brief Returns the width of the given image in pixels.
//! \param x_image Image handle.
//! \ingroup imagecommands
int xImageWidth(size_t x_image);

//! \brief Returns the height of the given image in pixels. 
//! \param x_image Image handle.
//! \ingroup imagecommands
int xImageHeight(size_t x_image);

//! \brief Returns x location of an image's drawing handle.
//! \param x_image Image handle.
//! \ingroup imagecommands
int xImageXHandle(size_t x_image);

//! \brief Returns y location of an image's drawing handle.
//! \param x_image Image handle.
//! \ingroup imagecommands
int xImageYHandle(size_t x_image);

//! \brief Centers image drawing handle.
//! \details When an image is loaded with xLoadImage(), the image handle
//! (the location within the image where the image is 'drawn from') is
//! always defaulted to the top left corner (coordinates 0, 0). This means
//! if you draw an image that is 50x50 pixels at screen location 200, 200,
//! the image will begin to be drawn at 200, 200 and extend to 250, 250. 
//! This command moves the image handle from the 0, 0 coordinate of the
//! image to the exact middle of the image. Therefore, in the same scenario
//! above, if you were to draw a 50x50 pixel image at screen location 200, 
//! 200 with its image handle set to Mid with this command, the image would
//! start drawing at 175, 175 and extend to 225, 225. 
//! You can manual set the location of the image's handle using the
//! xHandleImage() command. You can retrieve an image's handle using the
//! xImageXHandle() and xImageYHandle(). Finally, you can make all images
//! automatically load with the image handle set to middle using the
//! xAutoMidHandle() command. 
//! \param x_image Image handle.
//! \ingroup imagecommands
void xMidHandle(size_t x_image);

//! \brief Enables or disables auto appling xMidhandle() for all loading images.
//! \details When an image is loaded with xLoadImage(), the image handle
//! (the location within the image where the image is 'drawn from') is
//! always defaulted to the top left corner (coordinates 0, 0). This means
//! if you draw an image that is 50x50 pixels at screen location (200, 200),
//! the image will begin to be drawn at (200, 200) and extend to (250, 250). 
//! The xMidHandle() command moves the image's handle to the middle of the
//! image. See this command for more information about the image's handle. 
//! This command eliminates the need for the xMidHandle() command by making
//! ALL subsequently loaded images default to having their image handles
//! set to mid.
//! \param state If true - images will be loaded with auto midhandle, otherwise if
//! false.
//! \ingroup imagecommands
void xAutoMidHandle(bool state);

//! \brief Frees up an image.
//! \param x_image Image handle.
//! \ingroup imagecommands
void xFreeImage(size_t x_image);

//! \brief Returns specified image buffer handle.
//! \details You can use it to draw into image directly.
//! \param x_image Image handle.
//! \param frame Frame of animated image.
//! \ingroup imagecommands
int xImageBuffer(size_t x_image, int frame);

//! \brief Checks if image is picked in specified location.
//! \param x_image Image handle.
//! \param x x coordinate of image.
//! \param y y coordinate of image.
//! \param frame Frame of animated image.
//! \param px x coordinate of pick.
//! \param py y coordinate of pick.
//! \ingroup imagecommands
bool xImagePicked(size_t x_image, int x, int y, int frame, int px, int py);

//! \brief Checks if image's box is picked in specified location.
//! \param x_image Image handle.
//! \param x x coordinate of image.
//! \param y y coordinate of image.
//! \param px x coordinate of pick.
//! \param py y coordinate of pick.
//! \ingroup imagecommands
bool xImageBoxPicked(size_t x_image, int x, int y, int px, int py);

//! \brief Checks if images have collided.
//! \details This is the command to get pixel-perfect collisions between
//! images. It will not consider transparent pixels during the collision
//! check (basically, only the 'meat' of the image will invoke a collision).
//! This makes it perfect for most situations where you have odd-shaped
//! graphics to text against. 
//! The xImagesOverlap() command is mesh faster, however, but can only
//! determine if any of the two images have overlapped (this includes
//! transparent pixels). This method works if you have graphics that
//! completely fill their container and/or you don't plan on needing
//! pinpoint accuracy. 
//! \param x_image1 First image handle.
//! \param x1 First image x location.
//! \param y1 First image y location.
//! \param frame1 First image frame.
//! \param x_image2 Second image handle.
//! \param x2 Second image x location.
//! \param y2 Second image y location.
//! \param frame2 Second image frame.
//! \ingroup imagecommands
bool xImagesCollide(size_t x_image1, int x1, int y1, int frame1, size_t x_image2, int x2, int y2, int frame2);

//! \brief Checks if images are overlapped.
//! \details This is a very fast, simple collision type command that will
//! allow you to determine whether or not two images have overlapped each
//! other. This does not take into account any transparent pixels (see 
//! xImagesCollide()). 
//! In many cases, you might be able to get away with using this more
//! crude, yet quite fast method of collision detection. For games where
//! your graphics are very squared off and pixel-perfect accuracy isn't a
//! must, you can employ this command to do quick and dirty overlap checking. 
//! \param x_image1 First image handle.
//! \param x1 First image x location.
//! \param y1 First image y location.
//! \param x_image2 Second image handle.
//! \param x2 Second image x location.
//! \param y2 Second image y location.
//! \ingroup imagecommands
bool xImagesOverlap(size_t x_image1, int x1, int y1, size_t x_image2, int x2, int y2);

//! \brief Checks if image has collided with a rectangle on the screen.
//! \details There are many times when you need to see if an image has
//! collided with (or is touching) a specific rectangular area of the
//! screen. This command performs pixel perfect accurate collision
//! detection between the image of your choice and a specified rectangle on 
//! the screen. 
//! Howevever, should your program just need to detect a graphic (like a
//! mouse pointer) over at a particular location/region of the screen
//! (often called a 'hot spot'), this command works great.
//! As with any collision, you will need to know the PRECISE location of
//! the graphic you wish to test collision with, as well as the x, y,
//! width, and height of the screen area (rect) you wish to test.
//! \param x_image Image handle.
//! \param x Image's x location.
//! \param y Image's y location.
//! \param frame Image's frame.
//! \param rectx x location start of the rect.
//! \param recty y location start of the rect.
//! \param rectWidth Width of the rect.
//! \param rectHeight Height of the rect.
//! \ingroup imagecommands
bool xImageRectCollide(size_t x_image, int x, int y, int frame, int rectx, int recty, int rectWidth, int rectHeight);

//! \brief Checks if image is overlapped with a rectangle on the screen.
//! \param x_image Image handle.
//! \param x Image's x location.
//! \param y Image's y location.
//! \param rectx x location start of the rect.
//! \param recty y location start of the rect.
//! \param rectWidth Width of the rect.
//! \param rectHeight Height of the rect.
//! \ingroup imagecommands
bool xImageRectOverlap(size_t x_image, int x, int y, int rectx, int recty, int rectWidth, int rectHeight);

//! \brief This command will take two rectangular locations on the screen and see if they overlap.
//! \details You will need to know the x, y, width, and height of both regions to test.
//! Unlike the other collision commands, there is no image to detect a collision with -
//! simply one rectangular location overlapping another.
//! You could probably use this command instead of the xImageRectOverlap() command,
//! as they are really basically doing the same thing (and this is faster). 
//! \param rect1X First rect x location.
//! \param rect1Y First rect y location.
//! \param rect1Width Width of the first rect.
//! \param rect1Height Height of the first rect.
//! \param rect2X Second rect x location.
//! \param rect2Y Second rect y location.
//! \param rect2Width Width of the second rect.
//! \param rect2Height Height of the second rect.
//! \ingroup imagecommands
bool xRectsOverlap(int rect1X, int rect1Y, int rect1Width, int rect1Height, int rect2X, int rect2Y, int rect2Width, int rect2Height);

//! \brief Sets a transparent color of image
//! \param x_image Image handle.
//! \param red Red color value [0; 255].
//! \param green Green color value [0; 255].
//! \param blue Blue color value [0; 255].
//! \ingroup imagecommands
void xMaskImage(size_t x_image, int red, int green, int blue);

//! \brief Creates a copy of image.
//! \param x_image Image handle.
//! \ingroup imagecommands
size_t xCopyImage(size_t x_image);

//! \brief Sets a color of image.
//! \param x_image Image handle.
//! \param red Red value of color [0; 255].
//! \param green Green value of color [0; 255].
//! \param blue Blue value of color [0; 255].
//! \ingroup imagecommands
void xImageColor(size_t x_image, int red, int green, int blue);

//! \brief Sets an alpha value of image.
//! \param x_image Image handle.
//! \param alpha Alpha value in range [0.0; 1.0].
//! \ingroup imagecommands
void xImageAlpha(size_t x_image, float alpha);
	
//! \brief Sets a blending mode of image.
//! \param x_image Image handle.
//! \param mode Blending mode. See '\ref imgblendtypes' for more information.
//! \ingroup imagecommands
void xImageBlend(size_t x_image, int mode);

//! \brief Sets a global 2D rendering color.
//! \details Global color value will be applied for all drawn images.
//! \param red Red value of color.
//! \param green Green value of color.
//! \param blue Blue value of color.
//! \ingroup maincommands
void xSetGlobalColor(int red, int green, int blue);

//! \brief Sets a global 2D rendering alpha value.
//! \details Global alpha value will be applied for all drawn images.
//! \param alpha Alpha value in range [0.0; 1.0].
//! \ingroup maincommands
void xSetGlobalAlpha(float alpha);

//! \brief Sets a global 2D rendering blending mode.
//! \details If IMGBLEND_LOCAL is specified a local image blend mode is used.
//! \param mode Blending mode. See '\ref imgblendtypes' for more information.
//! \ingroup maincommands
void xSetGlobalBlend(int mode);
	
//! \brief Sets a global 2D rendering rotation.
//! \details Global rotation will be added for all drawn images
//! \param angle Number from 0 to 360 degrees.
//! \ingroup maincommands
void xSetGlobalRotate(float angle);

//! \brief Sets a global 2D drawing handle position.
//! \details Global handle will be added for all drawn images.
//! \param x x coordinate of the global drawing handle location.
//! \param y y coordinate of the global drawing handle location.
//! \ingroup maincommands
void xSetGlobalHandle(int x, int y);

//! \brief Sets a global 2D rendering scale.
//! \details Global scale will be applied for all drawn images.
//! \param x The amount to scale the image horizontally.
//! \param y The amount to scale the image vertically.
//! \ingroup maincommands
void xSetGlobalScale(float x, float y);
	
// Surfaces commands
//! \brief Adds a vertex to the specified surface and returns the vertices
//! index number, starting from 0. 
//! \details 'x', 'y', 'z' are the geometric coordinates of the vertex, and
//! 'u', 'v', 'w' are texture mapping coordinates. 
//! A vertex is a point in 3D space which is used to connect edges of a
//! triangle together. Without any vertices, you can't have any triangles.
//! At least three vertices are needed to create one triangle; one for each
//! corner. 
//! The optional 'u', 'v' and 'w' parameters allow you to specify texture
//! coordinates for a vertex, which will determine how any triangle created
//! using those vertices will be texture mapped. The 'u', 'v' and 'w'
//! parameters specified will take effect on both texture coordinate sets
//! (0 and 1). This works on the following basis:
//!
//! The top left of an image has the uv coordinates 0.0, 0.0. 
//!
//! The top right has coordinates 1.0, 0.0 
//!
//! The bottom right is 1.0, 1.0 
//!
//! The bottom left 0.0, 1.0 
//!
//! Thus, uv coordinates for a vertex correspond to a point in the image.
//! For example, coordinates 0.9, 0.1 would be near the upper right corner
//! of the image. 
//! So now imagine you have a normal equilateral triangle. By assigning the
//! bottom left vertex a uv coordinate of 0.0, 0.0, the bottom right a
//! coordinate of 1.0, 0.0 and the top centre 0.5, 1.0, this will texture
//! map the triangle with an image that fits it. 
//! When adding a vertex its default color is 255, 255, 255, 255.
//! \param surface Surface handle.
//! \param x x coordinate of vertex.
//! \param y y coordinate of vertex.
//! \param z z coordinate of vertex.
//! \param tu u texture coordinate of vertex.
//! \param tv v texture coordinate of vertex.
//! expansion 
//! \ingroup surfcommands
int xAddVertex(size_t surface, float x, float y, float z, float tu, float tv);

//! \brief Adds a triangle to a surface and returns the triangle's index
//! number, starting from 0.
//! \details The v0, v1 and v2 parameters are the index numbers of the
//! vertices created using xAddVertex(). 
//! Depending on how the vertices are arranged, then the triangle will only
//! be visible from a certain side. Imagine that a triangle's vertex points
//! are like dot-to-dot pattern, each numbered v0, v1, v2. If these dots,
//! starting from v0, through to V2, form a clockwise pattern relative to
//! the viewer, then the triangle will be visible. If these dots form an
//! anti-clockwise pattern relative to the viewer, then the triangle will
//! not be visible. 
//! The reason for having one-sided triangles is that it reduces the amount
//! of triangles that need to be rendered when one side faces the side of
//! an object which won't be seen (such as the inside of a snooker ball).
//! However, if you wish for a triangle to be two-sided, then you can either
//! create two triangles, using the same set of vertex numbers for both but
//! assigning them in opposite orders, or you can use xCopyEntity() and
//! xFlipMesh() together.
//! \param surface Surface handle.
//! \param v0 Index number of first vertex of triangle.
//! \param v1 Index number of second vertex of triangle.
//! \param v2 Index number of third vertex of triangle.
//! \see xAddVertex()
//! \ingroup surfcommands
int xAddTriangle(size_t surface, int v0, int v1, int v2);

//! \brief Sets the geometric coordinates of an existing vertex. 
//! \details This is the command used to perform what is commonly referred
//! to as 'dynamic mesh deformation'. It will reposition a vertex so that
//! all the triangle edges connected to it, will move also. This will give
//! the effect of parts of the mesh suddenly deforming. 
//! \param surface Surface handle.
//! \param index Vertex index.
//! \param x x position of vertex.
//! \param y y position of vertex.
//! \param z z position of vertex.
//! \ingroup surfcommands
void xVertexCoords(size_t surface, int index, float x, float y, float z);

//! \brief Sets the normal of an existing vertex.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \param x Normal x of vertex.
//! \param y Normal y of vertex.
//! \param z Normal z of vertex.
//! \ingroup surfcommands
void xVertexNormal(size_t surface, int index, float x, float y, float z);

//! \brief Sets the color of an existing vertex.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \param red Red value of vertex color.
//! \param green Green value of vertex color.
//! \param blue Blue value of vertex color.
//! \param alpha Alpha value of vertex color.
//! \ingroup surfcommands
void xVertexColor(size_t surface, int index, int red, int green, int blue, float alpha);

//! \brief Sets the texture coordinates of an existing vertex.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \param tu u coordinate of vertex.
//! \param tv v coordinate of vertex.
//! \param tw w coordinate of vertex.
//! \param setNum Texture coodrinates set. Should be set to 0 or 1.
//! \ingroup surfcommands
void xVertexTexCoords(size_t surface, int index, float tu, float tv, float tw, int setNum);

//! \brief Returns the number of vertices in a surface.
//! \param surface Surface handle.
//! \ingroup surfcommands
int xCountVertices(size_t surface);

//! \brief Returns the number of triangles in a surface.
//! \param surface Surface handle.
//! \ingroup surfcommands
int xCountTriangles(size_t surface);

//! \brief Returns the x coordinate of a vertex.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \ingroup surfcommands
float xVertexX(size_t surface, int index);

//! \brief Returns the y coordinate of a vertex.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \ingroup surfcommands
float xVertexY(size_t surface, int index);

//! \brief Returns the z coordinate of a vertex.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \ingroup surfcommands
float xVertexZ(size_t surface, int index);

//! \brief Returns the x component of a vertex normal.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \ingroup surfcommands
float xVertexNX(size_t surface, int index);

//! \brief Returns the y component of a vertex normal.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \ingroup surfcommands
float xVertexNY(size_t surface, int index);

//! \brief Returns the z component of a vertex normal.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \ingroup surfcommands
float xVertexNZ(size_t surface, int index);

//! \brief Returns the red component of a vertices color.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \ingroup surfcommands
int xVertexRed(size_t surface, int index);

//! \brief Returns the green component of a vertices color.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \ingroup surfcommands
int xVertexGreen(size_t surface, int index);

//! \brief Returns the blue component of a vertices color.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \ingroup surfcommands
int xVertexBlue(size_t surface, int index);

//! \brief Returns the alpha component of a vertices color, set using xVertexColor().
//! \param surface Surface handle.
//! \param index Vertex index.
//! \ingroup surfcommands
float xVertexAlpha(size_t surface, int index);

//! \brief Returns the texture u coordinate of a vertex.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \param setNum Texture coodrinates set. Should be set to 0 or 1.
//! \ingroup surfcommands
float xVertexU(size_t surface, int index, int setNum);

//! \brief Returns the texture v coordinate of a vertex.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \param setNum Texture coodrinates set. Should be set to 0 or 1.
//! \ingroup surfcommands
float xVertexV(size_t surface, int index, int setNum);

//! \brief Returns the texture w coordinate of a vertex.
//! \param surface Surface handle.
//! \param index Vertex index.
//! \param setNum Texture coodrinates set. Should be set to 0 or 1.
//! \ingroup surfcommands
float xVertexW(size_t surface, int index, int setNum);

//! \brief Returns the vertex of a triangle corner.
//! \param surface Surface handle.
//! \param index Triangle index.
//! \param corner Corner of triangle. Should be 0, 1 or 2.
//! \ingroup surfcommands
int xTriangleVertex(size_t surface, int index, int corner);

//! \brief Removes all vertices and/or triangles from a surface.
//! \details This is useful for clearing sections of mesh. The results will
//! be instantly visible.
//! After clearing a surface, you may wish to add vertices and triangles to
//! it again but with a slightly different polygon count for dynamic level
//! of detail (LOD).
//! \param surface Surface handle.
//! \param vertices True to remove all vertices from the specified
//! surface, false not to.
//! \param triangles True to remove all triangles from the specified
//! surface, false not to.
//! \ingroup surfcommands
void xClearSurface(size_t surface, bool vertices, bool triangles);

//! \brief Paints a surface with a brush. 
//! \details This has the effect of instantly altering the visible appearance
//! of that particular surface, i.e. section of mesh, assuming the brush's
//! properties are different to what was applied to the surface before.
//! \param surface Surface handle.
//! \param brush Brush handle.
//! \ingroup surfcommands
void xPaintSurface(size_t surface, size_t brush);

//! \brief Creates a surface attached to a mesh and returns the surface's handle. 
//! \details Surfaces are sections of mesh which are then used to attach
//! triangles to. You must have at least one surface per mesh in order to
//! create a visible mesh, however you can use as many as you like.
//! Splitting a mesh up into lots of sections allows you to affect those
//! sections individually, which can be a lot more useful than if all the
//! surfaces are combined into just one. 
//! \param entity Entity handle.
//! \param brush Brush handle.
//! \ingroup surfcommands
size_t xCreateSurface(size_t entity, size_t brush);

//! \brief Attempts to find a surface attached to the specified mesh and
//! created with the specified brush.
//! \details Returns the surface handle if found or 0 if not. 
//! \param entity Entity handle.
//! \param brush Brush handle.
//! \ingroup surfcommands
size_t xFindSurface(size_t entity, size_t brush);
	
// Brush commands
//! \brief Creates a brush and returns a brush handle. 
//! \details The green, red and blue values allow you to set the colour of
//! the brush. Values should be in the range [0; 255]. If omitted the
//! values default to 255.
//! A brush is a collection of properties such as color, alpha, shininess, 
//! textures, etc that are all stored as part of the brush. Then, all these
//! properties can be applied to an entity, mesh or surface at once just by
//! using xPaintEntity(), xPaintMesh() or xPaintSurface().
//! When creating your own mesh, if you wish for certain surfaces to look
//! differently from one another, then you will need to use brushes to paint
//! individual surfaces. Using commands such as xEntityColor(),
//! xEntityAlpha() will apply the effect to all surfaces at once, which may
//! not be what you wish to achieve.
//! \param red Brush red value.
//! \param green Brush green value.
//! \param blue Brush blue value.
//! \ingroup brushcommands
size_t xCreateBrush(int red, int green, int blue);

//! \brief Creates a brush, loads and assigns a texture to it, and returns
//! a brush handle.
//! \param path Filename of texture.
//! \param flags Loading flags. See '\ref tlflags' for more information.
//! \param uscale Brush u scale.
//! \param vscale Brush v scale.
//! \ingroup brushcommands
size_t xLoadBrush(const char * path, int flags, float uscale, float vscale);

//! \brief Frees up a brush.
//! \param brush Brush handle.
//! \ingroup brushcommands
void xFreeBrush(size_t brush);

//! \brief Sets the colour of a brush. 
//! \details The green, red and blue values should be in the range [0; 255].
//! The default brush color is 255, 255, 255. 
//! Please note that if xEntityFX() or xBrushFX() flag FX_VERTEXCOLOR is
//! being used, brush colour will have no effect and vertex colours will
//! be used instead. 
//! \param brush Brush handle.
//! \param red Red value of brush.
//! \param green Green value of brush.
//! \param blue Blue value of brush.
//! \ingroup brushcommands
void xBrushColor(size_t brush, int red, int green, int blue);

//! \brief Sets the alpha level of a brush.
//! \details The alpha value should be in the range [0.0; 1.0]. The default
//! brush alpha setting is 1.0.
//! The alpha level is how transparent an entity is. A value of 1.0 will
//! mean the entity is non-transparent, i.e. opaque. A value of 0.0 will
//! mean the entity is completely transparent, i.e. invisible. Values
//! between 0.0 and 1.0 will cause varying amount of transparency
//! accordingly, useful for imitating the look of objects such as glass
//! and ice.
//! \param brush Brush handle.
//! \param alpha Alpha level of brush.
//! \ingroup brushcommands
void xBrushAlpha(size_t brush, float alpha);

//! \brief Sets the specular shininess of a brush.
//! \details The shininess value should be in the range [0.0; 1.0]. The
//! default shininess setting is 0.0 .
//! Shininess is how much brighter certain areas of an object will appear
//! to be when a light is shone directly at them.
//! Setting a shininess value of 1.0 for a medium to high poly sphere,
//! combined with the creation of a light shining in the direction of it,
//! will give it the appearance of a shiny snooker ball.
//! \param brush Brush handle.
//! \param shininess Shininess of brush.
//! \ingroup brushcommands
void xBrushShininess(size_t brush, float shininess);

//! \brief Assigns a texture to a brush.
//! \details The optional frame parameter specifies which animation frame,
//! if any exist, should be assigned to the brush.
//! The optional index parameter specifies texture layer that the texture
//! should be assigned to.
//! \param brush Brush handle.
//! \param texture Texture handle.
//! \param frame Texture frame.
//! \param index Texture layer.
//! \ingroup brushcommands
void xBrushTexture(size_t brush, size_t texture, int frame, int index);

//! \brief Sets the blending mode for a brush.
//! \param brush Brush handle.
//! \param blend Blending type. See '\ref entblendtypes' for more infromation.
//! \ingroup brushcommands
void xBrushBlend(size_t brush, int blend);

//! \brief Sets miscellaneous effects for a brush.
//! \details Flags can be added to combine two or more effects.
//! \param brush Brush handle.
//! \param fx ffects flags See '\ref fxflags' for more infromation.
//! \ingroup brushcommands
void xBrushFX(size_t brush, int fx);

//! \brief Returns an entity's brush.
//! \param entity Entity handle.
//! \ingroup escommands
size_t xGetEntityBrush(size_t entity);

//! \brief Returns a brush with the same properties as is applied to the
//! specified mesh surface. 
//! \details If this command does not appear to be returning a valid brush,
//! try using xGetEntityBrush() instead. 
//! Remember, xGetSurfaceBrush() actually creates a new brush so don't
//! forget to free it afterwards using xFreeBrush() to prevent memory leaks. 
//! Once you have got the brush handle from a surface, you can use
//! xGetBrushTexture() and xTextureName() to get the details of what
//! texture(s) are applied to the brush. 
//! \param surface Surface handle.
//! \ingroup surfcommands
size_t xGetSurfaceBrush(size_t surface);

//! \brief Returns texture assigned to brush.
//! \param brush Brush handle.
//! \param index Texture layer index. Must be in range 0-7.
//! \ingroup brushcommands
size_t xGetBrushTexture(size_t brush, int index);
	
// Texture commands
//! \brief Creates a texture and returns its handle.
//! \details Width and height are the size of the texture. Note that the
//! actual texture size may be different from the width and height
//! requested, as different types of 3D hardware support different sizes
//! of texture.
//! The optional flags parameter allows you to apply certain effects to the
//! texture. Flags can be added to combine two or more effects. See '\ref
//! tlflags' for more information.
//! Once you have created a texture, use xSetBuffer(xTextureBuffer()) to
//! draw to it. iXors3D supports direct rendering into textures.
//! \param width Width of texture.
//! \param height Height of texture.
//! \param flags Texture creation flags.
//! \param frames Number of frames the texture will have.
//! \ingroup texcommands
size_t xCreateTexture(int width, int height, int flags, int frames);

//! \brief Loads a texture from an image file and returns the texture's handle.
//! \details The optional flags parameter allows you to apply certain effects
//! to the texture. Flags can be added to combine two or more effects. See
//! '\ref tlflags' for more infromation. Supported file formats: 
//! bmp, dds, dib, hdr, jpg, pfm, png, ppm, tga.
//! \param path Filename of image file to be used as texture.
//! \param flags Loading flags.
//! \ingroup texcommands
size_t xLoadTexture(const char * path, int flags);

//! \brief Loads an animated texture.
//! \details The 'flags' parameter allows you to apply certain effects to the
//! texture. Flags can be added to combine two or more effects. See '\ref 
//! tlflags' for more infromation.
//! \param path Name of image file.
//! \param flags Loading flags.
//! \param frameWidth Width in pixels of each frame in the texture.
//! \param frameHeight Height in pixels of each frame in the texture.
//! \param firstFrame The frame to start with (usually 0).
//! \param frames How many frames you are using of the imagestrip .
//! \ingroup texcommands
size_t xLoadAnimTexture(const char * path, int flags, int frameWidth, int frameHeight, int firstFrame, int frames);

//! \brief Frees up a texture.
//! \param texture Texture handle.
//! \ingroup texcommands
void xFreeTexture(size_t texture);

//! \brief Sets the blending mode for a texture. 
//! \details The texture blend mode determines how the texture will blend
//! with the texture or polygon which is 'below' it. Texture 0 will blend
//! with the polygons of the entity it is applied to. Texture 1 will blend
//! with texture 0. Texture 2 will blend with texture 1. And so on. 
//! Texture blending effectively takes the highest order texture (the one
//! with the highest index) and it blends with the texture below it, then
//! that result to the texture directly below again, and so on until
//! texture 0 which is blended with the polygons of the entity it is
//! applied to and thus the world, depending on the xEntityBlend() of the
//! object. 
//! Each of the blend modes are identical to their xEntityBlend()
//! counterparts.
//! \param texture Texture handle.
//! \param blend Blending mode. See '\ref texblendtypes' for more infromation.
//! \ingroup texcommands
void xTextureBlend(size_t texture, int blend);

//! \brief Sets the texture coordinate mode for a texture. 
//! \details This determines where the UV values used to look up a texture
//! come from.
//! \param texture Texture handle.
//! \param setNum UV coordinates number (0 or 1).
//! \ingroup texcommands
void xTextureCoords(size_t texture, int setNum);

//! \brief Scales a texture by an absolute amount. 
//! \details This will have an immediate effect on all instances of the
//! texture being used.
//! \param texture Texture handle.
//! \param u x scale of texture.
//! \param v y scale of texture.
//! \ingroup texcommands
void xScaleTexture(size_t texture, float u, float v);

//! \brief Positions a texture at an absolute position. 
//! \details This will have an immediate effect on all instances of the
//! texture being used. 
//! Positioning a texture is useful for performing scrolling texture
//! effects, such as for water etc.
//! \param texture Texture handle.
//! \param u u position of texture.
//! \param v v position of texture.
//! \ingroup texcommands
void xPositionTexture(size_t texture, float u, float v);

//! \brief Rotates a texture. 
//! \details This will have an immediate effect on all instances of the
//! texture being used. 
//! Rotating a texture is useful for performing swirling texture effects,
//! such as for smoke etc.
//! \param texture Texture handle.
//! \param angle Rotation angle.
//! \ingroup texcommands
void xRotateTexture(size_t texture, float angle);

//! \brief Returns the width of a texture.
//! \param texture Texture handle
//! \ingroup texcommands
int xTextureWidth(size_t texture);

//! \brief Returns the height of a texture.
//! \param texture Texture handle.
//! \ingroup texcommands
int xTextureHeight(size_t texture);

//! \brief Returns the handle of a texture's drawing buffer. 
//! \param texture Texture handle.
//! \param frame Texture frame.
//! \ingroup texcommands
int xTextureBuffer(size_t texture, int frame);

//! \brief Returns a texture's absolute filename. 
//! \details To find out just the name of the texture, you will need to
//! parse the string returned by xTextureName().
//! \param texture Texture handle.
//! \ingroup texcommands
const char * xTextureName(size_t texture);

// Mesh commands
//! \brief Creates a 'blank' mesh entity and returns its handle. 
//! \details When a mesh is first created it has no surfaces, vertices or
//! triangles associated with it.
//! \param parent Parent entity handle.
//! \ingroup meshcommands
size_t xCreateMesh(size_t parent);
	
//! \brief Returns true if the specified meshes are currently intersecting
//! \param firstMesh First entity handle
//! \param secondMesh Second entity handle
//! \ingroup meshcommands
bool xMeshesIntersect(size_t firstMesh, size_t secondMesh);

//! \brief Creates a pivot entity. 
//! \details A pivot entity is an invisible point in 3D space that's main
//! use is to act as a parent entity to other entities. The pivot can then
//! be used to control lots of entities at once, or act as new centre of
//! rotation for other entities. 
//! To enforce this relationship use xEntityParent() or make use of the
//! optional parent entity parameter available with all entity
//! load/creation commands. 
//! Indeed, this parameter is also available with the xCreatePivot()
//! command if you wish for the pivot to have a parent entity itself. 
//! \param parent Parent entity handle.
//! \ingroup meshcommands
size_t xCreatePivot(size_t parent);

//! \brief Similar to xLoadMesh(), loads a mesh from .B3D or .MD2 file and returns
//! a mesh handle. 
//! \details The difference between xLoadMesh() and xLoadAnimMesh() is that
//! any hierarchy and animation information present in the file is retained.
//! You can then either activate the animation by using the xAnimate()
//! command or find child entities within the hierarchy by using the
//! xFindChild(), xGetChild() functions. 
//! The parent parameter allows you to specify a parent entity for the mesh
//! so that when the parent is moved the child mesh will move with it.
//! However, this relationship is one way; applying movement commands to
//! the child will not affect the parent. 
//! Specifying a parent entity will still result in the mesh being created
//! at position 0, 0, 0 rather than at the parent entity's position.
//! \param path Name of the file containing the model to load.
//! \param parent Parent entity handle.
//! \ingroup meshcommands
size_t xLoadAnimMesh(const char * path, size_t parent);

//! \brief Loads a mesh from a .B3D or .MD2 file and returns the mesh handle. 
//! \details Any hierarchy and animation information in the file will be
//! ignored. Use xLoadAnimMesh() to maintain hierarchy and animation
//! information. 
//! The parent parameter allows you to specify a parent entity for
//! the mesh so that when the parent is moved the child mesh will move with
//! it. However, this relationship is one way; applying movement commands
//! to the child will not affect the parent. 
//! Specifying a parent entity will still result in the mesh being created
//! at position 0, 0, 0 rather than at the parent entity's position. 
//! \param path Name of the file containing the model to load.
//! \param parent Parent entity handle.
//! \ingroup meshcommands
size_t xLoadMesh(const char * path, size_t parent);

//! \brief Returns the number of surfaces in a mesh.
//! \details Surfaces are sections of mesh. A mesh may contain only one
//! section, or very many.
//! \param entity Entity handle.
//! \ingroup meshcommands
int xCountSurfaces(size_t entity);

//! \brief Returns the handle of the surface attached to the specified mesh
//! and with the specified index number. 
//! \details Index should be in the range [0; CountSurfaces(entity) - 1] 
//! You need to 'get a surface', i.e. get its handle, in order to be able
//! to then use that particular surface with other commands.
//! \param entity Entity handle.
//! \param index Index of surface.
//! \ingroup meshcommands
size_t xGetSurface(size_t entity, int index);

//! \brief Creates a cube mesh/entity and returns its handle. 
//! \details The cube will extend from -1, -1, -1 to +1, +1, +1. 
//! The optional parent parameter allows you to specify a parent entity for
//! the cube so that when the parent is moved the child cube will move with
//! it. However, this relationship is one way; applying movement commands
//! to the child will not affect the parent. 
//! Specifying a parent entity will still result in the cube being created
//! at position 0, 0, 0 rather than at the parent entity's position. 
//! Creation of cubes, cylinders and cones are a great way of getting
//! scenes set up quickly, as they can act as placeholders for more complex
//! pre-modeled meshes later on in program development. 
//! \param parent Parent entity handle
//! \ingroup meshcommands
size_t xCreateCube(size_t parent);

//! \brief Creates a sphere mesh/entity and returns its handle. 
//! \details The sphere will be centred at 0, 0, 0 and will have a radius
//! of 1. 
//! The segments value must be in the range 2-100 inclusive.
//! 
//! Example segments values: 
//! 
//! 8: 224 polygons - bare minimum amount of polygons for a sphere.
//! 
//! 16: 960 polygons - smooth looking sphere at medium-high distances.
//! 
//! 32: 3968 polygons - smooth sphere at close distances.
//! 
//! The parent parameter allow you to specify a parent entity for
//! the sphere so that when the parent is moved the child sphere will move
//! with it. However, this relationship is one way; applying movement
//! commands to the child will not affect the parent. 
//! Specifying a parent entity will still result in the sphere being
//! created at position 0, 0, 0 rather than at the parent entity's position. 
//! \param segments Sphere detail.
//! \param parent Parent entity handle.
//! \ingroup meshcommands
size_t xCreateSphere(int segments, size_t parent);

//! \brief Creates a cylinder mesh/entity and returns its handle. 
//! \details The cylinder will be centred at 0, 0, 0 and will have a radius
//! of 1. 
//! The segments value must be in the range 3-100 inclusive.
//! Example segments values (solid mesh): 
//!
//! 3: 8 polygons - a prism.
//!
//! 8: 28 polygons - bare minimum amount of polygons for a cylinder.
//! 
//! 16: 60 polygons - smooth cylinder at medium-high distances.
//! 
//! 32: 124 polygons - smooth cylinder at close distances.
//! 
//! The optional parent parameter allow you to specify a parent entity for
//! the cylinder so that when the parent is moved the child cylinder will
//! move with it. However, this relationship is one way; applying movement
//! commands to the child will not affect the parent. 
//! Specifying a parent entity will still result in the cylinder being
//! created at position 0, 0, 0 rather than at the parent entity's position. 
//! \param segments Cylinder detail.
//! \param solid True for a cone with a base, false for a cone without a base.
//! \param parent Parent entity handle.
//! \ingroup meshcommands
size_t xCreateCyllinder(int segments, bool solid, size_t parent);

//! \brief Creates a cone mesh/entity and returns its handle. 
//! \details The cone will be centred at 0, 0, 0 and the base of the cone
//! will have a radius of 1. 
//! The segments value must be in the range 3-100 inclusive. 
//! Example segments values (solid mesh): 
//! 
//! 4: 6 polygons - a pyramid.
//! 
//! 8: 14 polygons - bare minimum amount of polygons for a cone.
//!
//! 16: 30 polygons - smooth cone at medium-high distances.
//!
//! 32: 62 polygons - smooth cone at close distances.
//!
//! The optional parent parameter allow you to specify a parent entity for
//! the cone so that when the parent is moved the child cone will move with
//! it. However, this relationship is one way; applying movement commands
//! to the child will not affect the parent. 
//! Specifying a parent entity will still result in the cone being created
//! at position 0, 0, 0 rather than at the parent entity's position. 
//! \param segments Cone detail.
//! \param solid True for a cone with a base, false for a cone without a base.
//! \param parent Parent entity handle.
//! \ingroup meshcommands
size_t xCreateCone(int segments, bool solid, size_t parent);

//! \brief Adds the source mesh to the destination mesh. 
//! \details xAddMesh() works best with meshes that have previously only
//! had mesh commands used with them. So if you want to manipulate a mesh
//! before adding it to another mesh, make sure you use xScaleMesh(),
//! xPositionMesh(), xPaintMesh() etc rather than xScaleEntity(),
//! xPositionEntity(), xEntityTexture() etc before using xAddMesh(). 
//! However, something to be aware of when using commands such as
//! xRotateMesh is that all mesh commands work from a global origin of
//! (0, 0, 0). Therefore it is generally a good idea to scale and rotate a
//! mesh before positioning it, otherwise your mesh could end up in
//! unexpected positions. Also, when using xAddMesh(), the origin of the new
//! all-in-one mesh will be set at (0, 0, 0). 
//! After using xAddMesh(), the original 'srcMesh' mesh will still exist,
//! therefore use xFreeEntity() to delete it if you wish to do so.
//! \param srcMesh Source mesh.
//! \param destMesh Destination mesh.
//! \ingroup meshcommands
void xAddMesh(size_t srcMesh, size_t destMesh);

//! \brief Flips all the triangles in a mesh.
//! \details This is useful for a couple of reasons. Firstly though, it is
//! important to understand a little bit of the theory behind 3D graphics.
//! A 3D triangle is represented by three points; only when these points
//! are presented to the viewer in a clockwise-fashion is the triangle
//! visible. So really, triangles only have one side. 
//! Normally, for example in the case of a sphere, a model's triangles face
//! the inside of the model, so it doesn't matter that you can't see them.
//! However, what about if you wanted to use the sphere as a huge sky for
//! your world, i.e. so you only needed to see the inside? In this case you
//! would just use xFlipMesh(). 
//! Another use for xFlipMesh() is to make objects two-sided, so you can
//! see them from the inside and outside if you can't already. In this
//! case, you can copy the original mesh using xCopyEntity(), specifying
//! the original mesh as the parent, and flip it using xFlipMesh(). You
//! will now have two meshes occupying the same space - this will make it
//! double-sided, but beware, it will also double the polygon count.
//! The above technique is worth trying when an external modelling program
//! has exported a model in such a way that some of the triangles appear
//! to be missing.
//! \param entity Entity handle.
//! \ingroup meshcommands
void xFlipMesh(size_t entity);

//! \brief Creates a copy of an entity and returns the handle of the newly
//! created copy.
//! This is a new entity instance of an existing entity's mesh. Anything
//! you do to the original mesh (such as xRotateMesh()) will effect all the
//! copies. Other properties (such as xEntityColor(), xPositionEntity(),
//! etc.) since they are 'Entity' properties, will be individual to the copy. 
//! If a parent entity is specified, the copied entity will be created at
//! the parent entity's position. Otherwise, it will be created at 0, 0, 0. 
//! \param entity Entity handle.
//! \param parent Parent entity handle.
//! \ingroup eccommands
size_t xCopyEntity(size_t entity, size_t parent);

//! \brief Creates a copy of a mesh and returns the newly-created mesh's handle. 
//! \details The difference between xCopyMesh() and xCopyEntity() is that
//! xCopyMesh() performs a 'deep' copy of a mesh. 
//! \param entity Entity handle.
//! \param parent Parent entity handle.
//! \ingroup meshcommands
size_t xCopyMesh(size_t entity, size_t parent);

//! \brief Creates a full copy of an entity and returns the handle of the newly
//! created copy.
//! \param entity Entity handle.
//! \ingroup eccommands
size_t xCloneEntity(size_t entity);

//! \brief Creates a full copy of an mesh and returns the handle of the newly
//! created copy.
//! \param entity Entity handle.
//! \ingroup eccommands
size_t xCloneMesh(size_t entity);
	
//! \brief Paints a entity with a brush. 
//! \details The reason for using xPaintEntity() to apply specific
//! properties to a entity using a brush rather than just using 
//! xEntityTexture(), xEntityColor(), xEntityShininess() etc, is that you
//! can pre-define one brush, and then paint entities over and over again
//! using just the one command rather than lots of separate ones. 
//! \param entity Entity handle.
//! \param brush Brush handle.
//! \ingroup eccommands
void xPaintEntity(size_t entity, size_t brush);

//! \brief Paints a mesh with a brush. 
//! \details This has the effect of instantly altering the visible
//! appearance of the mesh, assuming the brush's properties are different
//! to what was was applied to the surface before. 
//! The reason for using xPaintMesh() to apply specific properties to a
//! mesh using a brush rather than just using xEntityTexture(), xEntityColor(),
//! xEntityShininess() etc, is that you can pre-define one brush, and then
//! paint meshes over and over again using just the one command rather than
//! lots of separate ones.
//! \param entity Entity handle.
//! \param brush Brush handle.
//! \ingroup meshcommands
void xPaintMesh(size_t entity, size_t brush);

//! \brief Moves all vertices of a mesh.
//! \details Unlike xPositionEntity(), xPositionMesh() actually modifies
//! the actual mesh structure. 
//! So whereas using xPositionEntity(0, 0, 1) would only move an entity by
//! one unit the first time it was  used, xPositionMesh(0, 0, 1) will move
//! the mesh by one unit every time it is used. 
//! This is because xPositionEntity() positions an entity based on a fixed
//! mesh structure, whereas xPositionMesh() actually modifies the mesh
//! structure itself.
//! \param entity Entity handle.
//! \param x x position of mesh.
//! \param y y position of mesh.
//! \param z z position of mesh.
//! \ingroup meshcommands
void xPositionMesh(size_t entity, float x, float y, float z);

//! \brief Rotates all vertices of a mesh by the specified rotation
//! \details Unlike xRotateEntity(), xRotateMesh() actually modifies the
//! actual mesh structure. 
//! So whereas using xRotateEntity(0, 45, 0) would only rotate an entity by
//! 45 degrees the first time it was used, xRotateMesh(0, 45, 0) will
//! rotate the mesh every time it is used. 
//! This is because xRotateEntity() rotates an entity based on a fixed mesh
//! structure, whereas xRotateMesh() actually modifies the mesh structure
//! itself
//! \param entity Entity handle.
//! \param pitch Pitch of mesh.
//! \param yaw Yaw of mesh.
//! \param roll Roll of mesh.
//! \ingroup meshcommands
void xRotateMesh(size_t entity, float pitch, float yaw, float roll);

//! \brief Scales all vertices of a mesh by the specified scaling factors
//! \details Unlike xScaleEntity(), xScaleMesh() actually modifies the
//! actual mesh structure. 
//! So whereas using xScaleEntity(2, 2, 2) would only double the size of an
//! entity the first time it was used, xScaleMesh(2, 2, 2) will double the
//! size of the mesh every time it is used. 
//! This is because xScaleEntity() scales an entity based on a fixed mesh
//! structure, whereas xScaleMesh() actually modifies the mesh structure
//! itself.
//! \param entity Entity handle.
//! \param x x scale of mesh.
//! \param y y scale of mesh.
//! \param z z scale of mesh.
//! \ingroup meshcommands
void xScaleMesh(size_t entity, float x, float y, float z);

//! \brief Recalculates all normals, tangents and binormals in a mesh.
//! \details This is necessary for correct lighting if you have not set
//! surface normals using xVertexNormal() commands. 
//! \param entity Entity handle.
//! \ingroup meshcommands
void xUpdateNormals(size_t entity);

//! \brief Returns the width of a mesh.
//! \details This is calculated by the actual vertex positions and so the
//! scale of the entity (set by xScaleEntity()) will not have an effect on
//! the resultant width. Mesh operations, on the other hand, will effect the
//! result.
//! \param entity Entity handle.
//! \ingroup meshcommands
float xMeshWidth(size_t entity);

//! \brief Returns the height of a mesh.
//! \details This is calculated by the actual vertex positions and so the
//! scale of the entity (set by xScaleEntity()) will not have an effect on
//! the resultant height. Mesh operations, on the other hand, will effect the
//! result.
//! \param entity Entity handle.
//! \ingroup meshcommands
float xMeshHeight(size_t entity);

//! \brief Returns the depth of a mesh.
//! \details This is calculated by the actual vertex positions and so the
//! scale of the entity (set by xScaleEntity()) will not have an effect on
//! the resultant depth. Mesh operations, on the other hand, will effect the
//! result.
//! \param entity Entity handle.
//! \ingroup meshcommands
float xMeshDepth(size_t entity);

//! \brief Scales and translates all vertices of a mesh so that the mesh
//! occupies the specified box 
//! \details Do not use a width, height or depth value of 0.0, otherwise
//! all mesh data will be destroyed and your mesh will not be displayed.
//! Use a value of 0.001 instead for a flat mesh along one axis.
//! \param entity Mesh handle.
//! \param x x position of mesh.
//! \param y y position of mesh.
//! \param z z position of mesh.
//! \param width Width of mesh.
//! \param height Height of mesh.
//! \param depth Depth of mesh.
//! \param uniform If true, the mesh will be scaled by the same amounts in
//! x, y and z, so will not be distorted.
//! \ingroup meshcommands
void xFitMesh(size_t entity, float x, float y, float z, float width, float height, float depth, bool uniform);
	
// Camera commands
//! \brief Creates a camera entity and returns its handle. 
//! \details Without at least one camera, you won't be able to see anything
//! in your 3D world. With more than one camera, you will be to achieve
//! effect such as split-screen modes and rear-view mirrors.
//! The optional parent parameter allow you to specify a parent entity for
//! the camera so that when the parent is moved the child camera will move
//! with it. However, this relationship is one way; applying movement
//! commands to the child will not affect the parent. 
//! Specifying a parent entity will still result in the camera being
//! created at position 0, 0, 0 rather than at the parent entity's position. 
//! \param parent Parent entity handle.
//! \ingroup camcommands
size_t xCreateCamera(size_t parent);

//! \brief Sets the camera projection mode.
//! \param camera Camera handle.
//! \param mode Projection mode. See '\ref projtypes' for more information.
//! \ingroup camcommands
void xCameraProjMode(size_t camera, int mode);

//! \brief Sets the camera fog mode. 
//! \details This will enable/disable fogging, a technique used to
//! gradually fade out graphics the further they are away from the camera.
//! This can be used to avoid 'pop-up', the moment at which 3D objects
//! suddenly appear on the horizon. 
//! The default fog colour is black and the default fog range is 1-1000,
//! although these can be changed by using xCameraFogColor() and
//! xCameraFogRange() respectively. 
//! Each camera can have its own fog mode, for multiple on-screen fog
//! effects.
//! \param camera Camera handle.
//! \param mode For mode. See '\ref fogtypes' for more information.
//! \ingroup camcommands
void xCameraFogMode(size_t camera, int mode);
	
//! \brief Sets camera fog range. 
//! \details The 'nearRange' parameter specifies at what distance in front
//! of the camera that the fogging effect will start; all 3D object before
//! this point will not be faded. 
//! The 'farRange' parameter specifies at what distance in front of the
//! camera that the fogging effect will end; all 3D objects beyond this
//! point will be completely faded out.
//! \param camera Camera handle.
//! \param fogStart Distance in front of camera that fog starts.
//! \param fogEnd Distance in front of camera that fog ends.
//! \ingroup camcommands
void xCameraFogRange(size_t camera, float fogStart, float fogEnd);

//! \brief Sets camera fog color.
//! \param camera Camera handle.
//! \param red Red value of fog.
//! \param green Green value of fog.
//! \param blue Blue value of fog.
//! \ingroup camcommands
void xCameraFogColor(size_t camera, int red, int green, int blue);
	
//! \brief Sets the camera viewport position and size.
//! \details The camera viewport is the area of the 2D screen that
//! the 3D graphics as viewed by the camera are displayed in. 
//! Setting the camera viewport allows you to achieve spilt-screen and
//! rear-view mirror effects.
//! \param camera Camera handle.
//! \param x x-coordinate of top left hand corner of viewport.
//! \param y y-coordinate of top left hand corner of viewport.
//! \param width Width of viewport.
//! \param height Height of viewport.
//! \ingroup camcommands
void xCameraViewport(size_t camera, int x, int y, int width, int height);

//! \brief Sets camera clear mode.
//! \param camera Camera handle.
//! \param clearColor True to clear the color buffer, false not to.
//! \param clearZBuffer True to clear the color z-buffer, false not to.
//! \ingroup camcommands
void xCameraClsMode(size_t camera, bool clearColor, bool clearZBuffer);

//! \brief Sets camera background color. Defaults to 0, 0, 0.
//! \param camera Camera handle.
//! \param red Red value of camera background color.
//! \param green Green value of camera background color.
//! \param blue Blue value of camera background color.
//! \ingroup camcommands
void xCameraClsColor(size_t camera, int red, int green, int blue);

//! \brief Sets camera range.
//! \details Try and keep the ratio of far/near as small as possible for
//! optimal z-buffer performance. Defaults to 1, 1000
//! \param camera Camera handle.
//! \param nearValue Distance in front of camera that 3D objects start
//! being drawn.
//! \param farValue Distance in front of camera that 3D object stop being
//! drawn.
//! \ingroup camcommands
void xCameraRange(size_t camera, float nearValue, float farValue);

//! \brief Sets zoom factor for a camera.
//! \param camera Camera handle.
//! \param zoom Zoom factor of camera.
//! \ingroup camcommands
void xCameraZoom(size_t camera, float zoom);
	
//! \brief Returns true if the specified entity is visible to the specified camera. 
//! \param entity Entity handle.
//! \param camera Camera handle.
//! \ingroup camcommands
void xEntityInView(size_t entity, size_t camera);
	
// Entity movement commands
//! \brief Scales an entity so that it is of an absolute size. 
//! \details Scale values of 1, 1, 1 are the default size when creating
//! /loading entities. 
//! Scale values of 2, 2, 2 will double the size of an entity. 
//! Scale values of 0, 0, 0 will make an entity disappear. 
//! Scale values of less than 0, 0, 0 will invert an entity and make it bigger.
//! \param entity Entity handle.
//! \param x x size of entity.
//! \param y y size of entity.
//! \param z z size of entity.
//! \param global Set local or global scale.
//! \ingroup emcommands
void xScaleEntity(size_t entity, float x, float y, float z, bool global);

//! \brief Positions an entity at an absolute position in 3D space. 
//! \details Entities are positioned using an x, y, z coordinate system.
//! x, y and z each have their own axis, and each axis has its own set of
//! values. By specifying a value for each axis, you can position an entity
//! anywhere in 3D space. 0, 0, 0 is the centre of 3D space, and if the
//! camera is pointing in the default positive z direction, then positioning
//! an entity with a z value of above 0 will make it appear in front of the
//! camera, whereas a negative z value would see it disappear behind the
//! camera. Changing the x value would see it moving sideways, and changing
//! the y value would see it moving up/down. 
//! Of course, the direction in which entities appear to move is relative
//! to the position and orientation of the camera.
//! \param entity Entity handle.
//! \param x x co-ordinate that entity will be positioned at.
//! \param y y co-ordinate that entity will be positioned at.
//! \param z z co-ordinate that entity will be positioned at.
//! \param global True if the position should be relative to 0, 0, 0
//! rather than a parent entity's position.
//! \ingroup emcommands
void xPositionEntity(size_t entity, float x, float y, float z, bool global);

//! \brief Moves an entity relative to its current position and orientation. 
//! \details What this means is that an entity will move in whatever
//! direction it is facing. So for example if you have an game character
//! is upright when first loaded and it remains upright (i.e. turns left or
//! right only), then moving it by a z amount will always see it move
//! forward or backward, moving it by a y amount will always see it move up
//! or down, and moving it by an x amount will always see it strafe.
//! \param entity Entity handle.
//! \param x x amount that entity will be moved by.
//! \param y y amount that entity will be moved by.
//! \param z z amount that entity will be moved by.
//! \param global Move relative local or global orientation.
//! \ingroup emcommands
void xMoveEntity(size_t entity, float x, float y, float z, bool global);

//! \brief Translates an entity relative to its current position and not
//! its orientation. 
//! \details What this means is that an entity will move in a certain
//! direction despite where it may be facing. Imagine that you have a game
//! character that you want to make jump in the air at the same time as
//! doing a triple somersault. Translating the character by a positive y
//! amount will mean the character will always travel directly up in their
//! air, regardless of where it may be facing due to the somersault action. 
//! \param entity Entity handle.
//! \param x x amount that entity will be translated by.
//! \param y y amount that entity will be translated by.
//! \param z z amount that entity will be translated by.
//! \ingroup emcommands
void xTranslateEntity(size_t entity, float x, float y, float z);

//! \brief Rotates an entity so that it is at an absolute orientation. 
//! \param entity Entity handle.
//! \param pitch Angle in degrees of pitch rotation.
//! \param yaw Angle in degrees of yaw rotation.
//! \param roll Angle in degrees of roll rotation.
//! \param global True if the angle rotated should be relative to 0, 0, 0
//! rather than a parent entity's orientation.
//! \ingroup emcommands
void xRotateEntity(size_t entity, float pitch, float yaw, float roll, bool global);

//! \brief Turns an entity relative to its current orientation. 
//! \param entity Entity handle.
//! \param pitch Angle in degrees that entity will be pitched.
//! \param yaw Angle in degrees that entity will be yawed.
//! \param roll Angle in degrees that entity will be rolled.
//! \param global True to turn in global coordinate system, false - for
//! local.
//! \ingroup emcommands
void xTurnEntity(size_t entity, float pitch, float yaw, float roll, bool global);

//! \brief Points one entity at another. 
//! \details The roll parameter allows you to specify a roll angle as
//! pointing an entity only sets pitch and yaw angles. 
//! If you wish for an entity to point at a certain position rather than
//! another entity, simply create a pivot entity at your desired position,
//! point the entity at this and then free the pivot.
//! \param src Source entity handle.
//! \param dest Destination entity handle.
//! \param roll Roll angle of entity.
//! \ingroup emcommands
void xPointEntity(size_t src, size_t dest, float roll);

//! \brief Aligns an entity axis to a vector.
//! \param entity Entity handle.
//! \param x Vector x.
//! \param y Vector y.
//! \param z Vector z.
//! \param axis Axis of entity that will be aligned to vector. See '\ref
//! axistypes' for more information.
//! \param rate Rate at which entity is aligned from current orientation
//! to vector orientation. Should be in the range [0.0; 1.0], 0.0 for
//! smooth transition and 1.0 for 'snap' transition.
//! \ingroup emcommands
void xAlignToVector(size_t entity, float x, float y, float z, int axis, float rate);
	
// Entity control commands
//! \brief Frees up an entity.
//! \param entity Entity handle.
//! \ingroup eccommands
void xFreeEntity(size_t entity);

//! \brief Sets the diffuse color of an entity. 
//! \details The red, green and blue values should be in the range [0; 255]
//! with 0 being darkest and 255 brightest. The default entity color is
//! 255, 255, 255 (white).
//! \param entity Entity handle.
//! \param red Red value of entity color.
//! \param green Green value of entity color.
//! \param blue Blue value of entity color.
//! \ingroup eccommands
void xEntityColor(size_t entity, int red, int green, int blue);

//! \brief Sets the alpha level of an entity. 
//! \details The 'alpha' value should be in a floating point value in the
//! range [0.0; 1.0]. The default entity alpha setting is 1.0. 
//! The alpha level is how transparent an entity is. A value of 1.0 will
//! mean the entity is opaque. A value of 0.0 will mean the entity is
//! completely transparent, i.e. invisible. Values between 0.0 and 1.0
//! will cause varying amount of transparency. This is useful for imitating
//! the look of objects such as glass and other translucent materials.
//! \param entity Entity handle.
//! \param alpha Alpha level of entity.
//! \ingroup eccommands
void xEntityAlpha(size_t entity, float alpha);

//! \brief Sets the specular shininess of an entity. 
//! \details The shininess value should be a floting point number in the
//! range [0.0; 1.0]. The default shininess setting is 0.0 .
//! Shininess is how much brighter certain areas of an object will appear
//! to be when a light is shone directly at them. 
//! Setting a shininess value of 1.0 for a medium to high poly sphere,
//! combined with the creation of a light shining in the direction of it,
//! will give it the appearance of a shiny snooker ball.
//! \param entity Entity handle.
//! \param shininess Shininess of entity.
//! \ingroup eccommands
void xEntityShininess(size_t entity, float shininess);

//! \brief Applies a texture to an entity. 
//! \details The optional frame parameter specifies which texture animation
//! frame should be used as the texture. 
//! The optional index parameter specifies which index number should be
//! assigned to the texture. Index numbers are used for the purpose of
//! multitexturing. See xTextureBlend(). 
//! \param entity Entity handle.
//! \param texture Texture handle.
//! \param frame Frame of texture.
//! \param index Index number of texture. Should be in the range to 0-7.
//! \ingroup eccommands
void xEntityTexture(size_t entity, size_t texture, int frame, int index);

//! \brief Sets the blending mode of an entity.
//! \details This blending mode determines the way in which the new RGBA of
//! the pixel being rendered is combined with the RGB of the background. 
//! To calculate the new RGBA of the pixel being rendered, the texture RGBA
//! for the pixel is taken, its alpha component multiplied by the
//! entities/brushes (where applicable) alpha value and its color compentent
//! multiplied by the entities/brushes colour. This is the RGBA which will
//! then be blended into the background pixel, and how this is done depends
//! on the xEntityBlend() value.
//! \param entity Entity handle
//! \param blend Blend mode. See '\ref entblendtypes' for more information
//! \ingroup eccommands
void xEntityBlend(size_t entity, int blend);

//! \brief Sets miscellaneous effects for an entity. 
//! \details Flags can be added to combine two or more effects.
//! \param entity Entity handle.
//! \param fx Effects flags. See '\ref fxflags' for more information.
//! \ingroup eccommands
void xEntityFX(size_t entity, int fx);

//! \brief Shows an entity. 
//! \details Once an entity has been hidden using xHideEntity(), use show
//! entity to make it visible and involved in collisions again.
//! Entities are shown by default after creating/loading them, so you
//! should only need to use xShowEntity() after using xHideEntity().
//! \param entity Entity handle.
//! \ingroup eccommands
void xShowEntity(size_t entity);

//! \brief Hides an entity, so that it is no longer visible, and is no
//! longer involved in collisions. 
//! \details The main purpose of hide entity is to allow you to create
//! entities at the beginning of a program, hide them, then copy them and
//! show as necessary in the main game. This is more efficient than creating
//! entities mid-game. 
//! If you wish to hide an entity so that it is no longer visible but still
//! involved in collisions, then use EntityAlpha 0 instead. This will make
//! an entity completely transparent. 
//! xHideEntity() affects the specified entity and all of its child
//! entities, if any exist.
//! \param entity Entity handle.
//! \ingroup eccommands
void xHideEntity(size_t entity);

//! \brief Sets an entity's name.
//! \param entity Entity handle.
//! \param name Name of entity.
//! \ingroup eccommands
void xNameEntity(size_t entity, const char * name);

//! \brief Attaches an entity to a parent. 
//! \details Parent may be 0, in which case the entity will have no parent
//! \param entity Entity handle.
//! \param parent Parent entity handle.
//! \param global True for the child entity to retain its global position
//! and orientation.
//! \ingroup eccommands
void xEntityParent(size_t entity, size_t parent, bool global);

//! \brief Returns a parent of an entity.
//! \param entity Entity handle.
//! \ingroup eccommands
size_t xGetParent(size_t entity);

//! \brief Sets the drawing order for an entity. 
//! \details An order value of 0 will mean the entity is drawn normally. A
//! value greater than 0 will mean that entity is drawn first, behind
//! everything else. A value less than 0 will mean the entity is drawn
//! last, in front of everything else. 
//! Setting an entity's order to non-0 also disables z-buffering for the
//! entity, so should be only used for simple, convex entities like
//! skyboxes, sprites etc. 
//! xEntityOrder() affects the specified entity but none of its child
//! entities, if any exist. 
//! \param entity Entity handle.
//! \param order Order that entity will be drawn in.
//! \ingroup eccommands
void xEntityOrder(size_t entity, int order);

//! \brief Enables auto fading for an entity.
//! \details This will cause an entity's alpha level to be adjusted at
//! distances between near and far to create a 'fade-in' effect. 
//! \param entity Entity handle.
//! \param nearValue Distance in front of the camera at which entity's will
//! start being faded.
//! \param farValue Distance in front of the camera at which entity's will
//! stop being faded (and will be invisible).
//! \ingroup eccommands
void xEntityAutoFade(size_t entity, float nearValue, float farValue);
	
// Entity state commands
//! \brief Returns x-coordinate of the entity. 
//! \details If the 'isGlobal' flag is set to ffalse then the parent's
//! local coordinate system is used. 
//! NOTE: If the entity has no parent then local and global coordinates are
//! the same. In this case you can think of the 3d world as the parent. 
//! Global coordinates refer to the 3d world. Xors3D uses a left-handed system: 
//!
//! X+ is to the right 
//!
//! Y+ is up 
//!
//! Z- is forward (from the screen) 
//!
//! Every entity also has its own local coordinate system.
//! The global system never changes. 
//! But the local system is carried along as an entity moves and turns.
//! \param entity Entity handle.
//! \param global True for global coordinates, false for local.
//! \ingroup escommands
float xEntityX(size_t entity, bool global);

//! \details If the 'isGlobal' flag is set to ffalse then the parent's
//! local coordinate system is used. 
//! NOTE: If the entity has no parent then local and global coordinates are
//! the same. In this case you can think of the 3d world as the parent. 
//! Global coordinates refer to the 3d world. Xors3D uses a left-handed system: 
//!
//! X+ is to the right 
//!
//! Y+ is up 
//!
//! Z- is forward (from the screen) 
//!
//! Every entity also has its own local coordinate system.
//! The global system never changes. 
//! But the local system is carried along as an entity moves and turns.
//! \param entity Entity handle.
//! \param global True for global coordinates, false for local.
//! \ingroup escommands
float xEntityY(size_t entity, bool global);

//! \brief Returns z-coordinate of the entity. 
//! \details If the 'isGlobal' flag is set to ffalse then the parent's
//! local coordinate system is used. 
//! NOTE: If the entity has no parent then local and global coordinates are
//! the same. In this case you can think of the 3d world as the parent. 
//! Global coordinates refer to the 3d world. Xors3D uses a left-handed system: 
//!
//! X+ is to the right 
//!
//! Y+ is up 
//!
//! Z- is forward (from the screen) 
//!
//! Every entity also has its own local coordinate system.
//! The global system never changes. 
//! But the local system is carried along as an entity moves and turns.
//! \param entity Entity handle.
//! \param global True for global coordinates, false for local.
//! \ingroup escommands
float xEntityZ(size_t entity, bool global);

//! \brief Returns the roll angle of an entity
//! \param entity Entity handle
//! \param global True if the roll angle returned should be
//! relative to 0 rather than a parent entity's roll angle
//! \ingroup escommands	
float xEntityRoll(size_t entity, bool global);

//! \brief Returns the yaw angle of an entity.
//! \param entity Entity handle.
//! \param global True if the yaw angle returned should be
//! relative to 0 rather than a parent entity's yaw angle.
//! \ingroup escommands
float xEntityYaw(size_t entity, bool global);

//! \brief Returns the pitch angle of an entity.
//! \param entity Entity handle.
//! \param global True if the pitch angle returned should be
//! relative to 0 rather than a parent entity's pitch angle.
//! \ingroup escommands
float xEntityPitch(size_t entity, bool global);

//! \brief Returns the name of an entity.
//! An entity's name may be set in a modelling program, or manually set
//! using xNameEntity().
//! \param entity Entity handle.
//! \ingroup escommands
const char * xEntityName(size_t entity);

//! \brief Assigns pointer to user data to the entity
//! \param entity Entity handle.
//! \param data Pointer to user data
//! \ingroup eccommands
void xSetEntityUserData(size_t entity, void * data);

//! \brief Returns pointer to user data for the entity
//! \param entity Entity handle.
//! \ingroup escommands
void * xGetEntityUserData(size_t entity);
	
//! \brief Sets function for alpha-test (masked textures)
//! \param entity Entity handle.
//! \param function Function type. See '\ref atestfuncs' for more information
//! \ingroup eccommands
void xSetAlphaFunc(size_t entity, int function);

//! \brief Returns function used for alpha-test (masked textures)
//! \param entity Entity handle.
//! \ingroup escommands
int xGetAlphaFunc(size_t entity);

//! \brief Sets reference value for alpha-test (masked textures)
//! \param entity Entity handle.
//! \param reference Reference value in range [0; 255]
//! \ingroup eccommands
void xSetAlphaRef(size_t entity, int reference);

//! \brief Returns reference value used for alpha-test (masked textures)
//! \param entity Entity handle.
//! \ingroup escommands
int xGetAlphaRef(size_t entity);
	
//! \brief Returns the number of children of an entity.
//! \param entity Entity handle.
//! \ingroup escommands
int xCountChildren(size_t entity);

//! \brief Returns a child of an entity.
//! \param entity Entity handle.
//! \param index Index of child entity. Should be in the range
//! [0; xCountChildren(entity) - 1].
//! \ingroup escommands
size_t xGetChild(size_t entity, int index);

//! \brief Returns the first child of the specified entity with matching name.
//! \param entity Entity handle.
//! \param name Child name to find within entity.
//! \ingroup escommands
size_t xFindChild(size_t entity, const char * name);

//! \brief Returns the distance between two entities.
//! \param entity The first entity handle.
//! \param entity2 The second entity handle.
//! \ingroup escommands
float xEntityDistance(size_t entity, size_t entity2);
	
// Input commands
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
//! \brief Returns number of screen touches.
//! \ingroup inputcommands
int xCountTouches();

//! \brief Flushes all touch states.
//! \ingroup inputcommands
void xFlushTouches();
	
//! \brief Enables multi-touch detection.
//! \ingroup inputcommands
void xEnableMultiTouch();
	
//! \brief Disables multi-touch detection.
//! \ingroup inputcommands
void xDisableMultiTouch();
	
//! \brief Returns a touch phase.
//! \details See '\ref touchphases' for more information.
//! \param index Index of a touch.
//! \ingroup inputcommands
int xTouchPhase(int index);

//! \brief Returns x position of current touch.
//! \details NOTE: You may get inaccurate values if you used scaled simulator window
//! \param index Index of touch.
//! \ingroup inputcommands
int xTouchX(int index);

//! \brief Returns y position of current touch.
//! \details NOTE: You may get inaccurate values if you used scaled simulator window
//! \param index Index of touch.
//! \ingroup inputcommands
int xTouchY(int index);

//! \brief Returns x position of previous touch.
//! \details NOTE: You may get inaccurate values if you used scaled simulator window
//! \param index Index of touch.
//! \ingroup inputcommands
int xTouchPrevX(int index);

//! \brief Returns y position previous touch.
//! \details NOTE: You may get inaccurate values if you used scaled simulator window
//! \param index Index of touch.
//! \ingroup inputcommands
int xTouchPrevY(int index);

//! \brief Return the time when the touch occurred or when it was last mutated.
//! The returned valus is in seconds since system startup.
//! \param index Index of touch.
//! \ingroup inputcommands
float xTouchTime(int index);

//! \brief Returns the number of times the finger was tapped for the given touch.
//! \param index Index of touch.
//! \ingroup inputcommands
int xTouchTapCount(int index);

//! \brief Returns the acceleration value for the x axis of the device.
//! \ingroup inputcommands
float xAccelerationX();

//! \brief Returns the acceleration value for the y axis of the device.
//! \ingroup inputcommands
float xAccelerationY();

//! \brief Returns the acceleration value for the z axis of the device.
//! \ingroup inputcommands
float xAccelerationZ();
	
//! \brief Returns the gravitation value for the x axis of the device.
//! \ingroup inputcommands
float xGravitationX();

//! \brief Returns the gravitation value for the y axis of the device.
//! \ingroup inputcommands
float xGravitationY();

//! \brief Returns the gravitation value for the z axis of the device.
//! \ingroup inputcommands
float xGravitationZ();
	
//! \brief Clears acceleration vector.
//! \ingroup inputcommands
void xFlushAcceleration();
	
//! \brief Enable or disable accelerometer.
//! \details By default accelerometer is disabled.
//! \param state True to enable accelerometer, false to disable.
//! \ingroup inputcommands
void xEnableAccelerometer(bool state);
	
//! \brief Sets update interval of acceleration value in seconds.
//! \details Default value is 0.01 s.
//! \param interval Update interval in seconds.
//! \ingroup inputcommands
void xAccelerometerInterval(float interval);

//! \brief Returns current update interval of acceleration value in seconds.
//! \ingroup inputcommands
float xGetAccelerometerInterval();
#else
	bool xKeyDown(int key);
	bool xKeyUp(int key);
	int xKeyHit(int key);
	bool xMouseDown(int key);
	bool xMouseUp(int key);
	int xMouseHit(int key);
	int xMouseX();
	int xMouseY();
	float xMouseXSpeed();
	float xMouseYSpeed();
	float xMouseZSpeed();
	void xFlushKeys();
	void xFlushMouse();
	void xMoveMouse(int x, int y);
	void xShowCursor();
	void xHideCursor();
#endif
	
// Lights commands
//! \brief Creates a light. 
//! \details Lights work by affecting the colour of all vertices within the
//! light's range. You need at to create at least one light if you wish to
//! use 3D graphics otherwise everything will appear flat.
//! \param type Type of light. See '\ref lighttypes' for more information.
//! \param parent Parent entity for a light.
//! \ingroup lightcommands
size_t xCreateLight(int type, size_t parent);

//! \brief Sets the range of a light. 
//! \details The range of a light is how far it reaches. Everything outside
//! the range of the light will not be affected by it.
//! The value is very approximate, and should be experimented with for best
//! results. Affect only for spot and point light sources.
//! \param light Light source handle.
//! \param range Range of light.
//! \ingroup lightcommands
void xLightRange(size_t light, float range);

//! \brief Sets the cone angle for a spot light. 
//! \details The default light cone angles setting is 0, 90. Affects only for
//! spot light sources.
//! \param light Light source handle.
//! \param inner Inner angle of cone.
//! \param outer Outer angle of cone.
//! \ingroup lightcommands
void xLightConeAngles(size_t light, float inner, float outer);

//! \brief Sets the color of a light.
//! \param light Light source handle.
//! \param red Red alue of light color.
//! \param green Green alue of light color.
//! \param blue Blue alue of light color.
//! \ingroup lightcommands
void xLightColor(size_t light, int red, int green, int blue);
	
// 3D math commands
//! \brief Returns the yaw value of a vector. 
//! \details Using this command will return the same result as using
//! xEntityYaw() to get the yaw value of an entity that is pointing in the
//! vector's direction. 
//! \param x x vector length.
//! \param y y vector length.
//! \param z z vector length.
//! \ingroup mathcommands
float xVectorYaw(float x, float y, float z);

//! \brief Returns the pitch value of a vector.
//! \details Using this command will return the same result as using
//! xEntityPitch() to get the pitch value of an entity that is pointing in
//! the vector's direction.
//! \param x x vector length.
//! \param y y vector length.
//! \param z z vector length.
//! \ingroup mathcommands
float xVectorPitch(float x, float y, float z);

//! \brief Transforms a point between coordinate systems.
//! \details After using xTFormPoint() the new components can be read with
//! xTFormedX(), xTFormedY() and xTFormedZ(). 
//! See xEntityX() for details about local coordinates. 
//! Consider a sphere built with xCreateSphere(). The 'north pole' is at
//! (0.0, 1.0, 0.0). 
//! At first, local and global coordinates are the same. As the sphere is
//! moved, turned and scaled the global coordinates of the point change.
//! But it is always at (0.0, 1.0, 0.0) in the sphere's local space.
//! \param x x component of a vector in 3D space.
//! \param y y component of a vector in 3D space.
//! \param z z component of a vector in 3D space.
//! \param src Handle of source entity, or 0 for 3d world.
//! \param dest Handle of destination entity, or 0 for 3d world.
//! \ingroup mathcommands
void xTFormPoint(float x, float y, float z, size_t src, size_t dest);

//! \brief Transforms a vector between coordinate systems.
//! \details After using xTFormVector() the new components can be read with
//! xTFormedX(), xTFormedY() and xTFormedZ().
//! See xEntityX() for details about local coordinates.
//! Similar to xTFormPoint(), but operates on a vector. A vector can be
//! thought of as 'displacement relative to current location'.
//! For example, vector (1.0, 2.0, 3.0) means one step to the right, two
//! steps up and three steps forward.
//! \param x x component of a vector in 3D space.
//! \param y y component of a vector in 3D space.
//! \param z z component of a vector in 3D space.
//! \param src Handle of source entity, or 0 for 3d world.
//! \param dest Handle of dstination entity, or 0 for 3d world.
//! \ingroup mathcommands
void xTFormVector(float x, float y, float z, size_t src, size_t dest);

//! \brief Transforms a vector between coordinate systems with normalization.
//! \details After using xTFormNormal() the new components can be read with
//! xTFormedX(), xTFormedY() and xTFormedZ(). 
//! This is exactly the same as xTFormVector() but with one added feature. 
//! After the transformation the new vector is 'normalized', meaning it 
//! is scaled to have length 1. 
//! For example, suppose the result of xTFormVector is (1.0, 2.0, 2.0). 
//! This vector has length sqrt(1.0 * 1.0 + 2.0 * 2.0 + 2.0 * 2.0) =
//! sqrt(9.0) = 3.0
//! This means xTFormNormal() would produce (1.0 / 3.0, 2.0 / 3.0, 2.0 / 3.0). 
//! \param x x component of a vector in 3D space.
//! \param y y component of a vector in 3D space.
//! \param z z component of a vector in 3D space.
//! \param src Handle of source entity, or 0 for 3d world.
//! \param dest Handle of dstination entity, or 0 for 3d world.
//! \ingroup mathcommands
void xTFormNormal(float x, float y, float z, size_t src, size_t dest);

//! \brief Returns the X component of the last xTFormPoint(), xTFormVector()
//! or xTFormNormal() operation.
//! \ingroup mathcommands
float xTFormedX();

//! \brief Returns the Y component of the last xTFormPoint(), xTFormVector()
//! or xTFormNormal() operation.
//! \ingroup mathcommands
float xTFormedY();

//! \brief Returns the Z component of the last xTFormPoint(), xTFormVector()
//! or xTFormNormal() operation.
//! \ingroup mathcommands
float xTFormedZ();

//! \brief Returns the yaw angle, that the first entity should be rotated by
//! in order to face the second one.
//! \details This command can be used to be point one entity at another,
//! rotating on the y axis only.
//! \param src Source entity handle.
//! \param dest Destination entity handle.
//! \ingroup mathcommands
float xDeltaYaw(size_t src, size_t dest);

//! \brief Returns the pitch angle, that the first entity should be rotated by
//! in order to face the second one.
//! \details This command can be used to be point one entity at another,
//! rotating on the x axis only.
//! \param src Source entity handle.
//! \param dest Destination entity handle.
//! \ingroup mathcommands
float xDeltaPitch(size_t src, size_t dest);
	
// Entity animation commands
//! \brief Animates an entity.
//! \param entity Entity handle.
//! \param mode Animating mode. See '\ref animtypes' for more information
//! \param speed Animation speed. A negative speed will play the animation
//! backwards.
//! \param setID Initially, an entity loaded with xLoadAnimMesh() will
//! have a single animation sequence. More sequences can be added using
//! either xLoadAnimSeq() or xAddAnimSeq(). Animation sequences are numbered
//! 0, 1, 2, etc.
//! \param smooth A value of 0 will cause an instant 'leap' to the first
//! frame, while values greater than 0 will cause a smooth transition.
//! \ingroup eacommands
void xAnimate(size_t entity, int mode, float speed, int setID, float smooth);

//! \brief Sets entity's animation time.
//! \param entity Entity handle.
//! \param value New animation time.
//! \ingroup eacommands
void xSetAnimTime(size_t entity, float value);

//! \brief Sets entity's animation speed
//! \param entity Entity handle
//! \param value New animation speed
//! \ingroup eacommands
void xSetAnimSpeed(size_t entity, float value);

//! \brief Returns the specified entity's current animation sequence.
//! \details This function must be used only with real skinned mesh, or it
//! will return wrong values.
//! \param entity Entity handle.
//! \ingroup eacommands
int xAnimSeq(size_t entity);

//! \brief Returns the length of the specified entity's current animation
//! sequence.
//! \details This function must be used only with real skinned mesh, or it
//! will return wrong values.
//! \param entity Entity handle.
//! \ingroup eacommands
float xAnimLength(size_t entity);

//! \brief Returns the current animation time of an entity.
//! \details This function must be used only with real skinned mesh, or it
//! will return wrong values.
//! \param entity Entity handle.
//! \ingroup eacommands
float xAnimTime(size_t entity);

//! \brief Returns the specified entity's current animation speed.
//! \details This function must be used only with real skinned mesh, or it
//! will return wrong values.
//! \param entity Entity handle.
//! \ingroup eacommands
float xAnimSpeed(size_t entity);

//! \brief Returns true if the specified entity is currently animating.
//! \details This function must be used only with real skinned mesh, or it
//! will return wrong values.
//! \param entity Entity handle.
//! \ingroup eacommands
bool xAnimating(size_t entity);

//! \brief Extracts a part of specified sequence to a new one and returns its
//! index.
//! \details B3D format suppots only one sequence per file. You can arrange
//! all animations into one in editor and then extact them in iXors3D
//! \param entity Entity handle.
//! \param startFrame The first frame of anim sequence to extract.
//! \param endFrame The last frame of anim sequence to extract.
//! \param setID Animation sequence to extract from.
//! \ingroup eacommands
int xExtractAnimSeq(size_t entity, int startFrame, int endFrame, int setID);

//! \brief Appends an animation sequence from a file to an entity. 
//! Returns the animation sequence number added.
//! \param entity Entity handle.
//! \param path Filename of animated 3D object.
//! \ingroup eacommands
int xLoadAnimSeq(size_t entity, const char * path);
	
// Ray-cast commands
//! \brief Sets the pick mode for an entity. 
//! \param entity Entity handle.
//! \param mode Entity picking mode. See '\ref picktypes' for more information
//! during an xEntityVisible() call.
//! \ingroup rccommands
void xEntityPickMode(size_t entity, int mode);

//! \brief Returns the first entity between x, y, z to dx, dy, dz
//! \param x x coordinate of start of line pick.
//! \param y y coordinate of start of line pick.
//! \param z z coordinate of start of line pick.
//! \param dx x coordinate of end of line pick.
//! \param dy y coordinate of end of line pick.
//! \param dz z coordinate of end of line pick.
//! \param radius Radius of line pick
//! \ingroup rccommands
size_t xLinePick(float x, float y, float z, float dx, float dy, float dz, float radius);

//! \brief Returns the world x coordinate of the most recently executed
//! pick command.
//! \details This might have been xCameraPick(), xEntityPick() or xLinePick().
//! The coordinate represents the exact point of where something was picked.
//! \ingroup rccommands
float xPickedX();

//! \brief Returns the world y coordinate of the most recently executed
//! pick command.
//! \details This might have been xCameraPick(), xEntityPick() or xLinePick().
//! The coordinate represents the exact point of where something was picked.
//! \ingroup rccommands
float xPickedY();

//! \brief Returns the world z coordinate of the most recently executed
//! pick command.
//! \details This might have been xCameraPick(), xEntityPick() or xLinePick().
//! The coordinate represents the exact point of where something was picked.
//! \ingroup rccommands
float xPickedZ();

//! \brief Returns the x component of the normal of the most recently
//! executed pick command.
//! \details This might have been xCameraPick(), xEntityPick() or xLinePick().
//! \ingroup rccommands
float xPickedNX();

//! \brief Returns the y component of the normal of the most recently
//! executed pick command.
//! \details This might have been xCameraPick(), xEntityPick() or xLinePick().
//! \ingroup rccommands
float xPickedNY();

//! \brief Returns the z component of the normal of the most recently
//! executed pick command.
//! \details This might have been xCameraPick(), xEntityPick() or xLinePick().
//! \ingroup rccommands
float xPickedNZ();

//! \brief Returns the time taken to calculate the most recently executed
//! pick command.
//! \details This might have been xCameraPick(), xEntityPick() or xLinePick().
//! \ingroup rccommands
float xPickedTime();

//! \brief Returns the entity 'picked' by the most recently executed pick
//! command.
//! \details This might have been xCameraPick(), xEntityPick() or xLinePick().
//! \ingroup rccommands
size_t xPickedEntity();

//! \brief Returns the handle of the surface that was 'picked' by the most
//! recently executed pick command.
//! \details This might have been xCameraPick(), xEntityPick() or xLinePick().
//! \ingroup rccommands
size_t xPickedSurface();

//! \brief Returns the index number of the triangle that was 'picked' by
//! the most recently executed pick command.
//! \details This might have been xCameraPick(), xEntityPick() or xLinePick().
//! \ingroup rccommands
int xPickedTriangle();

//! \brief Picks the entity positioned at the specified viewport coordinates
//! \details Returns the entity picked, or 0 if none there.
//! An entity must have its xEntityPickMode() set to a non-0 value value to
//! be 'pickable'.
//! \param camera Camera handle.
//! \param x 2D viewport x-coordinate.
//! \param y 2D viewport y-coordinate.
//! \ingroup rccommands
size_t xCameraPick(size_t camera, int x, int y);

//! \brief Returns the nearest entity 'ahead' of the specified entity.
//! \details An entity must have a non-zero xEntityPickMode() to be pickable. 
//! \param entity Entity handle.
//! \param radius Range of pick area around entity.
//! \ingroup rccommands
size_t xEntityPick(size_t entity, float radius);
	
// Collision system commands
//! \brief Enables collisions between two different entity types.
//! \details Entity types are just numbers you assign to an entity using
//! xEntityType(). iXors3d then uses the entity types to check for collisions
//! between all the entities that have those entity types.
//! Where any ways of checking for collisions, as denoted by the method
//! parameter. However, collision checking is always ellipsoid to something.
//! In order to know what size a source entity is, you must first assign an
//! entity radius to all source entities using xEntityRadius(). 
//! In the case of collision detection method SPHERETOSPHERE being selected,
//! then the destination entities concerned will need to have an
//! xEntityRadius() assigned to them too. In the case of method
//! SPHERETOBOX being selected, then the destination entities will need to
//! have an xEntityBox() assigned to them. Method SPHERETOTRIMESH requires
//! nothing to be assigned to the destination entities.
//! Engine does not only check for collisions, but it acts upon them when it
//! detects them too, as denoted by the response parameter. You have three
//! options in this situation. You can either choose to make the source
//! entity stop, slide or only slide upwards.
//! All collision checking occurs, and collision responses are acted out,
//! when xUpdateWorld() is called.
//! Finally, every time the xCollisions() command is used, collision
//! information is added to the collision information list. This can be
//! cleared at any time using the xClearCollisions() command.
//! \param srcType Entity type to be checked for collisions.
//! \param destType Entity type to be collided with.
//! \param method Collision detection method. See '\ref colltypes' for more
//! information.
//! \param response What the source entity does when a collision occurs.
//! See '\ref resptypes' for more information.
//! \ingroup ecolcommands
void xCollisions(int srcType, int destType, int method, int response);

//! \brief Clears the collision information list.
//! \details Whenever you use the xCollisions() command to enable collisions between 
//! two different entity types, information is added to the collision list.
//! This command clears that list, so that no collisions will be detected until
//! the xCollisions() command is used again.
//! \ingroup ecolcommands
void xClearCollisions();

//! \brief Resets the collision state of an entity.
//! \param entity Entity handle.
//! \ingroup ecolcommands
void xResetEntity(size_t entity);

//! \brief Sets the radius of an entity's collision sphere.
//! \details An entity radius should be set for all entities involved in
//! spherical collisions, which is all source entities (as collisions are
//! always sphere-to-something), and whatever destination entities are
//! involved in sphere-to-sphere collisions.
//! \param entity Entity handle.
//! \param xRadius x radius of entity's collision sphere.
//! \param yRadius y radius of entity's collision sphere.
//! \ingroup ecolcommands
void xEntityRadius(size_t entity, float xRadius, float yRadius);

//! \brief Sets the dimensions of an entity's collision box.
//! \param entity Entity handle.
//! \param x x position of entity's collision box.
//! \param y x position of entity's collision box.
//! \param z x position of entity's collision box.
//! \param width Width of entity's collision box.
//! \param height Height of entity's collision box.
//! \param depth Depth of entity's collision box.
//! \ingroup ecolcommands
void xEntityBox(size_t entity, float x, float y, float z, float width, float height, float depth);

//! \brief Sets the collision type for an entity.
//! A collision type value of 0 indicates that no collision checking will
//! occur with that entity. A collision value of [1; 999] will mean
//! collision checking will occur.
//! \param entity Entity handle.
//! \param type Collision type of entity. Must be in the range [0; 999] .
//! \param recurse True to apply collision type to entity's children.
//! \ingroup ecolcommands
void xEntityType(size_t entity, int type, bool recurse);

//! \brief Returns true if an entity collided with any other entity of the specified type.
//! \param entity Entity handle.
//! \param type Type of entity.
//! \ingroup ecolcommands
size_t xEntityCollided(size_t entity, int type);

//! \brief Returns how many collisions an entity was involved in during the
//! last xUpdateWorld().
//! \param entity Entity handle.
//! \ingroup ecolcommands
int xCountCollisions(size_t entity);

//! \brief Returns the world x coordinate of a particular collision.
//! \details Index should be in the range [0; xCountCollisions(entity) - 1] .
//! \param entity Entity handle.
//! \param index Index of collision.
//! \ingroup ecolcommands
float xCollisionX(size_t entity, int index);

//! \brief Returns the world y coordinate of a particular collision.
//! \details Index should be in the range [0; xCountCollisions(entity) - 1] .
//! \param entity Entity handle.
//! \param index Index of collision.
//! \ingroup ecolcommands
float xCollisionY(size_t entity, int index);

//! \brief Returns the world z coordinate of a particular collision.
//! \details Index should be in the range [0; xCountCollisions(entity) - 1] .
//! \param entity Entity handle.
//! \param index Index of collision.
//! \ingroup ecolcommands
float xCollisionZ(size_t entity, int index);

//! \brief Returns the x component of the normal of a particular collision.
//! \details Index should be in the range [0; xCountCollisions(entity) - 1] .
//! \param entity Entity handle.
//! \param index Index of collision.
//! \ingroup ecolcommands
float xCollisionNX(size_t entity, int index);

//! \brief Returns the y component of the normal of a particular collision.
//! \details Index should be in the range [0; xCountCollisions(entity) - 1] .
//! \param entity Entity handle.
//! \param index Index of collision.
//! \ingroup ecolcommands
float xCollisionNY(size_t entity, int index);

//! \brief Returns the z component of the normal of a particular collision.
//! \details Index should be in the range [0; xCountCollisions(entity) - 1] .
//! \param entity Entity handle.
//! \param index Index of collision.
//! \ingroup ecolcommands
float xCollisionNZ(size_t entity, int index);

//! \brief Returns the time taken to calculate a particular collision.
//! \details Index should be in the range [0; xCountCollisions(entity) - 1] .
//! \param entity Entity handle.
//! \param index Index of collision.
//! \ingroup ecolcommands
float xCollisionTime(size_t entity, int index);

//! \brief Returns the other entity involved in a particular collision.
//! \details Index should be in the range [0; xCountCollisions(entity) - 1] .
//! \param entity Entity handle.
//! \param index Index of collision.
//! \ingroup ecolcommands
size_t xCollisionEntity(size_t entity, int index);

//! \brief Returns the handle of the surface belonging to the specified
//! entity that was closest to the point of a particular collision.
//! \details Index should be in the range [0; xCountCollisions(entity) - 1] .
//! \param entity Entity handle.
//! \param index Index of collision.
//! \ingroup ecolcommands
size_t xCollisionSurface(size_t entity, int index);

//! \brief Returns the index number of the triangle belonging to the
//! specified entity that was closest to the point of a particular collision.
//! \details Index should be in the range [0; xCountCollisions(entity) - 1] .
//! \param entity Entity handle.
//! \param index Index of collision.
//! \ingroup ecolcommands
int xCollisionTriangle(size_t entity, int index);

//! \brief Returns entity collision type.
//! \param entity Entity handle.
//! \ingroup ecolcommands
int xGetEntityType(size_t entity);
	
// Terrain commands
//! \brief Creates a terrain entity and returns its handle.
//! \details The terrain extends from 0, 0, 0 to size, 1, size.
//! The parent parameter allows you to specify a parent entity for the
//! terrain so that when the parent is moved the child terrain will move
//! with it. However, this relationship is one way; applying movement
//! commands to the child will not affect the parent.
//! Specifying a parent entity will still result in the terrain being
//! created at position 0, 0, 0 rather than at the parent entity's position.
//! \param size Number of grid squares along each side of terrain, and must
//! be a power of 2 value, e.g. 32, 64, 128, 256, 512, 1024.
//! \param parent Parent entity handle.
//! \ingroup terrcommands
size_t xCreateTerrain(int size, size_t parent);

//! \brief Loads a terrain from an image file and returns the terrain's handle. 
//! \details The image's red channel is used to determine heights. Terrain
//! is initially the same width and depth as the image, and 1.0 unit high.
//! 
//! Tips on generating nice terrain:
//! 
//! * Smooth or blur the height map
//! 
//! * Reduce the y scale of the terrain
//! 
//! * Increase the x/z scale of the terrain
//! 
//! * Reduce the camera range
//! 
//! When texturing an entity, a texture with a scale of 1, 1, 1 (default)
//! will be the same size as one of the terrain's grid squares. A texture
//! that is scaled to the same size as the size of the bitmap used to load
//! it or the no. of grid square used to create it, will be the same size
//! as the terrain.
//! The parent parameter allows you to specify a parent entity for the
//! terrain so that when the parent is moved the child terrain will move
//! with it. However, this relationship is one way; applying movement
//! commands to the child will not affect the parent.
//! Specifying a parent entity will still result in the terrain being
//! created at position 0, 0, 0 rather than at the parent entity's position.
//! A heightmaps dimensions (width and height) must be the same and must be
//! a power of 2, e.g. 32, 64, 128, 256, 512, 1024.
//! \param path Filename of image file to be used as height map.
//! \param parent Parent entity handle.
//! \ingroup terrcommands
size_t xLoadTerrain(const char * path, size_t parent);

//! \brief Returns the grid size used to create a terrain.
//! \param terrain Entity handle.
//! \ingroup terrcommands
int xTerrainSize(size_t terrain);

//! \brief Enables or disables terrain shading.
//! \details Shaded terrains are a little slower than non-shaded terrains,
//! and in some instances can increase the visibility. However, the option
//! is there to have shaded terrains if you wish to do so.
//! \param terrain Entity handle.
//! \param state True to enable terrain shading, false to to disable it.
//! The default mode is false.
//! \ingroup terrcommands
void xTerrainShading(size_t terrain, bool state);

//! \brief Sets the detail level for a terrain
//! \param terrain Terrain handle
//! \param detail Terrains detail level (default - 2048)
//! \ingroup terrcommands
void xTerrainDetail(size_t terrain, int detail);
	
//! \brief Returns the height of the terrain at terrain grid coordinates x, z.
//! \details The value returned is in the range [0.0; 1.0].
//! \param terrain Entity handle.
//! \param x Grid x coordinate of terrain.
//! \param y Grid y coordinate of terrain.
//! \ingroup terrcommands
float xTerrainHeight(size_t terrain, int x, int y);

//! \brief Sets the height of a point on a terrain.
//! \param terrain Entity handle.
//! \param x Grid x coordinate of terrain.
//! \param y Grid y coordinate of terrain.
//! \param height Height of point on terrain. Should be in the range [0.0; 1.0] .
//! \ingroup terrcommands
void xModifyTerrain(size_t terrain, int x, int y, float height);

//! \brief Returns the interpolated x coordinate on a terrain.
//! \param terrain Entity handle.
//! \param x World x coordinate.
//! \param y World y coordinate.
//! \param z World z coordinate.
//! \ingroup terrcommands
float xTerrainX(size_t terrain, float x, float y, float z);

//! \brief Returns the interpolated y coordinate on a terrain.
//! \param terrain Entity handle.
//! \param x World x coordinate.
//! \param y World y coordinate.
//! \param z World z coordinate.
//! \ingroup terrcommands
float xTerrainY(size_t terrain, float x, float y, float z);

//! \brief Returns the interpolated z coordinate on a terrain.
//! \param terrain Entity handle.
//! \param x World x coordinate.
//! \param y World y coordinate.
//! \param z World z coordinate.
//! \ingroup terrcommands
float xTerrainZ(size_t terrain, float x, float y, float z);
	
// Sound system commands
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
//! \brief Returns true if iPod player is running.
//! \details In iPhones (iPodes) you can mix your game sounds with a system audio playback.
//! \ingroup audiocommands
bool xIsiPodPlaying();

//! \brief Enables iPod playback (enabled by default).
//! \ingroup audiocommands
void xEnableiPodMusic();
	
//! \brief Disables iPod playback (enabled by default).
//! \ingroup audiocommands
void xDisableiPodMusic();
	
//! \brief Switches to next item in a media player playlist.
//! \ingroup audiocommands
void xMediaPlayerNextItem();

//! \brief Switches to previous item in a media player playlist.
//! \ingroup audiocommands
void xMediaPlayerPrevItem();
	
//! \brief Switches to an item with specified identifier.
//! \param itemID Unique item ID.
//! \ingroup audiocommands
void xMediaPlayerToItem(uint itemID);
	
//! \brief Starts playing a current item in a media player.
//! \ingroup audiocommands
void xMediaPlayerPlay();

//! \brief Stops playing a current item in a media player.
//! \ingroup audiocommands
void xMediaPlayerStop();

//! \brief Pauses a current item in a media player.
//! \ingroup audiocommands
void xMediaPlayerPause();

//! \brief Returns a state of current item in a media player.
//! \details See '\ref mediaitemstate' for more information.
//! \ingroup audiocommands
int xMediaPlayerState();

//! \brief Sets repeat mode for a media player.
//! \details See '\ref repeatmodes' for more information.
//! \ingroup audiocommands
void xMediaPlayerRepeatMode(int mode);

//! \brief Returns current repeat mode of a media player.
//! \details See '\ref repeatmodes' for more information.
//! \ingroup audiocommands
int xMediaPlayerCurrentRepeatMode();

//! \brief Sets shuffle mode for media player.
//! \details See '\ref shufflemodes' for more information.
//! \ingroup audiocommands
void xMediaPlayerShuffleMode(int mode);

//! \brief Returns current shuffle mode of media player.
//! \details See '\ref shufflemodes' for more information.
//! \ingroup audiocommands
int xMediaPlayerCurrentShuffleMode();

//! \brief Sets current playback time in seconds.
//! \ingroup audiocommands
void xMediaPlayerTime(float newTime);

//! \brief Returns current playback time in seconds.
//! \ingroup audiocommands
float xMediaPlayerCurrentTime();
	
//! \brief Returns a unique ID of current item.
//! \details Not recommended to be used too frequently in realtime.
//! \ingroup audiocommands
uint xMediaPlayerItemID();
	
//! \brief Returns a type of current item.
//! \details See '\ref mediaitemtypes' for more infromation.
//!
//! Not recommended to be used too frequently in realtime.
//! \ingroup audiocommands
int xMediaPlayerItemType();

//! \brief Returns a title of current item.
//! \details Not recommended to be used too frequently in realtime.
//! \ingroup audiocommands
const char * xMediaPlayerItemTitle();

//! \brief Returns an album title of current item.
//! \details Not recommended to be used too frequently in realtime.
//! \ingroup audiocommands
const char * xMediaPlayerItemAlbum();

//! \brief Returns an artist of current item.
//! \details Not recommended to be used too frequently in realtime.
//! \ingroup audiocommands
const char * xMediaPlayerItemArtist();

//! \brief Returns a genre of current item.
//! \details Not recommended to be used too frequently in realtime.
//! \ingroup audiocommands
const char * xMediaPlayerItemGenre();

//! \brief Returns a composer of current item.
//! \details Not recommended to be used too frequently in realtime.
//! \ingroup audiocommands
const char * xMediaPlayerItemComposer();

//! \brief Returns a track number of current item in the album.
//! \details Not recommended to be used too frequently in realtime.
//! \ingroup audiocommands
int xMediaPlayerItemAlbumTrackNumber();

//! \brief Returns a disc number of current item.
//! \details Not recommended to be used too frequently in realtime.
//! \ingroup audiocommands
int xMediaPlayerItemDiscNumber();

//! \brief Returns a cover (artwork) of current item as an image
//! \details Do not forget to release the image.
//! \param width Image width in pixels.
//! \param height Image height in pixels.
//! \ingroup audiocommands
int xMediaPlayerItemCoverToImage(int width, int height);

//! \brief Returns a cover (artwork) of current item as a texture
//! \details Do not forget to release texture.
//! \param width Texture width in pixels.
//! \param height Texture height in pixels.
//! \ingroup audiocommands
int xMediaPlayerItemCoverToTexture(int width, int height);

//! \brief Returns lyrics text of current item.
//! \details Not recommended to be used too frequently in realtime.
//! \ingroup audiocommands
const char * xMediaPlayerItemLyrics();
#endif
	

//! \Update Audio Channels without xRenderWorld (2d only).
void xUpdateAudio();
	
	
//! \brief Loads a sound file into memory.
//! \param path Name of sound file. Supported formats: raw/wav/mp3/ogg.
//! \ingroup audiocommands
size_t xLoadSound(const char * path);

//! \brief Loads and plays a music file.
//! \details You must use a channel variable in order to stop or adjust
//! the music playing. You may use xStopChannel(), xPauseChannel(),
//! xResumeChannel(), etc. with this command.
//! You can't preload the audio like you can a sound sample via the
//! xLoadSound() command. Every time you call the xPlayMusic() command,
//! the file is reloaded and played.
//! \param path Name of music file. Supported formats: raw/wav/mp3/ogg.
//! \param looped True to play a music file in an endless loop.
//! \ingroup audiocommands
size_t xPlayMusic(const char * path, bool looped);

//! \brief Frees up a sound.
//! \param sound Sound handle.
//! \ingroup audiocommands
void xFreeSound(size_t sound);

//! \brief Sets up play back a sound file in an endless loop (like for
//! background music).
//! \details This command doesn't actually play the sound loop, just sets
//! it up for looping. You still need to execute the xPlaySound() command
//! to hear the sound.
//! \param sound Sound handle.
//! \ingroup audiocommands
void xLoopSound(size_t sound);

//! \brief Alters the pitch of a sound.
//! \details By changing the pitch, you can often reuse sounds for different
//! uses or to simulate a 'counting up/down' sound. To make the sound
//! 'higher pitched', increase the hertz. Conversely, decreasing the hertz
//! will 'lower' the pitch. Note: this is in relation to the original hertz
//! frequency of the sound. 
//! \param sound Sound handle.
//! \param pitch Valid playback hertz speed (up to 44000 hertz).
//! \ingroup audiocommands
void xSoundPitch(size_t sound, int pitch);

//! \brief Alters the playback volume of sound effect.
//! \details This command uses a floating point number from 0.0 to 1.0
//! to control the volume level.
//! \param sound Sound handle.
//! \param volume Floating point number from 0.0 (silence) to 1.0 (full volume).
//! \ingroup audiocommands
void xSoundVolume(size_t sound, float volume);

//! \brief Pans sound effect between the left and right speakers.
//! \param sound Sound handle
//! \param panoram Floating point number from -1.0 (left) to 0.0 (center) to
//! 1.0 (right).
//! \ingroup audiocommands
void xSoundPan(size_t sound, float panoram);

//! \brief Plays a sound previously loaded using the xLoadSound() command.
//! \param sound Sound handle.
//! \ingroup audiocommands
size_t xPlaySound(size_t sound);

//! \brief Stops channel playing.
//! \param channel Channel handle.
//! \ingroup audiocommands
void xStopChannel(size_t channel);

//! \brief Pauses channel playing.
//! \details When you are playing a sound channel, there may come a time
//! you wish to pause the sound for whatever reason (like to play another
//! sound effect). This command does this - and the channel can be resumed
//! with the xResumeChannel() command. You can use xStopChannel() to
//! actually halt the sound.
//! \param channel Channel handle.
//! \ingroup audiocommands
void xPauseChannel(size_t channel);

//! \brief Continues the playing of a sound sample or music track on the
//! given channel after you have temporarily halted playback on that
//! channel (via xPauseChannel()).
//! \param channel Channel handle.
//! \ingroup audiocommands
void xResumeChannel(size_t channel);

//! \brief Sets channel frequency.
//! \details You can alter the pitch of a sound channel that is playing
//! (or in use and just paused). Use the frequency of your sound as the
//! 'baseline' for pitch change. So if your sample is at 11025 hertz,
//! increase the pitch to 22050 to make the pitch twice as high, 8000 to
//! make it lower, etc. While similar to xSoundPitch(), this command let's
//! you change the pitch individually of each and every channel in use. 
//! \param channel Channel handle.
//! \param pitch Pitch to apply to the channel.
//! \ingroup audiocommands
void xChannelPitch(size_t channel, int pitch);

//! \brief Sets channel volume.
//! \details While xSoundVolume() happily changes the volume of the entire
//! program, this command will let you adjust volume rates on a 'per
//! channel' basis. Extremely useful.
//!  The volume value is a floating point value between 0.0 and 1.0 (0.0f
//! = silence, 0.5 = half volume, 1.0 = full volume).
//! \param channel Channel handle.
//! \param volume Volume level floating value between 0.0 and 1.0 .
//! \ingroup audiocommands
void xChannelVolume(size_t channel, float volume);

//! \brief Sets channel panoram value.
//! \details When you want to do real sound panning effects, this is the
//! command you'll use. This will allow you to pan the sound channels on a
//! 'per channel' basis between the left and right speakers. This command
//! makes it very easy to produce some really killer stereophonic effects. 
//! The pan value is between -1 and 1 with 0 being perfect center. -1 is
//! full left, and 1 is full right. To make it somewhere in between, try
//! -0.5 for 50% left or 0.75 for 75% right.
//! \param channel Channel handle.
//! \param panoram Panning value to denote channel playback.
//! \ingroup audiocommands
void xChannelPan(size_t channel, float panoram);

//! \brief Returns true if specified channel is being played.
//! \details Often you will need to know if a sound channel has completed
//! playing or not. This command will return 1 if the sound is still playing
//! or 0 if it has stopped. Use this to restart your background music or
//! some other sound that might have stopped unintentionally.
//! \param channel Channel handle.
//! \ingroup audiocommands
bool xChannelPlaying(size_t channel);

//! \brief Creates a listener entity and returns its handle.
//! \details Currently, only a single listener is supported. 
//! \param parent Parent entity handle.
//! \param rolloffFactor The rate at which volume diminishes with distance
//! \param dopplerFactor The severity of the doppler effect
//! \param distanceFactor Artificially scales distances
//! \ingroup audiocommands
size_t xCreateListener(size_t parent, float rolloffFactor, float dopplerFactor, float distanceFactor);

//! \brief Loads a sound and returns its handle for use with xEmitSound().
//! \param path Filename of sound file to be loaded and used as 3D sound.
//! \ingroup audiocommands
size_t xLoad3DSound(const char * path);

//! \brief Emits a sound attached to the specified entity and returns a
//! sound channel.
//! \details The sound must have been loaded using xLoad3DSound() for 3D
//! effects.
//! \param sound Sound handle.
//! \param entity Entity handle.
//! \ingroup audiocommands
size_t xEmitSound(size_t sound, size_t entity);
	
// Font commands
//! \brief Loads a font and returns a font handle.
//! \details iXors3D Engine uses bitmap fonts, so you can't set its style or size,
//! you must do it in font generation stage.
//! \param path Name of font file to be loaded.
//! \ingroup textcommands
size_t xLoadFont(const char * path);

//! \brief Activates a font previously loaded into memory (by xLoadFont() command)
//! for further use with printing commands such as xText().
//! \param font Font handle.
//! \ingroup textcommands
void xSetFont(size_t font);
	
//! \brief Enables or disables font texture color use.
//! \details Only an alpha channel of the font texture is used by default.
//! \param font Font handle.
//! \param state True to enable font texture colors, false to disable.
//! \ingroup textcommands
void xFontTextureColor(size_t font, bool state);

//! \brief Prints a string at the designated screen coordinates.
//! \param x Starting x coordinate to print text.
//! \param y Starting y coordinate to print text.
//! \param text Text to print.
//! \param centerx True to center horizontally.
//! \param centery True to center vertically.
//! \ingroup textcommands
void xText(int x, int y, const char * text, bool centerx, bool centery);

//! \brief Prints a string at the designated screen coordinates width align by rect width
//! \param x Starting x coordinate to print text.
//! \param y Starting y coordinate to print text.
//! \param width Width of align rect.
//! \param text Text to print.
//! \ingroup textcommands
void xTextEx(int x, int y, int width, const char * text);
	
//! \brief Frees up a font.
//! \param font Font handle.
//! \ingroup textcommands
void xFreeFont(size_t font);

//! \brief Returns the width, in pixels, of a current font.
//! \details Set the font by using xSetFont() command.
//! \ingroup textcommands
int xFontWidth();

//! \brief Returns the height, in pixels, of a current font.
//! \details Set the font by using xSetFont() command.
//! \ingroup textcommands
int xFontHeight();

//! \brief Returns the size, in pixels, the width of the indicated string.
//! \details This is useful for determining screen layout, scrolling of 
//! text, and more. The value is calculated basing on the size of the current font. 
//! \param text Any valid string.
//! \ingroup textcommands
int xStringWidth(const char * text);

//! \brief Returns the size, in pixels, the height of the indicated string.
//! \details This is useful for determining screen layout, scrolling of 
//! text, and more. The value is calculated basing on the size of the current font.
//! \param text Any valid string.
//! \ingroup textcommands
int xStringHeight(const char * text);
	
//! \brief Rotates a font.
//! \details The purpose of this command is to rotate a font a specified
//! number of degrees. You can use it in realtime.
//! \param font Font handle.
//! \param angle An integer number from 0 to 360 degrees.
//! \ingroup textcommands
void xRotateFont(size_t font, float angle);

//! \brief Sets font drawing handle position.
//! \param font Font handle.
//! \param x x coordinate of the new font drawing handle location.
//! \param y y coordinate of the new font drawing handle location.
//! \ingroup textcommands
void xHandleFont(size_t font, int x, int y);

//! \brief Resizes a font to a new size using a floating point percentage 
//! \details Use of a negative value performs font flipping. You can use it
//! in realtime.
//! \param font Font handle.
//! \param x The amount to scale the font horizontally.
//! \param y The amount to scale the font vertically.
//! \ingroup textcommands
void xScaleFont(size_t font, float x, float y);

//! \brief Sets an alpha value of the font.
//! \param font Font handle.
//! \param alpha Alpha value in range [0.0; 1.0] .
//! \ingroup textcommands
void xFontAlpha(size_t font, float alpha);

//! \brief Sets a blending mode of the font.
//! \param font Font handle.
//! \param mode Blending mode. See '\ref imgblendtypes' for more information.
//! \ingroup textcommands
void xFontBlend(size_t font, int mode);
	

//! \Set font color :)
void xFontColor(size_t font, int r, int g, int b);
	
	
// Sprites commands
//! \brief Creates a sprite entity and returns its handle.
//! Sprites are simple flat (usually textured) rectangles made from two
//! triangles.
//! \details The sprite will be positioned at 0, 0, 0 and extend from -1, -1 to +1, +1. 
//! Sprites have two real strengths. The first is that they consist of only
//! two polygons; meaning you can use many of them at once. This makes them
//! ideal for particle effects and 2D-using-3D games where you want lots of
//! sprites on-screen at once.
//! Secondly, sprites can be assigned a view mode using xSpriteViewMode().
//! By default this view mode is set to SPRITE_FIXED, which means the
//! sprite will always face the camera. So no matter what the orientation
//! of the camera is relative to the sprite, you will never actually notice
//! that they are flat; by giving them a spherical texture, you can make
//! them appear to look no different than a normal sphere. 
//! The parent parameter allow you to specify a parent entity for the
//! sprite so that when the parent is moved the child sprite will move with
//! it. However, this relationship is one way; applying movement commands
//! to the child will not affect the parent.
//! Specifying a parent entity will still result in the sprite being created
//! at position 0, 0, 0 rather than at the parent entity's position. 
//! Note: Sprites have their own commands for rotation and scaling.
//! \param parent Parent entity handle.
//! \ingroup sprcommands
size_t xCreateSprite(size_t parent);
	
//! \brief Creates a sprite entity, assigns a texture to it and retuns
//! sprite handle.
//! \details Supported file formats: 
//! bmp, dds, dib, hdr, jpg, pfm, png, ppm, tga.
//! \param path Filename of image file to be used as sprite.
//! \param flags Texture loading flags. See '\ref tlflags' for more information.
//! \param parent Parent entity handle.
//! \ingroup sprcommands
size_t xLoadSprite(const char * path, int flags, size_t parent);
	
//! \brief Rotates a sprite.
//! \param sprite Sprite handle.
//! \param angle Absolute angle of sprite roll rotation.
//! \ingroup sprcommands
void xRotateSprite(size_t sprite, float angle);
	
//! \brief Scales a sprite.
//! \param sprite Sprite handle.
//! \param x x scale of sprite.
//! \param y y scale of sprite.
//! \ingroup sprcommands
void xScaleSprite(size_t sprite, float x, float y);
	
//! \brief Sets a sprite handle. Defaults to 0, 0.
//! \details By default sprite extends from -1, -1 to +1, +1.
//! \param sprite Sprite handle.
//! \param x x coordinate of the new sprite drawing handle location.
//! \param y y coordinate of the new sprite drawing handle location.
//! \ingroup sprcommands
void xHandleSprite(size_t sprite, float x, float y);
	
//! \brief Sets the view mode of a sprite.
//! \details The view mode determines how a sprite alters its orientation
//! in respect to the camera. This allows the sprite to in some instances
//! give the impression that it is more than two dimensional.
//! See '\ref sviewmodes' for more infromation.
//! Note that if you use sprite view mode SPRITE_FREE, then because it is
//! independent from the camera, you will only be able to see it from one
//! side unless you use xEntityFX() flag FX_DISABLECULLING with it to
//! disable backface culling.
//! \param sprite Sprite handle.
//! \param mode View mode.
//! \ingroup sprcommands
void xSpriteViewMode(size_t sprite, int mode);

// File system commands
//! \brief Reads a directory.
//! \details In file operations, you will often need to parse through a
//! directory and retrieve unknown filenames and other folders from it.
//! This command opens a specified folder to begin these operations.
//! The command returns a file handle which is used by the other
//! commands to perform other services. You will use the xNextFile()
//! to iterate through each entry.
//! 
//! NOTE: In iPhone OS you may store files in application wrapper
//! directory or in Documents directory. iXors3D Engine supports
//! both. For files stored in application wrapper directory you need
//! to use 'app://' protocol tag in a path (e.g. 'app://myfile.txt'), and
//! 'file://' protocol tag (e.g. 'file://myfile.txt') for files
//! stored in Documents directory.
//! \param path Directory path.
//! \ingroup fscommands
size_t xReadDir(const char * path);

//! \brief Closes a directory.
//! \details Once you are finished with xNextFile() on the directory
//! previously opened for read with the xReadDir() command, use this
//! command to close the directory.
//! \param directory Directory handle.
//! \ingroup fscommands
void xCloseDir(size_t directory);
	
//! \brief Returns the next file or folder from the currently open directory
//! \details This will return a string containing the folder name or the
//! filename plus extention. Use xFileType() to determine if it is a file
//! or a folder. See xReadDir() and xCloseDir() for more information. You cannot move
//! 'backwards' through a directory, only forward. You might want to parse
//! the contents of a directory into an array for display, processing, etc.
//! \param directory Directory handle.
//! \ingroup fscommands
const char * xNextFile(size_t directory);
	
//! \brief Returns the currently selected directory for disk operations,
//! useful for advanced file operations.
//! \details Use xChangeDir() to change the current directory.
//! \param appDirectory True to get a current directory in application
//! wrapper, false to get current directory in Documents directory.
//! \ingroup fscommands
const char * xCurrentDir(bool appDirectory);
	
//! \brief Changes the currently selected directory for disk operations.
//! \details Use xCurrentDir() to see what the current directory is.
//! 
//! NOTE: In iPhone OS you may store files in application wrapper
//! directory or in Documents directory. iXors3D Engine supports
//! both. For files stored in application wrapper directory you need
//! to use 'app://' protocol tag in a path (e.g. 'app://myfile.txt'), and
//! 'file://' protocol tag (e.g. 'file://myfile.txt') for files
//! stored in Documents directory.
//! \param path Directory path
//! \ingroup fscommands
void xChangeDir(const char * path);

//! \brief Creates a directory at the specified destination.
//! 
//! NOTE: In iPhone OS you may store files in application wrapper
//! directory or in Documents directory. iXors3D Engine supports
//! both. For files stored in application wrapper directory you need
//! to use 'app://' protocol tag in a path (e.g. 'app://myfile.txt'), and
//! 'file://' protocol tag (e.g. 'file://myfile.txt') for files
//! stored in Documents directory.
//! \param path Directory path.
//! \ingroup fscommands
bool xCreateDir(const char * path);
	
//! \brief Deletes a specified directory from the device.
//! 
//! NOTE: In iPhone OS you may store files in application wrapper
//! directory or in Documents directory. iXors3D Engine supports
//! both. For files stored in application wrapper directory you need
//! to use 'app://' protocol tag in a path (e.g. 'app://myfile.txt'), and
//! 'file://' protocol tag (e.g. 'file://myfile.txt') for files
//! stored in Documents directory.
//! \param path Directory path.
//! \ingroup fscommands
bool xDeleteDir(const char * path);
	
//! \brief Opens the designated file and prepares it to be updated.
//! The file must exist since this function will not create a new file
//! \details By using xFilePos() and xSeekFile() the position within
//! the file that is being read or written can be determined and also
//! changed. This allows a file to be read and updated without having to
//! make a new copy of the file or working through the whole file sequentially.
//! 
//! NOTE: In iPhone OS you may store files in application wrapper
//! directory or in Documents directory. iXors3D Engine support
//! both. For files stored in application wrapper directory you need
//! touse 'app://' protocol tag in a path (e.g. 'app://myfile.txt'), and
//! 'file://' protocol tag (e.g. 'file://myfile.txt') for files
//! stored in Documents directory.
//! \param path File path.
//! \ingroup fscommands
size_t xOpenFile(const char * path);
	
//! \brief Opens the designated filename and prepares it to be read from.
//! 
//! NOTE: In iPhone OS you may store files in application wrapper
//! directory or in Documents directory. iXors3D Engine supports
//! both. For files stored in application wrapper directory you need
//! to use 'app://' protocol tag in a path (e.g. 'app://myfile.txt'), and
//! 'file://' protocol tag (e.g. 'file://myfile.txt') for files
//! stored in Documents directory.
//! \param path File path.
//! \ingroup fscommands
size_t xReadFile(const char * path);

//! \brief Opens the designated filename and prepares it to be written to.
//! 
//! NOTE: In iPhone OS you may store files in application wrapper
//! directory or in Documents directory. iXors3D Engine supports
//! both. For files stored in application wrapper directory you need
//! to use 'app://' protocol tag in a path (e.g. 'app://myfile.txt'), and
//! 'file://' protocol tag (e.g. 'file://myfile.txt') for files
//! stored in Documents directory.
//! \param path File path.
//! \ingroup fscommands
size_t xWriteFile(const char * path);
	
//! \brief Closes a file previously opened.
//! \details You should always close a file as soon as you have finished
//! reading or writing to it.
//! \param fileHandle File handle.
//! \ingroup fscommands
void xCloseFile(size_t fileHandle);
	
//! \brief Returns the current position within a file.
//! \details The returned integer is the offsets in bytes from the start
//! of the file to the current read/write position.
//! \param fileHandle File handle.
//! \ingroup fscommands
unsigned int xFilePos(size_t fileHandle);
	
//! \brief Sets the position within a file.
//! \details This allows random access to data within files. Note, the
//! offset is the number of bytes from the start of the file, where the
//! first byte is at offset 0. It is important to take account of the
//! size of the data elements in your file.
//! \param fileHandle File handle.
//! \param offset Offset in the file in bytes.
//! \ingroup fscommands
void xSeekFile(size_t fileHandle, unsigned int offset);
	
//! \brief Checks the filename you pass and determines if it exists and
//! whether or not it is a valid filename or if it is a directory
//! \details Here are the values it returns:
//!
//! 0 - The filename doesn't exist.
//! 
//! 1 - The filename exists.
//! 
//! 2 - The filename is not a file - but a directory.
//! 
//! NOTE: In iPhone OS you may store files in application wrapper
//! directory or in Documents directory. iXors3D Engine supports
//! both. For files stored in application wrapper directory you need
//! to use 'app://' protocol tag in a path (e.g. 'app://myfile.txt'), and
//! 'file://' protocol tag (e.g. 'file://myfile.txt') for files
//! stored in Documents directory.
//! \param path File path.
//! \ingroup fscommands
int xFileType(const char * path);
	
//! \brief Returns the size of a file.
//! 
//! NOTE: In iPhone OS you may store files in application wrapper
//! directory or in Documents directory. iXors3D Engine supports
//! both. For files stored in application wrapper directory you need
//! to use 'app://' protocol tag in a path (e.g. 'app://myfile.txt'), and
//! 'file://' protocol tag (e.g. 'file://myfile.txt') for files
//! stored in Documents directory.
//! \param path File path.
//! \ingroup fscommands
unsigned int xFileSize(const char * path);
	
//! \brief Copys a file from one location to another
//! 
//! NOTE: In iPhone OS you may store files in application wrapper
//! directory or in Documents directory. iXors3D Engine supports
//! both. For files stored in application wrapper directory you need
//! touse 'app://' protocol tag in a path (e.g. 'app://myfile.txt'), and
//! 'file://' protocol tag (e.g. 'file://myfile.txt') for files
//! stored in Documents directory.
//! \param pathFrom Path to the file to be copied
//! \param pathTo Path to copy the file to
//! \ingroup fscommands
bool xCopyFile(const char * pathFrom, const char * pathTo);
	
//! \brief Deletes a specified file
//! 
//! NOTE: In iPhone OS you may store files in application wrapper
//! directory or in Documents directory. iXors3D Engine supports
//! both. For files stored in application wrapper directory you need
//! to use 'app://' protocol tag in a path (e.g. 'app://myfile.txt'), and
//! 'file://' protocol tag (e.g. 'file://myfile.txt') for files
//! stored in Documents directory.
//! \param path File path
//! \ingroup fscommands
bool xDeleteFile(const char * path);
	
//! \brief Checks to see if the 'End of File' of an opened file has been reached.
//! \param fileHandle File handle.
//! \ingroup fscommands
bool xEof(size_t fileHandle);
	
//! \brief Reads a single byte from the file.
//! \param fileHandle File handle.
//! \ingroup fscommands
unsigned char xReadByte(size_t fileHandle);
	
//! \brief Reads a single short value (2 bytes) from the file.
//! \param fileHandle File handle.
//! \ingroup fscommands
short xReadShort(size_t fileHandle);
	
//! \brief Reads a single integer value (4 bytes) from the file.
//! \param fileHandle File handle.
//! \ingroup fscommands
int xReadInt(size_t fileHandle);
	
//! \brief Reads a single float value (4 bytes) from the file.
//! \param fileHandle File handle.
//! \ingroup fscommands
float xReadFloat(size_t fileHandle);
	
//! \brief Reads a string from the file.
//! \details Each string is stored in the file as a 4 byte integer followed by
//! the characters that form the string. The integer contains the number of
//! characters in the string, i.e. its length. Note, that 'Carriage Return',
//! 'Line Feed' and 'Null' characters are not use to indicate the end of the string.
//! \param fileHandle File handle.
//! \ingroup fscommands
const char * xReadString(size_t fileHandle);
	
//! \brief Reads a line from the file.
//! \details Characters are read from the input file until an 'end-of-line' mark is found
//! \param fileHandle File handle.
//! \ingroup fscommands
const char * xReadLine(size_t fileHandle);
	
//! \brief Reads bytes from the file.
//! \details NOTE: You must delete returned buffer manually.
//! \param fileHandle File handle.
//! \param size Number of bytes to be read.
//! \ingroup fscommands
void * xReadBytes(size_t fileHandle, unsigned int size);
	
//! \brief Writes a single byte into file.
//! \param fileHandle File handle.
//! \param value Byte value to be written.
//! \ingroup fscommands
void xWriteByte(size_t fileHandle, unsigned char value);
	
//! \brief Writes a single short value (2 bytes) into file.
//! \param fileHandle File handle.
//! \param value Short value to be written.
//! \ingroup fscommands
void xWriteShort(size_t fileHandle, short value);

//! \brief Writes a single integer value (4 bytes) into file.
//! \param fileHandle File handle.
//! \param value Integer value to be written.
//! \ingroup fscommands
void xWriteInt(size_t fileHandle, int value);

//! \brief Writes a single float value (4 bytes) into file.
//! \param fileHandle File handle.
//! \param value Float value to be written.
//! \ingroup fscommands
void xWriteFloat(size_t fileHandle, float value);
	
//! \brief Writes a string into file.
//! \param fileHandle File handle.
//! \param value String to be written.
//! \ingroup fscommands
void xWriteString(size_t fileHandle, const char * value);
	
//! \brief Writes a line into file.
//! \param fileHandle File handle.
//! \param value String to be written.
//! \ingroup fscommands
void xWriteLine(size_t fileHandle, const char * value);

//! \brief Writes a bytes into file.
//! \param fileHandle File handle.
//! \param value Pointer of data buffer to be written into file.
//! \param size Number of bytes to be written into file.
//! \ingroup fscommands
void xWriteBytes(size_t fileHandle, void * value, int size);

//! \brief Opens a movie file for playing.
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
//! \details iXors3d Engine supports only fullscreen video playback.
//!
//! Supported formats: .mov, .m4v, .3gp and .mpv;  supported compression standards:
//!
//! * H.264 Baseline Profile Level 3.0 video, up to 640 x 480 at 30 fps (the Baseline profile does not support B frames.)
//!
//! * MPEG-4 Part 2 video (Simple Profile)
//! \param path Path to movie file.
//! \ingroup videopbcommands
int xOpenMovie(const char * path);

//! \brief Starts movie playback.
//! \details For video playback only landscape screen orientation is used.
//! \param movie Movie handle.
//! \ingroup videopbcommands
void xPlayMovie(int movie);
	
//! \brief Stops movie playback.
//! \param movie Movie handle.
//! \ingroup videopbcommands
void xStopMovie(int movie);
	
//! \brief Closed movie file.
//! \param movie Movie handle.
//! \ingroup videopbcommands
void xCloseMovie(int movie);
	
//! \brief Returns true if the specified movie is being played back.
//! \param movie Movie handle.
//! \ingroup videopbcommands
bool xMoviePlaying(int movie);
#endif
	
//! \brief Creates a new HTTP request.
//! \param url URL for request.
//! \param timeout Connection timeout.
//! \param cacheble If true cache is used for request.
//! \ingroup netcommands
size_t xCreateHTTPRequest(const char * url, int timeout, bool cacheble);

//! \brief Sets connection timeout interval for HTTP request (in seconds).
//! \param request Request handle.
//! \param timeout Connection timeout in seconds.
//! \ingroup netcommands
void xSetRequestTimeoutInterval(size_t request, int timeout);

//! \brief Returns connection timeout interval of HTTP request (in seconds).
//! \param request Request handle.
//! \ingroup netcommands
int xGetRequestTimeoutInterval(size_t request);

//! \brief Enables caching for HTTP request.
//! \param request Request handle.
//! \ingroup netcommands
void xEnableRequestCaching(size_t request);

//! \brief Disables caching for HTTP request.
//! \param request Request handle.
//! \ingroup netcommands
void xDisableRequestCaching(size_t request);

//! \brief Checks if caching is enabled for HTTP request.
//! \param request Request handle.
//! \ingroup netcommands
bool xIsRequestCachable(size_t request);

//! \brief Returns URL of HTTP request.
//! \param request Request handle.
//! \ingroup netcommands
const char * GetRequestURL(size_t request);

//! \brief Sets request method.
//! \param request Request handle.
//! \param method Request method. See '\ref httpreqmethods' for more information.
//! \ingroup netcommands
void xSetRequestMethod(size_t request, int method);

//! \brief Returns request method.
//! \param request Request handle.
//! \ingroup netcommands
int xGetRequestMethod(size_t request);

//! \brief Enables cookies handle for request.
//! \param request Request handle.
//! \ingroup netcommands
void xEnableRequestCookies(size_t request);

//! \brief Disables cookies handle for request.
//! \param request Request handle.
//! \ingroup netcommands
void xDisableRequestCookies(size_t request);

//! \brief Checks if request handle cookies.
//! \param request Request handle.
//! \ingroup netcommands
bool xIsRequestHandleCookies(size_t request);

//! \brief Sets user name and password for HTTP authorization.
//! \param request Request handle.
//! \param userName User name (Use an empty string to finish HTTP authorization).
//! \param password User password.
//! \ingroup netcommands
void xSetRequestAuthenticationData(size_t request, const char * userName, const char * password);

//! \brief Sets referrer URL for HTTP request.
//! \param request Request handle.
//! \param referer Referer URL.
//! \ingroup netcommands
void xSetRequestReferer(size_t request, const char * referer);

//! \brief Sets user-agent identifier for HTTP request.
//! \param request Request handle.
//! \param userAgent User-agent identifier.
//! \ingroup netcommands
void xSetRequestUserAgent(size_t request, const char * userAgent);

//! \brief Sets cookie for HTTP request.
//! \param request Request handle.
//! \param name Cookie name.
//! \param value Cookie value.
//! \ingroup netcommands
void xAddRequestCookie(size_t request, const char * name, const char * value);

//! \brief Deletes cookie from HTTP request.
//! \param request Request handle.
//! \param name Cookie name.
//! \ingroup netcommands
void xDeleteRequestCookie(size_t request, const char * name);

//! \brief Deletes all cookies from HTTP request.
//! \param request Request handle.
//! \ingroup netcommands
void xClearRequestCookies(size_t request);

//! \brief Sets form field for HTTP request.
//! \param request Request handle.
//! \param name Field name.
//! \param value Field value.
//! \ingroup netcommands
void xAddRequestFormField(size_t request, const char * name, const char * value);

//! \brief Deletes form field from HTTP request.
//! \param request Request handle.
//! \param name Field name.
//! \ingroup netcommands
void xDeleteRequestFormField(size_t request, const char * name);

//! \brief Deletes all form fields from HTTP request.
//! \param request Request handle.
//! \ingroup netcommands
void xClearRequestFormFields(size_t request);

//! \brief Sends HTTP request to remote server and returns response handle.
//! \param request Request handle.
//! \param async Set true for asynchronous request.
//! \ingroup netcommands
size_t xSendHTTPRequest(size_t request, bool async);

//! \brief Returns response state.
//! \details See '\ref httpresptypes' for more information.
//! \param response Response handle.
//! \ingroup netcommands
int xGetResponseState(size_t response);

//! \brief Returns response data.
//! \param response Response handle.
//! \ingroup netcommands
void * xGetResponseData(size_t response);

//! \brief Returns response data length.
//! \param response Response handle.
//! \ingroup netcommands
uint xGetResponseDataLength(size_t response);

//! \brief Returns response MIME type.
//! \param response Response handle.
//! \ingroup netcommands
const char * xGetResponseMIMEType(size_t response);

//! \brief Returns response error code.
//! \param response Response handle.
//! \ingroup netcommands
int xGetResponseErrorCode(size_t response);

//! \brief Returns response error text.
//! \param response Response handle
//! \ingroup netcommands
const char * xGetResponseErrorText(size_t response);

//! \brief Deletes response.
//! \param response Response handle.
//! \ingroup netcommands
void xDeleteResponse(size_t response);
	
// physics commands
//! \brief Creates a dummy shape and links it to the entity. 
//! \details A dummy shape has no mass and collision body.
//! \param entity Entity handle
//! \ingroup pxcommands
void xEntityAddDummyShape(size_t entity);

//! \brief Creates a box shape and links it to the entity. 
//! \details Set any dimension of the box shape to zero or less than zero
//! and the shape will fit the dimensions of the entity automatically.
//! Setting mass to zero creates a fixed (non-dynamic) rigid body.
//! \param entity Entity handle
//! \param mass Mass of the body
//! \param width Width of the body
//! \param height Height of the body
//! \param depth Depth of the body
//! \ingroup pxcommands
void xEntityAddBoxShape(size_t entity, float mass, float width, float height, float depth);

//! \brief Creates a sphere shape and links it to the entity. 
//! \details Set the radius of the sphere shape to zero or less than zero
//! and the shape will fit the dimensions of the entity automatically.
//! Setting mass to zero creates a fixed (non-dynamic) rigid body.
//! \param entity Entity handle
//! \param mass Mass of the body
//! \param radius Radius of the body
//! \ingroup pxcommands
void xEntityAddSphereShape(size_t entity, float mass, float radius);

//! \brief Creates a capsule shape and links it to the entity. 
//! \details Set any dimension of the capsule shape to zero or less than zero
//! and the shape will fit the dimensions of the entity automatically.
//! Setting mass to zero creates a fixed (non-dynamic) rigid body.
//! \param entity Entity handle
//! \param mass Mass of the body
//! \param radius Radius of the body
//! \param height Height of the body
//! \ingroup pxcommands
void xEntityAddCapsuleShape(size_t entity, float mass, float radius, float height);

//! \brief Creates a cone shape and links it to the entity. 
//! \details Set any dimension of the cone shape to zero or less than zero
//! and the shape will fit the dimensions of the entity automatically.
//! Setting mass to zero creates a fixed (non-dynamic) rigid body.
//! \param entity Entity handle
//! \param mass Mass of the body
//! \param radius Radius of the body
//! \param height Height of the body
//! \ingroup pxcommands
void xEntityAddConeShape(size_t entity, float mass, float radius, float height);

//! \brief Creates a cylinder shape and links it to the entity. 
//! \details Set any dimension of the cylinder shape to zero or less than zero
//! and the shape will fit the dimensions of the entity automatically.
//! Setting mass to zero creates a fixed (non-dynamic) rigid body.
//! \param entity Entity handle
//! \param mass Mass of the body
//! \param width Width of the body
//! \param height Height of the body
//! \param depth Depth of the body
//! \ingroup pxcommands
void xEntityAddCylinderShape(size_t entity, float mass, float width, float height, float depth);

//! \brief Creates a trimesh (triangle mesh) shape and links it to the entity. 
//! \details Created trimesh shape is static which means that moving of vertices
//! won't affect the shape.
//! Setting mass to zero creates a fixed (non-dynamic) rigid body.
//! \param entity Entity handle
//! \param mass Mass of the body
//! \ingroup pxcommands
void xEntityAddTriMeshShape(size_t entity, float mass);

//! \brief Creates a shape of a convex hull and links it to the entity. 
//! \details The convex hull works much faster than the trimesh.
//! That's why the use of the convex hull is more preferable if it fits your needs.
//! Setting mass to zero creates a fixed (non-dynamic) rigid body.
//! \param entity Entity handle
//! \param mass Mass of the body
//! \ingroup pxcommands
void xEntityAddHullShape(size_t entity, float mass);

//! \brief Sets the vector of the gravity in the given world.
//! \details Default values are (0.0; -9.81; 0.0) .
//! If the world is not specified, the gravity of the active world will be changed.
//! \param x X-component of the gravity vector
//! \param y Y-component of the gravity vector
//! \param z Z-component of the gravity vector
//! \ingroup pxcommands
void xWorldGravity(float x, float y, float z);

//! \brief Applies a force to the center of mass of the entity's body.
//! \param entity Entity handle
//! \param x X-component of the force vector
//! \param y Y-component of the force vector
//! \param z Z-component of the force vector
//! \ingroup pxcommands
void xEntityApplyCentralForce(size_t entity, float x, float y, float z);

//! \brief Applies an impulse to the center of mass of the entity's body.
//! \param entity Entity handle
//! \param x X-component of the impulse vector
//! \param y Y-component of the impulse vector
//! \param z Z-component of the impulse vector
//! \ingroup pxcommands
void xEntityApplyCentralImpulse(size_t entity, float x, float y, float z);

//! \brief Applies a torque to the entity's body.
//! \param entity Entity handle
//! \param x X-component of the torque vector
//! \param y Y-component of the torque vector
//! \param z Z-component of the torque vector
//! \ingroup pxcommands
void xEntityApplyTorque(size_t entity, float x, float y, float z);

//! \brief Applies a torque impulse to the entity's body.
//! \param entity Entity handle
//! \param x X-component of the torque impulse vector
//! \param y Y-component of the torque impulse vector
//! \param z Z-component of the torque impulse vector
//! \ingroup pxcommands
void xEntityApplyTorqueImpulse(size_t entity, float x, float y, float z);

//! \brief Applies a force to the entity's body at the specific point relative to the center of this body.
//! \param entity Entity handle
//! \param x X-component of the force vector
//! \param y Y-component of the force vector
//! \param z Z-component of the force vector
//! \param pointx X-coordinate of the point
//! \param pointy Y-coordinate of the point
//! \param pointz Z-coordinate of the point
//! \ingroup pxcommands
void xEntityApplyForce(size_t entity, float x, float y, float z, float pointx, float pointy, float pointz);

//! \brief Applies an impulse to the entity's body at the specific point relative to the center of this body.
//! \param entity Entity handle
//! \param x X-component of the impulse vector
//! \param y Y-component of the impulse vector
//! \param z Z-component of the impulse vector
//! \param pointx X-coordinate of the point
//! \param pointy Y-coordinate of the point
//! \param pointz Z-coordinate of the point
//! \ingroup pxcommands
void xEntityApplyImpulse(size_t entity, float x, float y, float z, float pointx, float pointy, float pointz);

//! \brief Releases all the forces which were applied to the entity's body.
//! \details Linear and angular velocities are set to zero values.
//! \param entity Entity handle
//! \ingroup pxcommands
void xEntityReleaseForces(size_t entity);

//! \brief Sets the linear and angular damping of the entity's body.
//! \details The values of linear and angular damping are clamped to [0.0; 1.0].
//! \param entity Entity handle
//! \param linear The coefficient of the linear damping
//! \param angular The coefficient of the angular damping
//! \ingroup pxcommands
void xEntityDamping(size_t entity, float linear, float angular);

//! \brief Returns the coefficient of the linear damping of the entity's body.
//! \param entity Entity handle
//! \ingroup pxcommands
float xGetEntityLinearDamping(size_t entity);

//! \brief Returns the coefficient of the angular damping of the entity's body.
//! \param entity Entity handle
//! \ingroup pxcommands
float xGetEntityAngularDamping(size_t entity);

//! \brief Sets the friction of the entity's body.
//! \param entity Entity handle
//! \param friction The coefficient of the friction
//! \ingroup pxcommands
void xEntityFriction(size_t entity, float friction);

//! \brief Returns the friction of the entity's body.
//! \param entity Entity handle
//! \ingroup pxcommands
float xGetEntityFriction(size_t entity);

//! \brief Sets the restitution of the entity's body.
//! \param entity Entity handle
//! \param restitution The restitution value
//! \ingroup pxcommands
void xEntityRestitution(size_t entity, float restitution);

//! \brief Returns the restitution of the entity's body.
//! \param entity Entity handle
//! \ingroup pxcommands
float xGetEntityRestitution(size_t entity);
	
//! \brief Returns the x-component of the force acting on the entity's body.
//! \param entity Entity handle
//! \ingroup pxcommands
float xEntityForceX(size_t entity);

//! \brief Returns the y-component of the force acting on the entity's body.
//! \param entity Entity handle
//! \ingroup pxcommands
float xEntityForceY(size_t entity);

//! \brief Returns the z-component of the force acting on the entity's body.
//! \param entity Entity handle
//! \ingroup pxcommands
float xEntityForceZ(size_t entity);

//! \brief Returns the x-component of the torque acting on the entity's body.
//! \param entity Entity handle
//! \ingroup pxcommands
float xEntityTorqueX(size_t entity);

//! \brief Returns the y-component of the torque acting on the entity's body.
//! \param entity Entity handle
//! \ingroup pxcommands
float xEntityTorqueY(size_t entity);

//! \brief Returns the z-component of the torque acting on the entity's body.
//! \param entity Entity handle
//! \ingroup pxcommands
float xEntityTorqueZ(size_t entity);

//! \brief Frees the shape and the body of an entity.
//! \param entity Entity handle
//! \ingroup pxcommands
void xFreeEntityShapes(size_t entity);

//! \brief Returns the number of contacts of the entity's body.
//! \param entity Entity handle
//! \ingroup pxcommands
int xCountContacts(size_t entity);

//! \brief Returns the world x coordinate of a particular contact.
//! \param entity Entity handle
//! \param index Index of contact in range [0; xCountContacts(entity) - 1]
//! \ingroup pxcommands
float xEntityContactX(size_t entity, int index);

//! \brief Returns the world y coordinate of a particular contact.
//! \param entity Entity handle
//! \param index Index of contact in range [0; xCountContacts(entity) - 1]
//! \ingroup pxcommands
float xEntityContactY(size_t entity, int index);

//! \brief Returns the world z coordinate of a particular contact.
//! \param entity Entity handle
//! \param index Index of contact in range [0; xCountContacts(entity) - 1]
//! \ingroup pxcommands
float xEntityContactZ(size_t entity, int index);

//! \brief Returns the x component of the nornal of a particular contact.
//! \param entity Entity handle
//! \param index Index of contact in range [0; xCountContacts(entity) - 1]
//! \ingroup pxcommands
float xEntityContactNX(size_t entity, int index);

//! \brief Returns the y component of the nornal of a particular contact.
//! \param entity Entity handle
//! \param index Index of contact in range [0; xCountContacts(entity) - 1]
//! \ingroup pxcommands
float xEntityContactNY(size_t entity, int index);

//! \brief Returns the z component of the nornal of a particular contact.
//! \param entity Entity handle
//! \param index Index of contact in range [0; xCountContacts(entity) - 1]
//! \ingroup pxcommands
float xEntityContactNZ(size_t entity, int index);

float xEntityContactDistance(size_t entity, int index);

//! \brief Creates a joint between to bodies and returns its handle.
//! \param jointType The type of the joint. See '\ref jointtypes' for more
//! information about each type of joint
//! \param firstBody The handle of the first entity
//! \param secondBody The handle of the second entity
//! \ingroup pxcommands
size_t xCreateJoint(int jointType, size_t firstBody, size_t secondBody);

//! \brief Frees a joint.
//! \param joint Joint handle
//! \ingroup pxcommands
void xFreeJoint(size_t joint);

//! \brief Sets the coordinates of the pivot A of the 'point to point' joint.
//! \details Pivot A is a pivot of the first body connected to the second body by the given joint.
//! \param joint Joint handle
//! \param x Local x-coordinate
//! \param y Local y-coordinate
//! \param z Local z-coordinate
//! \ingroup pxcommands
void xJointPivotA(size_t joint, float x, float y, float z);

//! \brief Sets the coordinates of the pivot B of the 'point to point' joint.
//! \details Pivot B is a pivot of the second body connected to the first body by the given joint.
//! \param joint Joint handle
//! \param x Local x-coordinate
//! \param y Local y-coordinate
//! \param z Local z-coordinate
//! \ingroup pxcommands
void xJointPivotB(size_t joint, float x, float y, float z);

//! \brief Returns the local x-coodinate of the pivot A of the 'point to point' joint.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointPivotAX(size_t joint);

//! \brief Returns the local y-coodinate of the pivot A of the 'point to point' joint.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointPivotAY(size_t joint);

//! \brief Returns the local z-coodinate of the pivot A of the 'point to point' joint.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointPivotAZ(size_t joint);

//! \brief Returns the local x-coodinate of the pivot B of the 'point to point' joint.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointPivotBX(size_t joint);

//! \brief Returns the local y-coodinate of the pivot B of the 'point to point' joint.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointPivotBY(size_t joint);

//! \brief Returns the local z-coodinate of the pivot B of the 'point to point' joint.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointPivotBZ(size_t joint);

//! \brief Sets the linear limits of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \param lowerX The lower linear limit of the X axis
//! \param lowerY The lower linear limit of the Y axis
//! \param lowerZ The lower linear limit of the Z axis
//! \param upperX The upper linear limit of the X axis
//! \param upperY The upper linear limit of the Y axis
//! \param upperZ The upper linear limit of the Z axis
//! \ingroup pxcommands
void xJointLinearLimits(size_t joint, float lowerX, float lowerY, float lowerZ, float upperX, float upperY, float upperZ);

//! \brief Sets the angular limits of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \param lowerX The lower angular limit of the X axis
//! \param lowerY The lower angular limit of the Y axis
//! \param lowerZ The lower angular limit of the Z axis
//! \param upperX The upper angular limit of the X axis
//! \param upperY The upper angular limit of the Y axis
//! \param upperZ The upper angular limit of the Z axis
//! \ingroup pxcommands
void xJointAngularLimits(size_t joint, float lowerX, float lowerY, float lowerZ, float upperX, float upperY, float upperZ);

//! \brief Returns the lower linear limit of the X axis of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointLinearLowerX(size_t joint);

//! \brief Returns the lower linear limit of the Y axis of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointLinearLowerY(size_t joint);

//! \brief Returns the lower linear limit of the Z axis of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointLinearLowerZ(size_t joint);

//! \brief Returns the upper linear limit of the X axis of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointLinearUpperX(size_t joint);

//! \brief Returns the upper linear limit of the Y axis of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointLinearUpperY(size_t joint);

//! \brief Returns the upper linear limit of the Z axis of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointLinearUpperZ(size_t joint);

//! \brief Returns the lower angular limit of the X axis of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointAngularLowerX(size_t joint);

//! \brief Returns the lower angular limit of the Y axis of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointAngularLowerY(size_t joint);

//! \brief Returns the lower angular limit of the Z axis of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointAngularLowerZ(size_t joint);

//! \brief Returns the upper angular limit of the X axis of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointAngularUpperX(size_t joint);

//! \brief Returns the upper angular limit of the Y axis of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointAngularUpperY(size_t joint);

//! \brief Returns the upper angular limit of the Z axis of '6dof' and '6dofSpring' joints.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointAngularUpperZ(size_t joint);

//! \brief Enables or disables a spring on the specific DOF of '6dofSpring' joint.
//! \details If spring is enabled, the coefficients of damping and stiffness can be set.
//! \param joint Joint handle
//! \param index DOF index (see '\ref jointtypes')
//! \param enabled Enable or disable the spring
//! \param damping The coefficient of damping
//! \param stiffness The coefficient of stiffness
//! \ingroup pxcommands
void xJointSpringParam(size_t joint, int index, bool enabled, float damping, float stiffness);

//! \brief Sets the axis of the hinge joint.
//! \param joint Joint handle
//! \param x X
//! \param y Y
//! \param z Z
//! \ingroup pxcommands
void xJointHingeAxis(size_t joint, float x, float y, float z);

//! \brief Sets the limits and other parameters of the hinge joint.
//! \details Sets the lower and upper limits, the softness, the bias factor and the relaxation factor
//! of the hinge joint.
//! \param joint Joint handle
//! \param lowerLimit The lower limit
//! \param upperLimit The upper limit
//! \param softness The coefficient of softness
//! \param biasFactor The bias factor
//! \param relaxationFactor The relaxation factor
//! \ingroup pxcommands
void xJointHingeLimit(size_t joint, float lowerLimit, float upperLimit, float softness, float biasFactor, float relaxationFactor);

//! \brief Returns the lower limit of the hinge joint.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointHingeLowerLimit(size_t joint);

//! \brief Returns the upper limit of the hinge joint.
//! \param joint Joint handle
//! \ingroup pxcommands
float xJointHingeUpperLimit(size_t joint);

//! \brief Enables a motor of the specific dof of '6dof' or '6dofSpring' joints or the hinge joint.
//! \details The 'index' parameter is used only for '6dof' or '6dofSpring' joints. See '\ref jointtypes'.
//! \param joint Joint handle
//! \param dof DOF index (see '\ref jointtypes')
//! \param enabled Enable or disable the motor
//! \param targetVelocity The target angular velocity
//! \param maxForce The maximum force of the motor
//! \ingroup pxcommands
void xJointEnableMotor(size_t joint, int dof, bool enabled, float targetVelocity, float maxForce);

//! \brief Sets the motor target of the hinge joint.
//! \details xJointHingeMotorTarget sets target angular velocity ( (targetAngle - currentAngle) / deltaTime ) under the hood.
//! \param joint Joint handle
//! \param angle The target angle
//! \param delta The delta time
//! \ingroup pxcommands
void xJointHingeMotorTarget(size_t joint, float angle, float delta);

// single surface commands
//! \brief Creates a single surface mesh
//! \details Single surface mesh renders all associated with it entities as one
//! surface for the best performance on rendering similar objects
//! \ingroup meshcommands
size_t xCreateSingleSurface();
	
//! \brief Sets a texture flags for a single surface mesh
//! \details See '\ref tlflags' for more information
//! \ingroup meshcommands
void xSetSingleSurfaceFlags(size_t singleSurface, int flags);
	
//! \brief Adds new entity to the single surface mesh
//! \param singleSurface Single surface mesh handle
//! \param entity Instance handle
//! \ingroup meshcommands
void xAddSingleSurfaceInstance(size_t singleSurface, size_t entity);

//! \brief Removes entity from the single surface mesh
//! \param singleSurface Single surface mesh handle
//! \param entity Instance handle
//! \ingroup meshcommands
void xRemoveSingleSurfaceInstance(size_t singleSurface, size_t entity);
	
void xEnableAtlasesDebug(bool flag);

// 2D physics commands
//! \brief Creates a dummy shape 
//! \details A dummy shape has no mass and collision body.
//! \ingroup px2dcommands
size_t xCreateDummy2DShape();

//! \brief Creates a box shape
//! \details Setting mass to zero creates a fixed (non-dynamic) rigid body.
//! \param width Width of the shape
//! \param height Height of the shape
//! \param mass Mass of the body
//! \ingroup px2dcommands
size_t xCreateBox2DShape(float width, float height, float mass);

//! \brief Creates a circle shape
//! \details Setting mass to zero creates a fixed (non-dynamic) rigid body.
//! \param radii Circle radius
//! \param mass Mass of the body
//! \ingroup px2dcommands
size_t xCreateCircle2DShape(float radii, float mass);

//! \brief Creates a polygon shape
//! \details Getting a number of vertices and creates conves or concave shape from them.
//! iXors3d Engine support up to 32 vertices in polygion shape.
//! Setting mass to zero creates a fixed (non-dynamic) rigid body.
//! \param points Pinter to polyson vertices array
//! \param count Number of vertices in polygon
//! \param mass Mass of the body
//! \ingroup px2dcommands
size_t xCreatePolygon2DShape(float * points, int count, float mass);
	
//! \brief Sets a 2D shape mass
//! \param shape 2D shape handle
//! \param mass New shape's mass
//! \ingroup px2dcommands
void xSet2DShapeMass(size_t shape, float mass);	

//! \brief Returns a 2D shape mass
//! \param shape 2D shape handle
//! \ingroup px2dcommands
float xGet2DShapeMass(size_t shape);
	
//! \brief Sets a 2D shape position
//! \param shape 2D shape handle
//! \param x New x-coordinate of 2D shape
//! \param y New y-coordinate of 2D shape
//! \ingroup px2dcommands
void xPosition2DShape(size_t shape, float x, float y);

//! \brief Sets a 2D shape rotation angle
//! \param shape 2D shape handle
//! \param angle New rotatino angle of 2D shape in degrees
//! \ingroup px2dcommands
void xRotate2DShape(size_t shape, float angle);

//! \brief Returns a 2D shape position's x-coordinate
//! \param shape 2D shape handle
//! \ingroup px2dcommands
float x2DShapePositionX(size_t shape);

//! \brief Returns a 2D shape position's y-coordinate
//! \param shape 2D shape handle
//! \ingroup px2dcommands
float x2DShapePositionY(size_t shape);

//! \brief Returns a 2D shape rotation angle
//! \param shape 2D shape handle
//! \ingroup px2dcommands
float x2DShapeRotation(size_t shape);

//! \brief Sets a 2D physics world gravity vector (default value - [0.0, 10.0])
//! \param x New x-coordinate of 2D world's gravity
//! \param y New y-coordinate of 2D world's gravity
//! \ingroup px2dcommands
void x2DWorldGravity(float x, float y);

//! \brief Sets a 2D physics world simulation iterations
//! \param velocity Velocity simulation iterations. 6 used by default
//! \param position Position simulation iterations. 2 used by default
//! \ingroup px2dcommands
void x2DWorldIterations(int velocity, int position);
	
//! \brief Deletes a 2D shape from world
//! \param shape 2D shape handle
//! \ingroup px2dcommands
void xDelete2DShape(size_t shape);

//! \brief Enables or disables a 2D shape rotatation
//! \details This command useful for 2D characters realisation
//! \param shape 2D shape handle
//! \param flag If true - disables shape rotation, otherwise - enables
//! \ingroup px2dcommands
void xLock2DShapeRotation(size_t shape, bool flag);

//! \brief Returns if a 2D shape rotatation locked
//! \param shape 2D shape handle
//! \ingroup px2dcommands	
bool x2DShapeRotationLocked(size_t shape);

//! \brief Enables or disables a 2D shape bullet behavior
//! \details This command useful for a little shapes that moves with a
//! big speed. Its enables CCD for a shape and prevents its tunneling 
//! into the other shapes
//! \param shape 2D shape handle
//! \param flag If true - enables shape bullet behavior, otherwise - disables
//! \ingroup px2dcommands
void xSet2DShapeBullet(size_t shape, bool flag);

//! \brief Returns if a 2D shape bullet behavior enabled
//! \param shape 2D shape handle
//! \ingroup px2dcommands
bool xIs2DShapeBullet(size_t shape);

//! \brief Enables or disables a 2D shape sensor behavior
//! \details Sensors doesn't collide with other shapes, them only detects overlaps
//! this other shapes
//! \param shape 2D shape handle
//! \param flag If true - enables shape sensor behavior, otherwise - disables
//! \ingroup px2dcommands
void xSet2DShapeSensor(size_t shape, bool flag);

//! \brief Returns if a 2D shape sensor behavior enabled
//! \param shape 2D shape handle
//! \ingroup px2dcommands
bool xIs2DShapeSensor(size_t shape);

//! \brief Enables or disables a 2D shape
//! \details Inactive shapes doesn't collide with other shapes
//! \param shape 2D shape handle
//! \param flag If true - enables shape, otherwise - disables
//! \ingroup px2dcommands
void xSet2DShapeActive(size_t shape, bool flag);

//! \brief Returns if a 2D shape enabled
//! \param shape 2D shape handle
//! \ingroup px2dcommands
bool xIs2DShapeActive(size_t shape);

//! \brief Enables or disables a 2D shape sleeping
//! \param shape 2D shape handle
//! \param flag If true - enables shape sleeping, otherwise - disables
//! \ingroup px2dcommands	
void xAllow2DShapeSleeping(size_t shape, bool flag);

//! \brief Returns if a 2D shape's sleeping enabled
//! \param shape 2D shape handle
//! \ingroup px2dcommands
bool xIs2DShapeSleepingAllowed(size_t shape);
	
//! \brief Applies a force to the center of mass of the 2D shape
//! \param shape 2D shape handle
//! \param x X-component of the force vector
//! \param y Y-component of the force vector
//! \ingroup px2dcommands
void x2DShapeApplyCentralForce(size_t shape, float x, float y);

//! \brief Applies a impulse to the center of mass of the 2D shape
//! \param shape 2D shape handle
//! \param x X-component of the impulse vector
//! \param y Y-component of the impulse vector
//! \ingroup px2dcommands
void x2DShapeApplyCentralImpulse(size_t shape, float x, float y);

//! \brief Applies a torque to the 2D shape
//! \param shape 2D shape handle
//! \param omega A torque value
//! \ingroup px2dcommands
void x2DShapeApplyTorque(size_t shape, float omega);

//! \brief Applies a torque impulse to the 2D shape
//! \param shape 2D shape handle
//! \param omega A torque impulse value
//! \ingroup px2dcommands
void x2DShapeApplyTorqueImpulse(size_t shape, float omega);

//! \brief Applies a force to the 2D shape at the specific point relative to the center of this shape.
//! \param shape 2D shape handle
//! \param x X-component of the force vector
//! \param y Y-component of the force vector
//! \param pointx X-coordinate of the point
//! \param pointy Y-coordinate of the point
//! \ingroup px2dcommands
void x2DShapeApplyForce(size_t shape, float x, float y, float pointx, float pointy);

//! \brief Applies a impulse to the 2D shape at the specific point relative to the center of this shape.
//! \param shape 2D shape handle
//! \param x X-component of the impulse vector
//! \param y Y-component of the impulse vector
//! \param pointx X-coordinate of the point
//! \param pointy Y-coordinate of the point
//! \ingroup px2dcommands
void x2DShapeApplyImpulse(size_t shape, float x, float y, float pointx, float pointy);

//! \brief Releases all the forces which were applied to the 2D shape
//! \details Linear and angular velocities are set to zero values.
//! \param shape 2D shape handle
//! \ingroup px2dcommands
void x2DShapeReleaseForces(size_t shape);
	
//! \brief Sets the linear and angular damping of the 2D shape.
//! \details The values of linear and angular damping are clamped to [0.0; 1.0].
//! \param shape 2D shape handle
//! \param linear The coefficient of the linear damping
//! \param angular The coefficient of the angular damping
//! \ingroup px2dcommands
void x2DShapeDamping(size_t shape, float linear, float angular);

//! \brief Returns the coefficient of the linear damping of the 2D shape.
//! \param shape 2D shape handle
//! \ingroup px2dcommands
float xGet2DShapeLinearDamping(size_t shape);

//! \brief Returns the coefficient of the angular damping of the 2D shape.
//! \param shape 2D shape handle
//! \ingroup px2dcommands
float xGet2DShapeAngularDamping(size_t shape);

//! \brief Sets the friction of the 2D shape.
//! \param shape 2D shape handle
//! \param friction The coefficient of the friction
//! \ingroup px2dcommands
void x2DShapeFriction(size_t shape, float friction);

//! \brief Returns the friction of the 2D shape.
//! \param shape 2D shape handle
//! \ingroup px2dcommands
float xGet2DShapeFriction(size_t shape);

//! \brief Sets the density of the 2D shape.
//! \param shape 2D shape handle
//! \param density The coefficient of the density
//! \ingroup px2dcommands
void x2DShapeDensity(size_t shape, float density);

//! \brief Returns the density of the 2D shape.
//! \param shape 2D shape handle
//! \ingroup px2dcommands
float xGet2DShapeDensity(size_t shape);

//! \brief Sets the restitution of the 2D shape.
//! \param shape 2D shape handle
//! \param restitution The coefficient of the restitution
//! \ingroup px2dcommands
void x2DShapeRestitution(size_t shape, float restitution);

//! \brief Returns the restitution of the 2D shape.
//! \param shape 2D shape handle
//! \ingroup px2dcommands
float xGet2DShapeRestitution(size_t shape);
	
//! \brief Assings an image to the 2D shape for rendering
//! \details This command assings an image to the physical 2D shape
//! for rendering world by xRender2DWorld() command
//! \param shape 2D shape handle
//! \param x_image Image handle
//! \param frame Image frame
//! \ingroup maincommands
void x2DShapeAssignImage(size_t shape, size_t x_image, int frame);

//! \brief Sets an image frame for the assigned to the 2D shape image
//! \param shape 2D shape handle
//! \param frame Image frame
//! \ingroup maincommands
void x2DShapeImageFrame(size_t shape, int frame);

//! \brief Sets an image rendering order for the assigned to the 2D shape image
//! \details Images with a smaller order will render first
//! \param shape 2D shape handle
//! \param order Image rednering order
//! \ingroup maincommands
void x2DShapeImageOrder(size_t shape, int order);

//! \brief Returns number of the specified 2D sensor shape's touches by the other shapes.
//! \param shape 2D sensor shape handle
//! \ingroup px2dcommands
int xCount2DShapeTouches(size_t shape);

//! \brief Returns a shape handle that touching the specified 2D sensor shape.
//! \param shape 2D sensor shape handle
//! \param index Index of touch in range [0; xCount2DShapeTouches(shape) - 1]
//! \ingroup px2dcommands
size_t xGet2DShapeTouchingShape(size_t shape, int index);

//! \brief Returns number of the specified 2D shape's contacts with other shapes.
//! \param shape 2D shape handle
//! \ingroup px2dcommands
int xCount2DShapeCountacts(size_t shape);

//! \brief Returns the world x coordinate of a particular contact.
//! \param shape 2D shape handle
//! \param index Index of contact in range [0; xCount2DShapeCountacts(shape) - 1]
//! \ingroup px2dcommands
float x2DShapeContactX(size_t shape, int index);

//! \brief Returns the world y coordinate of a particular contact.
//! \param shape 2D shape handle
//! \param index Index of contact in range [0; xCount2DShapeCountacts(shape) - 1]
//! \ingroup px2dcommands
float x2DShapeContactY(size_t shape, int index);

//! \brief Returns the x component of the nornal of a particular contact.
//! \param shape 2D shape handle
//! \param index Index of contact in range [0; xCount2DShapeCountacts(shape) - 1]
//! \ingroup px2dcommands
float x2DShapeContactNX(size_t shape, int index);

//! \brief Returns the y component of the nornal of a particular contact.
//! \param shape 2D shape handle
//! \param index Index of contact in range [0; xCount2DShapeCountacts(shape) - 1]
//! \ingroup px2dcommands
float x2DShapeContactNY(size_t shape, int index);

//! \brief Returns the second collided shape of a particular contact.
//! \param shape 2D shape handle
//! \param index Index of contact in range [0; xCount2DShapeCountacts(shape) - 1]
//! \ingroup px2dcommands
size_t x2DShapeContactSecondShape(size_t shape, int index);
	
//! \brief Deletes a 2D joint from the world.
//! \param joint 2D joint handle
//! \ingroup px2dcommands
void xFree2DJoint(size_t joint);
	
//! \brief Creates a distance joint between two bodies and returns its handle.
//! \details A distance joint just says that the distance between two points
//! on two shapes must be constant. The distance joint can also be made soft, 
//! like a spring-damper connection. Softness is achieved by tuning two constants
//! in the definition: frequency and damping ratio.
//! \param bodyA The handle of the first shape
//! \param bodyB The handle of the second shape
//! \param collide True if bodies in joint must collide
//! \ingroup px2dcommands
size_t xCreateDistance2DJoint(size_t bodyA, int bodyB, bool collide);
	
//! \brief Creates a distance joint between two bodies and returns its handle.
//! \details A distance joint just says that the distance between two points
//! on two shapes must be constant. The distance joint can also be made soft, 
//! like a spring-damper connection. Softness is achieved by tuning two constants
//! in the definition: frequency and damping ratio.
//! \param bodyA The handle of the first shape
//! \param bodyB The handle of the second shape
//! \param pivotAX The x component of the first shape pivot relative to its center
//! \param pivotAY The y component of the first shape pivot relative to its center
//! \param pivotBX The x component of the second shape pivot relative to its center
//! \param pivotBY The y component of the second shape pivot relative to its center
//! \param collide True if bodies in joint must collide
//! \ingroup px2dcommands
size_t xCreateDistance2DJointWithPivots(size_t bodyA, size_t bodyB, float pivotAX, float pivotAY, float pivotBX, float pivotBY, bool collide);

//! \brief Returns a x compontnt of the 2D joint's pivot for the first shape in the world coordinates
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float x2DJointPivotAX(size_t joint);

//! \brief Returns a y compontnt of the 2D joint's pivot for the first shape in the world coordinates
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float x2DJointPivotAY(size_t joint);

//! \brief Returns a x compontnt of the 2D joint's pivot for the second shape in the world coordinates
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float x2DJointPivotBX(size_t joint);

//! \brief Returns a y compontnt of the 2D joint's pivot for the second shape in the world coordinates
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float x2DJointPivotBY(size_t joint);

//! \brief Sets the distance between shapes in the distance joint
//! \param joint 2D joint handle
//! \param distance New distance value
//! \ingroup px2dcommands
void xSet2DJointDistance(size_t joint, float distance);

//! \brief Sets the frequency of the distance joint
//! \details Think of the frequency as the frequency of a harmonic oscillator
//! (like a guitar string). The frequency is specified in Hertz.
//! \param joint 2D joint handle
//! \param frequency New frequency value
//! \ingroup px2dcommands
void xSet2DJointFrequency(size_t joint, float frequency);

//! \brief Sets the damping ratio of the distance joint
//! \details The damping ratio is non-dimensional and is typically between 0 
//! and 1, but can be larger. At 1, the damping is critical (all oscillations should vanish).
//! \param joint 2D joint handle
//! \param ratio New damping ratio value
//! \ingroup px2dcommands
void xSet2DJointDampingRatio(size_t joint, float ratio);
	
//! \brief Returns the distance between shapes in the distance joint
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointDistance(size_t joint);

//! \brief Returns the frequency in the distance joint
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointFrequency(size_t joint);

//! \brief Returns the damping ratio in the distance joint
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointDampingRatio(size_t joint);
	
//! \brief Creates a revolute joint between two bodies and returns its handle.
//! \details A revolute joint forces two shapes to share a common anchor point, 
//! often called a hinge axis. The revolute joint has a single degree of 
//! freedom: the relative rotation of the two bodies.
//! \param bodyA The handle of the first shape
//! \param bodyB The handle of the second shape
//! \param collide True if bodies in joint must collide
//! \ingroup px2dcommands
size_t xCreateRevolute2DJoint(size_t bodyA, size_t bodyB, bool collide);

//! \brief Creates a revolute joint between two bodies and returns its handle.
//! \details A revolute joint forces two shapes to share a common anchor point, 
//! often called a hinge axis. The revolute joint has a single degree of 
//! freedom: the relative rotation of the two bodies.
//! \param bodyA The handle of the first shape
//! \param bodyB The handle of the second shape
//! \param axisX The x component of the hinge axis relative to the first shape's center
//! \param axisY The y component of the hinge axis relative to the first shape's center
//! \param collide True if bodies in joint must collide
//! \ingroup px2dcommands
size_t xCreateRevolute2DJointWithAxis(size_t bodyA, size_t bodyB, float axisX, float axisY, bool collide);

//! \brief Sets a revolute joint rotation limits
//! \param joint 2D joint handle
//! \param enabled If true - enables limits, disables otherwise
//! \param lower Lower rotation limit in degrees
//! \param upper Upper rotation limit in degrees
//! \ingroup px2dcommands
void xSet2DJointHingeLimit(size_t joint, bool enabled, float lower, float upper);

//! \brief Returns a revolute joint's rotation lower limit
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointLowerHingeLimit(size_t joint);

//! \brief Returns a revolute joint's rotation upper limit
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointUpperHingeLimit(size_t joint);

//! \brief Returns if a revolute joint's rotation limits enabled
//! \param joint 2D joint handle
//! \ingroup px2dcommands
bool xGet2DJointHingeLimitEnabled(size_t joint);
	
//! \brief Sets a revolute joint rotation motor
//! \param joint 2D joint handle
//! \param enabled If true - enables rotation motor, disables otherwise
//! \param speed Motor speed in degrees per second
//! \param maxTorque Max motor torque
//! \ingroup px2dcommands
void xSet2DJointHingeMotor(size_t joint, bool enabled, float speed, float maxTorque);

//! \brief Returns a revolute joint's rotation motor's speed
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointHingeMotorSpeed(size_t joint);

//! \brief Returns a revolute joint's rotation motor's torque
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointHingeMotorTorque(size_t joint);

//! \brief Returns if a revolute joint's rotation motor enabled
//! \param joint 2D joint handle
//! \ingroup px2dcommands
bool xGet2DJointHingeMotorEnabled(size_t joint);
	
//! \brief Creates a prismatic joint between two bodies and returns its handle.
//! \details A prismatic joint allows for relative translation of two shapes
//! along a specified axis. A prismatic joint prevents relative rotation. 
//! Therefore, a prismatic joint has a single degree of freedom.
//! \param bodyA The handle of the first shape
//! \param bodyB The handle of the second shape
//! \param axisX The x component of the joint's translational axis
//! \param axisY The y component of the joint's translational axis
//! \param collide True if bodies in joint must collide
//! \ingroup px2dcommands
size_t xCreatePrismatic2DJoint(size_t bodyA, size_t bodyB, float axisX, float axisY, bool collide);

//! \brief Creates a prismatic joint between two bodies and returns its handle.
//! \details A prismatic joint allows for relative translation of two shapes
//! along a specified axis. A prismatic joint prevents relative rotation. 
//! Therefore, a prismatic joint has a single degree of freedom.
//! \param bodyA The handle of the first shape
//! \param bodyB The handle of the second shape
//! \param pivotX The x component of the first shape pivot relative to its center
//! \param pivotY The y component of the first shape pivot relative to its center
//! \param axisX The x component of the joint's translational axis
//! \param axisY The y component of the joint's translational axis
//! \param collide True if bodies in joint must collide
//! \ingroup px2dcommands
size_t xCreatePrismatic2DJointWithPivot(size_t bodyA, size_t bodyB, float pivotX, float pivotY, float axisX, float axisY, bool collide);

//! \brief Sets a prismatic joint linear limits
//! \param joint 2D joint handle
//! \param enabled If true - enables limits, disables otherwise
//! \param lower Lower linear limit in meters relative to the first shape's pivot
//! \param upper Upper linear limit in meters relative to the first shape's pivot
//! \ingroup px2dcommands
void xSet2DJointLinearLimit(size_t joint, bool enabled, float lower, float upper);

//! \brief Returns a prismatic joint's linear lower limit
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointLowerLinearLimit(size_t joint);

//! \brief Returns a prismatic joint's linear upper limit
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointUpperLinearLimit(size_t joint);

//! \brief Returns if a prismatic joint's linear limits enabled
//! \param joint 2D joint handle
//! \ingroup px2dcommands
bool xGet2DJointLinearLimitEnabled(size_t joint);

//! \brief Sets a prismatic joint's linear motor
//! \param joint 2D joint handle
//! \param enabled If true - enables linear motor, disables otherwise
//! \param speed Motor's speed in meters per second
//! \param maxForce Max motor's force
//! \ingroup px2dcommands
void xSet2DJointLinearMotor(size_t joint, bool enabled, float speed, float maxForce);

//! \brief Returns a prismatic joint's linear motor's speed
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointLinearMotorSpeed(size_t joint);

//! \brief Returns a prismatic joint's linear motor's force
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointLinearMotorForce(size_t joint);

//! \brief Returns if a prismatic joint's linear motor enabled
//! \param joint 2D joint handle
//! \ingroup px2dcommands
bool xGet2DJointLinearMotorEnabled(size_t joint);
	
//! \brief Creates a pulley joint between two bodies and returns its handle.
//! \details The pulley connects two bodies to ground and to each other. As
//! one body goes up, the other goes down. The total length of the pulley 
//! rope is conserved according to the initial configuration.
//! \param bodyA The handle of the first shape
//! \param bodyB The handle of the second shape
//! \param anchorAX The x component of the first shape's pulley anchor in the world coordinates
//! \param anchorAY The y component of the first shape's pulley anchor in the world coordinates
//! \param anchorBX The x component of the second shape's pulley anchor in the world coordinates
//! \param anchorBY The y component of the second shape's pulley anchor in the world coordinates
//! \param collide True if bodies in joint must collide
//! \ingroup px2dcommands
size_t xCreatePulley2DJoint(size_t bodyA, size_t bodyB, float anchorAX, float anchorAY, float anchorBX, float anchorBY, bool collide);

//! \brief Creates a pulley joint between two bodies and returns its handle.
//! \details The pulley connects two bodies to ground and to each other. As
//! one body goes up, the other goes down. The total length of the pulley 
//! rope is conserved according to the initial configuration.
//! \param bodyA The handle of the first shape
//! \param bodyB The handle of the second shape
//! \param anchorAX The x component of the first shape's pulley anchor in the world coordinates
//! \param anchorAY The y component of the first shape's pulley anchor in the world coordinates
//! \param anchorBX The x component of the second shape's pulley anchor in the world coordinates
//! \param anchorBY The y component of the second shape's pulley anchor in the world coordinates
//! \param pivotAX The x component of the first shape pivot relative to its center
//! \param pivotAY The y component of the first shape pivot relative to its center
//! \param pivotBX The x component of the second shape pivot relative to its center
//! \param pivotBY The y component of the second shape pivot relative to its center
//! \param collide True if bodies in joint must collide
//! \ingroup px2dcommands
size_t xCreatePulley2DJointWithPivots(size_t bodyA, size_t bodyB, float anchorAX, float anchorAY, float anchorBX, float anchorBY, float pivotAX, float pivotAY, float pivotBX, float pivotBY, bool collide);

//! \brief Returns a first shape's rope length in the pulley joint
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointPulleyLengthA(size_t joint);

//! \brief Returns a second shape's rope length in the pulley joint
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointPulleyLengthB(size_t joint);
	
//! \brief Creates a gear joint between two revolute or prismatic joints and returns its handle.
//! \details The gear joint requires that you have two shapes connected to ground by a revolute 
//! or prismatic joint. You can use any combination of those joint types. 
//! \param jointA The handle of the first revolute or prismatic joint
//! \param jointB The handle of the second revolute or prismatic joint
//! \ingroup px2dcommands
size_t xCreateGear2DJoint(size_t jointA, size_t jointB);

//! \brief Sets a gear joint's ratio
//! \details You can specify a gear ratio, its can be negative. Also keep in
//! mind that when one joint is a revolute joint (angular) and the other joint 
//! is prismatic (translation), and then the gear ratio will have units of 
//! length or one over length.
//! \param joint 2D joint handle
//! \param ratio New ratio value
//! \ingroup px2dcommands
void xSet2DJointGearRatio(size_t joint, float ratio);

//! \brief Returns a gear joint's ratio
//! \param joint 2D joint handle
//! \ingroup px2dcommands
float xGet2DJointGearRatio(size_t joint);
	
//! \brief Updates all 2D shapes positions and rotations
//! \param speed A master control for speed.
//! \ingroup maincommands
void xUpdate2DWorld(float speed);

//! \brief Renders all 2D shapes with attached images
//! \ingroup maincommands
void xRender2DWorld();
	
//! \brief Sets position for virtual camera for 2D world
//! \param x x-coordinate of camera's position
//! \param y y-coordinate of camera's position
//! \ingroup maincommands
void xPosition2DCamera(int x, int y);

//! \brief Returns the x-coordinate of camera's position
//! \ingroup maincommand
int x2DCameraX();

//! \brief Returns the y-coordinate of camera's position
//! \ingroup maincommand
int x2DCameraY();

//! \brief Deattachs all images from 2D shapes and deletes all shapes
//! \ingroup maincommands
void xClear2DWorld();
	
//! \brief Returns current time in millisecs
//! \ingroup maincommands
unsigned int xMillisecs();
	
//! \brief Creates new empty images atlas and returns its handle
//! \details You may use images atlas to merge different images into one
//! to reduce memory usage and draw calls (then you sequentially draw 
//! images stored in atlas - their draw within one draw call).
//!
//! Then you creates new atlas it doesn't contain any images, you may add
//! them using xAtlasAddImage() or xAtlasAddNamedImage() commands.
//!
//! NOTE: After calling xBuildAtlas() or first usage for drawing atlas
//! can't be changed.
//! \ingroup imgatlascommands
size_t xCreateAtlas();
	
//! \brief Loads new images atlas from file and returns its handle
//! \details You may use images atlas to merge different images into one
//! to reduce memory usage and draw calls (then you sequentially draw 
//! images stored in atlas - their draw within one draw call).
//!
//! NOTE: You can't change loaded atlas.
//! \param path Atlas file path
//! \ingroup imgatlascommands
size_t xLoadAtlas(const char * path);
	
//! \brief Deletes loaded or created atlas
//! \details This command also deletes all images associated with atlas
//! \param atlas Images atlas handle
//! \ingroup imgatlascommands
void xFreeAtlas(size_t atlas);
	
//! \brief Adds a new image into the images atlas
//! \details NOTE: You can't add image with deleted piels into the atlas
//! \param atlas Image atlas handle
//! \param x_image Image handle
//! \ingroup imgatlascommands
bool xAtlasAddImage(size_t atlas, size_t x_image);
	
//! \brief Adds a new image into the images atlas and sets its name in the atlas
//! \details NOTE: You can't add image with deleted piels into the atlas
//! \param atlas Image atlas handle
//! \param x_image Image handle
//! \param name Image name in the atlas
//! \ingroup imgatlascommands
bool xAtlasAddNamedImage(size_t atlas, size_t x_image, const char * name);
	
//! \brief Returns images count in the images atlas
//! \param atlas Image atlas handle
//! \ingroup imgatlascommands
int xCountAtlasImages(size_t atlas);
	
//! \brief Returns image for specified index in the images atlas
//! \param atlas Image atlas handle
//! \param index Image index in the atlas
//! \ingroup imgatlascommands
size_t xGetAtlasImage(size_t atlas, int index);
	
//! \brief Returns image for specified name in the images atlas
//! \param atlas Image atlas handle
//! \param name Image name in the atlas
//! \ingroup imgatlascommands
size_t xFindAtlasImage(size_t atlas, const char * name);
	
//! \brief Rebuilds the atlas image
//! \details After calling of this command you can't anymore change the atlas
//! \param atlas Image atlas handle
//! \ingroup imgatlascommands
void xBuildAtlas(size_t atlas);
	
//! \brief Returns total RAM size
//! \ingroup sysinfocommands
float xGetTotalPhysMem();

//! \brief Returns free RAM size
//! \ingroup sysinfocommands
float xGetAvailPhysMem();

//! \brief Returns used RAM size
//! \ingroup sysinfocommands
float xGetUsedPhysMem();

//! \brief Returns inactive RAM size
//! \ingroup sysinfocommands
float xGetInactivePhysMem();

//! \brief Returns user's CPU usage time
//! \ingroup sysinfocommands
float xGetCPUUserTime();

//! \brief Returns system's CPU usage time
//! \ingroup sysinfocommands
float xGetCPUSysTime();

//! \brief Returns idle CPU time
//! \ingroup sysinfocommands
float xGetCPUIdleTime();
	
//! \brief Enables or disables auto deleting of pixels buffer for images and texturs
//! \param flag Auto deleting flag
//! \ingroup maincommands
void xAutoDeletePixels(bool flag);

//! \brief Deletes pixels buffer for texture
//! \details By deleting pixels buffer you will reduce memory usage,
//! but you can't read/write pixels values.
//! \param texture Texture handle
//! \ingroup texcommands
void xDeleteTexturePixels(size_t texture);

//! \brief Deletes pixels buffer for image
//! \details By deleting pixels buffer you will reduce memory usage,
//! but you can't use pixel-perfect collisions or clone this images,
//! you can't add it into images atlas, or read/write pixels values.
//! \param x_image Image handle
//! \ingroup imagecommands
void xDeleteImagePixels(size_t x_image);
	
//! \brief Projects the world coordinates on to the 2D screen
//! \param camera Camera handle
//! \param x World coordinate x
//! \param y World coordinate y
//! \param z World coordinate z
//! \ingroup camcommands
int xCameraProject(size_t camera, float x, float y, float z);

//! \brief Returns the viewport x coordinate of the most recently executed 
//! xCameraProject()
//! \ingroup camcommands
float xProjectedX();

//! \brief Returns the viewport y coordinate of the most recently executed 
//! xCameraProject()
//! \ingroup camcommands
float xProjectedY();

//! \brief Returns the viewport z coordinate of the most recently executed 
//! xCameraProject()
//! \ingroup camcommands
float xProjectedZ();
	
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR

bool xIsGCSupported();
bool xGCAuthenticate();
bool xIsGCPlayerLogedIn();
const char * xGetGCPlayerName();
const char * xGetGCPlayerID();
int xGetGCFriendsCount();
const char * xGetGCFriendName(int index);
const char * xGetGCFriendID(int index);

#endif
	
#ifdef __cplusplus
}
#endif