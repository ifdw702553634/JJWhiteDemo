//
//  LiveTableView.h
//  JJWhiteDemo
//
//  Created by mude on 2019/3/15.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveTableView : UIView

@property (nonatomic, strong) NSArray<VideoSession *> *sessions;

@end

NS_ASSUME_NONNULL_END
