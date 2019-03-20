//
//  WhiteSettingTableViewCell.h
//  JJWhiteDemo
//
//  Created by mude on 2019/3/12.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WhiteSettingTableViewCell : UITableViewCell
- (void)updateWithProfile:(CGSize)profile isSelected:(BOOL)isSelected;
@end

NS_ASSUME_NONNULL_END
