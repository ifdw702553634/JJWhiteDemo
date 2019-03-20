//
//  RoomViewController.h
//  JJWhiteDemo
//
//  Created by JiaoJiao Network on 2019/3/9.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "EncryptionType.h"


@class RoomViewController;
@protocol RoomVCDelegate <NSObject>
- (void)roomVCNeedClose:(RoomViewController *)roomVC;
@end
NS_ASSUME_NONNULL_BEGIN

@interface RoomViewController : UIViewController
@property (copy, nonatomic) NSString *roomName;
@property (assign, nonatomic) CGSize dimension;
@property (assign, nonatomic) EncrypType encrypType;
@property (copy, nonatomic) NSString *encrypSecret;
@property (weak, nonatomic) id<RoomVCDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
