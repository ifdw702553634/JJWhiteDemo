//
//  RoomViewController.m
//  WhiteDemo
//
//  Created by mude on 2019/3/8.
//  Copyright © 2019 mude. All rights reserved.
//

#import "WhiteRoomViewController.h"
#import "AppDelegate.h"
#import "WhiteUtils.h"
#import "ToolSelectView.h"
#import "ColorTableViewController.h"
//live
#import "LiveTableView.h"
#import "VideoSession.h"
#import "KeyCenter.h"

//RTM
#import "AgoraRtm.h"
#import "Message.h"
#import "RightView.h"
#import "SendMessageModel.h"

//录屏相关
#import <SpriteKit/SpriteKit.h>
#import <ReplayKit/ReplayKit.h>
#import "VideoViewLayouter.h"


static NSInteger btnH = 44;

@interface WhiteRoomViewController ()<WhiteRoomCallbackDelegate,WhiteCommonCallbackDelegate, UIPopoverPresentationControllerDelegate,AgoraRtcEngineDelegate,AgoraRtmDelegate,RPBroadcastActivityViewControllerDelegate>{
    NSDictionary *_userInfo;//存用户个人信息
}
@property (nonatomic, strong) WhiteSDK *sdk;
@property (nonatomic, assign, getter=isReconnecting) BOOL reconnecting;
@property (nonatomic, strong) ToolSelectView *toolSelectView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

//观众相关,分页
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, strong) NSMutableArray *stuList;


//视频相关
@property (nonatomic, strong) LiveTableView *liveTableView;
@property (strong, nonatomic) UIView *broadcastButton;
@property (strong, nonatomic) UIButton *audioMuteButton;
@property (nonatomic, strong) UIButton *switchCameraButton;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *handButton;
@property (nonatomic, strong) UIButton *chatButton;//右上角聊天
@property (nonatomic, strong) UIButton *peerButton;//右上角人员按钮

@property (strong, nonatomic) AgoraRtcEngineKit *rtcEngine;

@property (strong, nonatomic) NSMutableArray<VideoSession *> *videoSessions;
@property (strong, nonatomic) VideoSession *fullSession;

//判断项
@property (nonatomic, assign) AgoraClientRole isTeacher;//是否是老师，用于辨别唯一
@property (assign, nonatomic) BOOL isBroadcaster;//是否主播模式
@property (assign, nonatomic) BOOL isAudio;//语音是否开启
@property (assign, nonatomic) BOOL isVideo;//视频是否开启
@property (assign, nonatomic) BOOL isPencil;//是否允许手写
@property (assign, nonatomic) BOOL isChat;//是否打开聊天框
@property (assign, nonatomic) BOOL isHand;//是否举手，举手状态下不可继续举手

@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) RightView *rightView;
@property (nonatomic, strong) UIView *maskView;

//录屏相关
@property (weak, nonatomic) RPBroadcastActivityViewController *broadcastActivityVC;
@property (weak, nonatomic) RPBroadcastController *broadcastController;
@property (strong, nonatomic) UIView *cameraPreview;
@property (strong, nonatomic) VideoViewLayouter *viewLayouter;

@end
@implementation WhiteRoomViewController

static NSString * const kCustomEvent = @"custom";

static NSInteger streamID = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BG_COLOR;
    self.isTeacher = self.clientRole;
    [self loadChannelAllUser];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).allowRotation = YES;
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    // 存储数据 供group中 使用
    [[[NSUserDefaults alloc] initWithSuiteName:@"group.JJWhiteDemo"] setValue:@{@"uid":[UserDefaultsUtils valueWithKey:@"uid"],@"channelName":_roomName} forKey:@"shareData"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).allowRotation = NO;
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
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
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.left.right.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-150);
    }];
    
    self.cameraPreview = [[UIView alloc] init];
    self.cameraPreview.hidden = YES;
    [self.boardView addSubview:_cameraPreview];
    [self.cameraPreview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.left.right.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-150);
    }];
    
    //peerButton 只有主播模式可以看到
    if (_isTeacher == AgoraClientRoleBroadcaster) {
        //右上角chat
        _chatButton = [[UIButton alloc] init];
        [_chatButton setImage:[UIImage imageNamed:@"btn_chat"] forState:UIControlStateNormal];
        [_chatButton addTarget:self action:@selector(doChatPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_chatButton setBackgroundColor:[UIColor whiteColor]];
        _chatButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_chatButton];
        [self.chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.right.equalTo(self.view).offset(0);
            make.width.offset(75);
            make.height.offset(50);
        }];
        
        _peerButton = [[UIButton alloc] init];
        [_peerButton setImage:[UIImage imageNamed:@"btn_student"] forState:UIControlStateNormal];
        [_peerButton addTarget:self action:@selector(doPeerPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_peerButton setBackgroundColor:[UIColor whiteColor]];
        _peerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_peerButton];
        [self.peerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.right.equalTo(self.chatButton.mas_left).offset(0);
            make.left.equalTo(self.boardView.mas_right).offset(0);
            make.height.offset(50);
        }];
    }
    
    self.liveTableView = [[NSBundle mainBundle] loadNibNamed:@"LiveTableView" owner:nil options:nil][0];
    //传入teacherid
    self.liveTableView.teacherId = self.mode.peerId;
    [self.view addSubview:_liveTableView];
    [_liveTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.isTeacher == AgoraClientRoleBroadcaster) {
            make.top.equalTo(self.chatButton.mas_bottom).offset(0);
        }else {
            make.top.equalTo(self.mas_topLayoutGuideBottom).offset(0);
        }
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.right.equalTo(self.view).offset(0);
        make.left.equalTo(self.boardView.mas_right).offset(0);
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
    
    CGFloat width = (_isTeacher == AgoraClientRoleBroadcaster)?btnH:0;
    if (@available(iOS 12.0, *)) {
        RPSystemBroadcastPickerView *systemBroadcastPicker = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(2, SCREEN_WIDTH-btnH-2, width, width)];
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"JJWhiteDemoBroadcast" withExtension:@"appex" subdirectory:@"PlugIns"];
        if (url) {
            NSBundle *bundle = [NSBundle bundleWithURL:url];
            if (bundle) {
                systemBroadcastPicker.preferredExtension = bundle.bundleIdentifier;
            }
        }
        self.broadcastButton = systemBroadcastPicker;
    } else {
        UIButton *appBroadcastButton = [[UIButton alloc] initWithFrame:CGRectMake(2, SCREEN_WIDTH-btnH-2, width, width)];
        [appBroadcastButton setImage:[UIImage imageNamed:@"btn_join"] forState:UIControlStateNormal];
        [appBroadcastButton addTarget:self action:@selector(doBroadcastPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.broadcastButton = appBroadcastButton;
    }
    [self.boardView addSubview:self.broadcastButton];
    
    //switchCameraButton
    _switchCameraButton = [[UIButton alloc] init];
    [_switchCameraButton setImage:[UIImage imageNamed:@"btn_overturn"] forState:UIControlStateNormal];
    [_switchCameraButton addTarget:self action:@selector(doSwitchCameraPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.boardView addSubview:_switchCameraButton];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-2);
        make.left.equalTo(self.broadcastButton.mas_right).offset(2);
        make.width.height.offset(btnH);
    }];
    
    //按钮加载boardView上
    _audioMuteButton = [[UIButton alloc] init];
    [_audioMuteButton setImage:[UIImage imageNamed:@"btn_mute"] forState:UIControlStateNormal];
    [_audioMuteButton addTarget:self action:@selector(doMutePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.boardView addSubview:_audioMuteButton];
    [self.audioMuteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-2);
        make.left.equalTo(self.switchCameraButton.mas_right).offset(2);
        make.width.height.offset(btnH);
    }];
    
    //videoButton  听众不显示开关摄像头按钮
    if (_isTeacher == AgoraClientRoleBroadcaster) {
        _videoButton = [[UIButton alloc] init];
        [_videoButton setImage:[UIImage imageNamed:@"btn_video_on"] forState:UIControlStateNormal];
        [_videoButton addTarget:self action:@selector(doVideoPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.boardView addSubview:_videoButton];
        [self.videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-2);
            make.left.equalTo(self.audioMuteButton.mas_right).offset(2);
            make.width.height.offset(btnH);
        }];
    }
    
    
    //只有观众模式才有举手按钮以及消息输入框
    if (_isTeacher == AgoraClientRoleAudience) {
        //handButton
        _handButton = [[UIButton alloc] init];
        [_handButton setImage:[UIImage imageNamed:@"btn_hand"] forState:UIControlStateNormal];
        [_handButton addTarget:self action:@selector(doHandPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.boardView addSubview:_handButton];
        [self.handButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-2);
            make.right.equalTo(self.boardView).offset(-2);
            make.width.height.offset(btnH);
        }];
    }
    
    _maskView = [[UIView alloc] init];
    [_maskView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    _maskView.alpha = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideRightView:)];
    [_maskView addGestureRecognizer:tap];
    [self.view addSubview:_maskView];
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
    }];
    
    
    _rightView = [[NSBundle mainBundle] loadNibNamed:@"RightView" owner:nil options:nil][0];
    [self.view addSubview:_rightView];
    _rightView.refreshBlock = ^(RefreshType type) {
        [weakSelf loadAudienceList:type];
    };
    _rightView.audienceClickBlock = ^(NSDictionary * _Nonnull stuInfo) {
        [weakSelf optionWithAudienceId:[stuInfo[@"id"] integerValue]];
    };
    [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.left.equalTo(self.view.mas_right).offset(0);
        make.width.height.offset(200);
    }];
    [self.view bringSubviewToFront:_progressHUD];
    
    [self.view layoutIfNeeded];
    //layoutIfNeeded 之后再给size赋值
    self.toolSelectView.superViewSize = self.boardView.bounds.size;
    
}

- (void)optionWithAudienceId:(NSInteger)uid {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    alertVC.popoverPresentationController.sourceView = _rightView;
    alertVC.popoverPresentationController.sourceRect = _rightView.bounds;
    [alertVC addAction:[UIAlertAction actionWithTitle:@"发言" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //点击发言后，隐藏侧边栏
        [self hideRightView:nil];
        SendMessageModel *msgModel = [[SendMessageModel alloc] init];
        msgModel.type = MessageTypeOnSpeak;
        msgModel.fromUser = [[UserDefaultsUtils valueWithKey:@"uid"] integerValue];
        msgModel.toUser = uid;
        msgModel.msg = @"拉上麦序";
        msgModel.time = [AppUtils getCurrentTimes];
        [self sendMessageWithPeer:[NSString stringWithFormat:@"%ld",(long)uid] model:msgModel];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)loadAudienceList:(RefreshType)type {
    _pageSize = 15;
    if (type == RefreshTypeRefresh) {
        _page = 1;
    }
    [HandlerBusiness JJGetServiceWithApicode:ApiCodeGetChannelUser Parameters:@{@"cname":self.roomName,@"page":@(_page),@"pageSize":@(_pageSize)} Success:^(id data, id msg) {
        NSArray *arr = data[@"Data"];
        if (type == RefreshTypeRefresh) {
            self.stuList = [arr mutableCopy];
            [self.rightView.tableView.mj_header endRefreshing];
            if ([data[@"LastPage"] boolValue] == YES) {
                [self.rightView.tableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                [self.rightView.tableView.mj_footer resetNoMoreData];
                self.page ++;
            }
        }else {
            if ([data[@"LastPage"] boolValue] == YES) {
                [self.rightView.tableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                self.page ++;
                [self.rightView.tableView reloadData];
                [self.rightView.tableView.mj_footer endRefreshing];
            }
            [self.stuList addObjectsFromArray:arr];
        }
        self.rightView.stuList = self.stuList;
        DBG(@"%@", data);
    } Failed:^(NSString *error, NSString *errorDescription) {
        //下拉刷新，判断没有学生的时候清空数组
        if (type == RefreshTypeRefresh && [error isEqualToString:@"没有学生信息了！"]) {
            self.stuList = [@[] mutableCopy];
            self.rightView.stuList = self.stuList;
        }
        [self.rightView.tableView.mj_header endRefreshing];
        [self.rightView.tableView.mj_footer endRefreshingWithNoMoreData];
        DBG(@"ApiCodeGetChannelUser-----api fail %@",error);
    } Complete:^{
    }];
}

- (void)loadChannelAllUser {
    //获取频道User总数
    [HandlerBusiness JJGetServiceWithApicode:ApiCodeGetChannelAllUser Parameters:@{@"cname":self.roomName} Success:^(id data, id msg) {
        DBG(@"ApiCodeGetChannelAllUser-----%@", data);
        if (self.isTeacher == AgoraClientRoleAudience) {
            NSArray *broadcasters = data[@"broadcasters"];
            if (broadcasters.count == 0) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"老师不在线哦" preferredStyle:UIAlertControllerStyleAlert];
                [alertVC setDismissInterval:kTimeSpan complete:^{
                    [self leaveChannel];
                }];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        }
    } Failed:^(NSString *error, NSString *errorDescription) {
        DBG(@"ApiCodeGetChannelAllUser-----api fail %@",error);
    } Complete:^{
    }];
    
    if (_isTeacher == AgoraClientRoleAudience) {
        //获取个人信息
        [HandlerBusiness JJGetServiceWithApicode:ApiCodeGetUserById Parameters:@{@"userId": [UserDefaultsUtils valueWithKey:@"uid"]} Success:^(id data, id msg) {
            self->_userInfo = data;
            //获取到个人信息之后在执行房间内的操作
            [self whiteSDK];
            [self prepareView];
            self.videoSessions = [[NSMutableArray alloc] init];
            [self loadAgoraKit];
            //RTM 相关
            [AgoraRtm updateDelegate:self];
            [self addNotificationObserver];
            DBG(@"ApiCodeGetUserById-----%@", data);
        } Failed:^(NSString *error, NSString *errorDescription) {
            DBG(@"ApiCodeGetUserById-----api fail %@",error);
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"接口调用失败" preferredStyle:UIAlertControllerStyleAlert];
            [alertVC setDismissInterval:kTimeSpan complete:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [self presentViewController:alertVC animated:YES completion:nil];
        } Complete:^{
            
        }];
    }else {
        [HandlerBusiness JJGetServiceWithApicode:ApiCodeGetTeacherById Parameters:@{@"teacherId": [UserDefaultsUtils valueWithKey:@"uid"]} Success:^(id data, id msg) {
            DBG(@"ApiCodeGetTeacherById-----%@", data);
            self->_userInfo = data;
            //获取到个人信息之后在执行房间内的操作
            [self whiteSDK];
            [self prepareView];
            self.videoSessions = [[NSMutableArray alloc] init];
            [self loadAgoraKit];
            //RTM 相关
            [AgoraRtm updateDelegate:self];
            [self addNotificationObserver];
        } Failed:^(NSString *error, NSString *errorDescription) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"接口调用失败" preferredStyle:UIAlertControllerStyleAlert];
            [alertVC setDismissInterval:kTimeSpan complete:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [self presentViewController:alertVC animated:YES completion:nil];
        } Complete:^{
            
        }];
    }
    
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
        //学生身份开关麦克风，发消息给老师
        if (self.isTeacher == AgoraClientRoleAudience) {
            SendMessageModel *model = [[SendMessageModel alloc] init];
            model.type = isAudio ? MessageTypeCloseAudio : MessageTypeOpenAudio;
            model.fromUser = [[UserDefaultsUtils valueWithKey:@"uid"] integerValue];
            model.toUser = self.mode.peerId;
            model.msg = isAudio ? @"关闭麦克风" : @"打开麦克风";
            model.time = [AppUtils getCurrentTimes];
            [self sendMessageWithPeer:[NSString stringWithFormat:@"%ld",(long)self.mode.peerId] model:model];
        }
    });
}

- (void)setIsPencil:(BOOL)isPencil {
    _isPencil = isPencil;
    //老师则设置白板模式
    if (self.isTeacher == AgoraClientRoleBroadcaster) {
        [self.room setViewMode:isPencil ? WhiteViewModeFollower : WhiteViewModeBroadcaster];
    }
    [self.room disableOperations:isPencil];
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        //回调或者说是通知主线程刷新，
        //学生身份开关麦克风，发消息给老师
        if (self.isTeacher == AgoraClientRoleAudience) {
            SendMessageModel *model = [[SendMessageModel alloc] init];
            model.type = isPencil ? MessageTypeClosePencil : MessageTypeOpenPencil;
            model.fromUser = [[UserDefaultsUtils valueWithKey:@"uid"] integerValue];
            model.toUser = self.mode.peerId;
            model.msg = isPencil ? @"关闭手写笔" : @"打开手写笔";
            model.time = [AppUtils getCurrentTimes];
            [self sendMessageWithPeer:[NSString stringWithFormat:@"%ld",(long)self.mode.peerId] model:model];
        }
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

- (void)setIsHand:(BOOL)isHand {
    _isHand = isHand;
    //举手
    if (isHand == YES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.handButton setImage:[UIImage imageNamed:@"btn_hand_on"] forState:UIControlStateNormal];
        });
        //变为举手状态，举手状态不可重复举手，只有老师端已读才可继续举手
        SendMessageModel *model = [[SendMessageModel alloc] init];
        model.type = MessageTypeHand;
        model.fromUser = [[UserDefaultsUtils valueWithKey:@"uid"] integerValue];
        model.toUser = self.mode.peerId;
        model.msg = @"举手";
        model.time = [AppUtils getCurrentTimes];
        [self sendMessageWithPeer:[NSString stringWithFormat:@"%ld",(long)self.mode.peerId] model:model];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.handButton setImage:[UIImage imageNamed:@"btn_hand"] forState:UIControlStateNormal];
        });
    }
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

- (VideoViewLayouter *)viewLayouter {
    if (!_viewLayouter) {
        _viewLayouter = [[VideoViewLayouter alloc] init];
    }
    return _viewLayouter;
}

- (void)cancel {
    [self leaveChannel];
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


#pragma mark - Room Action

- (void)whiteSDK {
    NSString *sdkToken = [WhiteUtils sdkToken];
    
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
}

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
    
    [self joinRoomWithToken:self.roomToken];
    
    
    
//    [WhiteUtils getRoomTokenWithUuid:self.roomUuid Result:^(BOOL success, id response, NSError *error) {
//        if (success) {
//            NSString *roomToken = response[@"msg"][@"roomToken"];
//            [self joinRoomWithToken:roomToken];
//        } else {
//            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"加入房间失败", nil) message:[NSString stringWithFormat:@"服务器信息:%@，系统错误信息:%@", [error localizedDescription], [response description]] preferredStyle:UIAlertControllerStyleAlert];
//            alertVC.popoverPresentationController.sourceView = self.view;
//            alertVC.popoverPresentationController.sourceRect = self.view.bounds;
//            UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                [self.navigationController popViewControllerAnimated:YES];
//            }];
//            [alertVC addAction:action];
//            [self presentViewController:alertVC animated:YES completion:nil];
//        }
//    }];
}

- (void)joinRoomWithToken:(NSString *)roomToken
{
//    self.title = NSLocalizedString(@"正在连接房间", nil);
    self.progressHUD.label.text = @"正在连接房间";
    WhiteSdkConfiguration *config = [WhiteSdkConfiguration defaultConfig];
    
    //如果不需要拦截图片API，则不需要开启，页面内容较为复杂时，可能会有性能问题
    config.enableInterrupterAPI = NO;
    config.debug = YES;
    //sdk 2.0.2 新增
    config.userCursor = YES;
    
    
    [self prepareWhiteView];
    [self updateButtonsVisiablity];
    
    WhiteMemberInformation *memberInfo = [[WhiteMemberInformation alloc] initWithUserId:[UserDefaultsUtils valueWithKey:@"uid"] name:_userInfo[@"weixinName"] avatar:_userInfo[@"avatar"]];
    
    self.sdk = [[WhiteSDK alloc] initWithWhiteBoardView:self.boardView config:config commonCallbackDelegate:self.commonDelegate];
    
    WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:self.roomUuid roomToken:roomToken memberInfo:memberInfo];
    
    [self.sdk joinRoomWithConfig:roomConfig callbacks:self.roomCallbackDelegate completionHandler:^(BOOL success, WhiteRoom * _Nullable room, NSError * _Nullable error) {
        if (success) {
            
            [self.progressHUD removeFromSuperview];
            self.progressHUD = nil;
            
            self.roomToken = roomToken;
            self.room = room;
            [self.room addMagixEventListener:@"CommandCustomEvent"];
            [self roleSettings];
            [self toolInit];
            
            if (self.roomBlock) {
                self.roomBlock(self.room, nil);
            }
        } else if (self.roomBlock) {
            self.roomBlock(nil, error);
            [self.progressHUD removeFromSuperview];
        } else {
            self.title = NSLocalizedString(@"加入失败", nil);
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"加入房间失败", nil) message:[NSString stringWithFormat:@"错误信息:%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
            alertVC.popoverPresentationController.sourceView = self.view;
            alertVC.popoverPresentationController.sourceRect = self.view.bounds;
            UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self leaveChannel];
                
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

//拦截图片，替换成返回值的方法（未使用）
- (NSString *)urlInterrupter:(NSString *)url
{
    return @"https://white-pan-cn.oss-cn-hangzhou.aliyuncs.com/124/image/image.png";
}

#pragma mark -  视频直播

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
            [self setAlert:[NSString stringWithFormat:@"Join channel failed: %d", code]];
        });
    }
    if (_isTeacher == AgoraClientRoleBroadcaster) {
        _rightView.tableType = 2;//默认设置为2
        //获取观众列表
        [self loadAudienceList:RefreshTypeRefresh];
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

- (void)updateButtonsVisiablity {
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 12.0, *)) {
        }else {
            [(UIButton *)self.broadcastButton setImage:[UIImage imageNamed:self.isBroadcaster ? @"btn_join_cancel" : @"btn_join"] forState:UIControlStateNormal];
        }
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
    
    //关闭录屏
    [self stopReplayKitBroadcasting];
    
    //向extension发送消息
    CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter ();
    CFNotificationCenterPostNotification(notification, CFSTR("cn.com.mude.JJWhiteDemo.StopScreen"), NULL,NULL, YES);
    //TODO 向所有人发送关闭直播间的信息
    
}

- (void)setIdleTimerActive:(BOOL)active {
    [UIApplication sharedApplication].idleTimerDisabled = !active;
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
    NSMutableArray *sessions = [[NSMutableArray alloc] init];
    BOOL isScreen = NO;
    for (VideoSession *session in displaySessions) {
        if (session.uid == _mode.peerId + 10000) {
            //学生角色需要显示录屏直播
            if (_isTeacher == AgoraClientRoleAudience) {
                //录屏直播单独处理，mode
                session.canvas.renderMode = AgoraVideoRenderModeFit;
                //录屏直播不需要镜像
                [self.rtcEngine setLocalVideoMirrorMode:AgoraVideoMirrorModeDisabled];
                [self.rtcEngine setParameters:@"{\"che.video.enableRemoteViewMirror\":false}"];
                isScreen = YES;
                [self.viewLayouter layoutSessions:@[session] fullSession:session inContainer:self.cameraPreview];
                self.cameraPreview.hidden = NO;
            }
        }else {
            //摄像头需要打开镜像模式
            [self.rtcEngine setLocalVideoMirrorMode:AgoraVideoMirrorModeEnabled];
            [self.rtcEngine setParameters:@"{\"che.video.enableRemoteViewMirror\":true}"];
            [sessions addObject:session];
        }
    }
    //如果没有录屏直播的session，则隐藏cameraPreview
    if (isScreen == NO) {
        self.cameraPreview.hidden = YES;
    }
    
    self.liveTableView.sessions = sessions;
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
        self.isPencil = NO;
    }else {
        self.isPencil = YES;
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

#pragma mark ---按钮点击事件
//点击事件
- (void)doBroadcastPressed:(UIButton *)sender {
    if (_isTeacher == AgoraClientRoleBroadcaster) {
        if (self.isBroadcaster) {
            [self startReplayKitBroadcasting];
        } else {
            [self stopReplayKitBroadcasting];
        }
    }
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

//学生举手按钮点击事件
- (void)doHandPressed:(UIButton *)sender {
    if (!_isHand) {
        self.isHand = YES;
    }
}

- (void)doChatPressed:(UIButton *)sender {
    NSLog(@"chat click");
    _isChat = YES;//设置为聊天
    _rightView.tableType = 1;//消息列表
    
    //消息标记为已读
    for (Message *msg in self.list) {
        //发送消息高速举手用户消息已读
        if (msg.status == MessageReadStatusUnread) {
            msg.status = MessageReadStatusRead;
            SendMessageModel *model = [[SendMessageModel alloc] init];
            model.type = MessageTypeRead;
            model.fromUser = [[UserDefaultsUtils valueWithKey:@"uid"] integerValue];
            model.toUser = [msg.userId integerValue];
            model.msg = @"消息已读";
            model.time = [AppUtils getCurrentTimes];
            [self sendMessageWithPeer:[NSString stringWithFormat:@"%@",msg.userId] model:model];
        }
    }
    self.rightView.msgList = [_list mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatButton setImage:[UIImage imageNamed:@"btn_chat"] forState:UIControlStateNormal];
    });
    [UIView animateWithDuration:0.2f animations:^{
        [self.rightView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_right).offset(-200);
        }];
        self.maskView.alpha = 1.f;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)doPeerPressed:(UIButton *)sender {
    NSLog(@"Peer click");
    _rightView.tableType = 2;//观众列表
    [UIView animateWithDuration:0.2f animations:^{
        [self.rightView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_right).offset(-200);
        }];
        self.maskView.alpha = 1.f;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideRightView:(id)sender {
    _isChat = NO;//设置为非聊天
    NSLog(@"hide view");
    [UIView animateWithDuration:0.2f animations:^{
        [self.rightView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_right).offset(0);
        }];
        self.maskView.alpha = 0.f;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -RTM 相关
- (void)setMode:(ChatMode)mode {
    _mode = mode;
}

- (NSMutableArray *)list {
    if (!_list) {
        _list = [NSMutableArray array];
    }
    return _list;
}

//所有消息，包括发出去跟接收到的
- (void)appendMsg:(NSString *)text user:(NSString *)user {
    Message *msg = [[Message alloc] init];
    msg.userId = user;
    msg.text = text;
    SendMessageModel *model = [SendMessageModel yy_modelWithJSON:text];
    //部分信息需要显示在聊天屏上 TODO
    //暂时只显示举手信息
    if (model.type == MessageTypeHand) {
        if ([user integerValue] != [[UserDefaultsUtils valueWithKey:@"uid"] integerValue]) {
            if (_isChat == NO) {
                msg.status = MessageReadStatusUnread;//标记为未读
                //通知主线程刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.chatButton setImage:[UIImage imageNamed:@"btn_chat_new"] forState:UIControlStateNormal];
                });
                
            }else {
                msg.status = MessageReadStatusRead;//标记为已读
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.chatButton setImage:[UIImage imageNamed:@"btn_chat"] forState:UIControlStateNormal];
                });
            }
        }
        [self.list addObject:msg];
        self.rightView.msgList = [self.list mutableCopy];
    }
//    if (model.type == MessageTypeOnSpeak || model.type == MessageTypeOffSpeak
//        || model.type == MessageTypeHand || model.type == MessageTypeMessage
//        || ((model.type == MessageTypeCloseAudio || model.type == MessageTypeOpenAudio
//        || model.type == MessageTypeClosePencil || model.type == MessageTypeOpenPencil) && model.toUser != self.mode.peerId)) {
//
//    }
}

- (BOOL)pressedReturnToSendText:(NSString *)text {
    if (!text || text.length == 0) {
        return NO;
    }
    NSString *name = [NSString stringWithFormat:@"%ld",(long)self.mode.peerId];
    [self sendPeer:name msg:text];
    return YES;
}

- (void)addNotificationObserver {
    //注册按钮点击通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoButtonClick:) name:@"videoButtonClick" object:nil];
}

//接收按钮点击通知
- (void)videoButtonClick:(NSNotification *)noti{
    SendMessageModel *model = [[SendMessageModel alloc] init];
    model.fromUser = [[UserDefaultsUtils valueWithKey:@"uid"] integerValue];
    model.toUser = [[noti object][@"uid"] integerValue];
    model.time = [AppUtils getCurrentTimes];
    model.type = [[noti object][@"messageType"] integerValue];
    model.msg = [noti object][@"msg"];
    [self sendMessageWithPeer:[NSString stringWithFormat:@"%@",[noti object][@"uid"]] model:model];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Peer
//输入框发送文本信息
- (void)sendPeer:(NSString *)peer msg: (NSString *)msg {
    SendMessageModel *model = [[SendMessageModel alloc] init];
    model.type = MessageTypeMessage;
    model.fromUser = [[UserDefaultsUtils valueWithKey:@"uid"] integerValue];
    model.toUser = [peer integerValue];
    model.msg = msg;
    model.time = [AppUtils getCurrentTimes];
    [self sendMessageWithPeer:peer model:model];
}

- (void)sendMessageWithPeer:(NSString *)peer model:(SendMessageModel *)model {
    NSString *dataStr = [model yy_modelToJSONString];
    AgoraRtmMessage *message = [[AgoraRtmMessage alloc] initWithText:dataStr];
    __weak WhiteRoomViewController *weakSelf = self;
    [AgoraRtm.kit sendMessage:message toPeer:peer completion:^(AgoraRtmSendPeerMessageState state) {
        NSLog(@"send peer msg error: %ld", (long)state);
        [weakSelf appendMsg:dataStr user:AgoraRtm.current];
    }];
}

#pragma mark - AgoraRtmDelegate
- (void)rtmKit:(AgoraRtmKit *)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    NSLog(@"connection state changed: %ld", (long)reason);
}

- (void)rtmKit:(AgoraRtmKit *)kit messageReceived:(AgoraRtmMessage *)message fromPeer:(NSString *)peerId {
    [self appendMsg:message.text user:peerId];
    SendMessageModel *model = [SendMessageModel yy_modelWithJSON:message.text];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self messageEventWithMessageType:model];
    });
}

//对收到的消息进行处理
- (void)messageEventWithMessageType:(SendMessageModel *)model {
    NSInteger type = model.type;
    //学生收到消息处理消息
    if (self.isTeacher == AgoraClientRoleAudience) {
        //收到消息后，反向发送通知
        if (type == MessageTypeClosePencil || type == MessageTypeCloseAudio
            || type == MessageTypeOpenPencil || type == MessageTypeCloseAudio) {
            NSDictionary *dic = @{@"messageType": @(type)};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"audioMsgSuccess" object:dic];
        }
        switch (type) {
            case MessageTypeHand:
                DBG(@"*****举手*****");
                break;
            case MessageTypeCloseAudio:
                self.isAudio = YES;
                DBG(@"*****关闭麦克风*****");
                break;
            case MessageTypeOpenAudio:
                self.isAudio = NO;
                DBG(@"*****打开麦克风*****");
                break;
            case MessageTypeClosePencil:
                self.isPencil = YES;
                DBG(@"*****关闭手写笔*****");
                break;
            case MessageTypeOpenPencil:
                self.isPencil = NO;
                DBG(@"*****打开手写笔*****");
                break;
            case MessageTypeMessage:
                DBG(@"*****课程内信息*****");
                break;
            case MessageTypeOnSpeak:
                self.clientRole = AgoraClientRoleBroadcaster;
                self.isAudio = NO;
                self.isVideo = NO;
                self.isPencil = NO;
                self.handButton.hidden = YES;
                [self.rtcEngine setClientRole:self.clientRole];
                [self updateInterfaceWithAnimation:YES];
                DBG(@"*****拉上麦序*****");
                break;
            case MessageTypeOffSpeak:
                self.clientRole = AgoraClientRoleAudience;
                self.isPencil = YES;
                self.handButton.hidden = NO;
                if (self.fullSession.uid == 0) {
                    self.fullSession = nil;
                }
                [self.rtcEngine setClientRole:self.clientRole];
                [self updateInterfaceWithAnimation:YES];
                DBG(@"*****踢出麦序*****");
                break;
            case MessageTypeOver:
                [self setAlert:@"课程结束"];
                DBG(@"*****课程结束*****");
                break;
            case MessageTypeRead:
                //消息已读，取消举手状态
                self.isHand = NO;
                break;
            default:
                break;
        }
    }else {
        //TODO 老师端收到消息的处理
        switch (type) {
            case MessageTypeHand:
            {
                [self.view makeToast:[NSString stringWithFormat:@"%ld举手了",(long)model.fromUser]];
                break;
            }
            case MessageTypeCloseAudio:
            case MessageTypeOpenAudio:
            case MessageTypeOpenPencil:
            case MessageTypeClosePencil:
                //收到开关麦克风的消息后，发送消息
            {
                NSDictionary *dic = @{@"messageType": @(type)};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"audioMsgSuccess" object:dic];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark  录屏相关
- (void)startReplayKitBroadcasting {
    if (![RPScreenRecorder sharedRecorder].isAvailable) {
        return;
    }
    [RPScreenRecorder sharedRecorder].cameraEnabled = YES;
    [RPScreenRecorder sharedRecorder].microphoneEnabled = YES;
    
    NSString *bundleID = @"";
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"JJWhiteDemoBroadcastSetupUI" withExtension:@"appex" subdirectory:@"PlugIns"];
    if (url) {
        NSBundle *bundle = [NSBundle bundleWithURL:url];
        if (bundle) {
            bundleID = bundle.bundleIdentifier;
        }
    }
    if (@available(iOS 11.0, *)) {
        [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithPreferredExtension:bundleID handler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
            [self presentBroadcastActivityVC:broadcastActivityViewController];
        }];
    } else {
        // Fallback on earlier versions
        [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
            [self presentBroadcastActivityVC:broadcastActivityViewController];
        }];
    }
    
}

- (void)presentBroadcastActivityVC:(RPBroadcastActivityViewController *)broadcastActivityVC{
    if (!broadcastActivityVC) {
        return;
    }
    broadcastActivityVC.delegate = self;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        broadcastActivityVC.modalPresentationStyle = UIModalPresentationPopover;
        broadcastActivityVC.popoverPresentationController.sourceView = _broadcastButton;
        broadcastActivityVC.popoverPresentationController.sourceRect = _broadcastButton.frame;
        broadcastActivityVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    }
    [self presentViewController:broadcastActivityVC animated:YES completion:nil];
    self.broadcastActivityVC = broadcastActivityVC;
}

- (void)stopReplayKitBroadcasting {
    if (_broadcastController) {
        [_broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
        }];
    }
}

- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(RPBroadcastController *)broadcastController error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        RPBroadcastActivityViewController *broadcastActivityVC = self.broadcastActivityVC;
        if (broadcastActivityVC) {
            [broadcastActivityVC dismissViewControllerAnimated:YES completion:nil];
        }
        self.broadcastController = broadcastController;
        if (broadcastController) {
            [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"startBroadcastWithHandler error:%@",error.localizedDescription);
                }else {
                }
            }];
        }
    });
}


@end
