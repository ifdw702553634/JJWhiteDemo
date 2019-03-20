//
//  SettingsViewController.h
//  JJWhiteDemo
//
//  Created by JiaoJiao Network on 2019/3/9.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

@class SettingsViewController;
@protocol SettingsVCDelegate <NSObject>
- (void)settingsVC:(SettingsViewController *)settingsVC didSelectDimension:(CGSize)dimension;
@end

NS_ASSUME_NONNULL_BEGIN

@interface SettingsViewController : UIViewController

@property (assign, nonatomic) CGSize dimension;
@property (weak, nonatomic) id<SettingsVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
