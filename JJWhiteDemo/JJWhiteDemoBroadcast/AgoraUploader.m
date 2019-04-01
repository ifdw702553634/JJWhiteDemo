//
//  AgoraUploader.m
//  Agora-Screen-Sharing-iOS-Broadcast
//
//  Created by mude on 2019/3/29.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "AgoraUploader.h"
#import "KeyCenter.h"
#import "AgoraAudioProcessing.h"


static AgoraUploader *agoraUploaderManager = nil;
static AgoraRtcEngineKit *sharedAgoraEngine = nil;
static CGSize videoDimension;
@interface AgoraUploader()

//@property (nonatomic, assign) CGSize videoDimension;
//@property (nonatomic, strong) AgoraRtcEngineKit *sharedAgoraEngine;

@end

@implementation AgoraUploader

+ (instancetype _Nonnull)shareManager {
    if (!agoraUploaderManager) {
        agoraUploaderManager = [[AgoraUploader alloc] init];
        CGSize screenSize = [UIScreen mainScreen].currentMode.size;
        CGSize boundingSize = CGSizeMake(720, 1280);
        CGFloat mW = boundingSize.width / screenSize.width;
        CGFloat mH = boundingSize.height / screenSize.height;
        if (mH < mW) {
            boundingSize.width = boundingSize.height / screenSize.height * screenSize.width;
        }else if (mW < mH) {
            boundingSize.height = boundingSize.width / screenSize.width * screenSize.height;
        }
        videoDimension = boundingSize;
        
        
        AgoraRtcEngineKit *kit = [AgoraRtcEngineKit sharedEngineWithAppId:[KeyCenter AppId] delegate:nil];
        [kit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
        [kit setClientRole:AgoraClientRoleBroadcaster];
        [kit enableVideo];
        [kit setExternalVideoSource:YES useTexture:YES pushMode:YES];
        AgoraVideoEncoderConfiguration *videoConfig = [[AgoraVideoEncoderConfiguration alloc] initWithSize:videoDimension frameRate:AgoraVideoFrameRateFps60 bitrate:AgoraVideoBitrateStandard orientationMode:AgoraVideoOutputOrientationModeAdaptative];
        [kit setVideoEncoderConfiguration:videoConfig];
        [AgoraAudioProcessing registerAudioPreprocessing:kit];
        [kit setRecordingAudioFrameParametersWithSampleRate:44100 channel:1 mode:AgoraAudioRawFrameOperationModeReadWrite samplesPerCall:1024];
        [kit setParameters:@"{\"che.audio.external_device\":true}"];
        [kit muteAllRemoteAudioStreams:YES];
        [kit muteAllRemoteVideoStreams:YES];
        sharedAgoraEngine = kit;
    }
    return agoraUploaderManager;
}

- (void)startBroadcastTo:(NSString *) channel uid:(NSInteger)uid{
    uid += 10000;
    [sharedAgoraEngine joinChannelByToken:nil channelId:channel info:nil uid:uid joinSuccess:nil];
}

- (void)sendVideoBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef videoFrame;
    if (CMSampleBufferGetImageBuffer(sampleBuffer)) {
        videoFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
    }else {
        return;
    }
    int rotation = 0;
    NSNumber *orientationAttachment = CMGetAttachment(sampleBuffer, (CFStringRef)RPVideoSampleOrientationKey, nil);
    if (orientationAttachment) {
        int orientation = [orientationAttachment intValue];
        switch (orientation) {
            case kCGImagePropertyOrientationUp:
            case kCGImagePropertyOrientationUpMirrored:
                rotation = 0;
                break;
            case kCGImagePropertyOrientationDown:
            case kCGImagePropertyOrientationDownMirrored:
                rotation = 180;
                break;
            case kCGImagePropertyOrientationRight:
            case kCGImagePropertyOrientationRightMirrored:
                rotation = 270;
                break;
            case kCGImagePropertyOrientationLeft:
            case kCGImagePropertyOrientationLeftMirrored:
                rotation = 90;
                break;
            default:
                break;
        }
    }
    CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    AgoraVideoFrame *frame = [[AgoraVideoFrame alloc] init];
    frame.format = 12;
    frame.time = time;
    frame.textureBuf = videoFrame;
    frame.rotation = rotation;
    [sharedAgoraEngine pushExternalVideoFrame:frame];
}

- (void)sendAudioAppBuffer:(CMSampleBufferRef)sampleBuffer {
    [AgoraAudioProcessing pushAudioAppBuffer:sampleBuffer];
}

- (void)sendAudioMicBuffer:(CMSampleBufferRef)sampleBuffer {
    [AgoraAudioProcessing pushAudioMicBuffer:sampleBuffer];
}

- (void)stopBroadcast {
    [sharedAgoraEngine leaveChannel:nil];
}


@end
