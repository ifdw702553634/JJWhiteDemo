
#import <Foundation/Foundation.h>
#import "BaseHandlerBusiness.h"

@interface HandlerBusiness : NSObject

/**
 *  Post调用接口 -
 */
+(void)JJPostServiceWithApicode:(NSString*)apicode Parameters:(NSDictionary*)parameters Success:(ApiSuccessBlock)success Failed:(ApiFailedBlock)failed Complete:(ApiCompleteBlock)complete;


/**
 *  Get接口
 */
+(void)JJGetServiceWithApicode:(NSString*)apicode Parameters:(NSDictionary*)parameters Success:(ApiSuccessBlock)success Failed:(ApiFailedBlock)failed Complete:(ApiCompleteBlock)complete;

@end
