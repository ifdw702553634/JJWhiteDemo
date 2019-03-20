//
//  WhiteSettingTableViewCell.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/12.
//  Copyright © 2019 mude. All rights reserved.
//

#import "WhiteSettingTableViewCell.h"

@interface WhiteSettingTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *resLabel;
@property (weak, nonatomic) IBOutlet UILabel *frameLabel;

@end

@implementation WhiteSettingTableViewCell

- (void)updateWithProfile:(CGSize)profile isSelected:(BOOL)isSelected {
    self.resLabel.text = [self resolutionOfProfile:profile];
    self.frameLabel.text = [self fpsOfProfile:profile];
    self.backgroundColor = isSelected ? [UIColor colorWithRed:0 green:0 blue:0.5 alpha:0.3] : [UIColor whiteColor];
}

- (NSString *)resolutionOfProfile:(CGSize)profile {
    return [NSString stringWithFormat:@"%d×%d", (int)profile.width, (int)profile.height];
}

- (NSString *)fpsOfProfile:(CGSize)profile {
    return @"24";
}
@end
