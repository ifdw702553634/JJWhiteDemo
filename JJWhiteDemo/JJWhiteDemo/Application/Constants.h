//
//  Constants.h
//  PhotoSelectDemo
//
//  Created by mude on 17/1/10.
//  Copyright © 2017年 DreamTouch. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define kTimeSpan 1.5

//color
#define Rgb2UIColor(r, g, b, a)        [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:((a)/1.0)]
#define Hsv2UIColor(h, s, v, a)        [UIColor colorWithHue:((h)/360.0) saturation:((s)/100.0) brightness:((v)/100.0) alpha:((a)/1.0)]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define THEME_COLOR Rgb2UIColor(26, 169, 169, 1)
//#define BG_COLOR Rgb2UIColor(248, 248, 248, 1)
#define SPECIAL_BG_COLOR Rgb2UIColor(44, 251, 205, 0.1)
#define BG_COLOR Rgb2UIColor(248, 248, 248, 1) //背景色
#define SEC_COLOR Rgb2UIColor(250, 250, 250, 1)
#define THI_COLOR Rgb2UIColor(71, 137, 169, 1)
#define MASK_COLOR Rgb2UIColor(51, 51, 51, 1)
#define TEXT_COLOR_AIDE Rgb2UIColor(162 , 172, 181, 1) //文字辅助色

//判断iphone设备
#define IS_IPHONE4                  (SCREEN_HEIGHT == 480)
#define IS_IPHONE5                  (SCREEN_HEIGHT == 568)

//size
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

#define SCREEN_WIDTH  ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define TABLEVIEW_RECT CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)
#define TABLEVIEW_RECT_WITHOUTNAV CGRectMake(0, -20, SCREEN_WIDTH, SCREEN_HEIGHT+20)
#define NAVIGATION_HEIGHT (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) + CGRectGetHeight(self.navigationController.navigationBar.frame))

//APP INFO
#define APP_DISPLAYNAME     [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
#define ALERT_TITLE APP_DISPLAYNAME
#define VERSION             [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define SystemVersion [[UIDevice currentDevice] systemVersion]
#define SystemBuild [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

#ifdef DEBUG
#define DBG(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define DBG(format, ...)
#endif


#define IS_NULL_STRING(__POINTER) \
(__POINTER == nil || \
__POINTER == (NSString *)[NSNull null] || \
![__POINTER isKindOfClass:[NSString class]] || \
![__POINTER length])

#endif /* Constants_h */
