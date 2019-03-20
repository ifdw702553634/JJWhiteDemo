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

@interface StartViewController ()<SettingsDelegate,LiveRoomDelegate>
@property (nonatomic, strong) UITextField *inputV;
@property (nonatomic, strong) UITextField *liveName;
@property (assign, nonatomic) CGSize videoProfile;

@property (assign, nonatomic) AgoraClientRole clientRole;
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
    
    _liveName = [[UITextField alloc] init];
    _liveName.enabled = YES;
    _liveName.placeholder = NSLocalizedString(@"输入房间名称，加入房间", nil);
    _liveName.text = @"test";
    _liveName.textAlignment = NSTextAlignmentCenter;
    [stackView addArrangedSubview:_liveName];
    
    UITextField *field = [[UITextField alloc] init];
    field.enabled = YES;
    field.placeholder = NSLocalizedString(@"输入房间ID，加入房间", nil);
    field.text = @"cb1d4a8d990c432ea814c110a8db1390";
    field.textAlignment = NSTextAlignmentCenter;
    [stackView addArrangedSubview:field];
    self.inputV = field;
    
    UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [joinBtn setTitle:NSLocalizedString(@"加入房间", nil) forState:UIControlStateNormal];
    [joinBtn addTarget:self action:@selector(joinRoom:) forControlEvents:UIControlEventTouchUpInside];
    [stackView addArrangedSubview:joinBtn];
    
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [createBtn setTitle:NSLocalizedString(@"创建新房间", nil) forState:UIControlStateNormal];
    [createBtn addTarget:self action:@selector(createRoom:) forControlEvents:UIControlEventTouchUpInside];
    [stackView addArrangedSubview:createBtn];
    
    createBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [createBtn setTitle:NSLocalizedString(@"回放房间", nil) forState:UIControlStateNormal];
    [createBtn addTarget:self action:@selector(replayRoom:) forControlEvents:UIControlEventTouchUpInside];
    [stackView addArrangedSubview:createBtn];
    
    for (UIView *view in stackView.arrangedSubviews) {
        [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeybroader:)];
    [self.view addGestureRecognizer:tap];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(pushToSetting:)];
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
            vc.roomUuid = strongSelf.inputV.text;
            vc.clientRole = self.clientRole;
            vc.roomName = strongSelf.liveName.text;
            vc.videoProfile = strongSelf.videoProfile;
            vc.delegate = strongSelf;
            vc.roomName = strongSelf.liveName.text;
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

- (void)dismissKeybroader:(id)sender
{
    [self.inputV resignFirstResponder];
}


#pragma mark - Button Action
- (void)joinRoom:(UIButton *)sender
{
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    sheet.popoverPresentationController.sourceView = sender;
    sheet.popoverPresentationController.sourceRect = sender.bounds;
    UIAlertAction *broadcaster = [UIAlertAction actionWithTitle:@"Broadcaster" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.clientRole = AgoraClientRoleBroadcaster;
        NSString *channelName = self.liveName.text;
        if (![self checkString:channelName]) {
            return;
        }
        [[AgoraSignal sharedKit] channelJoin:channelName];
        
        
    }];
    UIAlertAction *audience = [UIAlertAction actionWithTitle:@"Audience" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.clientRole = AgoraClientRoleAudience;
        NSString *channelName = self.liveName.text;
        if (![self checkString:channelName]) {
            return;
        }
        [[AgoraSignal sharedKit] channelJoin:channelName];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [sheet addAction:broadcaster];
    [sheet addAction:audience];
    [sheet addAction:cancel];
    [self presentViewController:sheet animated:YES completion:nil];
    
}

- (void)createRoom:(UIButton *)sender
{
    WhiteRoomViewController *vc = [[WhiteRoomViewController alloc] init];
    vc.clientRole = AgoraClientRoleBroadcaster;
    vc.roomName = _liveName.text;
    vc.videoProfile = self.videoProfile;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)replayRoom:(UIButton *)sender
{
    WhitePlayerViewController *vc = [[WhitePlayerViewController alloc] init];
    vc.roomUuid = [self.inputV.text length] > 0 ? self.inputV.text : @"1df260f6996948a2ab34fed4479610f0";
    [self.navigationController pushViewController:vc animated:YES];
}

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
