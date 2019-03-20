//
//  BaseHandlerBusiness.h
//  AHCAD
//
//  Created by zjm on 2017/9/8.
//  Copyright © 2017年 DreamTouch. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <Foundation/Foundation.h>
#import "JJApiClient.h"

@interface BaseHandlerBusiness : AFHTTPSessionManager
/**
 *  Handler处理完成后调用的Block
 */
typedef void (^ApiCompleteBlock)();

/**
 *  Handler处理成功时调用的Block
 */
typedef void (^ApiSuccessBlock)(id data , id msg);

/**
 *  Handler处理失败时调用的Block
 */
typedef void (^ApiFailedBlock)(NSString * error ,NSString * errorDescription);

+ (void)PostServiceWithBaseUrl:(NSString *)baseUrl Apicode:(NSString*)apicode Parameters:(NSDictionary*)parameters Success:(ApiSuccessBlock)success Failed:(ApiFailedBlock)failed Complete:(ApiCompleteBlock)complete;

//get方法
+ (void)GetServiceWithBaseUrl:(NSString *)baseUrl Apicode:(NSString*)apicode Parameters:(NSDictionary*)parameters Success:(ApiSuccessBlock)success Failed:(ApiFailedBlock)failed Complete:(ApiCompleteBlock)complete;

@end
