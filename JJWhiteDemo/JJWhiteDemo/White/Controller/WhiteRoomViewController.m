//
//  RoomViewController.m
//  WhiteDemo
//
//  Created by mude on 2019/3/8.
//  Copyright © 2019 mude. All rights reserved.
//

#import "WhiteRoomViewController.h"
#import <Masonry/Masonry.h>
#import "CommandListController.h"
#import "AppDelegate.h"
#import "WhiteUtils.h"
#import "ToolSelectView.h"
#import "ColorTableViewController.h"
#import "MsgTableView.h"

//live
#import "LiveRoomView.h"
#import "LiveTableView.h"
#import "VideoSession.h"
#import "KeyCenter.h"
#import <MBProgressHUD.h>

//chat
#import "Message.h"
#import "UIColor+Extension.h"
#import "AgoraSignal.h"

@interface WhiteRoomViewController ()<WhiteRoomCallbackDelegate,WhiteCommonCallbackDelegate, UIPopoverPresentationControllerDelegate,AgoraRtcEngineDelegate,UITextFieldDelegate>
@property (nonatomic, copy) NSString *roomToken;
@property (nonatomic, strong) WhiteSDK *sdk;
@property (nonatomic, assign, getter=isReconnecting) BOOL reconnecting;
@property (nonatomic, strong) ToolSelectView *toolSelectView;

@property (nonatomic, strong) MBProgressHUD *progressHUD;

//视频相关
@property (nonatomic, strong) LiveTableView *liveTableView;
@property (strong, nonatomic) MsgTableView *msgTableView;
@property (strong, nonatomic) UIButton *broadcastButton;
@property (strong, nonatomic) UIButton *audioMuteButton;
@property (nonatomic, strong) UIButton *switchCameraButton;
@property (nonatomic, strong) UIButton *videoButton;

@property (strong, nonatomic) AgoraRtcEngineKit *rtcEngine;
@property (assign, nonatomic) BOOL isBroadcaster;
@property (assign, nonatomic) BOOL isAudio;//语音是否开启
@property (assign, nonatomic) BOOL isVideo;//视频是否开启
@property (strong, nonatomic) NSMutableArray<VideoSession *> *videoSessions;
@property (strong, nonatomic) VideoSession *fullSession;

//信令
@property (nonatomic, assign) NSInteger userNum;
@property (nonatomic, strong) UITextField *txtField;

@end
@implementation WhiteRoomViewController

static NSString * const kCustomEvent = @"custom";

static NSInteger streamID = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *sdkToken = [WhiteUtils sdkToken];
    self.view.backgroundColor = [UIColor colorWithRed:66.f/255.f green:66.f/255.f blue:66.f/255.f alpha:0.5f];
    
    if ([sdkToken length] == 0) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"sdk token 不合法", nil) message:NSLocalizedString(@"请在 console.herewhite.com 注册并申请 Token，并在 WhiteUtils sdkToken 方法中，填入 SDKToken 进行测试", nil) preferredStyle:UIAlertControllerStyleAlert];
        alertVC.popoverPresentationController.sourceView = self.view;
        alertVC.popoverPresentationController.sourceRect = self.view.bounds;
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:nil];
    } else if ([self.roomUuid length] > 0) {
        [self joinRoom];
    } else {
        [self createRoom];
    }
    
    [self prepareView];
    
    
    self.videoSessions = [[NSMutableArray alloc] init];
    
    [self loadAgoraKit];
    
    //信令chat相关
    [[AgoraSignal sharedKit] channelQueryUserNum:self.roomName];
    self.messageList.identifier = self.roomName;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).allowRotation = YES;
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [self addAgoraSignalBlock];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).allowRotation = NO;
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [[AgoraSignal sharedKit] channelLeave:self.roomName];
    [[AgoraSignal sharedKit] logout];
}

//userNum
- (void)setUserNum:(NSInteger)userNum {
    _userNum = userNum;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.title = [NSString stringWithFormat:@"%@ (%lu)", self.roomName, userNum];
    });
}
- (MessageList *)messageList {
    if (!_messageList) {
        _messageList = [[MessageList alloc] init];
    }
    return _messageList;
}



- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

- (void)prepareView {
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressHUD.layer.zPosition = 10;
}

- (void)prepareWhiteView {
    self.boardView = [[WhiteBoardView alloc] init];
    [self.view addSubview:self.boardView];
    [self.boardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.bottom.right.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-150);
    }];
    
    self.liveTableView = [[NSBundle mainBundle] loadNibNamed:@"LiveTableView" owner:nil options:nil][0];
    [self.view addSubview:_liveTableView];
    [_liveTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.right.equalTo(self.view).offset(0);
        make.left.equalTo(self.boardView.mas_right).offset(0);
    }];
    
    //用于显示消息
    self.msgTableView = [[MsgTableView alloc] init];
    [self.boardView addSubview:_msgTableView];
    [_msgTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.boardView).offset(20);
        make.left.equalTo(self.boardView).offset(20);
        make.width.offset(100);
        make.height.offset(150);
    }];
    
    __weak WhiteRoomViewController *weakSelf = self;
    self.toolSelectView = [[NSBundle mainBundle] loadNibNamed:@"ToolSelectView" owner:nil options:nil][0];
    self.toolSelectView.toolSelectBlock = ^(ToolSelectTableViewCell *cell) {
        ColorTableViewController *controller = [[ColorTableViewController alloc] initWithRoom:weakSelf.room];
        [weakSelf showPopoverViewController:controller sourceView:cell];
    };
    self.toolSelectView.cancelBlock = ^{
        [weakSelf cancel];
    };
    [self.view addSubview:_toolSelectView];
    [_toolSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.view).offset(0);
        make.right.equalTo(self.boardView.mas_left).offset(0);
    }];
    
    
    //按钮加载boardView上
    _broadcastButton = [[UIButton alloc] init];
    [_broadcastButton setImage:[UIImage imageNamed:@"btn_join"] forState:UIControlStateNormal];
    [_broadcastButton addTarget:self action:@selector(doBroadcastPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.boardView addSubview:_broadcastButton];
    [self.broadcastButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(0);
        make.left.equalTo(self.boardView).offset(0);
        make.width.height.offset(44);
    }];
    //switchCameraButton
    _switchCameraButton = [[UIButton alloc] init];
    [_switchCameraButton setImage:[UIImage imageNamed:@"btn_overturn"] forState:UIControlStateNormal];
    [_switchCameraButton addTarget:self action:@selector(doSwitchCameraPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.boardView addSubview:_switchCameraButton];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(0);
        make.left.equalTo(self.broadcastButton.mas_right).offset(0);
        make.width.height.offset(44);
    }];
    
    //按钮加载boardView上
    _audioMuteButton = [[UIButton alloc] init];
    [_audioMuteButton setImage:[UIImage imageNamed:@"btn_mute"] forState:UIControlStateNormal];
    [_audioMuteButton addTarget:self action:@selector(doMutePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.boardView addSubview:_audioMuteButton];
    [self.audioMuteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(0);
        make.left.equalTo(self.switchCameraButton.mas_right).offset(0);
        make.width.height.offset(44);
    }];
    
    //videoButton
    _videoButton = [[UIButton alloc] init];
    [_videoButton setImage:[UIImage imageNamed:@"btn_video_on"] forState:UIControlStateNormal];
    [_videoButton addTarget:self action:@selector(doVideoPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.boardView addSubview:_videoButton];
    [self.videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(0);
        make.left.equalTo(self.audioMuteButton.mas_right).offset(0);
        make.width.height.offset(44);
    }];
    
    //发消息相关
    _txtField = [[UITextField alloc] init];
    _txtField.delegate = self;
    _txtField.placeholder = @"发送消息请输入...";
    [self.boardView addSubview:_txtField];
    [_txtField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(0);
        make.left.equalTo(self.videoButton.mas_right).offset(20);
        make.right.equalTo(self.boardView).offset(20);
        make.width.height.offset(44);
    }];
    
    [self.view bringSubviewToFront:_progressHUD];
}

- (BOOL)isBroadcaster {
    return self.clientRole == AgoraClientRoleBroadcaster;
}

- (void)setClientRole:(AgoraClientRole)clientRole {
    _clientRole = clientRole;

    [self updateButtonsVisiablity];
}

- (void)setIsAudio:(BOOL)isAudio {
    _isAudio = isAudio;
    [self.rtcEngine muteLocalAudioStream:isAudio];

    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.audioMuteButton setImage:[UIImage imageNamed:(isAudio ? @"btn_mute_cancel" : @"btn_mute")] forState:UIControlStateNormal];
        //回调或者说是通知主线程刷新，
    });
}

- (void)setIsVideo:(BOOL)isVideo {
    _isVideo = isVideo;
    [self.rtcEngine muteLocalVideoStream:isVideo];
    //禁用摄像头
    [self.rtcEngine enableLocalVideo:!isVideo];
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoButton setImage:[UIImage imageNamed:(isVideo ? @"btn_video_off" : @"btn_video_on")] forState:UIControlStateNormal];
        //回调或者说是通知主线程刷新，
    });
}

- (void)setVideoSessions:(NSMutableArray<VideoSession *> *)videoSessions {
    _videoSessions = videoSessions;
    if (self.liveTableView) {
        [self updateInterfaceWithAnimation:YES];
    }
}

- (void)setFullSession:(VideoSession *)fullSession {
    _fullSession = fullSession;
    if (self.liveTableView) {
        [self updateInterfaceWithAnimation:YES];
    }
}

- (void)cancel {
    [self leaveChannel];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Property
/* 默认为self，主要为了 Unit Testing */
- (id<WhiteRoomCallbackDelegate>)_roomCallbackDelegate
{
    if (!_roomCallbackDelegate) {
        _roomCallbackDelegate = self;
    }
    return _roomCallbackDelegate;
}

#pragma mark - BarItem
- (void)setupShareBarItem
{
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"设置 API", nil) style:UIBarButtonItemStylePlain target:self action:@selector(settingAPI:)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"分享", nil) style:UIBarButtonItemStylePlain target:self action:@selector(shareRoom:)];
    
    self.navigationItem.rightBarButtonItems = @[item1, item2];
}

- (void)settingAPI:(id)sender
{
    CommandListController *controller = [[CommandListController alloc] initWithRoom:self.room];
    [self showPopoverViewController:controller sourceView:sender];
}

- (void)shareRoom:(id)sender
{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.roomUuid ? :@""] applicationActivities:nil];
    activityVC.popoverPresentationController.sourceView = [self.navigationItem.rightBarButtonItem valueForKey:@"view"];
    [self presentViewController:activityVC animated:YES completion:nil];
    NSLog(@"%@", [NSString stringWithFormat:NSLocalizedString(@"房间 UUID: %@", nil), self.roomUuid]);
}

#pragma mark - Room Action

/**
 创建房间：
 1. 调用创建房间API，服务器会同时返回了该房间的 roomToken；
 2. 通过 roomToken 进行加入房间操作。
 */
- (void)createRoom
{
//    self.title = NSLocalizedString(@"创建房间中...", nil);
    _progressHUD.label.text = @"创建房间中...";
    [WhiteUtils createRoomWithResult:^(BOOL success, id response, NSError *error) {
        if (success) {
            NSString *roomToken = response[@"msg"][@"roomToken"];
            NSString *uuid = response[@"msg"][@"room"][@"uuid"];
            self.roomUuid = uuid;
            if (self.roomUuid && roomToken) {
                [self joinRoomWithToken:roomToken];
            } else {
                NSLog(NSLocalizedString(@"连接房间失败，room uuid:%@ roomToken:%@", nil), self.roomUuid, roomToken);
                self.title = NSLocalizedString(@"创建失败", nil);
                
                self.progressHUD.label.text = @"创建失败";
                [self.progressHUD removeFromSuperview];
                self.progressHUD = nil;
            }
        } else if (self.roomBlock) {
            self.roomBlock(nil, error);
        } else {
            NSLog(NSLocalizedString(@"创建房间失败，error:", nil), [error localizedDescription]);
            self.title = NSLocalizedString(@"创建失败", nil);
            
            self.progressHUD.label.text = @"创建失败";
            [self.progressHUD removeFromSuperview];
            self.progressHUD = nil;
        }
    }];
}

/**
 已有 room uuid，加入房间
 1. 与服务器通信，获取该房间的 room token
 2. 通过 roomToken 进行加入房间操作。
 */
- (void)joinRoom
{
    NSString *copyPast = [UIPasteboard generalPasteboard].string;
    if ([copyPast length] == 32 && !self.roomUuid) {
        NSLog(@"%@", [NSString stringWithFormat:NSLocalizedString(@"粘贴板 UUID：%@", nil), copyPast]);
        self.roomUuid = copyPast;
    }
//    self.title = NSLocalizedString(@"加入房间中...", nil);
    self.progressHUD.label.text = @"加入房间中...";
    [WhiteUtils getRoomTokenWithUuid:self.roomUuid Result:^(BOOL success, id response, NSError *error) {
        if (success) {
            NSString *roomToken = response[@"msg"][@"roomToken"];
            [self joinRoomWithToken:roomToken];
        } else {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"加入房间失败", nil) message:[NSString stringWithFormat:@"服务器信息:%@，系统错误信息:%@", [error localizedDescription], [response description]] preferredStyle:UIAlertControllerStyleAlert];
            alertVC.popoverPresentationController.sourceView = self.view;
            alertVC.popoverPresentationController.sourceRect = self.view.bounds;
            UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    }];
}

- (void)joinRoomWithToken:(NSString *)roomToken
{
//    self.title = NSLocalizedString(@"正在连接房间", nil);
    self.progressHUD.label.text = @"正在连接房间";
    WhiteSdkConfiguration *config = [WhiteSdkConfiguration defaultConfig];
    
    //如果不需要拦截图片API，则不需要开启，页面内容较为复杂时，可能会有性能问题
    config.enableInterrupterAPI = YES;
    config.debug = YES;
    
    
    [self prepareWhiteView];
    [self updateButtonsVisiablity];
    
    self.sdk = [[WhiteSDK alloc] initWithWhiteBoardView:self.boardView config:config commonCallbackDelegate:self.commonDelegate];
    [self.sdk joinRoomWithRoomUuid:self.roomUuid roomToken:roomToken callbacks:self.roomCallbackDelegate completionHandler:^(BOOL success, WhiteRoom * _Nonnull room, NSError * _Nonnull error) {
        if (success) {
//            self.title = NSLocalizedString(@"我的白板", nil);
            
            [self.progressHUD removeFromSuperview];
            self.progressHUD = nil;
            
            self.roomToken = roomToken;
            self.room = room;
            [self.room addMagixEventListener:CommandCustomEvent];
            [self setupShareBarItem];
            [self roleSettings];
            [self toolInit];
            
            if (self.roomBlock) {
                self.roomBlock(self.room, nil);
            }
        } else if (self.roomBlock) {
            self.roomBlock(nil, error);
        } else {
            self.title = NSLocalizedString(@"加入失败", nil);
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"加入房间失败", nil) message:[NSString stringWithFormat:@"错误信息:%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
            alertVC.popoverPresentationController.sourceView = self.view;
            alertVC.popoverPresentationController.sourceRect = self.view.bounds;
            UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    }];
}

#pragma mark - UIPopoverPresentationController & Delegate
- (void)showPopoverViewController:(UIViewController *)vc sourceView:(id)sourceView
{
    vc.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *present = vc.popoverPresentationController;
    present.permittedArrowDirections = UIPopoverArrowDirectionAny;
    present.delegate = self;
    if ([sourceView isKindOfClass:[UIView class]]) {
        present.sourceView = sourceView;
        present.sourceRect = [sourceView bounds];
    } else if ([sourceView isKindOfClass:[UIBarButtonItem class]]) {
        present.barButtonItem = sourceView;
    } else {
        present.sourceView = self.view;
    }
    [self presentViewController:vc animated:YES completion:nil];
}

//不建议用这个方法，用下面那个（这个在plus上横屏的时候样式有问题）横屏时popoverview窗口大小异常
/**(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
 return UIModalPresentationNone;
 } */

//横屏无异常
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection{
    return UIModalPresentationNone;
    
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return YES;
}

#pragma mark - Get State API
- (void)getTestingAPI
{
//    [self.room getPptImagesWithResult:^(NSArray<NSString *> *pptPages) {
//        NSLog(@"%@", pptPages);
//    }];
    
    [self.room getScenesWithResult:^(NSArray<WhiteScene *> * _Nonnull scenes) {
        NSLog(@"%@", scenes);
    }];
    
    [self.room getGlobalStateWithResult:^(WhiteGlobalState *state) {
        NSLog(@"%@", [state jsonString]);
    }];
    
    /** 获取当前教具 **/
    [self.room getMemberStateWithResult:^(WhiteMemberState *state) {
        NSLog(@"当前教具%@", [state jsonString]);
    }];
    
    /** 获取当前视角状态 **/
    [self.room getBroadcastStateWithResult:^(WhiteBroadcastState *state) {
        NSLog(@"%@", [state jsonString]);
    }];
    
    [self.room getRoomMembersWithResult:^(NSArray<WhiteRoomMember *> *roomMembers) {
        for (WhiteRoomMember *m in roomMembers) {
            NSLog(@"%@", [m jsonString]);
        }
    }];
}

#pragma mark - WhiteRoomCallbackDelegate
- (void)firePhaseChanged:(WhiteRoomPhase)phase
{
    NSLog(@"%s, %ld", __FUNCTION__, (long)phase);
    if (phase == WhiteRoomPhaseDisconnected && self.sdk && !self.isReconnecting) {
        self.reconnecting = YES;
        [self.sdk joinRoomWithUuid:self.roomUuid roomToken:self.roomToken completionHandler:^(BOOL success, WhiteRoom *room, NSError *error) {
            self.reconnecting = NO;
            NSLog(@"reconnected");
            if (error) {
                NSLog(@"error:%@", [error localizedDescription]);
            } else {
                self.room = room;
            }
        }];
    }
}

- (void)fireRoomStateChanged:(WhiteRoomState *)magixPhase;
{
    NSLog(@"%s, %@", __func__, [magixPhase jsonString]);
}

- (void)fireBeingAbleToCommitChange:(BOOL)isAbleToCommit
{
    NSLog(@"%s, %d", __func__, isAbleToCommit);
}

- (void)fireDisconnectWithError:(NSString *)error
{
    NSLog(@"%s, %@", __func__, error);
}

- (void)fireKickedWithReason:(NSString *)reason
{
    NSLog(@"%s, %@", __func__, reason);
}

- (void)fireCatchErrorWhenAppendFrame:(NSUInteger)userId error:(NSString *)error
{
    NSLog(@"%s, %lu %@", __func__, (unsigned long)userId, error);
}

- (void)fireMagixEvent:(WhiteEvent *)event
{
    NSLog(@"fireMagixEvent: %@", [event jsonString]);
}

#pragma mark - WhiteRoomCallbackDelegate
- (void)throwError:(NSError *)error
{
    NSLog(@"throwError: %@", error.userInfo);
}

- (NSString *)urlInterrupter:(NSString *)url
{
    return @"https://white-pan-cn.oss-cn-hangzhou.aliyuncs.com/124/image/image.png";
}

#pragma mark - textField Delegate
- (void)sendDataWithString:(NSString *)message {
//    [self.msgTableView appendMsgToTableViewWithMsg:message msgType:MsgTypeChat];
    [[AgoraSignal sharedKit] messageChannelSend:self.roomName msg:message msgID:[NSString stringWithFormat:@"%lu", (unsigned long)self.messageList.list.count]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendDataWithString:textField.text];
    textField.text = @"";
    [self.view endEditing:YES];
    return YES;
}

#pragma mark -  视频直播

- (void)updateButtonsVisiablity {
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.broadcastButton setImage:[UIImage imageNamed:self.isBroadcaster ? @"btn_join_cancel" : @"btn_join"] forState:UIControlStateNormal];
        self.audioMuteButton.hidden = !self.isBroadcaster;
        self.switchCameraButton.hidden = !self.isBroadcaster;
        self.videoButton.hidden = !self.isBroadcaster;
        //回调或者说是通知主线程刷新，
    });
}

- (void)leaveChannel {
    [self setIdleTimerActive:YES];
    
    [self.rtcEngine setupLocalVideo:nil];
    [self.rtcEngine leaveChannel:nil];
    if (self.isBroadcaster) {
        [self.rtcEngine stopPreview];
    }
    
    for (VideoSession *session in self.videoSessions) {
        [session.hostingView removeFromSuperview];
    }
    [self.videoSessions removeAllObjects];
    
    if ([self.delegate respondsToSelector:@selector(liveVCNeedClose:)]) {
        [self.delegate liveVCNeedClose:self];
    }
}

- (void)setIdleTimerActive:(BOOL)active {
    [UIApplication sharedApplication].idleTimerDisabled = !active;
}

- (void)alertString:(NSString *)string {
    if (!string.length) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = self.view.bounds;
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateInterfaceWithAnimation:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self updateInterface];
            [self.view layoutIfNeeded];
        }];
    } else {
        [self updateInterface];
    }
}

- (void)updateInterface {
    NSArray *displaySessions;
    if (!self.isBroadcaster && self.videoSessions.count) {
        displaySessions = [self.videoSessions subarrayWithRange:NSMakeRange(1, _videoSessions.count - 1)];
    } else {
        displaySessions = [self.videoSessions copy];
    }
    
    self.liveTableView.sessions = displaySessions;
    [self setStreamTypeForSessions:displaySessions fullSession:self.fullSession];
}

- (void)setStreamTypeForSessions:(NSArray<VideoSession *> *)sessions fullSession:(VideoSession *)fullSession {
    if (fullSession) {
        for (VideoSession *session in sessions) {
            [self.rtcEngine setRemoteVideoStream:session.uid type:(session == self.fullSession ? AgoraVideoStreamTypeHigh : AgoraVideoStreamTypeLow)];
        }
    } else {
        for (VideoSession *session in sessions) {
            [self.rtcEngine setRemoteVideoStream:session.uid type:AgoraVideoStreamTypeHigh];
        }
    }
}

- (void)addLocalSession {
    VideoSession *localSession = [VideoSession localSession];
    [self.videoSessions addObject:localSession];
    [self.rtcEngine setupLocalVideo:localSession.canvas];
    [self updateInterfaceWithAnimation:YES];
}

- (VideoSession *)fetchSessionOfUid:(NSUInteger)uid {
    for (VideoSession *session in self.videoSessions) {
        if (session.uid == uid) {
            return session;
        }
    }
    return nil;
}

- (VideoSession *)videoSessionOfUid:(NSUInteger)uid {
    VideoSession *fetchedSession = [self fetchSessionOfUid:uid];
    if (fetchedSession) {
        return fetchedSession;
    } else {
        VideoSession *newSession = [[VideoSession alloc] initWithUid:uid];
        [self.videoSessions addObject:newSession];
        [self updateInterfaceWithAnimation:YES];
        return newSession;
    }
}

//MARK: - Agora Media SDK 白板

//设置用户类型（主播/游客）
- (void)roleSettings {
    self.toolSelectView.room = self.room;
    if (self.isBroadcaster) {
        [self.room setViewMode:WhiteViewModeBroadcaster];
        [self.room disableOperations:NO];
    }else {
        //设置游客模式 只读
        [self.room setViewMode:WhiteViewModeFollower];
        [self.room disableOperations:YES];
    }
}

//设置初始教具
- (void)toolInit {
    WhiteMemberState *mState = [[WhiteMemberState alloc] init];
    mState.currentApplianceName = AppliancePencil;
    mState.strokeColor = @[@(0),@(0),@(0)];
    mState.strokeWidth = @(5);
    [self.room setMemberState:mState];
    //初始化颜色为黑色，发送通知
    NSDictionary *dic = @{@"colorArray":@[@(0),@(0),@(0)]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"colorChange" object:dic];
}

- (void)loadAgoraKit {
    self.rtcEngine = [AgoraRtcEngineKit sharedEngineWithAppId:[KeyCenter AppId] delegate:self];
    [self.rtcEngine setChannelProfile:AgoraChannelProfileLiveBroadcasting];
    [self.rtcEngine setLocalVideoMirrorMode:AgoraVideoMirrorModeEnabled];
    [self.rtcEngine setParameters:@"{\"che.video.enableRemoteViewMirror\":true}"];
    // Warning: only enable dual stream mode if there will be more than one broadcaster in the channel
    [self.rtcEngine enableDualStreamMode:YES];
    
    [self.rtcEngine enableVideo];
    AgoraVideoEncoderConfiguration *configuration = [[AgoraVideoEncoderConfiguration alloc] initWithSize:self.videoProfile
                                                                                               frameRate:AgoraVideoFrameRateFps24
                                                                                                 bitrate:AgoraVideoBitrateStandard
                                                                                         orientationMode:AgoraVideoOutputOrientationModeAdaptative];
    [self.rtcEngine setVideoEncoderConfiguration:configuration];
    [self.rtcEngine setClientRole:self.clientRole];
    
    [self.rtcEngine createDataStream:&streamID reliable:YES ordered:YES];
    
    if (self.isBroadcaster) {
        [self.rtcEngine startPreview];
    }
    
    [self addLocalSession];
    
    //用户 ID，32 位无符号整数。建议设置范围：1到 (232-1)，并保证唯一性。如果不指定（即设为0），SDK 会自动分配一个，并在 joinSuccessBlock 回调方法中返回，App 层必须记住该返回值并维护，SDK 不对该返回值进行维护。
    //uid为用户id
    int code = [self.rtcEngine joinChannelByToken:nil channelId:self.roomName info:nil uid:[[[NSUserDefaults standardUserDefaults] stringForKey:@"uid"] integerValue] joinSuccess:nil];
    if (code == 0) {
        [self setIdleTimerActive:NO];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertString:[NSString stringWithFormat:@"Join channel failed: %d", code]];
        });
    }

}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    VideoSession *userSession = [self videoSessionOfUid:uid];
    [self.rtcEngine setupRemoteVideo:userSession.canvas];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed {
    if (self.videoSessions.count) {
        [self updateInterfaceWithAnimation:NO];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    VideoSession *deleteSession;
    for (VideoSession *session in self.videoSessions) {
        if (session.uid == uid) {
            deleteSession = session;
        }
    }
    
    if (deleteSession) {
        [self.videoSessions removeObject:deleteSession];
        [deleteSession.hostingView removeFromSuperview];
        [self updateInterfaceWithAnimation:YES];
        
        if (deleteSession == self.fullSession) {
            self.fullSession = nil;
        }
    }
}

//点击事件
- (void)doBroadcastPressed:(UIButton *)sender {
    if (self.isBroadcaster) {
        self.clientRole = AgoraClientRoleAudience;
        //重新设置为跟随模式
        [self.room setViewMode:WhiteViewModeFollower];
        //禁用手势
        [self.room disableOperations:YES];
        if (self.fullSession.uid == 0) {
            self.fullSession = nil;
        }
    } else {
        self.isAudio = NO;
        self.isVideo = NO;
        self.clientRole = AgoraClientRoleBroadcaster;
        //不禁用手势
        [self.room disableOperations:NO];
    }
    
    [self.rtcEngine setClientRole:self.clientRole];
    [self updateInterfaceWithAnimation:YES];
}
- (void)doMutePressed:(UIButton *)sender {
    self.isAudio = !self.isAudio;
}
- (void)doSwitchCameraPressed:(UIButton *)sender {
    [self.rtcEngine switchCamera];
}
- (void)doVideoPressed:(UIButton *)sender {
    self.isVideo = !self.isVideo;
}

#pragma mark - 信令 chat
- (void)addAgoraSignalBlock {
    __weak typeof(self) weakSelf = self;
    [AgoraSignal sharedKit].onMessageSendError = ^(NSString *messageID, AgoraEcode ecode) {
        [weakSelf alertString:[NSString stringWithFormat:@"Message send failed with error: %lu", ecode]];
    };
    [AgoraSignal sharedKit].onMessageChannelReceive = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            Message *message = [[Message alloc] initWithAccount:account message:msg];
            [strongSelf.messageList.list addObject:message];
            [strongSelf updateTableView:strongSelf.msgTableView withMessage:message];
            strongSelf.txtField.text = @"";
        });
    };
    
    [AgoraSignal sharedKit].onChannelQueryUserNumResult = ^(NSString *channelID, AgoraEcode ecode, int num) {
        weakSelf.userNum = num;
    };
    
    [AgoraSignal sharedKit].onChannelUserJoined = ^(NSString *account, uint32_t uid) {
        weakSelf.userNum ++;
    };
    
    [AgoraSignal sharedKit].onChannelUserLeaved = ^(NSString *account, uint32_t uid) {
        weakSelf.userNum --;
    };
    
    //点对点收到消息回调
    [AgoraSignal sharedKit].onMessageInstantReceive = ^(NSString *account, uint32_t uid, NSString *msg) {
        NSLog(@"%@", msg);
        if ([msg isEqualToString:@"mute_off"]) {
            weakSelf.isAudio = NO;
        }else if ([msg isEqualToString:@"mute_on"]) {
            weakSelf.isAudio = YES;
        }else if ([msg isEqualToString:@"cacnel"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.clientRole = AgoraClientRoleAudience;
                //禁用手势
                [strongSelf.room disableOperations:YES];
                //重新设置为跟随模式
                [strongSelf.room setViewMode:WhiteViewModeFollower];
                if (strongSelf.fullSession.uid == 0) {
                    strongSelf.fullSession = nil;
                }
                [strongSelf.rtcEngine setClientRole:weakSelf.clientRole];
                [strongSelf updateInterfaceWithAnimation:YES];
            });
        }else if ([msg isEqualToString:@"video_off"]) {
            weakSelf.isVideo = NO;
        }else if ([msg isEqualToString:@"video_on"]) {
            weakSelf.isVideo = YES;
        }
    };
}

- (void)updateTableView:(UITableView *)tableView withMessage:(Message *)message {
    [self.msgTableView appendMsgToTableViewWithMsg:message msgType:MsgTypeChat];
}


@end
