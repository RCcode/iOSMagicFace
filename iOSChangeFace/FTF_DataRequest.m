//
//  ME_DataRequest.m
//  IOSMirror
//
//  Created by gaoluyangrc on 14-7-4.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import "FTF_DataRequest.h"
#import "AppDelegate.h"
#import "CMethods.h"
#import "Reachability.h"
#import "AFNetworking/AFNetworking/AFNetworking.h"

@implementation FTF_DataRequest

- (id)initWithDelegate:(id<WebRequestDelegate>)request_Delegate
{
    self = [super init];
    
    self.delegate = request_Delegate;
    
    return self;
}

#pragma mark -
#pragma mark 公共请求 （Post）
- (void)requestServiceWithPost:(NSString *)url_Str jsonRequestSerializer:(AFJSONRequestSerializer *)requestSerializer isRegisterToken:(BOOL)token
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HTTP_BASEURL,url_Str];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.manager.requestSerializer = requestSerializer;
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    appDelegate.manager.responseSerializer = responseSerializer;
    
    [appDelegate.manager POST:token?kPushURL:url parameters:self.valuesDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //解析数据
        NSDictionary *dic = (NSDictionary *)responseObject;
        [self.delegate didReceivedData:dic withTag:requestTag];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hideMBProgressHUD();
        NSLog(@"error.......%@",error);
        [self.delegate requestFailed:requestTag];
    }];
}

#pragma mark -
#pragma mark 公共请求 （Get）
- (void)requestServiceWithGet:(NSString *)url_Str
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    appDelegate.manager.requestSerializer = requestSerializer;
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    appDelegate.manager.responseSerializer = responseSerializer;
    
    [appDelegate.manager GET:url_Str parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         //解析数据
                         NSDictionary *dic = (NSDictionary *)responseObject;
                         [self.delegate didReceivedData:dic withTag:requestTag];
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         [self.delegate requestFailed:requestTag];
                     }];
    
}

#pragma mark -
#pragma mark 版本更新
- (void)updateVersion:(NSString *)url withTag:(NSInteger)tag
{
    if (![self checkNetWorking])
        return;
    requestTag = tag;
    [self requestServiceWithGet:url];
}

#pragma mark -
#pragma mark 注册设备
- (void)registerToken:(NSDictionary *)dictionary withTag:(NSInteger)tag
{
    if (![self checkNetWorking])
        return;
    requestTag = tag;
    self.valuesDictionary = dictionary;
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setTimeoutInterval:30];
    [self requestServiceWithPost:nil jsonRequestSerializer:requestSerializer  isRegisterToken:YES];
}

#pragma mark -
#pragma mark 更多应用
- (void)moreApp:(NSDictionary *)dictionary withTag:(NSInteger)tag
{
    if (![self checkNetWorking])
        return;
    requestTag = tag;
    self.valuesDictionary = dictionary;
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSerializer setTimeoutInterval:30];

    [self requestServiceWithPost:@"getIOSAppListNew.do" jsonRequestSerializer:requestSerializer  isRegisterToken:NO];
}

#pragma mark -
#pragma mark 检测网络状态
- (BOOL)checkNetWorking
{
    
    BOOL connected = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable ? YES : NO;

    return connected;
}

@end
