//
//  RightView.h
//  JJWhiteDemo
//
//  Created by mude on 2019/3/21.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RightView : UIView

@property (nonatomic, strong) NSMutableArray *list;

@property (nonatomic, copy) NSString *teacherName;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
