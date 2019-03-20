//
//  StartViewController.m
//  WhiteDemo
//
//  Created by mude on 2019/3/8.
//  Copyright © 2019 mude. All rights reserved.
//

#import "StartViewController.h"
#import "WhiteRoomViewController.h"
#import "WhiteSettingViewController.h"
#import "WhitePlayerViewController.h"

//chat
#import "AgoraSignal.h"

#import "HandlerBusiness.h"
#import <MBProgressHUD.h>

@interface StartViewController ()<SettingsDelegate,LiveRoomDelegate>{
    
}
@property (assign, nonatomic) CGSize videoProfile;

@property (assign, nonatomic) AgoraClientRole clientRole;

@property (nonatomic, strong) NSDictionary *dataDic;
@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.videoProfile = AgoraVideoDimension640x480;
    
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionFillProportionally;
    stackView.alignment = UIStackViewAlignmentCenter;
    [self.view addSubview:stackView];
    
    stackView.frame = CGRectMake(0, 0, 300, 200);
    stackView.center = self.view.center;
    stackView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    UIButton *roomABtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [roomABtn setTitle:NSLocalizedString(@"房间id 2", nil) forState:UIControlStateNormal];
    [roomABtn addTarget:self action:@selector(joinRoom:) forControlEvents:UIControlEventTouchUpInside];
    roomABtn.tag = 2;
    [stackView addArrangedSubview:roomABtn];
    
    UIButton *roomBBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [roomBBtn setTitle:NSLocalizedString(@"房间id 3", nil) forState:UIControlStateNormal];
    [roomBBtn addTarget:self action:@selector(joinRoom:) forControlEvents:UIControlEventTouchUpInside];
    roomBBtn.tag = 3;
    [stackView addArrangedSubview:roomBBtn];
    
    
    for (UIView *view in stackView.arrangedSubviews) {
        [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(pushToSetting:)];
}

- (void)loadDataWithRoomId:(NSInteger)roomId {
    [MBProgressHUD showHUDAddedTo: self.view animated:YES];
    [HandlerBusiness JJGetServiceWithApicode:ApiCodeGetClassRoom Parameters:@{@"roomId":@(roomId)} Success:^(id data, id msg) {
        NSLog(@"%@", data);
        self.dataDic = data;
        if ([[data[@"teacher_id"] description] isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"uid"]]) {
            self.clientRole = AgoraClientRoleBroadcaster;
        }else {
            self.clientRole = AgoraClientRoleAudience;
        }
        [[AgoraSignal sharedKit] channelJoin:data[@"room_name"]];
    } Failed:^(NSString *error, NSString *errorDescription) {
        NSLog(@"Api Failed");
    } Complete:^{
        [MBProgressHUD hideHUDForView: self.view animated:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addAgoraSignalBlock];
}

- (void)addAgoraSignalBlock {
    __weak typeof(self) weakSelf = self;
    [AgoraSignal sharedKit].onChannelJoined = ^(NSString *channelID) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            WhiteRoomViewController *vc = [[WhiteRoomViewController alloc] init];
            vc.roomUuid = strongSelf.dataDic[@"white_room_uuid"];
            vc.clientRole = self.clientRole;
            vc.roomName = strongSelf.dataDic[@"room_name"];
            vc.roomToken = strongSelf.dataDic[@"white_room_token"];
            vc.videoProfile = strongSelf.videoProfile;
            vc.delegate = strongSelf;
            [strongSelf.navigationController pushViewController:vc animated:YES];
        });
    };
    [AgoraSignal sharedKit].onChannelJoinFailed = ^(NSString *channelID, AgoraEcode ecode) {
        [weakSelf alertString:[NSString stringWithFormat:@"Join channel failed with error: %lu", ecode]];
    };
}

- (BOOL)checkString:(NSString *)string {
    if (!string.length) {
        [self alertString:@"The channel name is empty !"];
        return NO;
    }
    
    if (string.length > 128) {
        [self alertString:@"The channel name is too long !"];
        return NO;
    }
    
    return YES;
}

- (void)alertString:(NSString *)string {
    if (!string.length) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [weakSelf presentViewController:alert animated:YES completion:nil];
    });
}

- (void)pushToSetting:(id)sender {
    
    WhiteSettingViewController *vc = [[WhiteSettingViewController alloc] init];
    vc.videoProfile = self.videoProfile;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - Button Action
- (void)joinRoom:(UIButton *)sender
{
    [self loadDataWithRoomId:sender.tag];
    
}

//- (void)createRoom:(UIButton *)sender
//{
//    WhiteRoomViewController *vc = [[WhiteRoomViewController alloc] init];
//    vc.clientRole = AgoraClientRoleBroadcaster;
//    vc.roomName = _liveName.text;
//    vc.videoProfile = self.videoProfile;
//    vc.delegate = self;
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (void)replayRoom:(UIButton *)sender
//{
//    WhitePlayerViewController *vc = [[WhitePlayerViewController alloc] init];
//    vc.roomUuid = [self.inputV.text length] > 0 ? self.inputV.text : @"1df260f6996948a2ab34fed4479610f0";
//    [self.navigationController pushViewController:vc animated:YES];
//}

#pragma mark - setting delegete
- (void)settingsVC:(WhiteSettingViewController *)settingsVC didSelectProfile:(CGSize)profile {
    self.videoProfile = profile;
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - live delegete
- (void)liveVCNeedClose:(WhiteRoomViewController *)liveVC {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
