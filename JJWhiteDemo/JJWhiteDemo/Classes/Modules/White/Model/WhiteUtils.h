//
//  WhiteUtils.h
//  JJWhiteDemo
//
//  Created by mude on 2019/3/12.
//  Copyright © 2019 mude. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WhiteUtils : NSObject

+ (NSString *)sdkToken;
+ (void)createRoomWithResult:(void (^) (BOOL success, id _Nullable response, NSError * _Nullable error))result;
+ (void)getRoomTokenWithUuid:(NSString *)uuid Result:(void (^) (BOOL success, id _Nullable response, NSError * _Nullable error))result;

@end

NS_ASSUME_NONNULL_END
