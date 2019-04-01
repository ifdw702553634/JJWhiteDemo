//
//  ToolSelectView.h
//  JJWhiteDemo
//
//  Created by mude on 2019/3/12.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToolSelectTableViewCell.h"

typedef void(^ToolSelectBlock)(ToolSelectTableViewCell * _Nonnull cell);
typedef void(^CancelBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface ToolSelectView : UIView

@property (nonatomic, strong) WhiteRoom *room;

@property (nonatomic, copy) ToolSelectBlock toolSelectBlock;
@property (nonatomic, copy) CancelBlock cancelBlock;

@end

NS_ASSUME_NONNULL_END
