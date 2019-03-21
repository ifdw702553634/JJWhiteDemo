//
//  CommandListController.h
//  WhiteDemo
//
//  Created by mude on 2019/3/8.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *CommandCustomEvent = @"CommandCustomEvent";

@interface CommandListController : UITableViewController

@property (nonatomic, copy) NSString *roomName;

- (instancetype)initWithRoom:(WhiteRoom *)room;

@end

NS_ASSUME_NONNULL_END
