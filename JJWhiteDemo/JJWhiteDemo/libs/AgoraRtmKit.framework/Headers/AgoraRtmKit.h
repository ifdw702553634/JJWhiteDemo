//
//  AgoraRtmKit.h
//  AgoraRtmKit
//
//  Copyright (c) 2018 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 TBD
 */
@class AgoraRtmKit;
/**
 TBD
 */
@class AgoraRtmMessage;
/**
 TBD
 */
@class AgoraRtmChannel;

/**
 TBD
 */
typedef NS_ENUM(NSInteger, AgoraRtmMessageType) {
    /** TBD */
    AgoraRtmMessageTypeUndefined = 0,
    /** TBD */
    AgoraRtmMessageTypeText = 1,
};

/** The state of sending a point-to-point (P2P) message.
 */
typedef NS_ENUM(NSInteger, AgoraRtmSendPeerMessageState) {
    /** The initial state. The P2P message is not sent. */
    AgoraRtmSendPeerMessageStateInit = 0,
    /** Fails to send the P2P message. */
    AgoraRtmSendPeerMessageStateFailure = 1,
    /** The P2P message is not received by the specified user (peer) because the specified user (peer) is offline. */
    AgoraRtmSendPeerMessageStatePeerUnreachable = 2,
    /** The P2P message is received by the specified user (peer). */
    AgoraRtmSendPeerMessageStateReceivedByPeer = 3,
    /** A timeout in sending the P2P message. The current time limit is set as 5 seconds. */
    AgoraRtmSendPeerMessageStateTimeout = 4,
};

/** Connection states.
*/
typedef NS_ENUM(NSInteger, AgoraRtmConnectionState) {
    AgoraRtmConnectionStateDisConnected = 1,
    AgoraRtmConnectionStateConnecting = 2,
    AgoraRtmConnectionStateConnected = 3,
    AgoraRtmConnectionStateReConnecting = 4,
    AgoraRtmConnectionStateAborted = 5,
};

/** Reasons for the connection state change. 
*/
typedef NS_ENUM(NSInteger, AgoraRtmConnectionChangeReason) {
    AgoraRtmConnectionChangeReasonLogin = 1,
    AgoraRtmConnectionChangeReasonLoginSuccess = 2,
    AgoraRtmConnectionChangeReasonLoginFailure = 3,
    AgoraRtmConnectionChangeReasonLoginTimeout = 4,
    AgoraRtmConnectionChangeReasonInterrupted = 5,
    AgoraRtmConnectionChangeReasonLogout = 6,
    AgoraRtmConnectionChangeReasonBannedByServer = 7,
};

/** Login status.
 */
typedef NS_ENUM(NSInteger, AgoraRtmLoginErrorCode) {
    /** Login succeeds. No error occurs. */
    AgoraRtmLoginErrorOk = 0,
    /** Login fails for an unknown reason.*/
    AgoraRtmLoginErrorUnknown = 1,
    /** Login is rejected for the reason that the user has already logged in, the SDK is not initialized or the login is rejected by the server. */
    AgoraRtmLoginErrorRejected = 2,
    /** Invalid login argument.*/
    AgoraRtmLoginErrorInvalidArgument = 3,
    /** Invalid App ID. */
    AgoraRtmLoginErrorInvalidAppId = 4,
    /** Invalid token. */
    AgoraRtmLoginErrorInvalidToken = 5,
    /** The token has expired and login is rejected.*/
    AgoraRtmLoginErrorTokenExpired = 6,
    /** Unauthorized login. */
    AgoraRtmLoginErrorNotAuthorized = 7,
    /** A login timeout. */
    AgoraRtmLoginErrorAlreadyLogin = 8,
    AgoraRtmLoginErrorTimeout = 9,
    AgoraRtmLoginErrorLoinTooOften = 10,
};

/** Logout status.
 */
typedef NS_ENUM(NSInteger, AgoraRtmLogoutErrorCode) {
    /** Logout succeeds. */
    AgoraRtmLogoutErrorOk = 0,
    /** Logout fails. Maybe the SDK is not initialized or the user is not logged in. */
    AgoraRtmLogoutErrorRejected = 1,
};

/**
 TBD
 */
typedef void (^AgoraRtmLoginBlock)(AgoraRtmLoginErrorCode errorCode);
/**
 TBD
 */
typedef void (^AgoraRtmLogoutBlock)(AgoraRtmLogoutErrorCode errorCode);
/**
 TBD
 */
typedef void (^AgoraRtmSendPeerMessageBlock)(AgoraRtmSendPeerMessageState state);

__attribute__((visibility("default"))) @interface AgoraRtmMessage: NSObject
@property (nonatomic, assign, readonly) AgoraRtmMessageType type;
@property (nonatomic, copy) NSString *text;

/** Creates a text message to be sent by the user. 
 
 @param text Text message with a string of less than 32 KB.

 */
- (instancetype _Nonnull)initWithText:(NSString *)text;
@end

@protocol AgoraRtmChannelDelegate;

@protocol AgoraRtmDelegate <NSObject>
@optional

/** Occurs when a connection state changes.

 @param kit An AgoraRtmKit instance bound to the delegate.
 @param state New connection state. See AgoraRtmConnectionState.

 */
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason;
/** Occurs when a message is received.
 
 @param kit An AgoraRtmKit instance bound to the delegate.
 @param message The received message.
 @param peerId User ID of the user sending the message.
 
 */
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId;
@end

__attribute__((visibility("default"))) @interface AgoraRtmKit: NSObject
@property (atomic, weak) id<AgoraRtmDelegate> agoraRtmDelegate;
@property (nonatomic, readonly, nullable) NSMutableDictionary<NSString *, AgoraRtmChannel *> *channels;

/** Creates an RtmClient instance. 

The Agora RTM SDK supports multiple RtmClient instances.

@param appId The App ID issued by Agora for your project in Agora Dashboard. Apply for a new App ID from Agora if it is missing from your kit.

@param delegate AgoraRtmDelegate for receiving callbacks. 

@return

 */
- (instancetype _Nullable)initWithAppId:(NSString * _Nonnull)appId
                              delegate:(id <AgoraRtmDelegate> _Nullable)delegate;

/** Allows a user to log in Agora's real-time messaging system.
 
 @param token A token generated by the app server and used to log in Agora's real-time messaging system. @p token is used when dynamic authentication is enabled. Set @p token as @p nil at the integration and test stages.

 @param userId User ID of the user logging in Agora's real-time messaging system.
 
 - The string can neither exceed 64 bytes in length nor start with a space. 
 - Supported characters:
    - The 26 lowercase English letters: a to z
    - The 26 uppercase English letters: A to Z
    - The 10 numbers: 0 to 9
    - Space
    - "!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?", "@", "[", "]", "^", "_", " {", "}", "|", "~", ","
 
 **Note:** Do not set `userId` as `nil`.

 @param completionBlock Login status. See AgoraRtmLoginErrorCode.

 */
- (void)loginByToken:(NSString * _Nullable)token
                user:(NSString * _Nonnull)userId
          completion:(AgoraRtmLoginBlock _Nullable)completionBlock;
/** Allows a user to log out of Agora's real-time messaging system.
 
 @param completionBlock Logout status. See AgoraRtmLogoutErrorCode.
 */
- (void)logoutWithCompletion:(AgoraRtmLogoutBlock _Nullable )completionBlock;

/** Allows a user to send a point-to-point (P2P) message to a specific peer user.

 @param message The message to be sent. For information about creating a message, see AgoraRtmMessage.

 @param peerId User ID of the peer user.

 @param completionBlock The state of sending the message. See AgoraRtmSendPeerMessageState.

 */
- (void)sendMessage:(AgoraRtmMessage * _Nonnull)message
             toPeer:(NSString * _Nonnull)peerId
         completion:(AgoraRtmSendPeerMessageBlock _Nullable)completionBlock;

/** Creates an Agora real-time messaging channel.

**Note:** You can create multiple channels in an RtmClient instance.

@param channelId The unique channel name for the Agora RTM session in the string format smaller than 64 bytes and cannot be empty or set as `null`. 

Supported characters:
 - The 26 lowercase English letters: a to z
 - The 26 uppercase English letters: A to Z
 - The 10 numbers: 0 to 9
 - Space
 -"!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?", "@", "[", "]", "^", "_", " {", "}", "|", "~", ","

@param delegate AgoraRtmDelegate for receiving callbacks. 
*/
- (AgoraRtmChannel * _Nullable)createChannelWithId:(NSString * _Nonnull)channelId
                                    delegate:(id <AgoraRtmChannelDelegate> _Nullable)delegate;
/**
 
 */
- (BOOL)destroyChannelWithId: (NSString *) channelId;

/**-----------------------------------------------------------------------------
 * @name Customized Methods (Technical Preview)
 * -----------------------------------------------------------------------------
 */

/** Provides the technical preview functionalities or special customizations by configuring the SDK with JSON options.

 **Note:**

 The JSON options are not public by default. Agora is working on making commonly used JSON options public in a standard way. Contact [support@agora.io](mailto:support@agora.io) for more information.

 @param options SDK options in JSON format.
 */
- (int)setParameters:(NSString * _Nonnull)options;

@end


#pragma mark channel

/** The state of sending a channel message.
*/
typedef NS_ENUM(NSInteger, AgoraRtmSendChannelMessageState) {
    /** The initial state. The channel message is not sent. */
    AgoraRtmSendChannelMessageStateInit = 0,
    /** Fails to send the channel message. */
    AgoraRtmSendChannelMessageStateFailure = 1,
    /** The channel message is received by the server. */
    AgoraRtmSendChannelMessageStateReceivedByServer = 2,
    /** A timeout in sending the channel message. */
    AgoraRtmSendChannelMessageStateTimeout = 4,
};

/** The state of a user joining a channel.
*/
typedef NS_ENUM(NSInteger, AgoraRtmJoinChannelErrorCode) {
    /** The user joins the channel successfully. */
    AgoraRtmJoinChannelErrorOk = 0,
    /** The user fails to join the channel. */
    AgoraRtmJoinChannelErrorFailure = 1,
    /** The user cannot join the channel. The user may already be in the channel. */
    AgoraRtmJoinChannelErrorRejected = 2,
    /** The user fails to join the channel. Maybe the argument is invalid. */
    AgoraRtmJoinChannelErrorInvalidArgument = 3,
    /** A timeout in joining the channel. */
    AgoraRtmJoinChannelErrorTimeout = 4,
};

/** The state of a user leaving a channel. 
*/
typedef NS_ENUM(NSInteger, AgoraRtmLeaveChannelErrorCode) {
    /** The user leaves the channel successfully. */
    AgoraRtmLeaveChannelErrorOk = 0,
    /** The user fails to leaves the channel. */
    AgoraRtmLeaveChannelErrorFailure = 1,
    /** The user cannot leave the channel. The user may not be in the channel. */
    AgoraRtmLeaveChannelErrorRejected = 2,
};

/** The state of retrieving the user list of a channel.
*/
typedef NS_ENUM(NSInteger, AgoraRtmGetMembersErrorCode) {
    /** Retrieves the user list of a channel. */
    AgoraRtmGetMembersErrorOk = 0,
    /** Fails to retrieve the user list of a channel. */
    AgoraRtmGetMembersErrorFailure = 1,
    /** Cannot retrieve the user list of a channel. */
    AgoraRtmGetMembersErrorRejected = 2,
    /** A timeout in retreiving the user list of a channel. */
    AgoraRtmGetMembersErrorTimeout = 3,
};

typedef void (^AgoraRtmJoinChannelBlock)(AgoraRtmJoinChannelErrorCode state);
typedef void (^AgoraRtmLeaveChannelBlock)(AgoraRtmLeaveChannelErrorCode state);
typedef void (^AgoraRtmSendChannelMessageBlock)(AgoraRtmSendChannelMessageState state);
typedef void (^AgoraRtmGetMembersBlock)(NSArray *members, AgoraRtmGetMembersErrorCode errorCode);

__attribute__((visibility("default"))) @interface AgoraRtmMember: NSObject
@property (nonatomic, copy, nonnull) NSString *userId;
@property (nonatomic, copy, nonnull) NSString *channelId;
@end

/** The AgoraRtmChannelDelegate protocol enables callback event notifications to your app.
 
 The SDK uses delegate callbacks in the AgoraRtmChannelDelegate protocol to report runtime events to the app.

*/
@protocol AgoraRtmChannelDelegate <NSObject>
@optional
/** Occurs when a user joins a channel.
 
 @param member User ID of the user joining the channel.
 */
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit channel:(AgoraRtmChannel * _Nonnull)channel memberJoined:(AgoraRtmMember * _Nonnull)member;
/** Occurs when a user leaves a channel.

@param member User ID of the user leaving the channel. 
 */
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit channel:(AgoraRtmChannel * _Nonnull)channel memberLeft:(AgoraRtmMember * _Nonnull)member;
/** Occurs when a message is received.
  
 @param message The received message.

 @param member User ID of the user sending the message.
 
 */
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member;
@end

__attribute__((visibility("default"))) @interface AgoraRtmChannel: NSObject
/** Allows a user to join a channel.
 
 @param completionBlock Returns:
 - The [memberJoined]([AgoraRtmChannelDelegate rtmKit:channel:memberJoined:]) callback, if this method call succeeds.
 - An error code (see AgoraRtmJoinChannelErrorCode), if this method call fails.

 */
- (void)joinWithCompletion:(AgoraRtmJoinChannelBlock _Nullable)completionBlock;
/** Allows a user to leave a channel.
 
 @param completionBlock Returns:
 
 - The [memberLeft]([AgoraRtmChannelDelegate rtmKit:channel:memberLeft:]) callback, if this method call succeeds.
 - An error code (see AgoraRtmLeaveChannelErrorCode), if this method call fails.
 */
- (void)leaveWithCompletion:(AgoraRtmLeaveChannelBlock _Nullable)completionBlock;

/** Allows a user to send a message to a channel.
 
 @param message The message to be sent.

 @param completionBlock The state of sending the message. See AgoraRtmSendChannelMessageState.

 */
- (void)sendMessage:(AgoraRtmMessage * _Nonnull)message
         completion:(AgoraRtmSendChannelMessageBlock _Nullable)completionBlock;
/** Retrieves the user list of a channel.
 
 @param completionBlock Returns:
 
 - The list of users in the channel, if this method call succeeds.
 - An error code (see AgoraRtmGetMembersErrorCode), if this method call fails. 
 */
- (void)getMembersWithCompletion:(AgoraRtmGetMembersBlock _Nullable)completionBlock;
@end
