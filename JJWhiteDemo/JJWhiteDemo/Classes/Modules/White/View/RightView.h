//
//  RightView.h
//  JJWhiteDemo
//
//  Created by mude on 2019/3/21.
//  Copyright © 2019 mude. All rights reserved.
//

#import <UIKit/UIKit.h>

//RTM  相关
typedef NS_ENUM(NSInteger, RefreshType) {
    //下拉刷新
    RefreshTypeRefresh = 0,
    //上拉加载
    RefreshTypeLoad
};

NS_ASSUME_NONNULL_BEGIN

typedef void(^RefreshBlock)(RefreshType type);
typedef void(^AudienceClickBlock)(NSDictionary *stuInfo);

@interface RightView : UIView

@property (nonatomic, strong) NSMutableArray *msgList;

@property (nonatomic, strong) NSArray *stuList;

//列表类型 1.消息列表 2.观众列表
@property (nonatomic, assign) NSInteger tableType;

@property (nonatomic, copy) RefreshBlock refreshBlock;

@property (nonatomic, copy) AudienceClickBlock audienceClickBlock;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
