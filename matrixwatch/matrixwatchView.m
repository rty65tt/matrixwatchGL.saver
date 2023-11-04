//
//  matrixwatchView.m
//  matrixwatch
//
//  Created by u1 on 24.10.2023.
//

//#include <stdlib.h>
#import "matrixwatchView.h"

#define sName        @"matrixwatch"

@implementation matrixwatchView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        
        vsnum = VSNUMBER;

        
        grey = 0.05;
        scale = SCALE;
        zoomflag = TRUE;
        flagTimeInit = TRUE;
        cursec = 0;
        
        ScreenSaverDefaults *defaults =
            [ScreenSaverDefaults defaultsForModuleWithName: sName];
        [defaults synchronize];

        rezoom     = (int)[defaults integerForKey:@"rezoom"];
        rezoom     = (rezoom) ? rezoom : 3;
        
        hidewatch  = [defaults boolForKey:@"hidewatch"];
        hidewatch  = (hidewatch) ? hidewatch : FALSE;
        
        if (self.isPreview) {
            vsnum = VSNUMBER / 7;
            hidewatch = TRUE; // No work!!!
        }
        
        NSOpenGLPixelFormatAttribute attributes[] = {
            NSOpenGLPFAAccelerated,
            NSOpenGLPFAColorSize, 24,
            NSOpenGLPFAAlphaSize, 8,
            NSOpenGLPFABackingStore,
            NSOpenGLPFADoubleBuffer,
            0 };
        
        NSOpenGLPixelFormat *format =
            [[NSOpenGLPixelFormat alloc] initWithAttributes: attributes];
                
        glView = [[NSOpenGLView alloc] initWithFrame: NSZeroRect
                                         pixelFormat: format];

        [self addSubview:glView];
        [self setUpOpenGL];
        
        [self setAnimationTimeInterval:1/10.0];

    }
    return self;
}

- (void)setUpOpenGL
{

    [[glView openGLContext] makeCurrentContext];
    
    glClearColor( 0.f, 0.f, 0.f, 1.0f );
    [self loadTexture:TEXTURE];
//    [self genTexture];

//    glDepthFunc( GL_LEQUAL );
//    glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );

}

- (void)setFrameSize:(NSSize)newSize
{
    [super setFrameSize:newSize];
    [glView setFrameSize:newSize];
    
    width = (GLsizei)newSize.width;
    height = (GLsizei)newSize.height;
    
    koef = width > height ? (float)width / height: (float)height / width;

}

- (void)drawingSquareFill:(float)ix iy:(float)iy mx:(int)mx my:(int)my {
    
    glEnable(GL_TEXTURE_2D);
//    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
//    glColor3f(1, 1, 1);
    
    glPushMatrix();
    
    glTranslatef((float)ix, (float)iy, 0);
    glScalef(step, step, 1);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glVertexPointer(2, GL_FLOAT, 0, rectCrd);
    glTexCoordPointer(2, GL_FLOAT, 0, rectTxt);
    
    static float charSize = 1/16.0;
    int x = mx;
    int y = my;
    struct { float left,right,top,bottom;} rct;
    rct.left    = x * charSize;
    rct.right   = rct.left + charSize;
    rct.top     = y * charSize;
    rct.bottom  = rct.top + charSize;
    rectTxt[0] = rectTxt[6] = rct.left;
    rectTxt[2] = rectTxt[4] = rct.right;
    rectTxt[1] = rectTxt[3] = rct.bottom;
    rectTxt[5] = rectTxt[7] = rct.top;
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glPopMatrix();
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisable(GL_TEXTURE_2D);
}

- (void)draw_symbol:(int)m x:(int)x y:(int)y cel:(int)cel row:(int)row p_matrix:(char *)p_matrix {
    int bm_x = 0;
    int bm_y = 0;
    int counter;
    char *p_2char = &p_matrix[cel * row * m];
    char *p_bm = p_2char;

    glColor3ubv(colors);

    while (1)
    {
        counter = 0;
        do
        {
            if (p_bm[counter] != 48)
            {
                if(flagTimeInit) {
                    ddig[tcount].mx = rand()%15;
                    ddig[tcount].my = rand()%15;
                }
                float nx = (x + bm_x) * space;
                float ny = (y + bm_y) * -space;
                
                if(ddig[tcount].sym_x != nx || ddig[tcount].sym_y != ny) {
                    glColor3ub(10, 10, 10);
                    [self drawingSquareFill:(ddig[tcount].sym_x)
                                         iy:(ddig[tcount].sym_y)
                                         mx:(ddig[tcount].mx)
                                         my:(ddig[tcount].my)];
                    
                    
                    ddig[tcount].sym_x = nx;
                    ddig[tcount].sym_y = ny;
                    glColor3ub(100, 150, 60);
                    [self drawingSquareFill:(ddig[tcount].sym_x)
                                         iy:(ddig[tcount].sym_y)
                                         mx:(ddig[tcount].mx)
                                         my:(ddig[tcount].my)];
                }
                tcount++;
            }
            bm_x += 1;
            ++counter;
        } while (counter < cel);
        if (!--row)
            break;
        bm_y += 1;
        p_bm += cel;
        bm_x = 0;
        counter = 0;
    }
//    glColor3ubv(colors);
}

- (void)fillBack {
    for (int iy=-cy; iy <= cy; iy++)
    {
        for (int ix=-cx; ix <= cx; ix++)
        {
            GLubyte grey = rand()%25;
            glColor3ub(grey, grey, grey);
            
            [self drawingSquareFill:(ix * space) iy:(iy * space) mx:(rand()%15) my:(rand()%15)];
        }
    }
    
}

- (void)startAnimation
{
    [super startAnimation];
    [[glView openGLContext] makeCurrentContext];
    
    space = 2.0f / vsnum;
    step = space * 0.5f;
    cy = 1.0f / space;
    
    cx = cy * koef;

    free(FlashSym);
    FlashSym = (struct fSym*) malloc( sizeof(struct fSym[cx*2]) );
    
    glColor3ub(1, 1, 1);
    glLoadIdentity();
    glOrtho(-XYSCALE*scale, XYSCALE*scale, -XYSCALE*scale, XYSCALE*scale, -1, 1);
    
    glScalef( 1 / koef, 1, 1);
        
    glClearColor( 0.0f, 0.0f, 0.0f, 1.0f );
    glColor3f(1, 1, 1);
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    

    [self fillBack];
    
    for (int i = 0; i < cx*2; i++) {
        FlashSym[i].x = 0;
        FlashSym[i].y = vsnum / 2;
        FlashSym[i].mx = rand()%15;
        FlashSym[i].my = rand()%15;
        FlashSym[i].flash = (rand()%10) ? FALSE: TRUE;
    }
    
    [[glView openGLContext] flushBuffer];
//    [self setNeedsDisplay:YES];
    
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    [[glView openGLContext] makeCurrentContext];
    
    // Draw background
    float ix, iy;
    for (int i=0; i < CELLC; i++)
    {
        GLubyte rc = rand()%25;
        glColor3ub(rc, rc, rc);

        int lcx = -cx;
        ix = (int)(((float)arc4random()/0x100000000)*(cx-lcx)+lcx);
        int lcy = -cy;
        iy = (int)(((float)arc4random()/0x100000000)*(cy-lcy)+lcy);

        [self drawingSquareFill:(ix * space) iy:(iy * space) mx:(rand()%15) my:(rand()%15)];

    }

    CurTime st;
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    st.hour   = (int)[calendar component:NSCalendarUnitHour      fromDate:now];
    st.minute = (int)[calendar component:NSCalendarUnitMinute    fromDate:now];
    st.second = (int)[calendar component:NSCalendarUnitSecond    fromDate:now];
    st.wday   = (int)[calendar component:NSCalendarUnitWeekday   fromDate:now];
    st.mday   = (int)[calendar component:NSCalendarUnitDay       fromDate:now];

    st.wday = (st.wday == 1) ? 7 : st.wday-1;

    if(st.second != cursec && !hidewatch) {
        cursec = st.second;

        // foreground font
        colors = def_hh_colors;

        tcount = 0;

        [self draw_symbol:st.hour / 10     x:-19   y:-8 cel:5  row:9 p_matrix:digit_matrix];
        [self draw_symbol:st.hour % 10     x:-13   y:-8 cel:5  row:9 p_matrix:digit_matrix];
        [self draw_symbol:st.minute / 10   x:-5    y:-8 cel:5  row:9 p_matrix:digit_matrix];
        [self draw_symbol:st.minute % 10   x:1     y:-8 cel:5  row:9 p_matrix:digit_matrix];
        
        int cd = 0;
        int wwx = 5;
        int wlx = -17;
        int wdx = wlx - 2;
        // Draw Week Line
        for(int i=0; i < 7; i++) {
            colors = def_wd_colors;
            if (i > 4 ) {colors = def_ew_colors;}
    #ifdef PREVIEW
//            NSLog(@"Week Day %i", st.wday);
    #endif /* PREVIEW */
            [self draw_symbol:0         x:wlx+(i*wwx)   y:2 cel:wwx  row:1 p_matrix:"01110"];
            if (st.wday == i+1 ) { // Select Curent Day
                cd = i;
                [self draw_symbol:0     x:wlx+(i*wwx)   y:3 cel:wwx  row:1 p_matrix:"01110"];
            }
        }
        
        // Draw Month Day
        colors = def_cd_colors;
        [self draw_symbol:st.mday / 10  x:wdx+(cd*wwx)    y:5 cel:4  row:7 p_matrix:m_deys_matrix];
        [self draw_symbol:st.mday % 10  x:wdx+(cd*wwx)+5  y:5 cel:4  row:7 p_matrix:m_deys_matrix];
        
        
        
        [self draw_symbol:st.second / 10   x:9     y:-8 cel:5  row:9 p_matrix:digit_matrix];
        [self draw_symbol:st.second % 10   x:15    y:-8 cel:5  row:9 p_matrix:digit_matrix];

        // Blink Dots
        int dc = st.second % 2;
        [self draw_symbol:dc x:-7  y:-8 cel:1 row:9 p_matrix:dots_matrix]; //::
        [self draw_symbol:dc x:7   y:-8 cel:1 row:9 p_matrix:dots_matrix]; //::
        
        while(tcount++) {
            if(ddig[tcount].sym_x == 0) {
                break;
            }
            glColor3ub(10, 10, 10);
            [self drawingSquareFill:(ddig[tcount].sym_x)
                                 iy:(ddig[tcount].sym_y)
                                 mx:(ddig[tcount].mx)
                                 my:(ddig[tcount].my)];
            ddig[tcount].sym_x = 0;
        }
        
        
#ifdef PREVIEW
        NSLog(@"tcount: %i", tcount);
#endif /* PREVIEW */

    }
    flagTimeInit = FALSE;

    if(!hidewatch){
        for(int i = 0; i < 20; i++) {
            ddig[tcount].mx = rand()%15;
            ddig[tcount].my = rand()%15;
            int rt = rand()%tcount;
            int vc = rand()%15;
            (rt % 4) ? glColor3ub(140+vc, 140+vc, 100) : glColor3ub(150+vc, 100+vc, 50+vc);
            
            [self drawingSquareFill:(ddig[rt].sym_x)
                                 iy:(ddig[rt].sym_y)
                                 mx:(ddig[tcount].mx)
                                 my:(ddig[tcount].my)];
            
        }
    }

    
    [[glView openGLContext] flushBuffer];
//    [self setNeedsDisplay:YES];
    
#ifdef PREVIEW
    if (st.second % 20 == 0 ) {
#else
//        if (st.second % 2 == 0 ) {
    if (st.minute % rezoom == 0 && st.second == 59) {
#endif /* PREVIEW */

        [NSThread sleepForTimeInterval:0.1];
        if (vsnum > VSNUMBER)   {zoomflag = TRUE;}
        if (vsnum < 41)         {zoomflag = FALSE;}
        vsnum = (zoomflag) ? vsnum-1 : vsnum+1;
        [self startAnimation];

    }

        // Rain
    for(int i = 0; i < cx*2; i++){
        FlashSym[i].x = 0;

        int r = rand()%30;

        if(rand()%2 == 1){

            if(FlashSym[i].flash) {
                glColor3ub(r, r, r);
            } else {glColor3ub(30+r, 30+r, 15+r);}

            [self drawingSquareFill:((i-cx) * space) iy:(FlashSym[i].y * space) mx:(rand()%15) my:(rand()%15)];
            FlashSym[i].y = FlashSym[i].y-1;

        }
        if( FlashSym[i].flash ) {
            glColor3ub(r, r, r);
        } else {
            int fc = 90+r;
            glColor3ub(fc, fc, r);

        }
        [self drawingSquareFill:((i-cx) * space) iy:(FlashSym[i].y * space) mx:(rand()%15) my:(rand()%15)];
        if(FlashSym[i].y < -vsnum / 2 ) {
            FlashSym[i].flash = (FlashSym[i].flash) ? FALSE : TRUE;
            FlashSym[i].y = vsnum / 2;
        }

    }

    return;
}

//- (void)dealloc
//{
//    [glView removeFromSuperview];
//    [glView release];
//    [super dealloc];
//}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    if( ! configureSheet ) {
        [thisBundle loadNibNamed: @"ConfigureSheet"
                           owner: self
                 topLevelObjects: nil];
    }
    
    [IBrezoom setIntValue:rezoom];
   
    return configureSheet;
    
}
    
- (IBAction) configureSheet_save:(id) sender {

    ScreenSaverDefaults *defaults =
        [ScreenSaverDefaults defaultsForModuleWithName:sName];
    
    rezoom    = [IBrezoom intValue];
    hidewatch = ( [IBhidewatch state] == NSControlStateValueOn ) ? TRUE : FALSE;
    
    [defaults setInteger:rezoom   forKey:@"rezoom"];
    [defaults setBool:hidewatch   forKey:@"hidewatch"];
    
    [defaults synchronize];
    [[NSApplication sharedApplication] endSheet:self.configureSheet];

}
    
- (IBAction) configureSheet_cancel:(id) sender {

    [[NSApplication sharedApplication] endSheet:self.configureSheet];

}

- (IBAction) configureSheet_defaults:(id) sender {

    [IBrezoom setIntValue:3];
    [IBhidewatch setState:NSControlStateValueOff];
    
}

- (void)loadTexture:(NSString *)name
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)[bundle URLForImageResource:name], NULL);
//    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)[[NSBundle mainBundle] URLForImageResource:name], NULL);

    CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    CFRelease(imageSource);
    size_t ww = CGImageGetWidth (image);
    size_t wh = CGImageGetHeight(image);
    CGRect rect = CGRectMake(0.0f, 0.0f, ww, wh);
    
    void *imageData = malloc(ww * wh * 4);
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(imageData, ww, wh, 8, ww * 4, colourSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
    CFRelease(colourSpace);
    CGContextTranslateCTM(ctx, 0, wh);
    CGContextScaleCTM(ctx, 1.0f, -1.0f);
    CGContextSetBlendMode(ctx, kCGBlendModeCopy);
    CGContextDrawImage(ctx, rect, image);
    CGContextRelease(ctx);
    CFRelease(image);
    
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glPixelStorei(GL_UNPACK_ROW_LENGTH, (GLint)ww);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)ww, (int)wh,
                                0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    free(imageData);
    
}

- (void)genTexture {
    int ww = 2;
    int wh = 2;
    struct {unsigned char r,g,b,a; } data[2][2];
    memset(data, 0, sizeof(data));
    data[0][0].r = 175;
    data[0][0].g = 225;
    data[0][0].b = 225;
    
    data[1][0].r = 225;
    data[1][0].g = 225;
    data[1][0].b = 200;
    
    data[1][1].r = 205;
    data[1][1].g = 225;
    data[1][1].b = 205;
    
    data[0][1].r = 215;
    data[0][1].g = 255;
    data[0][1].b = 215;

    glGenTextures (1, &texture);
    glBindTexture (GL_TEXTURE_2D, texture);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA, ww, wh, 0,
                                    GL_RGBA, GL_UNSIGNED_BYTE, data);
    glBindTexture(GL_TEXTURE_2D, 0);
}

    
@end
