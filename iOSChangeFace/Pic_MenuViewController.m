//
//  Pic_MenuViewController.m
//  BeautySelfie
//
//  Created by MAXToooNG on 14-6-4.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import "Pic_MenuViewController.h"
#import "Pic_RootTableViewCellObject.h"
#import "SliderViewController.h"
#import "MobClick.h"
#import "CMethods.h"
#import "FTF_Global.h"

#define FEEDBACK_EMAIL @"rcplatform.help@gmail.com"
#define FOLLOW_US_URL @"http://instagram.com/face2face_rc"

@interface Pic_MenuViewController ()
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    BOOL _doAnimation;
}
@end

@implementation Pic_MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = colorWithHexString(@"#232323",1.0f);
    
    [self initTableView];
    
    [SliderViewController sharedSliderController].target = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTableView
{
    
    UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(70, 56, 109, 17)];
    logoImage.image = [UIImage imageNamed:@"listlogo@2x"];
    [self.view addSubview:logoImage];
    
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(28, 103, 190, 6)];
    //UIImage *logo_lineImage = [pngImagePath(@"listlogo_line") stretchableImageWithLeftCapWidth:20 topCapHeight:3];
    lineImage.image = [UIImage imageNamed:@"listlogo_line@2x"];
    [self.view addSubview:lineImage];
    
     _dataArray = [[NSMutableArray alloc] init];
    [self initViewsWith1136];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 116, 320, 400)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

- (void)initViewsWith1136
{
    NSArray *titleArray = [[NSArray alloc] initWithObjects:LocalizedString(@"Update", nil),LocalizedString(@"Rate this app", nil),LocalizedString(@"Feedback", nil), LocalizedString(@"Share", nil),LocalizedString(@"Follow us", nil),nil];
    NSArray *imageNameArray = [[NSArray alloc] initWithObjects:@"icon_update_normal",@"icon_grade_norma",@"icon_Feedback_normal",@"icon_share_normal",@"icon_Follow us_norma", nil];
    NSArray *imageHLNameArray = [[NSArray alloc] initWithObjects:@"icon_update_pressed",@"icon_grade_pressed",@"icon_Feedback_pressed",@"icon_share_pressed",@"icon_Follow us_pressed", nil];
    for (int i = 0; i < titleArray.count; i++)
    {
        Pic_RootTableViewCellObject *model = [[Pic_RootTableViewCellObject alloc] init];
        model.title = [titleArray objectAtIndex:i];
        model.imageName = [imageNameArray objectAtIndex:i];
        model.imageHLName = [imageHLNameArray objectAtIndex:i];
        [_dataArray addObject:model];
    }
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            //更新
            [FTF_Global event:@"Home" label:@"more_update"];
            [self jumpToAppStore];
        }
            break;
        case 1:
        {
            //评分
            [FTF_Global event:@"Home" label:@"more_rate"];
            [self gotoAppStorePageRaisal];
        }
            break;
        case 2:
            //反馈
        {
            [FTF_Global event:@"Home" label:@"more_feedback"];
            
            // app名称 版本
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
            NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
            NSString *app_Version = [infoDictionary objectForKey:@"CFBundleVersion"];
            
            //设备型号 系统版本
            NSString *deviceName = doDevicePlatform();
            NSString *deviceSystemName = [[UIDevice currentDevice] systemName];
            NSString *deviceSystemVer = [[UIDevice currentDevice] systemVersion];
            
            //设备分辨率
            CGFloat scale = [UIScreen mainScreen].scale;
            CGFloat resolutionW = [UIScreen mainScreen].bounds.size.width * scale;
            CGFloat resolutionH = [UIScreen mainScreen].bounds.size.height * scale;
            NSString *resolution = [NSString stringWithFormat:@"%.f * %.f", resolutionW, resolutionH];
            
            //本地语言
            NSString *language = [[NSLocale preferredLanguages] firstObject];
            
            NSString *diveceInfo = [NSString stringWithFormat:@"%@ %@, %@, %@ %@, %@, %@", app_Name, app_Version, deviceName, deviceSystemName, deviceSystemVer,  resolution, language];
            
            //直接发邮件
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            if(!picker) break;
            picker.mailComposeDelegate =self;
            NSString *subject = [NSString stringWithFormat:@"Magic Face %@ (iOS)", LocalizedString(@"Feedback", nil)];
            [picker setSubject:subject];
            [picker setToRecipients:@[FEEDBACK_EMAIL]];
            [picker setMessageBody:diveceInfo isHTML:NO];
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
    }
            break;
        case 3:
        {
            //分享
            [FTF_Global event:@"Home" label:@"more_share"];
            //需要分享的内容
            
            NSString *shareContent = LocalizedString(@"shareContent", nil);
            NSArray *activityItems = @[shareContent];
            
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            __weak UIActivityViewController *blockActivityVC = activityVC;
            
            activityVC.completionHandler = ^(NSString *activityType,BOOL completed){
                if(completed)
                {

                }
                [blockActivityVC dismissViewControllerAnimated:YES completion:nil];
                
                [[UIApplication sharedApplication].keyWindow addSubview:[FTF_Global shareGlobal].bannerView];
                [FTF_Global shareGlobal].bannerView.hidden = NO;
            };
            [self presentViewController:activityVC animated:YES completion:nil];
        }
            break;
        case 4:
        {
            //关注我们
            [FTF_Global event:@"Home" label:@"more_care"];
            NSURL *instagramURL = [NSURL URLWithString:@"instagram://user?username=face2face_rc"];
            if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
                [[UIApplication sharedApplication] openURL:instagramURL];
            }else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:FOLLOW_US_URL]];
            }

        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIde = @"cellIde";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
    }
    
    Pic_RootTableViewCellObject *model = [_dataArray objectAtIndex:indexPath.row];
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(31, 13, 25 , 25)];
    iconImageView.image = [UIImage imageNamed:model.imageName];
    iconImageView.highlightedImage = [UIImage imageNamed:model.imageHLName];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(64, 0, 170, 52)];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    label.text = model.title;
    label.highlightedTextColor = colorWithHexString(@"#f85e5e",1.f);
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(26, 43, 190, 1)];
    lineView.backgroundColor = colorWithHexString(@"#666666", 1.0f);
    
    UIView *view = [[UIView alloc] initWithFrame:cell.frame];
    view.backgroundColor = colorWithHexString(@"#1e1e1e",1.f);
    cell.selectedBackgroundView = view;
    [cell.contentView addSubview:iconImageView];
    [cell.contentView addSubview:label];
    [cell.contentView addSubview:lineView];
    [cell setTintColor:colorWithHexString(@"#f85e5e",1.f)];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark 打开appStore (评分及手动更新)
- (void)jumpToAppStore{
    NSString *evaluateString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appleID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:evaluateString]];
}

- (void)gotoAppStorePageRaisal
{
    NSString * nsStringToOpen = [NSString  stringWithFormat: @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",appleID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:nsStringToOpen]];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
