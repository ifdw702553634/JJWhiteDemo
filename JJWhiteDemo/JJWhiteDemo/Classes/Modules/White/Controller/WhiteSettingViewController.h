//
//  WhiteSettingViewController.h
//  JJWhiteDemo
//
//  Created by mude on 2019/3/12.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WhiteSettingViewController;
@protocol SettingsDelegate <NSObject>
- (void)settingsVC:(WhiteSettingViewController *_Nonnull)settingsVC didSelectProfile:(CGSize)profile;
@end

NS_ASSUME_NONNULL_BEGIN

@interface WhiteSettingViewController : UIViewController
@property (assign, nonatomic) CGSize videoProfile;
@property (weak, nonatomic) id<SettingsDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
