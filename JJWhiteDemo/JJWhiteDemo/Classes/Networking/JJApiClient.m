
#import "JJApiClient.h"

@implementation JJApiClient

//TODO：接口
//*---------------------- http:// -----------------*/

NSString *const ApiCodeGetClassRoom    = @"/getClassRoom";
NSString *const ApiCodeGetChannelUser  = @"/getChannelUser";
NSString *const ApiCodeGetChannelAllUser = @"/getChannelAllUser";
NSString *const ApiCodeGetUserById = @"/getUserById";
NSString *const ApiCodeGetTeacherById = @"/getTeacherById";
NSString *const ApiCodeUploadImageGetWH = @"/comm/UploadImageGetWH";

/**
 *  接口apicode和Model映射关系
 *
 *  @return 映射字典
 */
+(NSDictionary *)mapModel
{
    //TODO:对应 model
    return @{
             };
}

@end
