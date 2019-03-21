//
//  WhiteSettingViewController.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/12.
//  Copyright © 2019 mude. All rights reserved.
//

#import "WhiteSettingViewController.h"
#import "WhiteSettingTableViewCell.h"


@interface WhiteSettingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *profiles;
@end

@implementation WhiteSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(complate:)];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"WhiteSettingTableViewCell" bundle:nil] forCellReuseIdentifier:@"WhiteSettingTableViewCell"];
}

- (void)complate:(id)sender {
    if ([self.delegate respondsToSelector:@selector(settingsVC:didSelectProfile:)]) {
        [self.delegate settingsVC:self didSelectProfile:self.videoProfile];
    }
}

- (NSArray *)profiles {
    if (!_profiles) {
        _profiles = @[@(AgoraVideoDimension160x120),
                      @(AgoraVideoDimension320x180),
                      @(AgoraVideoDimension320x240),
                      @(AgoraVideoDimension640x360),
                      @(AgoraVideoDimension640x480),
                      @(AgoraVideoDimension1280x720)];
    }
    return _profiles;
}

- (void)setVideoProfile:(CGSize)videoProfile {
    _videoProfile = videoProfile;
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.profiles.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WhiteSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WhiteSettingTableViewCell" forIndexPath:indexPath];
    CGSize selectedProfile = [self.profiles[indexPath.row] CGSizeValue];
    [cell updateWithProfile:selectedProfile isSelected:CGSizeEqualToSize(selectedProfile, self.videoProfile)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize selectedProfile = [self.profiles[indexPath.row] CGSizeValue];
    self.videoProfile = selectedProfile;
}

@end
