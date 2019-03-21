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
    // Initialization code
}

- (void)setUid:(NSUInteger)uid {
    _uid = uid;
    if (_uid == 0 || _uid == [[[NSUserDefaults standardUserDefaults] stringForKey:@"uid"] integerValue]) {
        self.selfLabel.text = @"自己";
        self.muteBtn.hidden = YES;
        self.cancelBtn.hidden = YES;
        self.pencilBtn.hidden = YES;
    }else {
        self.selfLabel.text = [NSString stringWithFormat:@"%ld",uid];
        [self.selfLabel setBackgroundColor:THEME_COLOR];
        self.muteBtn.hidden = NO;
        self.pencilBtn.hidden = NO;
        self.cancelBtn.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)muteBtnClick:(UIButton *)sender {
    //按钮点击 发送通知
    NSDictionary *dic = @{@"btnType":@(sender.tag), @"uid":@(_uid)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"videoButtonClick" object:dic];
}



@end
