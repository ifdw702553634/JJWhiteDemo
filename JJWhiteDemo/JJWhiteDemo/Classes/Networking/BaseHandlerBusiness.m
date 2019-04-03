
#import "BaseHandlerBusiness.h"
#import "YYModel.h"
#import "sys/utsname.h"
#import "JJApiClient.h"

static BaseHandlerBusiness *_sharedReal = nil;
static dispatch_once_t onceTokenReal;

@implementation BaseHandlerBusiness

+ (void)PostServiceWithBaseUrl:(NSString *)baseUrl Apicode:(NSString*)apicode Parameters:(NSDictionary*)parameters Success:(ApiSuccessBlock)success Failed:(ApiFailedBlock)failed Complete:(ApiCompleteBlock)complete{
    
    dispatch_once(&onceTokenReal, ^{
        _sharedReal = [[BaseHandlerBusiness alloc] init];
        _sharedReal.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain",@"text/html",@"multipart/form-data",nil];
        _sharedReal.requestSerializer = [AFJSONRequestSerializer serializer];
        
        _sharedReal.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    if (parameters==nil) {
        parameters = @{};
    }
    
    NSMutableURLRequest *request  =[_sharedReal.requestSerializer requestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@",baseUrl,apicode] parameters:[parameters mutableCopy] error:nil];
    [[_sharedReal dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (complete!=nil) {
            complete();
        }
        if (error) {
            if (failed!=nil){
                failed(@"网络错误",@"网络错误或接口调用失败");
            }
            return;
        }
        if ([responseObject[@"code"] integerValue] != 200) {
            failed(responseObject[@"msg"],responseObject[@"state"]);
        }
        else
        {
            NSString *modelStr = [JJApiClient mapModel][apicode];
            if (modelStr!=nil && ![modelStr isEqualToString:@""]) {
                Class cla = NSClassFromString(modelStr);
                if (!cla) {
                    NSLog(@"找不到对应模型类，%@", modelStr);
                }
                success([cla yy_modelWithJSON:responseObject[@"data"]],responseObject[@"msg"]);
            }
            else{
                success(responseObject[@"data"],responseObject[@"msg"]);
            }
        }
    }] resume];
}

+ (void)PostServiceUploadDataWithBaseUrl:(NSString *)baseUrl Data:(NSData *)data Apicode:(NSString*)apicode Parameters:(NSDictionary*)parameters Success:(ApiSuccessBlock)success Failed:(ApiFailedBlock)failed Complete:(ApiCompleteBlock)complete{
    
    dispatch_once(&onceTokenReal, ^{
        _sharedReal = [[BaseHandlerBusiness alloc] init];
        [_sharedReal.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        _sharedReal.requestSerializer = [AFHTTPRequestSerializer serializer];
        _sharedReal.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sharedReal.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript",@"text/plain", nil];
        
        _sharedReal.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    [_sharedReal POST:[NSString stringWithFormat:@"%@%@",baseUrl,apicode] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //当提交一张图片或一个文件的时候 name 可以随便设置，服务端直接能拿到，如果服务端需要根据name去取不同文件的时候，则appendPartWithFileData 方法中的 name 需要根据form的中的name一一对应
        NSData *jsonData = [parameters[@"dir"] dataUsingEncoding:NSUTF8StringEncoding];
        [formData appendPartWithFormData:jsonData name:@"dir"];
        
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval timeInterval =[dat timeIntervalSince1970];
        [formData appendPartWithFileData: data name:@"Img" fileName:[NSString stringWithFormat:@"%.6f.png",timeInterval] mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] integerValue] != 200) {
            failed(responseObject[@"msg"],responseObject[@"state"]);
        }
        else
        {
            NSString *modelStr = [JJApiClient mapModel][apicode];
            if (modelStr!=nil && ![modelStr isEqualToString:@""]) {
                Class cla = NSClassFromString(modelStr);
                if (!cla) {
                    NSLog(@"找不到对应模型类，%@", modelStr);
                }
                success([cla yy_modelWithJSON:responseObject[@"data"]],responseObject[@"msg"]);
            }
            else{
                success(responseObject[@"data"],responseObject[@"msg"]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            if (failed!=nil){
                failed(@"网络错误",@"网络错误或接口调用失败");
            }
            return;
        }
    }];
    
    
}

+ (void)GetServiceWithBaseUrl:(NSString *)baseUrl Apicode:(NSString*)apicode Parameters:(NSDictionary*)parameters Success:(ApiSuccessBlock)success Failed:(ApiFailedBlock)failed Complete:(ApiCompleteBlock)complete{
    
    dispatch_once(&onceTokenReal, ^{
        _sharedReal = [[BaseHandlerBusiness alloc] init];
        _sharedReal.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain",@"text/html",nil];
        _sharedReal.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedReal.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    NSMutableURLRequest *request  =[_sharedReal.requestSerializer requestWithMethod:@"Get" URLString:[NSString stringWithFormat:@"%@%@",baseUrl,apicode] parameters:parameters error:nil];
    
    
    [[_sharedReal dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (complete!=nil) {
            complete();
        }
        if (error) {
            if (failed!=nil){
                failed(@"网络错误",@"网络错误或接口调用失败");
            }
            return;
        }
        if ([responseObject[@"code"] integerValue] != 200) {
            failed(responseObject[@"msg"],responseObject[@"state"]);
        }
        else
        {
            NSString *modelStr = [JJApiClient mapModel][apicode];
            if (modelStr!=nil && ![modelStr isEqualToString:@""]) {
                Class cla = NSClassFromString(modelStr);
                if (!cla) {
                    NSLog(@"找不到对应模型类，%@", modelStr);
                }
                success([cla yy_modelWithJSON:responseObject[@"data"]],responseObject[@"msg"]);
            }
            else{
                success(responseObject[@"data"],responseObject[@"msg"]);
            }
        }
    }] resume];
}


@end
