
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
        _sharedReal.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain",@"text/html",nil];
        _sharedReal.requestSerializer = [AFJSONRequestSerializer serializer];
        
        _sharedReal.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    if (parameters==nil) {
        parameters = @{};
    }
    
    //todo
    NSMutableDictionary *muteParam = [[NSMutableDictionary alloc] init];
//    [muteParam setObject:apicode forKey:@"apicode"];
    [muteParam setObject:parameters forKey:@"args"];
    [muteParam setObject:@"" forKey:@"token"];
    
    NSMutableURLRequest *request  =[_sharedReal.requestSerializer requestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@",baseUrl,apicode] parameters:[muteParam mutableCopy] error:nil];
    [[_sharedReal dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary *  _Nullable responseObject, NSError * _Nullable error) {
        if (complete!=nil) {
            complete();
        }
        if (error) {
            if (failed!=nil){
                failed(@"网络错误",@"网络错误或接口调用失败");
            }
            return;
        }
        if ([responseObject[@"retcode"] integerValue] != 1) {
            failed(responseObject[@"msg"][@"error"],responseObject[@"msg"][@"prompt"]);
        }
        else
        {
            NSString *modelStr = [JJApiClient mapModel][apicode];
            if (modelStr!=nil && ![modelStr isEqualToString:@""]) {
                Class cla = NSClassFromString(modelStr);
                if (!cla) {
                    NSLog(@"找不到对应模型类，%@", modelStr);
                }
                success([cla yy_modelWithJSON:responseObject[@"obj"]],responseObject[@"msg"][@"prompt"]);
            }
            else{
                success(responseObject[@"obj"],responseObject[@"msg"][@"prompt"]);
            }
        }
    }] resume];
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
