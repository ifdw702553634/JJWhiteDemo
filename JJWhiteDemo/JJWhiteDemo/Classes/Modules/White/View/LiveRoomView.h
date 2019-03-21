//
//  LiveRoomView.h
//  JJWhiteDemo
//
//  Created by mude on 2019/3/12.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LiveRoomBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface LiveRoomView : UIView
@property (weak, nonatomic) IBOutlet UIView *remoteContainerView;

@property (nonatomic, copy) LiveRoomBlock liveRoomBlock;

@end

NS_ASSUME_NONNULL_END
