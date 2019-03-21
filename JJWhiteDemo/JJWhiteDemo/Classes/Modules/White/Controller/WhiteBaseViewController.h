//
//  WhiteBaseViewController.h
//  JJWhiteDemo
//
//  Created by mude on 2019/3/12.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WhiteBaseViewController : BaseViewController

@property (nonatomic, copy, nullable) NSString *roomUuid;
@property (nonatomic, strong) WhiteBoardView *boardView;

#pragma mark - CallbackDelegate
@property (nonatomic, weak, nullable) id<WhiteCommonCallbackDelegate> commonDelegate;

@end

NS_ASSUME_NONNULL_END
