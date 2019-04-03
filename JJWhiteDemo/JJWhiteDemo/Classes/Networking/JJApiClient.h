
#import <Foundation/Foundation.h>

@interface JJApiClient : NSObject
//TODO:Apicode
/*----------------------url地址-------------------*/

extern NSString *const ApiCodeGetClassRoom;
extern NSString *const ApiCodeGetChannelUser;
extern NSString *const ApiCodeGetChannelAllUser;
extern NSString *const ApiCodeGetUserById;
extern NSString *const ApiCodeGetTeacherById;
extern NSString *const ApiCodeUploadImageGetWH;


+(NSDictionary *)mapModel;


@end
