//
//  BroadcastSetupViewController.m
//  ScreenSharingDemoBroadcastSetupUI
//
//  Created by mude on 2019/3/29.
//  Copyright © 2019 mude. All rights reserved.
//

#import "BroadcastSetupViewController.h"

@interface BroadcastSetupViewController()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *channelNameTextField;
@end

@implementation BroadcastSetupViewController
- (IBAction)doCancelPressed:(id)sender {
    [self userDidCancelSetup];
}

- (IBAction)doStartPressed:(id)sender {
    [self userStartBroadcastWithChannel:_channelNameTextField.text];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self userDidFinishSetup];
}

- (void)userStartBroadcastWithChannel:(NSString *)channel {
    if ([channel isEqualToString:@""] || !channel) {
        return;
    }
    NSDictionary *setupInfo = @{@"channelName":channel};
    [[NSExtensionContext alloc] completeRequestWithBroadcastURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://apple.com/broadcast/streamID"]] setupInfo:setupInfo];
}

// Call this method when the user has finished interacting with the view controller and a broadcast stream can start
- (void)userDidFinishSetup {
    
    // URL of the resource where broadcast can be viewed that will be returned to the application
    NSURL *broadcastURL = [NSURL URLWithString:@"http://apple.com/broadcast/streamID"];
    
    // Dictionary with setup information that will be provided to broadcast extension when broadcast is started
    //应用拓展之间公用数据
    NSDictionary *myData = [[[NSUserDefaults alloc] initWithSuiteName:@"group.JJWhiteDemo"] valueForKey:@"shareData"];
    
    // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
    [self.extensionContext completeRequestWithBroadcastURL:broadcastURL setupInfo:myData];
}

- (void)userDidCancelSetup {
    // Tell ReplayKit that the extension was cancelled by the user
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"cn.com.mude.JJWhiteDemo.JJWhiteDemoBroadcastSetupUI" code:-1 userInfo:nil]];
}

@end
