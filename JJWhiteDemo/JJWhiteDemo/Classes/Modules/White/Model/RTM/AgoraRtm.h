//
//  AgoraRtm.h
//  Agora-Rtm-Tutorial
//
//  Created by CavanSu on 2019/2/19.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtmKit/AgoraRtmKit.h>
#import "KeyCenter.h"

typedef NS_ENUM(NSInteger, LoginStatus) {
    LoginStatusOnline = 0,
    LoginStatusOffline
};

@interface AgoraRtm : NSObject
+ (AgoraRtmKit *)kit;
+ (NSString *)current;
+ (void)setCurrent:(NSString *)name;
+ (LoginStatus)status;
+ (void)setStatus:(LoginStatus)status;
+ (void)updateDelegate:(id <AgoraRtmDelegate> _Nullable)delegate;
@end
