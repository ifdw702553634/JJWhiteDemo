//
//  RightView.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/21.
//  Copyright © 2019 mude. All rights reserved.
//

#import "RightView.h"
#import "RightMessageTableViewCell.h"
#import "AgoraRtm.h"
#import "RightAudienceTableViewCell.h"

static NSString *kRightMessageTableViewCell = @"RightMessageTableViewCell";
static NSString *kRightAudienceTableViewCell = @"RightAudienceTableViewCell";
@interface RightView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MJRefreshNormalHeader *header;
@property (nonatomic, strong) MJRefreshBackNormalFooter *footer;

@end

@implementation RightView

- (void)awakeFromNib {
    [super awakeFromNib];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 55;
    
    [_tableView registerNib:[UINib nibWithNibName:kRightMessageTableViewCell bundle:nil] forCellReuseIdentifier:kRightMessageTableViewCell];
    
    [_tableView registerNib:[UINib nibWithNibName:kRightAudienceTableViewCell bundle:nil] forCellReuseIdentifier:kRightAudienceTableViewCell];
}

- (MJRefreshNormalHeader *)header {
    if (!_header) {
        _header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
        _header.lastUpdatedTimeLabel.hidden = YES;
        _header.stateLabel.hidden = YES;
    }
    return _header;
}

- (MJRefreshBackNormalFooter *)footer {
    if (!_footer) {
        _footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        [_footer setTitle:@"上拉加载更多" forState:MJRefreshStateIdle];
        [_footer setTitle:@"上拉加载更多" forState:MJRefreshStatePulling];
        [_footer setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
        [_footer setTitle:@"暂无更多" forState:MJRefreshStateNoMoreData];
    }
    return _footer;
}

- (void)setTableType:(NSInteger)tableType {
    _tableType = tableType;
    if (tableType == 2) {
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
        _tableView.mj_header = self.header;
        // 设置footer
        _tableView.mj_footer = self.footer;
        [self loadData];
    }else {
        if (_msgList.count > 0) {
            NSIndexPath *end = [NSIndexPath indexPathForRow:_msgList.count - 1 inSection:0];
            __weak RightView *weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                [weakSelf.tableView scrollToRowAtIndexPath:end atScrollPosition:UITableViewScrollPositionBottom animated:true];
            });
        }else {
            [self.tableView reloadData];
        }
        _tableView.mj_header = nil;
        _tableView.mj_footer = nil;
    }
}

- (void)loadData {
    self.refreshBlock(RefreshTypeRefresh);
}

- (void)loadMoreData {
    self.refreshBlock(RefreshTypeLoad);
}

- (void)setStuList:(NSArray *)stuList {
    _stuList = stuList;
    if (_tableType == 2) {
        __weak RightView *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }
}

- (void)setMsgList:(NSMutableArray *)msgList {
    _msgList = msgList;
    if (_tableType == 1 && _msgList.count > 0) {
        NSIndexPath *end = [NSIndexPath indexPathForRow:msgList.count - 1 inSection:0];
        __weak RightView *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:end atScrollPosition:UITableViewScrollPositionBottom animated:true];
        });
    }
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableType == 1 ? _msgList.count:_stuList.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50)];
    lbl.textAlignment = NSTextAlignmentCenter;
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setBackgroundColor:THEME_COLOR];
    lbl.text = _tableType == 1 ? @"消息":@"学生";
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
    if (_tableType == 1) {
        Message *msg = self.msgList[indexPath.row];
        RightMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRightMessageTableViewCell forIndexPath:indexPath];
        cell.message = msg;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else {
        RightAudienceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRightAudienceTableViewCell forIndexPath:indexPath];
        cell.audienceName.text = self.stuList[indexPath.row][@"weixinName"];
        [cell.headImageView sd_setImageWithURL:self.stuList[indexPath.row][@"avatar"]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //观众列表相应点击事件
    if (_tableType == 2) {
        self.audienceClickBlock(self.stuList[indexPath.row]);
    }
}

@end
