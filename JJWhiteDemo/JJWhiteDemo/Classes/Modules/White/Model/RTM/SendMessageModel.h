//
//  SendMessageModel.h
//  JJWhiteDemo
//
//  Created by mude on 2019/3/21.
//  Copyright © 2019 mude. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SendMessageModel : NSObject
@property (nonatomic, assign) NSInteger type;//1、举手，2、关闭麦克风，3、关闭手写笔，4、课程内信息，5、课程结束
@property (nonatomic, assign) NSInteger fromUser;
@property (nonatomic, assign) NSInteger toUser;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *time;
@end

NS_ASSUME_NONNULL_END
