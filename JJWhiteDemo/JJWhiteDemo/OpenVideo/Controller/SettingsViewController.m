//
//  SettingsViewController.m
//  JJWhiteDemo
//
//  Created by JiaoJiao Network on 2019/3/9.
//  Copyright © 2019 mude. All rights reserved.
//

#import "SettingsViewController.h"
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "DimensionCell.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dimensionList;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doConfirmPressed:)];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DimensionCell" bundle:nil] forCellReuseIdentifier:@"DimensionCell"];
    
    // Do any additional setup after loading the view from its nib.
}

- (NSArray *)dimensionList {
    if (!_dimensionList) {
        _dimensionList = @[@(AgoraVideoDimension160x120),
                           @(AgoraVideoDimension240x180),
                           @(AgoraVideoDimension320x240),
                           @(AgoraVideoDimension640x360),
                           @(AgoraVideoDimension640x480),
                           @(AgoraVideoDimension960x720)];
    }
    return _dimensionList;
}

- (void)setDimension:(CGSize)dimension {
    _dimension = dimension;
    [self.tableView reloadData];
}

- (void)doConfirmPressed:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(settingsVC:didSelectDimension:)]) {
        [self.delegate settingsVC:self didSelectDimension:self.dimension];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dimensionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DimensionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DimensionCell" forIndexPath:indexPath];
    CGSize dimension = [self.dimensionList[indexPath.row] CGSizeValue];
    [cell updateWithDimension:dimension isSelected:CGSizeEqualToSize(self.dimension, dimension)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize selectedDimension = [self.dimensionList[indexPath.row] CGSizeValue];
    self.dimension = selectedDimension;
}

@end
