//
//  MsgTableView.h
//  OpenVideoCall
//
//  Created by CavanSu on 24/11/2017.
//  Copyright © 2017 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageType.h"
#import "Message.h"

@interface MsgTableView : UITableView

- (void)appendMsgToTableViewWithMsg:(Message *)message msgType:(MsgType)type;

@end
