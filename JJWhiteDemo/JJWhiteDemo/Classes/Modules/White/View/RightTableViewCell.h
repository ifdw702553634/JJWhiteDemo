//
//  RightTableViewCell.h
//  JJWhiteDemo
//
//  Created by mude on 2019/3/21.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeLeft,
    CellTypeRight
};

NS_ASSUME_NONNULL_BEGIN

@interface RightTableViewCell : UITableViewCell

- (void)updateType:(CellType)type message:(Message *)message;

@end

NS_ASSUME_NONNULL_END
