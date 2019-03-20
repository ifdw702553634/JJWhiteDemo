//
//  LiveTableViewCell.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/15.
//  Copyright © 2019 mude. All rights reserved.
//

#import "LiveTableViewCell.h"
#import "AgoraSignal.h"

@implementation LiveTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _muteBtn.selected = NO;
    // Initialization code
}

- (void)setUid:(NSUInteger)uid {
    _uid = uid;
    if (_uid == 0 || _uid == [[[NSUserDefaults standardUserDefaults] stringForKey:@"uid"] integerValue]) {
        self.selfLabel.hidden = NO;
        self.muteBtn.hidden = YES;
        self.cancelBtn.hidden = YES;
        self.videoBtn.hidden = YES;
    }else {
        self.selfLabel.hidden = YES;
        self.muteBtn.hidden = NO;
        self.videoBtn.hidden = NO;
        self.cancelBtn.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)muteBtnClick:(UIButton *)sender {
    if (sender.tag == 1) {
        [[AgoraSignal sharedKit] messageInstantSend:[NSString stringWithFormat:@"%lu",_uid] uid:0 msg:@"cacnel" msgID:@""];
        [AgoraSignal sharedKit].onMessageSendError = ^(NSString *messageID, AgoraEcode ecode) {
            NSLog(@"Error code:%lu",(unsigned long)ecode);
        };
        [AgoraSignal sharedKit].onMessageSendSuccess = ^(NSString *messageID) {
            NSLog(@"---- Send Success ----");
        };
    }else if (sender.tag == 2) {
        NSString *msg = sender.isSelected? @"mute_off":@"mute_on";
        [[AgoraSignal sharedKit] messageInstantSend:[NSString stringWithFormat:@"%lu",_uid] uid:0 msg:msg msgID:@""];
        [AgoraSignal sharedKit].onMessageSendError = ^(NSString *messageID, AgoraEcode ecode) {
            NSLog(@"Error code:%lu",(unsigned long)ecode);
        };
        [AgoraSignal sharedKit].onMessageSendSuccess = ^(NSString *messageID) {
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                sender.selected = !sender.isSelected;
                //回调或者说是通知主线程刷新，
            });
        };
    }else if (sender.tag == 3) {
        NSString *msg = sender.isSelected? @"video_off":@"video_on";
        [[AgoraSignal sharedKit] messageInstantSend:[NSString stringWithFormat:@"%lu",_uid] uid:0 msg:msg msgID:@""];
        [AgoraSignal sharedKit].onMessageSendError = ^(NSString *messageID, AgoraEcode ecode) {
            NSLog(@"Error code:%lu",(unsigned long)ecode);
        };
        [AgoraSignal sharedKit].onMessageSendSuccess = ^(NSString *messageID) {
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                sender.selected = !sender.isSelected;
                //回调或者说是通知主线程刷新，
            });
        };
    }
}



@end
