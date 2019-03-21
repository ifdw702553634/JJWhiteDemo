//
//  BaseViewController.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/21.
//  Copyright © 2019 mude. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //if this is  NOT in navigation Stack
    if (self.navigationItem!=nil) {
        self.navigationItem.backBarButtonItem = [AppUtils navigationBackButtonWithNoTitle];
    }
    [self.view setBackgroundColor:BG_COLOR];
}

- (void)setAlert:(NSString *)msg
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:ALERT_TITLE message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertVC setDismissInterval:kTimeSpan];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
