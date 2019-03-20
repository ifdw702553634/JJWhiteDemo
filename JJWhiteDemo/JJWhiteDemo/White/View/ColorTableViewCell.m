//
//  ColorTableViewCell.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/12.
//  Copyright © 2019 mude. All rights reserved.
//

#import "ColorTableViewCell.h"

@implementation ColorTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.colorView.layer.cornerRadius = 3.f;
    self.colorView.layer.masksToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
