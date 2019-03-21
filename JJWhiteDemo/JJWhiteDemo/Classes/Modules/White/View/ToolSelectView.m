//
//  ToolSelectView.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/12.
//  Copyright © 2019 mude. All rights reserved.
//

#import "ToolSelectView.h"


typedef NS_ENUM(NSInteger, ToolType) {
    TypeCancel,
    ToolTypePencil,
    ToolTypeText,
    ToolTypeColor,
    ToolTypeEraser,
    ToolTypeSelector
};

static NSString *kToolSelectTableViewCell = @"ToolSelectTableViewCell";

@interface ToolSelectView()<UITableViewDelegate, UITableViewDataSource>{
    NSIndexPath *_selectIndex;//记录选中的行
    
    NSArray *_colorArray;//记录当前颜色
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *toolArr;

@end

@implementation ToolSelectView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"ToolSelectTableViewCell" bundle:nil] forCellReuseIdentifier:kToolSelectTableViewCell];
    [self setData];
    
    //注册颜色变化的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorChange:) name:@"colorChange" object:nil];
}

-(void)dealloc{
    //移除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setData {
     _toolArr = @[@"btn_cancel",@"btn_pencil",@"btn_text",@"btn_color",@"btn_eraser",@"btn_move"];
    _selectIndex = [NSIndexPath indexPathForRow:ToolTypePencil inSection:0];
    [self.tableView reloadData];
}

//接收通知，改变color icon的颜色
- (void)colorChange:(NSNotification *)noti{
    _selectIndex = [NSIndexPath indexPathForRow:ToolTypePencil inSection:0];
    [self.tableView reloadData];
    //使用object处理消息
    _colorArray = [noti object][@"colorArray"];
    [self changeIconColor:_colorArray];
}

- (void)changeIconColor:(NSArray *)colorArr {
    ToolSelectTableViewCell *cell = (ToolSelectTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ToolTypeColor inSection:0]];
    cell.iconImage.image = [cell.iconImage.image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    cell.iconImage.tintColor = [UIColor colorWithRed:[colorArr[0] floatValue]/255.f green:[colorArr[1] floatValue]/255.f blue:[colorArr[2] floatValue]/255.f alpha:1.f];
}

#pragma mark - tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _toolArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToolSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kToolSelectTableViewCell forIndexPath:indexPath];
    cell.iconImage.image = [UIImage imageNamed:_toolArr[indexPath.row]];
    if (indexPath.row == ToolTypeColor) {
        cell.iconImage.image = [cell.iconImage.image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
        cell.iconImage.tintColor = [UIColor colorWithRed:[_colorArray[0] floatValue]/255.f green:[_colorArray[1] floatValue]/255.f blue:[_colorArray[2] floatValue]/255.f alpha:1.f];
    }
    if (indexPath.row == TypeCancel) {
        cell.backgroundColor = [UIColor redColor];
    }else if (indexPath == _selectIndex && indexPath.row != TypeCancel) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:237.f/255.f green:86.f/255.f blue:86.f/255.f alpha:0.5f];
    }else {
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case TypeCancel:
        {
            self.cancelBlock();
            break;
        }
        case ToolTypePencil:
        {
            _selectIndex = indexPath;
            WhiteMemberState *mState = [[WhiteMemberState alloc] init];
            mState.currentApplianceName = AppliancePencil;
            [self.room setMemberState:mState];
            break;
        }
        case ToolTypeColor:
        {
            ToolSelectTableViewCell *cell = (ToolSelectTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            self.toolSelectBlock(cell);
            break;
        }
        case ToolTypeEraser:
        {
            _selectIndex = indexPath;
            WhiteMemberState *mstate = [[WhiteMemberState alloc] init];
            mstate.currentApplianceName = ApplianceEraser;
            [self.room setMemberState:mstate];
        }
            break;
        case ToolTypeText:
        {
            _selectIndex = indexPath;
            WhiteMemberState *mstate = [[WhiteMemberState alloc] init];
            mstate.currentApplianceName = ApplianceText;
            [self.room setMemberState:mstate];
        }
            break;
        case ToolTypeSelector:
        {
            _selectIndex = indexPath;
            WhiteMemberState *mstate = [[WhiteMemberState alloc] init];
            mstate.currentApplianceName = ApplianceSelector;
            [self.room setMemberState:mstate];
        }
            break;
            
        default:
            break;
    }
    [tableView reloadData];
    
}


@end
