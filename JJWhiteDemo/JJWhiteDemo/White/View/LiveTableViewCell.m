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
    }else if (sender.tag == 2) {
    }else if (sender.tag == 3) {
    }
}



@end
