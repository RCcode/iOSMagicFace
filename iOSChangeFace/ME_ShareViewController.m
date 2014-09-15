//
//  ME_ShareViewController.m
//  IOSMirror
//
//  Created by gaoluyangrc on 14-6-20.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#define btnWidth 53.f
#define btnHeight 53.f
#define labelWidth 75.f
#define labelHeight 20.f
#define label_Y 55.f
#define kToInstagramPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"EditImage.igo"]
#define kToMorePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"EditImage.jpg"]

static NSString *kShareHotTags = @"(Made with @face2face_rc)#face2face";

#import "CMethods.h"
#import "FTF_Global.h"
#import "ME_SQLMassager.h"
#import "FTF_DataRequest.h"
#import "RC_AppInfo.h"
#import "UIImageView+WebCache.h"
#import <Social/Social.h>

#import "ME_ShareViewController.h"

@interface ME_ShareViewController ()
{
    UITableView *appMoretableView;
    UIDocumentInteractionController *documetnInteractionController;
}
@end

@implementation ME_ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)dealloc
{
    [FTF_Global shareGlobal].bigImage = nil;
    appMoretableView = nil;
    documetnInteractionController = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = colorWithHexString(@"#eeeeee",1.f);
    
    CGFloat itemWH = 44;
    UIButton *navBackItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 129, itemWH)];
    [navBackItem setImage:pngImagePath(@"btn_back_normal") forState:UIControlStateNormal];
    [navBackItem setImage:pngImagePath(@"btn_back_pressed") forState:UIControlStateHighlighted];
    navBackItem.imageView.contentMode = UIViewContentModeCenter;
    navBackItem.imageEdgeInsets = UIEdgeInsetsMake(0, -32, 0, 0);
    [navBackItem addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navBackItem];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(0, 0, 44, 44);
    [nextBtn setImage:pngImagePath(@"btn_home_normal") forState:UIControlStateNormal];
    [nextBtn setImage:pngImagePath(@"btn_home_pressed") forState:UIControlStateHighlighted];
    nextBtn.imageView.contentMode = UIViewContentModeCenter;
    nextBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -32);
    [nextBtn addTarget:self action:@selector(homeItem:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:nextBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    NSArray *imagesNormalArray = [NSArray
        arrayWithObjects:@"btn_save_normal",@"btn_Insta_normal",@"btn_Facebook_normal",@"btn_more_normal", nil];
    NSArray *imagesSelectArray = [NSArray arrayWithObjects:@"btn_save_pressed",@"btn_Insta_pressed",@"btn_Facebook_pressed",@"btn_more_pressed", nil];
    NSArray *titleArray = [NSArray
        arrayWithObjects:LocalizedString(@"save", @""),@"Instagram",@"Facebook",LocalizedString(@"more", @""), nil];
    
    for (int i = 0; i < 4; i++) {
        
        UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(10 + labelWidth * i, 10, labelWidth, labelWidth)];
        
        UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        imageBtn.tag = i;
        [imageBtn setFrame:CGRectMake(11, 0, btnWidth, btnHeight)];
        [imageBtn setImage:pngImagePath([imagesNormalArray objectAtIndex:i]) forState:UIControlStateNormal];
        [imageBtn setImage:pngImagePath([imagesSelectArray objectAtIndex:i]) forState:UIControlStateSelected];
        [imageBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:imageBtn];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, label_Y, labelWidth, labelHeight)];
        titleLabel.text = [titleArray objectAtIndex:i];
        titleLabel.font = [UIFont systemFontOfSize:12.f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [backView addSubview:titleLabel];
        
        [self.view addSubview:backView];
    }
    
    UILabel *markLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, labelWidth + 12, 240, 40)];
    markLabel.text = LocalizedString(@"showWaterMark", @"");
    markLabel.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:markLabel];
    
    UISwitch *switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(250, labelWidth + 20, 80, 40)];
    if ([FTF_Global shareGlobal].isOn)
    {
        [switchBtn setOn:YES];
    }
    else
    {
        [switchBtn setOn:NO];
    }
    [switchBtn addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switchBtn];
    
    //判断是否已下载完数据
    if ([FTF_Global shareGlobal].appsArray.count == 0)
    {
        //查看数据库中是否存在
        if ([[ME_SQLMassager shareStance] getAllData].count == 0)
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
        else
        {
            [FTF_Global shareGlobal].appsArray = [[ME_SQLMassager shareStance] getAllData];
        }
    }
    
    appMoretableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 140, 320, iPhone5()?(self.view.bounds.size.height - 230):(self.view.bounds.size.height - 230 - 60))];
    [appMoretableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    appMoretableView.delegate = self;
    appMoretableView.dataSource = self;
    appMoretableView.backgroundColor = colorWithHexString(@"#eeeeee",1.f);
    appMoretableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:appMoretableView];
    
}

- (void)switchChanged:(UISwitch *)switchBtn
{
    if (switchBtn.isOn)
    {
        [FTF_Global event:@"Share" label:@"water_On"];
    }
    else
    {
        [FTF_Global event:@"Share" label:@"water_Off"];
    }
    [FTF_Global shareGlobal].isOn = switchBtn.isOn;
    [FTF_Global shareGlobal].bigImage = nil;
}

- (void)cancel:(id)sender
{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadView" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)homeItem:(id)sender
{
    if ([FTF_Global shareGlobal].isChange)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:LocalizedString(@"saveOrBack", @"")
                                                       delegate:self
                                              cancelButtonTitle:LocalizedString(@"cancel", @"")
                                              otherButtonTitles:LocalizedString(@"dialog_sure", @""),nil];
        alert.tag = 11;
        [alert show];
    }
    else
    {
        [FTF_Global shareGlobal].isCrop = NO;
        [FTF_Global shareGlobal].filterType = NC_NORMAL_FILTER;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 11 && buttonIndex == 1)
    {
        [FTF_Global shareGlobal].isChange = NO;
        [FTF_Global shareGlobal].isCrop = NO;
        [FTF_Global shareGlobal].filterType = NC_NORMAL_FILTER;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)btnClick:(UIButton *)button
{
    [FTF_Global shareGlobal].isChange = NO;

    if ([FTF_Global shareGlobal].bigImage == nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scaleImage" object:nil];
    }
    
    switch (button.tag)
    {
        case 0:
            [FTF_Global event:@"Share" label:@"Share_save"];
            UIImageWriteToSavedPhotosAlbum([FTF_Global shareGlobal].bigImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            break;
        case 1:
        {
            [FTF_Global event:@"Share" label:@"Share_Instagram"];
            NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
            if (![[UIApplication sharedApplication] canOpenURL:instagramURL])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:LocalizedString(@"instagram_notinstall", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:LocalizedString(@"dialog_sure", nil)
                                                          otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            
            //保存本地 如果已存在，则删除
            if([[NSFileManager defaultManager] fileExistsAtPath:kToInstagramPath]){
                [[NSFileManager defaultManager] removeItemAtPath:kToInstagramPath error:nil];
            }
            
            NSData *imageData = UIImageJPEGRepresentation([FTF_Global shareGlobal].bigImage, 1);
            [imageData writeToFile:kToInstagramPath atomically:YES];
            
            //分享
            NSURL *fileURL = [NSURL fileURLWithPath:kToInstagramPath];
            
            documetnInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
            documetnInteractionController.delegate = self;
            documetnInteractionController.UTI = @"com.instagram.exclusivegram";
            documetnInteractionController.annotation = @{@"InstagramCaption":kShareHotTags};
            [documetnInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated:YES];
        }
            break;
        case 2:
        {
            [FTF_Global event:@"Share" label:@"Share_Facebook"];
            SLComposeViewController *socialVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            // 写一个bolck，用于completionHandler的初始化
            SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result) {
                if (result == SLComposeViewControllerResultCancelled) {
                    NSLog(@"canceled");
                }
                else
                {
                    NSLog(@"done");
                }
                [socialVC dismissViewControllerAnimated:YES completion:Nil];
            };
            socialVC.completionHandler = myBlock;
            [socialVC addImage:[FTF_Global shareGlobal].bigImage];
            // 以模态的方式展现view controller
            if (socialVC != nil) {
                [self presentViewController:socialVC animated:YES completion:Nil];
            }else{
                [[[UIAlertView alloc] initWithTitle:@"No Facebook Account" message:@"There are no Facebook accounts configured. You can add or create a Facebook account in Settings" delegate: nil cancelButtonTitle:LocalizedString(@"Confirm", nil) otherButtonTitles:nil, nil] show];
            }
        }
            break;
        case 3:
        {
            [FTF_Global event:@"Share" label:@"Share_More"];
            //保存本地 如果已存在，则删除
            if([[NSFileManager defaultManager] fileExistsAtPath:kToMorePath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:kToMorePath error:nil];
            }
            
            NSData *imageData = UIImageJPEGRepresentation([FTF_Global shareGlobal].bigImage, 1);
            [imageData writeToFile:kToMorePath atomically:YES];
            
            NSURL *fileURL = [NSURL fileURLWithPath:kToMorePath];
            documetnInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
            documetnInteractionController.delegate = self;
            documetnInteractionController.UTI = @"com.instagram.photo";
            documetnInteractionController.annotation = @{@"InstagramCaption":@"来自MirrorGrid"};
            [documetnInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated:YES];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark 保存至本地相册 结果反馈
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error && [FTF_Global shareGlobal].bigImage != nil)
    {
        MBProgressHUD *hud = showMBProgressHUD(LocalizedString(@"saved_in_album", nil), NO);
        hud.color = [UIColor blackColor];
        [hud performSelector:@selector(hide:) withObject:nil afterDelay:1.5];
    }
    else
    {
        MBProgressHUD *hud = showMBProgressHUD(LocalizedString(@"saved_in_album_Fail", nil), NO);
        hud.color = [UIColor blackColor];
        [hud performSelector:@selector(hide:) withObject:nil afterDelay:1.5];
    }
    
}

#pragma mark -
#pragma mark UITableViewDelegate And UITableDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 170.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [FTF_Global shareGlobal].appsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = colorWithHexString(@"#eeeeee",1.f);
    
    for (UIView *subView in [cell.contentView subviews])
    {
        [subView removeFromSuperview];
    }
    
    RC_AppInfo *appInfo = [[FTF_Global shareGlobal].appsArray objectAtIndex:indexPath.row];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;

    CGSize labelsize = sizeWithContentAndFont(appInfo.appDesc, CGSizeMake(300, 100), 12);
    
    [titleLabel setFrame:CGRectMake(20, 0, labelsize.width, labelsize.height)];
    titleLabel.text = appInfo.appDesc;
    titleLabel.font = [UIFont systemFontOfSize:12.f];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, labelsize.height + 10, 290, 120)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:appInfo.bannerUrl] placeholderImage:nil];
    [cell.contentView addSubview:imageView];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RC_AppInfo *appInfo = [[FTF_Global shareGlobal].appsArray objectAtIndex:indexPath.row];
    
    [FTF_Global event:@"Share" label:appInfo.appName];
    
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appInfo.openUrl]])
    {
        NSString *evaluateString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appInfo.downUrl];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:evaluateString]];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appInfo.openUrl]];
    }
}

#pragma mark -
#pragma mark WebRequestDelegate
- (void)didReceivedData:(NSDictionary *)dic withTag:(NSInteger)tag
{
    NSArray *infoArray = [dic objectForKey:@"list"];
    NSMutableArray *isDownArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *noDownArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *infoDic in infoArray)
    {
        RC_AppInfo *appInfo = [[RC_AppInfo alloc]initWithDictionary:infoDic];
        if (appInfo.isHave)
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
            [[ME_SQLMassager shareStance] insertAppInfo:array];
        }
    }
    [appMoretableView reloadData];
}

- (void)requestFailed:(NSInteger)tag
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
