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
#import "KeyCenter.h"

#import "AgoraRtm.h"

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
    [self logout];
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
            uid = @"261";
        }else if ([account isEqualToString:@"mude"]) {
            uid = @"262";
        }else {
            uid = @"1";
        }
        NSString *lastAccount = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
        if (![uid isEqualToString:lastAccount]) {
            [[NSUserDefaults standardUserDefaults] setValue:uid forKey:@"uid"];
        }
        [self loginWithUid:uid];
    }
}

- (void)loginWithUid:(NSString *)uid {
    
    [AgoraRtm setCurrent:uid];
    
    [AgoraRtm.kit loginByToken:nil user:uid completion:^(AgoraRtmLoginErrorCode errorCode) {
        if (errorCode != AgoraRtmLoginErrorOk) {
            return;
        }
        
        [AgoraRtm setStatus:LoginStatusOnline];
        
        __weak ViewController *weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            StartViewController *vc = [[StartViewController alloc] init];
            
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
    }];
}

- (void)logout {
    if (AgoraRtm.status == LoginStatusOffline) {
        return;
    }
    
    [AgoraRtm.kit logoutWithCompletion:^(AgoraRtmLogoutErrorCode errorCode) {
        if (errorCode != AgoraRtmLogoutErrorOk) {
            return;
        }
        
        [AgoraRtm setStatus:LoginStatusOffline];
    }];
}



- (BOOL)checkString:(NSString *)string {
    if (!string.length) {
        [self setAlert:@"The channel name is empty !"];
        return NO;
    }
    
    if (string.length > 128) {
        [self setAlert:@"The channel name is too long !"];
        return NO;
    }
    
    if ([string containsString:@" "]) {
        [self setAlert:@"The accout contains space !"];
        return NO;
    }
    
    return YES;
}

@end
