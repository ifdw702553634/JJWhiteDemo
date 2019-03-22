//
//  RightTableViewCell.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/21.
//  Copyright © 2019 mude. All rights reserved.
//

#import "RightTableViewCell.h"
#import "SendMessageModel.h"

@interface RightTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


@end

@implementation RightTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setMessage:(Message *)message {
    _message = message;
    SendMessageModel *msg = [SendMessageModel yy_modelWithJSON:message.text];
    if (!msg) {
        _contentLabel.text = [NSString stringWithFormat:@"%@说：%@",message.userId,message.text];
        _timeLabel.text = @"暂无";
    }
    if (msg.type == 1) {
        _contentLabel.text = [NSString stringWithFormat:@"%ld举手了",(long)msg.fromUser];
        _timeLabel.text = msg.time;
    }else if (msg.type == 2) {
        _contentLabel.text = [NSString stringWithFormat:@"%ld麦克风",(long)msg.fromUser];
        _timeLabel.text = msg.time;
    }else if (msg.type == 3) {
        _contentLabel.text = [NSString stringWithFormat:@"%ld手写笔",(long)msg.fromUser];
        _timeLabel.text = msg.time;
    }else if (msg.type == 4) {
        _contentLabel.text = [NSString stringWithFormat:@"%ld说了：%@",(long)msg.fromUser,msg.msg];
        _timeLabel.text = msg.time;
    }
}

@end
