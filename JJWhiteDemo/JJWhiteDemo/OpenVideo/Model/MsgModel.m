//
//  MsgModel.m
//  OpenVideoCall
//
//  Created by CavanSu on 24/11/2017.
//  Copyright © 2017 Agora. All rights reserved.
//

#import "MsgModel.h"

@implementation MsgModel

+ (instancetype)modelWithMessage:(NSString *)message type:(MsgType)type {
    
    MsgModel *model = [[MsgModel alloc] init];
    model.message = message;
    if (type == MsgTypeChat) {
        model.color = [UIColor colorWithRed:255.f/255.f green:126.f/255.f blue:79.f/255.f alpha:0.5];
    }
    else {
        model.color = [UIColor colorWithRed:249.f/255.f green:128.f/255.f blue:114.f/255.f alpha:0.5];
    }
    
    return model;
}

@end
