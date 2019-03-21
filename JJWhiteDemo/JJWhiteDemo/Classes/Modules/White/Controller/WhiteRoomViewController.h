//
//  RoomViewController.h
//  WhiteDemo
//
//  Created by mude on 2019/3/8.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhiteBaseViewController.h"

//RTM  相关
typedef NS_ENUM(NSInteger, ChatType) {
    ChatTypePeer = 0,
    ChatTypeGroup
};

typedef struct  {
    ChatType type;
    NSString *name;
} ChatMode;

//接受按钮点击通知
typedef NS_ENUM(NSInteger, ButtonType) {
    ButtonTypeCancel = 1,
    ButtonTypeAudio = 2,
    ButtonTypePencil = 3
};


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
@property (copy, nonatomic) NSString *roomName;

#pragma mark - RTM  相关
@property (nonatomic, assign) ChatMode mode;

@end

NS_ASSUME_NONNULL_END
