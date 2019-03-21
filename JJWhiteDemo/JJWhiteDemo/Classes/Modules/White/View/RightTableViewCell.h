//
//  RightTableViewCell.h
//  JJWhiteDemo
//
//  Created by mude on 2019/3/21.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"


NS_ASSUME_NONNULL_BEGIN

@interface RightTableViewCell : UITableViewCell
@property (nonatomic, copy) Message *message;
@end

NS_ASSUME_NONNULL_END
