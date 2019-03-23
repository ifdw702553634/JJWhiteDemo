//
//  LiveTableViewCell.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/15.
//  Copyright © 2019 mude. All rights reserved.
//

#import "LiveTableViewCell.h"

@implementation LiveTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _muteBtn.selected = NO;
    
    //注册按钮点击通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioMsgSuccess:) name:@"audioMsgSuccess" object:nil];
    // Initialization code
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)audioMsgSuccess:(NSNotification *)noti {
    NSInteger type = [[noti object][@"messageType"] integerValue];
    switch (type) {
        case MessageTypeOpenPencil:
            self.pencilBtn.selected = NO;
            break;
        case MessageTypeClosePencil:
            self.pencilBtn.selected = YES;
            break;
        case MessageTypeOpenAudio:
            self.muteBtn.selected = NO;
            break;
        case MessageTypeCloseAudio:
            self.muteBtn.selected = YES;
            break;
        default:
            break;
    }
}

- (void)setUid:(NSUInteger)uid {
    _uid = uid;
    if (_uid == 0 || _uid == [[UserDefaultsUtils valueWithKey:@"uid"] integerValue]) {
        self.selfLabel.text = @"自己";
        self.muteBtn.hidden = YES;
        self.cancelBtn.hidden = YES;
        self.pencilBtn.hidden = YES;
    }else {
        if ([[UserDefaultsUtils valueWithKey:@"uid"] integerValue] == _teacherId) {
            self.selfLabel.text = [NSString stringWithFormat:@"%ld",uid];
            [self.selfLabel setBackgroundColor:THEME_COLOR];
            self.muteBtn.hidden = NO;
            self.pencilBtn.hidden = NO;
            self.cancelBtn.hidden = NO;
        }else {
            if (_uid == _teacherId) {
                self.selfLabel.text = @"主播";
                [self.selfLabel setBackgroundColor:[UIColor redColor]];
            }else {
                self.selfLabel.text = [NSString stringWithFormat:@"%ld",uid];
                [self.selfLabel setBackgroundColor:THEME_COLOR];
            }
            self.muteBtn.hidden = YES;
            self.pencilBtn.hidden = YES;
            self.cancelBtn.hidden = YES;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)muteBtnClick:(UIButton *)sender {
    //按钮点击 发送通知
    NSDictionary *dic = @{};
    sender.selected = !sender.selected;
    switch (sender.tag) {
        case ButtonTypeCancel:
            dic = @{
                    @"uid":@(_uid),
                    @"messageType": @(MessageTypeOffSpeak),
                    @"msg": @"移除麦序"
                    };
            break;
        case ButtonTypeAudio:
            dic = @{
                    @"uid":@(_uid),
                    @"messageType": (sender.isSelected)?@(MessageTypeCloseAudio):@(MessageTypeOpenAudio),
                    @"msg": (sender.isSelected)?@"关闭麦克风":@"打开麦克风"
                    };
            break;
        case ButtonTypePencil:
            dic = @{
                    @"uid":@(_uid),
                    @"messageType": (sender.isSelected)?@(MessageTypeClosePencil):@(MessageTypeOpenPencil),
                    @"msg": (sender.isSelected)?@"关闭手写笔":@"打开手写笔"
                    };
            break;
            
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"videoButtonClick" object:dic];
}



@end
