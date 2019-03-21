//
//  UserDefaultsUtils.h
//  ICP
//
//  Created by DreamTouch on 15/1/27.
//  Copyright (c) 2015年 Friday. All rights reserved.
//

/**
 *  简单的存储本地数据
 all keys array:userId 用户名
 password 密码
 identityType 身份类型
 
 */

#import <Foundation/Foundation.h>
@interface UserDefaultsUtils : NSObject
+(void)saveWithDic:(NSDictionary *)dic;

+(void)saveValue:(id) value forKey:(NSString *)key;

+(id)valueWithKey:(NSString *)key;

+(BOOL)boolValueWithKey:(NSString *)key;

+(void)saveBoolValue:(BOOL)value withKey:(NSString *)key;

+(void)removeValueWithKey:(NSString *)key;

+(void)removeAllValues;

+(void)removeValueWithArray:(NSArray *)arr;

+(void)print;

@end
