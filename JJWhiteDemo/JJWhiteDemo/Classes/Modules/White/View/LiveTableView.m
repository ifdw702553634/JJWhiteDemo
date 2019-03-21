//
//  LiveTableView.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/15.
//  Copyright © 2019 mude. All rights reserved.
//

#import "LiveTableView.h"
#import "LiveTableViewCell.h"
#import "VideoViewLayouter.h"

static NSString *kLiveTableViewCell = @"LiveTableViewCell";
@interface LiveTableView()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) VideoViewLayouter *viewLayouter;

@end

@implementation LiveTableView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:kLiveTableViewCell bundle:nil] forCellReuseIdentifier:kLiveTableViewCell];
}

- (VideoViewLayouter *)viewLayouter {
    if (!_viewLayouter) {
        _viewLayouter = [[VideoViewLayouter alloc] init];
    }
    return _viewLayouter;
}

- (void)setSessions:(NSArray<VideoSession *> *)sessions {
    _sessions = sessions;
    [self.tableView reloadData];
}

#pragma mark - tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sessions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLiveTableViewCell forIndexPath:indexPath];
    [self.viewLayouter layoutSessions:@[_sessions[indexPath.row]] fullSession:nil inContainer:cell.liveView];
    cell.uid = _sessions[indexPath.row].uid;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//设置cell分割线做对齐
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

@end
