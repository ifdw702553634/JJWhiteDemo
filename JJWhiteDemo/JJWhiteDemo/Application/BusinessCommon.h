//
//  BusinessCommon.h
//  jiaojiao
//
//  Created by mude on 2019/3/26.
//  Copyright © 2019 jiaojiao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BusinessCommon : NSObject

//服务器(develop)
extern NSString *const kWebHTTP;
extern NSString *const kBaseUrl;
extern NSString *const kBaseImgUrl;
//appkey相关
extern NSString *const kWECHAT_APPKEY;
extern NSString *const kWECHAT_SECRET;
extern NSString *const kUSHARE_APPKEY;
extern NSString *const kJPUSH_APPKEY;
extern NSString *const kJPUSH_CHANNEL;
extern NSString *const kAppID;

@end

NS_ASSUME_NONNULL_END
