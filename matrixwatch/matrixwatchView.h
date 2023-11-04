//
//  matrixwatchView.h
//  matrixwatch
//
//  Created by u1 on 24.10.2023.
//

#import <Foundation/Foundation.h>

#import <AppKit/AppKit.h>

#import <ScreenSaver/ScreenSaver.h>

#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <GLKit/glkit.h>
#import <Cocoa/Cocoa.h>

#import "defvar.h"

@interface matrixwatchView : ScreenSaverView
{
    NSOpenGLView *glView;
    
    GLuint texture;
    
    int   *textID;
    float rectCoord;
    float rectText;
    
    int width;
    int height;
    
    struct fSym *FlashSym;
    TimeDig ddig[255];
    
    bool flagTimeInit;
    int tcount;
    int cursec;
    
    int     vsnum;
    float   scale;
    bool    zoomflag;
    
    float koef;
    int   cx;
    
    float grey;
    
    float space;
    float step;
    int   cy;
    
    int   rezoom;
    bool  hidewatch;
    NSString    *codemap;
    
    IBOutlet id configureSheet;

    IBOutlet id IBDefaults;
    IBOutlet id IBCancel;
    IBOutlet id IBSave;

    IBOutlet id IBrezoom;
    IBOutlet id IBhidewatch;
    
    IBOutlet id IBcodemap;
    
}

- (void)setUpOpenGL;
- (void)setFrameSize:(NSSize)newSize;

- (void)loadTexture:(NSString *)name;
- (void)genTexture;

- (IBAction)configureSheet_save:(id)sender;
- (IBAction)configureSheet_cancel:(id)sender;
- (IBAction)configureSheet_defaults:(id)sender;

@end
