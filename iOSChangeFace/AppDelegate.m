//
//  AppDelegate.m
//  iOSChangeFace
//
//  Created by gaoluyangrc on 14-7-26.
//  Copyright (c) 2014年 rcplatform. All rights reserved.
//

#import "AppDelegate.h"
#import "MobClick.h"
#import "Flurry.h"
#import "GADBannerView.h"
#import "FTF_RootViewController.h"
#import "SliderViewController.h"
#import "Pic_MenuViewController.h"
#import "LRNavigationController.h"
#import "FTF_Global.h"
#import "CMethods.h"
#import "RC_AppInfo.h"
#import "ME_SQLMassager.h"
#import "FTF_DataRequest.h"
#import "UIDevice+DeviceInfo.h"
#import <AdSupport/AdSupport.h>
#define AdMobID @"ca-app-pub-3747943735238482/7117549852"
#define UMengKey @"5477e76bfd98c51dbb000031"
#define FlurryAppKey @"Q85WBVSCNNNC284VSQ8K"
#define UDKEY_ShareCount @"shareCount"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [SliderViewController sharedSliderController].LeftVC=[[Pic_MenuViewController alloc] init];
    LRNavigationController *nav=[[LRNavigationController alloc] initWithRootViewController:[SliderViewController sharedSliderController]];
    
    nav.navigationBar.translucent = NO;
    //navBar背景图
    UIEdgeInsets ed = {0.0f, 10.0f, 0.0f, 10.0f};
    UIImage *image = [pngImagePath(@"bg") resizableImageWithCapInsets:ed resizingMode:UIImageResizingModeTile];
    [nav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    nav.canDragBack = NO;
    
    [FTF_Global shareGlobal].nav = nav;
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
    //注册通知
    [self registNotification];
    
    if (iPhone5())
    {
        //广告
        [self adMobSetting];
    }
    
    //友盟
    [self umengSetting];
    
    //AFNetWorking
    [self netWorkingSetting];
    
    //检测更新
    [self checkVersion];
    
    //下载应用列表
    [self downLoadAppsInfo];
    
    
    //4次分享，即弹框
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    int shareCount = [[userDefault objectForKey:UDKEY_ShareCount] intValue];
    
    if(shareCount != -1)
    {
        shareCount++;
        if((shareCount >= 4) && !(shareCount % 4)){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:LocalizedString(@"comment_us", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"normal", nil)
                                                  otherButtonTitles:LocalizedString(@"good", nil), LocalizedString(@"bad", nil), nil];
            alert.tag = 11;
            [alert show];
        }
        
        [userDefault setObject:@(shareCount) forKey:UDKEY_ShareCount];
        [userDefault synchronize];
    }
    
    [self cancelNotification];
    return YES;
}

- (void)memoryInfo{
    logMemoryInfo();
}

#pragma mark -
#pragma mark umeng
- (void)umengSetting
{
    [MobClick startWithAppkey:UMengKey reportPolicy:SEND_ON_EXIT channelId:@"App Store"];
    [MobClick updateOnlineConfig];
    
    [Flurry startSession:FlurryAppKey];
    [Flurry setSessionReportsOnCloseEnabled:YES];
}

#pragma mark -
#pragma mark 版本检测
- (void)checkVersion
{
    NSString *urlStr = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appleID];
    FTF_DataRequest *request = [[FTF_DataRequest alloc] initWithDelegate:self];
    [request updateVersion:urlStr withTag:10];
}

- (void)downLoadAppsInfo
{
    //Bundle Id
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *language = [[NSLocale preferredLanguages] firstObject];
    if ([language isEqualToString:@"zh-Hans"])
    {
        language = @"zh";
    }
    
    NSDictionary *dic = @{@"appId":[NSNumber numberWithInt:moreAppID],@"packageName":bundleIdentifier,@"language":language,@"version":currentVersion,@"platform":[NSNumber numberWithInt:0]};
    FTF_DataRequest *request = [[FTF_DataRequest alloc] initWithDelegate:self];
    [request moreApp:dic withTag:11];
}

#pragma mark -
#pragma mark 配置广告条
- (void)adMobSetting
{
    /** AdMob相关 **/
    CGPoint origin = CGPointMake(0, [UIScreen mainScreen].bounds.size.height - kGADAdSizeBanner.size.height);
    GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:origin];
    bannerView.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:bannerView];
    bannerView.adUnitID = AdMobID;
    bannerView.rootViewController = self.window.rootViewController;
    GADRequest *request = [GADRequest request];
    NSString *deviesID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    request.testDevices = @[deviesID];
    [bannerView loadRequest:request];
    //赋值
    [FTF_Global shareGlobal].bannerView = bannerView;
    
}

- (void)registNotification
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                             categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

- (void)cancelNotification{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

#pragma mark -
#pragma mark 处理远程通知事件
- (void)doNotificationWithInfo:(NSDictionary *)userInfo{
    [self cancelNotification];
    
    if(userInfo == nil) return;
    
    NSDictionary *dictionary = [userInfo objectForKey:@"aps"];
    NSString *alert = [dictionary objectForKey:@"alert"];
    NSString *type = [userInfo objectForKey:@"type"];
    NSString *urlStr = [userInfo objectForKey:@"url"];
    
    switch (type.intValue) {
        case 0:
        {
            //Ad
            self.updateUrlStr = urlStr;
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@""
                                                               message:alert
                                                              delegate:self
                                                     cancelButtonTitle:LocalizedString(@"cancel", @"")
                                                     otherButtonTitles:LocalizedString(@"dialog_sure", @""), nil];
            alertView.tag = 12;
            [alertView show];
            
        }
            break;
        case 1:
        {
            //Update
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                           message:LocalizedString(@"New Version available", @"")
                                                          delegate:self
                                                 cancelButtonTitle:LocalizedString(@"Remind later", @"")
                                                 otherButtonTitles:LocalizedString(@"Upgrade now", @""), nil];
            alert.tag = 13;
            [alert show];
        }
            break;
        default:
            break;
    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSRange range = NSMakeRange(1,[[deviceToken description] length]-2);
    NSString *deviceTokenStr = [[deviceToken description] substringWithRange:range];
    NSLog(@"deviceTokenStr==%@",deviceTokenStr);
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    if (token == nil || [token isKindOfClass:[NSNull class]] || ![token isEqualToString:deviceTokenStr]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:deviceTokenStr forKey:@"deviceToken"];
        //注册token
        [self postData:[NSString stringWithFormat:@"%@",deviceTokenStr]];
    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Fail to Register For Remote Notificaions With Error :error = %@",error.description);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self doNotificationWithInfo:userInfo];
}

#pragma mark -
#pragma mark 提交设备信息
- (void)postData:(NSString *)token{
    NSDictionary *infoDic = [self deviceInfomation:token];
    FTF_DataRequest *request = [[FTF_DataRequest alloc] initWithDelegate:self];
    [request registerToken:infoDic withTag:11];
}

#pragma mark -
#pragma mark 配置AFN
- (void)netWorkingSetting
{
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
}

#pragma mark -
#pragma mark 获取设备信息
- (NSDictionary *)deviceInfomation:(NSString *)token
{
    
    @autoreleasepool {
        //Bundle Id
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        //NSString *macAddress = [UIDevice getMacAddressWithUIDevice];
        NSString *systemVersion = [UIDevice currentVersion];
        NSString *model = [UIDevice currentModel];
        NSString *modelVersion = [UIDevice currentModelVersion];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"Z"];
        NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
        [dateFormatter setTimeZone:timeZone];
        NSDate *date = [NSDate date];
        //+0800
        NSString *timeZoneZ = [dateFormatter stringFromDate:date];
        NSRange range = NSMakeRange(0, 3);
        //+08
        NSString *timeZoneInt = [timeZoneZ substringWithRange:range];
        
        //en
        NSArray *languageArray = [NSLocale preferredLanguages];
        NSString *language = [languageArray objectAtIndex:0];
        
        //US
        NSLocale *locale = [NSLocale currentLocale];
        NSString *country = [[[locale localeIdentifier] componentsSeparatedByString:@"_"] lastObject];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:token forKeyPath:@"token"];
        [params setValue:timeZoneInt forKeyPath:@"timeZone"];
        [params setValue:language forKey:@"language"];
        [params setValue:bundleIdentifier forKeyPath:@"bundleid"];
        [params setValue:idfv forKeyPath:@"mac"];
        [params setValue:bundleIdentifier forKeyPath:@"pagename"];
        [params setValue:model forKeyPath:@"model"];
        [params setValue:modelVersion forKeyPath:@"model_ver"];
        [params setValue:systemVersion forKeyPath:@"sysver"];
        [params setValue:country forKeyPath:@"country"];
        
        return params;
    }
    
}

#pragma mark -
#pragma mark WebDataRequestDelegate
- (void)didReceivedData:(NSDictionary *)dic withTag:(NSInteger)tag
{
    switch (tag) {
        case 10:
        {
            //解析数据
            NSArray *results = [dic objectForKey:@"results"];
            if ([results count] == 0 || results == nil || [results isKindOfClass:[NSNull class]])
            {
                return ;
            }
            
            NSDictionary *dictionary = [results objectAtIndex:0];
            NSString *version = [dictionary objectForKey:@"version"];
            NSString *trackViewUrl = [dictionary objectForKey:@"trackViewUrl"];//地址trackViewUrl
            self.trackURL = trackViewUrl;
            
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString *currentVersion = [infoDict objectForKey:@"CFBundleVersion"];
            
            if ([currentVersion compare:version options:NSNumericSearch] == NSOrderedAscending)
            {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                               message:LocalizedString(@"application_update", @"")
                                                              delegate:self
                                                     cancelButtonTitle:LocalizedString(@"cancel", @"")
                                                     otherButtonTitles:LocalizedString(@"go", @""), nil];
                alert.tag = 14;
                [alert show];
                
            }
        }
            break;
        case 11:
        {
            NSArray *infoArray = [dic objectForKey:@"list"];
            NSMutableArray *isDownArray = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *noDownArray = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *infoDic in infoArray)
            {
                RC_AppInfo *appInfo = [[RC_AppInfo alloc]initWithDictionary:infoDic];
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appInfo.openUrl]])
                {
                    [isDownArray addObject:appInfo];
                }
                else
                {
                    [noDownArray addObject:appInfo];
                }
            }
            NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
            [dataArray addObjectsFromArray:noDownArray];
            [dataArray addObjectsFromArray:isDownArray];
            [FTF_Global shareGlobal].appsArray = dataArray;
            
            //判断是否有新应用
            if ([FTF_Global shareGlobal].appsArray.count > 0) {
                NSMutableArray *dataArray = [[ME_SQLMassager shareStance] getAllData];
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
                
                for (RC_AppInfo *app in [FTF_Global shareGlobal].appsArray)
                {
                    BOOL isHave = NO;
                    for (RC_AppInfo *appInfo in dataArray)
                    {
                        if (app.appId == appInfo.appId)
                        {
                            isHave = YES;
                        }
                    }
                    if (!isHave) {
                        [array addObject:app];
                    }
                }
                
                //插入新数据
                if (array.count > 0)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"MoreAPP"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"addMoreImage" object:nil];
                    [[ME_SQLMassager shareStance] insertAppInfo:array];
                }
            }
        }
            break;
        default:
            break;
    }
    
    hideMBProgressHUD();
}

- (void)requestFailed:(NSInteger)tag
{
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 11)
    {
        if(buttonIndex == 0)
        {
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@(-1) forKey:UDKEY_ShareCount];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if(buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreURL]];
        }
    }
    else if (alertView.tag == 12)
    {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updateUrlStr]];
        }
    }
    else if (alertView.tag == 13 || alertView.tag == 14)
    {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreURL]];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"即将进入前台");
    [self cancelNotification];
    
    //优先取全局变量中的数据，取不到 再取数据库中的
    NSMutableArray *temp_appInfoArr = [[ME_SQLMassager shareStance] getAllData];
    NSMutableArray *appInfoArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *un_down_datasource = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *have_down_datasource = [NSMutableArray arrayWithCapacity:0];
    for (RC_AppInfo *appInfo in temp_appInfoArr)
    {
        NSURL *url = [NSURL URLWithString:appInfo.openUrl];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [have_down_datasource addObject:appInfo];
        }
        else
        {
            [un_down_datasource addObject:appInfo];
        }
    }
    
    [appInfoArr addObjectsFromArray:un_down_datasource];
    [appInfoArr addObjectsFromArray:have_down_datasource];
    
    if(appInfoArr == nil)
        return;
    
    [FTF_Global shareGlobal].appsArray = nil;
    [FTF_Global shareGlobal].appsArray = appInfoArr;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMoreApp" object:nil];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
