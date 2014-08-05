//
//  FTF_AdjustFaceViewController.m
//  iOSChangeFace
//
//  Created by gaoluyangrc on 14-7-26.
//  Copyright (c) 2014年 rcplatform. All rights reserved.
//

#import "FTF_AdjustFaceViewController.h"
#import "UIImage+Zoom.h"
#import "CMethods.h"
#import "FTF_Global.h"
#import "FTF_Button.h"
#import "FTF_DirectionView.h"
#import "FTF_EditFaceViewController.h"
#define ToolBarHeight 104.f
#define BtnWidth 320.f/6.f

@interface FTF_AdjustFaceViewController ()
{
    float lastScale;
    BOOL isTiny;
    double recordedRotation;
    UIImageView *libaryImageView;
}
@end

@implementation FTF_AdjustFaceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)dealloc
{
    libaryImageView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    lastScale = 1.f;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    FTF_DirectionView *toolBarView = [[FTF_DirectionView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 154, 320, ToolBarHeight)];
    toolBarView.delegate = self;
    [self.view addSubview:toolBarView];
    
}

#pragma mark -
#pragma mark 初始化视图
- (void)loadAdjustViews:(UIImage *)image
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 320, 320)];
    backView.layer.masksToBounds = YES;
    [self.view addSubview:backView];
    
    //相册里选取的图片
    if (image.size.width > image.size.height)
    {
        libaryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, image.size.height * (320.f/1080.f))];
    }
    else
    {
        libaryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width * (320.f/1080.f), 320)];
    }
    libaryImageView.backgroundColor =  [UIColor redColor];
    libaryImageView.center = CGPointMake(160, 160);
    libaryImageView.userInteractionEnabled = YES;
    libaryImageView.image = [UIImage zoomImageWithImage:image];
    [self addGestureRecognizerToView:libaryImageView];
    [backView addSubview:libaryImageView];
    
    //脸图
    UIImageView *faceModelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    faceModelImageView.image = [UIImage zoomImageWithImage:pngImagePath(@"focus")];
    [backView addSubview:faceModelImageView];
}

- (void)addGestureRecognizerToView:(UIView *)view
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    [pan addTarget:self action:@selector(panView:changePoint:)];
    [view addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] init];
    [pin addTarget:self action:@selector(pinView:changeScale:)];
    [view addGestureRecognizer:pin];
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:changeRotate:)];
    [view addGestureRecognizer:rotationGesture];
}

#pragma mark -
#pragma mark 移动
- (void)panView:(UIPanGestureRecognizer *)recognizer changePoint:(CGPoint)point
{
    UIView *panView = recognizer.view;
    
    CGPoint translation;
    if (isTiny)
    {
        translation = point;
        isTiny = NO;
    }
    else
    {
        translation = [recognizer translationInView:self.view];
    }
    
    panView.center = CGPointMake(panView.center.x + translation.x, panView.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

#pragma mark -
#pragma mark 缩放
- (void)pinView:(UIPinchGestureRecognizer *)recognizer changeScale:(float)tinyScale
{
    UIView *imageView = recognizer.view;
    
    CGFloat scale;
    if (isTiny)
    {
        scale = 1.0 - (lastScale - tinyScale);
        isTiny = NO;
    }
    else
    {
        scale = 1.0 - (lastScale - [recognizer scale]);
    }
    
    if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        lastScale = 1.0;
        return;
    }
    
    CGAffineTransform newTransform = CGAffineTransformScale(imageView.transform, scale, scale);
    [imageView setTransform:newTransform];
    
    lastScale = [recognizer scale];
}

#pragma mark -
#pragma mark 旋转
- (void)rotateView:(UIRotationGestureRecognizer *)recognizer changeRotate:(float)tinyScale
{

    UIView *imageView = recognizer.view;
    CGFloat rotation;

    if (isTiny)
    {
        rotation = tinyScale;
        isTiny = NO;
    }
    else
    {
        rotation = 0.0 - (recordedRotation - [recognizer rotation]);
    }
    
    CGAffineTransform currentTransform = imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    [imageView setTransform:newTransform];
    
    recordedRotation = [recognizer rotation];
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        recordedRotation = recordedRotation - [recognizer rotation];
    }
}

- (void)rightItemClick:(UIBarButtonItem *)item
{
    FTF_EditFaceViewController *editFace = [[FTF_EditFaceViewController alloc] initWithNibName:@"FTF_EditFaceViewController" bundle:nil];
    editFace.libaryImage = libaryImageView.image;
    editFace.imageRect = libaryImageView.frame;
    [self.navigationController pushViewController:editFace animated:YES];
}

#pragma mark - 
#pragma mark DirectionDelegate
- (void)directionBtnClick:(NSUInteger)tag
{
    if (tag == 0)
    {
        libaryImageView.transform = CGAffineTransformMakeRotation(0);
        if ([FTF_Global shareGlobal].compressionImage.size.width > [FTF_Global shareGlobal].compressionImage.size.height)
        {
            libaryImageView.frame = CGRectMake(0, 0, 320, [FTF_Global shareGlobal].compressionImage.size.height * (320.f/1080.f));
        }
        else
        {
            libaryImageView.frame = CGRectMake(0, 0, [FTF_Global shareGlobal].compressionImage.size.width * (320.f/1080.f), 320);
        }
        libaryImageView.center = CGPointMake(160, 160);
        libaryImageView.image = [FTF_Global shareGlobal].compressionImage;
    }
    else if (tag == 5 || tag == 6)
    {
        for (UIPinchGestureRecognizer *recognizer in libaryImageView.gestureRecognizers)
        {
            if ([recognizer isKindOfClass:[UIPinchGestureRecognizer class]])
            {
                UIPinchGestureRecognizer *pin = (UIPinchGestureRecognizer *)recognizer;
                float scale = 1 + (tag == 5 ? 0.06 : -0.06);
                isTiny = YES;
                [self pinView:pin changeScale:scale];
            }
        }
    }
    else if (tag == 7 || tag == 8)
    {
        for (UIRotationGestureRecognizer *recognizer in libaryImageView.gestureRecognizers)
        {
            if ([recognizer isKindOfClass:[UIRotationGestureRecognizer class]])
            {
                UIRotationGestureRecognizer *rotation = (UIRotationGestureRecognizer *)recognizer;
                float scale = tag == 7 ? -0.01 : 0.01;
                isTiny = YES;
                [self rotateView:rotation changeRotate:scale];
            }
        }
    }
    else
    {
        for (UIGestureRecognizer *recognizer in libaryImageView.gestureRecognizers)
        {
            if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]])
            {
                UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)recognizer;
                
                CGPoint point;
                if (tag == 2 || tag == 4)
                {
                    point = CGPointMake(0, tag == 2 ? -5 : 5);
                }
                else
                {
                    point = CGPointMake(tag == 1 ? -5 : 5, 0);
                }
                isTiny = YES;
                [self panView:pan changePoint:point];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
