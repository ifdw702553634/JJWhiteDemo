
#ifndef Enumeration_h
#define Enumeration_h

//RTM  相关
typedef NS_ENUM(NSInteger, ChatType) {
    //单聊
    ChatTypePeer = 0,
    //群聊
    ChatTypeGroup
};

//视频上的按钮点击通知枚举
typedef NS_ENUM(NSInteger, ButtonType) {
    //踢出麦序
    ButtonTypeCancel = 1,
    //开关麦克风
    ButtonTypeAudio = 2,
    //开关手写笔
    ButtonTypePencil = 3
};


//左边教具栏目按钮的枚举
typedef NS_ENUM(NSInteger, ToolType) {
    //退出
    TypeCancel,
    //手写笔
    ToolTypePencil,
    //输入文本
    ToolTypeText,
    //改变颜色
    ToolTypeColor,
    //橡皮擦
    ToolTypeEraser,
    //选择工具
    ToolTypeSelector,
    //插入图片
    ToolTypeAddImage
};

//左边教具栏目按钮的枚举
typedef NS_ENUM(NSInteger, MessageType) {
    //举手
    MessageTypeHand = 1,
    //关闭麦克风
    MessageTypeCloseAudio = 2,
    //打开麦克风
    MessageTypeOpenAudio = 3,
    //关闭手写笔
    MessageTypeClosePencil = 4,
    //打开手写笔
    MessageTypeOpenPencil = 5,
    //课程内信息
    MessageTypeMessage = 6,
    //邀请发言（提上麦序）
    MessageTypeOnSpeak = 7,
    //关闭发言（踢出麦序）
    MessageTypeOffSpeak = 8,
    //课程结束
    MessageTypeOver = 9,
    //消息已读
    MessageTypeRead = 10
};


//消息已读未读状态
typedef NS_ENUM(NSInteger, MessageReadStatus) {
    //未读
    MessageReadStatusUnread = 0,
    //已读
    MessageReadStatusRead
};


#endif /* Enumeration_h */
