//
//  defvar.h
//  matrixwatch
//
//  Created by u1 on 25.10.2023.
//

//#define FPS             6.0
#define CELLC           10   // num adds background cycle
#define SCALE           1.0  // koef for zooming
#define XYSCALE         1.0  // for Ortho
#define VSNUMBER        71   // num cells vertical
#define TEXTURE         @"matrixcodemap"    // texture file name

static char digit_matrix[451] = "\
111111000110001100011000110001100011000111111\
000110000100001000010000100001000010000100001\
111110000100001000011111110000100001000011111\
111110000100001000010111100001000010000111111\
100011000110001100011111100001000010000100001\
111111000010000100001111100001000010000111111\
111111000010000100001111110001100011000111111\
111111000100001000010000100001000010000100001\
111111000110001100011111110001100011000111111\
111111000110001100011111100001000010000111111";

static char dots_matrix[136] = "\
001000100\
000101000\
001101100";

static char m_deys_matrix[281] = "1111100110011001100110011111001100010001000100010001000111110001000111111000100011111111000100010111000100011111100110011001111100010001000111111000100011110001000111111111100010001111100110011111111110010001001001000100010011111001100111111001100111111111100110011111000100011111";
static char w_deys_matrix[246] = "11101111010100111010010101001110111111010110101011010111101010110101011110111101001011100101010010111001011101111000101100011110001001110100101011110100101110010001001000100101110111101001010100101010010101001011101111000100100011110001011110111";

static GLubyte  def_bg_colors[] = {12, 12, 12};
//static GLubyte def_bg_colors[] = {24, 24, 24};
static GLubyte  def_fg_colors[] = {38, 38, 38};
static GLubyte  def_hh_colors[] = {90, 90, 30};
static GLubyte  def_mm_colors[] = {76, 38, 0};
static GLubyte  def_ss_colors[] = {58, 56, 5};
static GLubyte  def_ww_colors[] = {63, 50, 38};
static GLubyte  def_dd_colors[] = {38, 76, 0};

static GLubyte  def_wd_colors[] = {60, 70, 60};
static GLubyte  def_ew_colors[] = {78, 0, 0};
static GLubyte  def_cd_colors[] = {78, 48, 0};

static GLubyte * colors = def_hh_colors;

static float rectCrd[] = {-1,1, 1,1, 1,-1, -1,-1};

static float rectTxt[] = {0,0, 1,0, 1,1, 0,1};

typedef struct {
    int wday;
    int mday;

    int hour;
    int minute;
    int second;

} CurTime;

struct fSym {
    int x;
    int y;

    int mx;
    int my;
    bool flash;
};

typedef struct {
    
    int mx;
    int my;
    
    float sym_x;
    float sym_y;
    
} TimeDig;
