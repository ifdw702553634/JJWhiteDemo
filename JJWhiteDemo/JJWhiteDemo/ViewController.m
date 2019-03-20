//
//  ViewController.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/8.
//  Copyright © 2019 mude. All rights reserved.
//

#import "ViewController.h"
#import "StartViewController.h"
#import <Masonry/Masonry.h>
#import "AgoraSignal.h"
#import "LogWriter.h"
#import "Message.h"
#import "KeyCenter.h"
#import "UIColor+Extension.h"



@interface ViewController ()

@property (nonatomic, strong) UITextField *chatTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"White Demo";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _chatTextField = [[UITextField alloc] init];
    _chatTextField.enabled = YES;
    _chatTextField.placeholder = NSLocalizedString(@"输入登录账号", nil);
    _chatTextField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_chatTextField];
    [_chatTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.right.equalTo(self.view).offset(-50);
        make.left.equalTo(self.view).offset(50);
        make.height.offset(44);
    }];
    
    UIButton *whiteBtn = [[UIButton alloc] init];
    whiteBtn.tag = 1;
    [whiteBtn setTitle:@"点击进入白板" forState:UIControlStateNormal];
    [whiteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [whiteBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:whiteBtn];
    [whiteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chatTextField.mas_bottom).offset(20);
        make.right.equalTo(self.view).offset(-50);
        make.left.equalTo(self.view).offset(50);
        make.height.offset(44);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeybroader:)];
    [self.view addGestureRecognizer:tap];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addAgoraSignalBlock];
}

- (void)dismissKeybroader:(id)sender
{
    [_chatTextField resignFirstResponder];
}

- (void)btnClick:(UIButton *)sender {
    if (sender.tag == 1) {
        [_chatTextField resignFirstResponder];
        NSString *account = self.chatTextField.text;
        if (![self checkString:account]) {
            return;
        }
        NSString *uid = @"";
        //此处先设置假的uid
        if ([account isEqualToString:@"away"]) {
            uid = @"1";
        }else if ([account isEqualToString:@"mude"]) {
            uid = @"2";
        }else {
            uid = @"1";
        }
        [[AgoraSignal sharedKit] login2:[KeyCenter AppId] account:uid token:@"_no_need_token" uid:0 deviceID:nil retry_time_in_s:60 retry_count:5];
        NSString *lastAccount = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
        if (![uid isEqualToString:lastAccount]) {
            [[NSUserDefaults standardUserDefaults] setValue:uid forKey:@"uid"];
            [[MessageCenter sharedCenter].chatMessages removeAllObjects];
        }
        
        if ([[MessageCenter sharedCenter] userColor][uid] == nil) {
            [[MessageCenter sharedCenter] userColor][uid] = [UIColor randomColor];
        }
    }
}

- (void)addAgoraSignalBlock {
    __weak typeof(self) weakSelf = self;
    [AgoraSignal sharedKit].onLoginSuccess = ^(uint32_t uid, int fd) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            StartViewController *vc = [[StartViewController alloc] init];
            [strongSelf.navigationController pushViewController:vc animated:YES];
        });
    };
    
    [AgoraSignal sharedKit].onLoginFailed = ^(AgoraEcode ecode) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf alertString:[NSString stringWithFormat:@"Login failed with error: %lu", ecode]];
    };
    
    [AgoraSignal sharedKit].onLog = ^(NSString *txt) {
        if (!txt.length) {
            return;
        }
        
        [LogWriter writeLog:txt];
    };
    
    [AgoraSignal sharedKit].onMessageInstantReceive = ^(NSString *account, uint32_t uid, NSString *msg) {
        NSMutableDictionary *chatMessages = [MessageCenter sharedCenter].chatMessages;
        Message *message = [[Message alloc] initWithAccount:account message:msg];
        
        MessageList *messageList = chatMessages[account];
        if (!messageList) {
            chatMessages[account] = [[MessageList alloc] initWithIdentifier:account message:message];
        }
        
        [messageList.list addObject:message];
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
    
    if ([string containsString:@" "]) {
        [self alertString:@"The accout contains space !"];
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



@end
