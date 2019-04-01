//
//  AgoraUploader.h
//  Agora-Screen-Sharing-iOS-Broadcast
//
//  Created by mude on 2019/3/29.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ReplayKit/ReplayKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraUploader : NSObject

+ (instancetype _Nonnull)shareManager;
- (void)startBroadcastTo:(NSString *) channel uid:(NSInteger)uid;
- (void)stopBroadcast;
- (void)sendVideoBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)sendAudioAppBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)sendAudioMicBuffer:(CMSampleBufferRef)sampleBuffer;
@end

NS_ASSUME_NONNULL_END
