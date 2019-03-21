//
//  UIAlertController+AutoHide.m
//
//  Created by Friday on 16/4/12.
//  Copyright © 2016年 DreamTouch. All rights reserved.
//

#import "UIAlertController+AutoHide.h"

@implementation UIAlertController (AutoHide)

- (void)setDismissInterval:(CGFloat)interval
{
    [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
}
-(void)performDismiss:(NSTimer*)timer
{
    if ([timer userInfo]!=nil && [timer userInfo][@"completeBlock"]!=nil) {
        [self dismissViewControllerAnimated:YES completion:[timer userInfo][@"completeBlock"] == [NSNull null] ? nil : [timer userInfo][@"completeBlock"]];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setDismissInterval:(CGFloat)interval complete:(void(^ __nullable)(void))complete;
{
    [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(performDismiss:) userInfo:complete == nil?@{@"completeBlock" : [NSNull null]} : @{@"completeBlock" : complete} repeats:NO];
}

- (void)setCancelTitle:(NSString *)cancelTitle SureTitle:(NSString *)sureTitle cancelBlock:(void (^)(UIAlertAction *action))cancel sureBlock:(void (^)(UIAlertAction *action))sure
{
    if (cancelTitle!=nil||cancelTitle.length>0) {
        [self addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (cancel!=nil) {
                cancel(action);
            }
        }]];
    }
    if (sureTitle!=nil||sureTitle.length>0) {
        [self addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (sure!=nil) {
                sure(action);
            }
        }]];
    }
}

@end
