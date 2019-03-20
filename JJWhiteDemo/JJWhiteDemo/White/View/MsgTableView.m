//
//  MsgTableView.m
//  OpenVideoCall
//
//  Created by CavanSu on 24/11/2017.
//  Copyright © 2017 Agora. All rights reserved.
//

#import "MsgTableView.h"
#import "MsgCell.h"
#import "MsgModel.h"

@interface MsgTableView () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *msgArray;
@end

static NSString *kMsgCell = @"MsgCell";

@implementation MsgTableView

- (instancetype)init {
    if ([super init]) {
        self.delegate = self;
        self.dataSource = self;
        self.alpha = 0.5f;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self registerNib:[UINib nibWithNibName:kMsgCell bundle:nil] forCellReuseIdentifier:kMsgCell];
    }
    return self;
}


#pragma mark- Append msg to tableView to display
- (void)appendMsgToTableViewWithMsg:(Message *)message msgType:(MsgType)type
{
    MsgModel *model = [MsgModel modelWithMessage:message.message acount:message.account type:type];
    
    [self.msgArray insertObject:model atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma mark- <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _msgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgCell *cell = [tableView dequeueReusableCellWithIdentifier:kMsgCell forIndexPath:indexPath];
    cell.reloadBlock = ^{
        [self reloadData];
    };
    MsgModel *model = _msgArray[indexPath.row];
    cell.model = model;
    return cell;
}

#pragma mark- <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgModel *model = _msgArray[indexPath.row];
    
    return model.height;
    
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20;
}

- (NSMutableArray *)msgArray {
    
    if (!_msgArray) {
        _msgArray = [NSMutableArray array];
    }
    return _msgArray;
}

@end
