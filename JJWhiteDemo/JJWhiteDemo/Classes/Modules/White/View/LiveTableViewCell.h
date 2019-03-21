//
//  LiveTableViewCell.h
//  JJWhiteDemo
//
//  Created by mude on 2019/3/15.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface LiveTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *liveView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UILabel *selfLabel;
@property (weak, nonatomic) IBOutlet UIButton *pencilBtn;

@property (assign, nonatomic) NSUInteger uid;
@end

NS_ASSUME_NONNULL_END
