//
//  RightView.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/21.
//  Copyright © 2019 mude. All rights reserved.
//

#import "RightView.h"
#import "RightTableViewCell.h"
#import "AgoraRtm.h"

static NSString *kRightTableViewCell = @"RightTableViewCell";
@interface RightView()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation RightView

- (void)awakeFromNib {
    [super awakeFromNib];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 55;
    
    [_tableView registerNib:[UINib nibWithNibName:kRightTableViewCell bundle:nil] forCellReuseIdentifier:kRightTableViewCell];
}

- (void)setList:(NSMutableArray *)list {
    _list = list;
    NSIndexPath *end = [NSIndexPath indexPathForRow:list.count - 1 inSection:0];
    __weak RightView *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadData];
        [weakSelf.tableView scrollToRowAtIndexPath:end atScrollPosition:UITableViewScrollPositionBottom animated:true];
    });
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _list.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50)];
    lbl.textAlignment = NSTextAlignmentCenter;
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setBackgroundColor:[UIColor colorWithRed:237.f/255.f green:86.f/255.f blue:86.f/255.f alpha:1.f]];
    lbl.text = _teacherName;
    return lbl;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *msg = self.list[indexPath.row];
    
    RightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRightTableViewCell forIndexPath:indexPath];
    cell.message = msg;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
