//
//  AppUtils.h
//  ICP
//
//  Created by Ryan on 14+5+23.
//  Copyright (c) 2014年 zlycare. All rights reserved.
//
/**
 *  通用性方法类
 */
#import <Foundation/Foundation.h>

@interface AppUtils : NSObject

/********************** System Utils ***********************/
//弹出UIAlertView
+ (void)showAlertMessage:(NSString *)msg;
//关闭键盘
+ (void)closeKeyboard;
//获取MD5加密后字符串
+ (NSString *)md5FromString:(NSString *)str;

/******* UITableView & UINavigationController Utils *******/
//返回View覆盖多余的tableview cell线条
+ (UIView *)tableViewsFooterView;
//返回UILabel作为UITableView的header
+ (UILabel *)tableViewsHeaderLabelWithMessage:(NSString *)message;
//获取没有文字的导航栏返回按钮
+ (UIBarButtonItem *)navigationBackButtonWithNoTitle;

/********************** NSDate Utils ***********************/
//根据指定格式将NSDate转换为NSString
+ (NSString *)stringFromDate:(NSDate *)date formatter:(NSString *)formatter;
//根据指定格式将NSString转换为NSDate
+ (NSDate *)dateFromString:(NSString *)dateString formatter:(NSString *)formatter;

/********************* Category Utils **********************/
//根据颜色码取得颜色对象
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

/********************* Verification Utils **********************/
//验证手机号码合法性（正则）
+ (BOOL)checkPhoneNumber:(NSString *)phoneNumber;
//验证手机号码合法性(数字加位数)（正则）
+ (BOOL)checkSimplePhoneNumber:(NSString *)phoneNumber;
//验证车牌号是否正确
+ (BOOL)isPlateWithPlateNumber:(NSString *)plateNumber;
//时间戳转时间
+ (NSString *)getTimeByTimeStamp:(NSString *)timeStamp withFormat:(NSString *)format;
//邮箱正则校验
+(BOOL)isValidateEmail:(NSString *)email;
//获取当天0点0分
+ (NSDate *)zeroOfDate;
//如果想要判断设备是ipad，要用如下方法
+ (BOOL)getIsIpad;
//获取当前时间
+ (NSString*)getCurrentTimes;
@end
