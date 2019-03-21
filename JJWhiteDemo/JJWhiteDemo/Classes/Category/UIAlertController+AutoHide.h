//
//  UIAlertController+AutoHide.h
//
//  Created by Friday on 16/4/12.
//  Copyright © 2016年 DreamTouch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (AutoHide)

- (void)setDismissInterval:(CGFloat)interval;

- (void)setDismissInterval:(CGFloat)interval complete:(void(^ __nullable)(void))complete;

- (void)setCancelTitle:( NSString * _Nullable )cancelTitle SureTitle:(NSString * _Nullable)sureTitle cancelBlock:(void (^ __nullable)(UIAlertAction * _Nullable action))cancel sureBlock:(void (^ __nullable)(UIAlertAction * _Nullable action))sure;

@end
