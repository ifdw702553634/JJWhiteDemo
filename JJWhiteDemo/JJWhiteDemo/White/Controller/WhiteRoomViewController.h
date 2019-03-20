//
//  RoomViewController.h
//  WhiteDemo
//
//  Created by mude on 2019/3/8.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "WhiteBaseViewController.h"


@class WhiteRoomViewController;
@protocol LiveRoomDelegate <NSObject>
- (void)liveVCNeedClose:(WhiteRoomViewController *)liveVC;
@end

typedef void(^RoomBlock)(WhiteRoom * _Nullable room, NSError * _Nullable eroror);

NS_ASSUME_NONNULL_BEGIN

@interface WhiteRoomViewController : WhiteBaseViewController

@property (nonatomic, strong) WhiteRoom *room;
@property (nonatomic, copy) NSString *roomToken;

#pragma mark - Unit Testing
@property (nonatomic, weak) id<WhiteRoomCallbackDelegate> roomCallbackDelegate;
@property (nonatomic, copy) RoomBlock roomBlock;

#pragma mark - 直播
@property (assign, nonatomic) AgoraClientRole clientRole;
@property (assign, nonatomic) CGSize videoProfile;
@property (weak, nonatomic) id<LiveRoomDelegate> delegate;

#pragma mark - chat
@property (copy, nonatomic) NSString *roomName;

@end

NS_ASSUME_NONNULL_END
