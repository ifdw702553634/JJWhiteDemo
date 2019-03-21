//
//  ColorTableViewController.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/12.
//  Copyright © 2019 mude. All rights reserved.
//

#import "ColorTableViewController.h"
#import "ColorTableViewCell.h"

static NSString *kColorTableViewCell = @"ColorTableViewCell";
@interface ColorTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *colorArr;
@property (nonatomic, strong) WhiteRoom *room;
@property (nonatomic, assign, getter=isReadonly) BOOL readonly;

@end

@implementation ColorTableViewController

- (instancetype)initWithRoom:(WhiteRoom *)room
{
    if (self = [super init]) {
        _room = room;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _colorArr = @[@[@(0),@(0),@(0)],@[@(0),@(255),@(0)],@[@(255),@(0),@(0)],@[@(0),@(0),@(255)],@[@(255),@(255),@(0)],@[@(0),@(255),@(255)],@[@(255),@(0),@(255)]];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"ColorTableViewCell" bundle:nil] forCellReuseIdentifier:kColorTableViewCell];
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(50, MIN(self.colorArr.count, 6) * 44);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.colorArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ColorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kColorTableViewCell forIndexPath:indexPath];
    NSArray *color = _colorArr[indexPath.row];
    cell.colorView.backgroundColor = [UIColor colorWithRed:[color[0] floatValue]/255.f green:[color[1] floatValue]/255.f blue:[color[2] floatValue]/255.f alpha:1.f];
    // Configure the cell...
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //获取当前教具
    [self.room getMemberStateWithResult:^(WhiteMemberState *state) {
        NSLog(@"当前教具%@", [state jsonString]);
    }];
    
    WhiteMemberState *mState = [[WhiteMemberState alloc] init];
    mState.currentApplianceName = AppliancePencil;
    mState.strokeColor = _colorArr[indexPath.row];
    mState.strokeWidth = @(5);
    [self.room setMemberState:mState];
    
    //颜色改变，发送通知
    NSDictionary *dic = @{@"colorArray":_colorArr[indexPath.row]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"colorChange" object:dic];
    
    //点击消失
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
