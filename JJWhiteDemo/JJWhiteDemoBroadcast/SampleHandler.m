//
//  SampleHandler.m
//  JJWhiteDemoBroadcast
//
//  Created by mude on 2019/4/1.
//  Copyright © 2019 mude. All rights reserved.
//


#import "SampleHandler.h"
#import "AgoraUploader.h"

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    if (setupInfo && [[setupInfo allKeys] containsObject:@"channelName"]) {
        NSString *channel = [setupInfo[@"channelName"] description];
        NSInteger uid = [[setupInfo[@"uid"] description] integerValue];
        [[AgoraUploader shareManager] startBroadcastTo:channel uid:uid];
    }else {
        // 取出数据
        //应用拓展之间公用数据
        NSDictionary *myData = [[[NSUserDefaults alloc] initWithSuiteName:@"group.JJWhiteDemo"] valueForKey:@"shareData"];
        [[AgoraUploader shareManager] startBroadcastTo:myData[@"channelName"] uid:[myData[@"uid"] integerValue]];
    }
    [self receiveNotification];
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional. 
}

// 接收通知
- (void)receiveNotification {
    CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter ();
    CFNotificationCenterAddObserver(notification, (__bridge const void *)(self), observerMethod,CFSTR("cn.com.mude.JJWhiteDemo.StopScreen"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

void observerMethod (CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    //关闭直播
    [(__bridge SampleHandler *)observer finishBroadcastWithError:[NSError errorWithDomain:@"" code:-1 userInfo:nil]];
    // Your custom work
}

- (void)dealloc {
    CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter ();
    CFNotificationCenterRemoveObserver(notification, (__bridge const void *)(self), CFSTR("cn.com.mude.JJWhiteDemo.StopScreen"), NULL);
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    [[AgoraUploader shareManager] stopBroadcast];
    // User has requested to finish the broadcast.
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            [[AgoraUploader shareManager] sendVideoBuffer:sampleBuffer];
            // Handle video sample buffer
            break;
        case RPSampleBufferTypeAudioApp:
            [[AgoraUploader shareManager] sendAudioAppBuffer:sampleBuffer];
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            [[AgoraUploader shareManager] sendAudioMicBuffer:sampleBuffer];
            // Handle audio sample buffer for mic audio
            break;
        default:
            break;
    }
}

@end
