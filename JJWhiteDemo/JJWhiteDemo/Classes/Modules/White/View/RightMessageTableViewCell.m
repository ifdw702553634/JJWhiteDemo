//
//  RightMessageTableViewCell.m
//  JJWhiteDemo
//
//  Created by mude on 2019/3/21.
//  Copyright © 2019 mude. All rights reserved.
//

#import "RightMessageTableViewCell.h"
#import "SendMessageModel.h"

@interface RightMessageTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


@end

@implementation RightMessageTableViewCell

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
    NSString *per = (msg.fromUser == [[UserDefaultsUtils valueWithKey:@"uid"] integerValue])?@"你":[NSString stringWithFormat:@"%ld",(long)msg.fromUser];
    
    NSString *perUser = (msg.toUser == [[UserDefaultsUtils valueWithKey:@"uid"] integerValue])?@"你":[NSString stringWithFormat:@"%ld",(long)msg.toUser];
    if (msg.type == MessageTypeHand) {
        _contentLabel.text = [NSString stringWithFormat:@"%@举手了",per];
        _timeLabel.text = msg.time;
    }else if (msg.type == MessageTypeMessage) {
        _contentLabel.text = [NSString stringWithFormat:@"%@说了：%@",per,msg.msg];
        _timeLabel.text = msg.time;
    }else if (msg.type == MessageTypeOnSpeak) {
        _contentLabel.text = [NSString stringWithFormat:@"%@被提上麦序",perUser];
        _timeLabel.text = msg.time;
    }else if (msg.type == MessageTypeOffSpeak) {
        _contentLabel.text = [NSString stringWithFormat:@"%@被踢出麦序",perUser];
        _timeLabel.text = msg.time;
    }else if (msg.type == MessageTypeCloseAudio) {
        _contentLabel.text = [NSString stringWithFormat:@"%@的麦克风权限被关闭",perUser];
        _timeLabel.text = msg.time;
    }else if (msg.type == MessageTypeOpenAudio) {
        _contentLabel.text = [NSString stringWithFormat:@"%@的麦克风权限被开启",perUser];
        _timeLabel.text = msg.time;
    }else if (msg.type == MessageTypeClosePencil) {
        _contentLabel.text = [NSString stringWithFormat:@"%@的手写权限被关闭",perUser];
        _timeLabel.text = msg.time;
    }else if (msg.type == MessageTypeOpenPencil) {
        _contentLabel.text = [NSString stringWithFormat:@"%@的手写权限被开启",perUser];
        _timeLabel.text = msg.time;
    }
}

@end
