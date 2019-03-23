//
//  RightAudienceTableViewCell.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/23.
//  Copyright © 2019 mude. All rights reserved.
//

#import "RightAudienceTableViewCell.h"

@implementation RightAudienceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _headImageView.layer.cornerRadius = 25.f;
    _headImageView.layer.masksToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
