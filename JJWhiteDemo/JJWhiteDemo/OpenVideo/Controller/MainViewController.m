//
//  MainViewController.m
//  JJWhiteDemo
//
//  Created by JiaoJiao Network on 2019/3/9.
//  Copyright © 2019 mude. All rights reserved.
//

#import "MainViewController.h"
#import "SettingsViewController.h"
#import "RoomViewController.h"
#import "EncryptionType.h"

@interface MainViewController ()<SettingsVCDelegate, RoomVCDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *roomNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *encrypTextField;
@property (assign, nonatomic) CGSize dimension;
@property (assign, nonatomic) EncrypType encrypType;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"视频通话";
    
    self.dimension = AgoraVideoDimension640x360;
    self.encrypType = [[EncryptionType encrypTypeArray][0] intValue];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(pushToSetting:)];
    // Do any additional setup after loading the view from its nib.
}

- (void)pushToSetting:(id)sender {
    SettingsViewController *vc = [[SettingsViewController alloc] init];
    vc.dimension = self.dimension;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)doJoinPressed:(id)sender {
    [self.view endEditing:YES];
    [self enterRoom];
}
- (IBAction)doEncrypPressed:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *encrypTypeArray = [EncryptionType encrypTypeArray];
    __weak typeof(self) weakself = self;
    
    for (int i = 0; i < encrypTypeArray.count; i++) {
        EncrypType type = [encrypTypeArray[i] intValue];
        UIAlertAction *action = [UIAlertAction actionWithTitle:[EncryptionType descriptionWithEncrypType:type] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakself.encrypType = type;
            [sender setTitle:[EncryptionType descriptionWithEncrypType:type] forState:UIControlStateNormal];
        }];
        [alertController addAction:action];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)enterRoom {
    if (!self.roomNameTextField.text.length) {
        return;
    }
    RoomViewController *vc = [[RoomViewController alloc] init];
    vc.roomName = self.roomNameTextField.text;
    vc.dimension = self.dimension;
    vc.encrypType = self.encrypType;
    vc.encrypSecret = self.encrypTextField.text;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

//MARK: - delegates
- (void)settingsVC:(SettingsViewController *)settingsVC didSelectDimension:(CGSize)dimension {
    self.dimension = dimension;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)roomVCNeedClose:(RoomViewController *)roomVC {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self enterRoom];
    return YES;
}

@end
