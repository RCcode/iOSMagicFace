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
#import "LRNavigationController.h"
#define ToolBarHeight 104.f
#define BtnWidth 320.f/6.f

@interface FTF_AdjustFaceViewController ()
{
    float lastScale;
    float imageScale;
    BOOL isTiny;
    double recordedRotation;
    UIImageView *libaryImageView;
    NSArray *eventArray;
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
    eventArray = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    lastScale = 1.f;
    imageScale = 1.f;
    [FTF_Global shareGlobal].rorationDegree = 0;
    
    UIImageView *blur = [[UIImageView alloc] initWithFrame:self.view.bounds];
    blur.userInteractionEnabled = YES;
    UIEdgeInsets ed = {0.0f, 10.0f, 0.0f, 10.0f};
    UIImage *newImage = [pngImagePath(@"bg") resizableImageWithCapInsets:ed resizingMode:UIImageResizingModeTile];
    blur.image = newImage;
    [self.view addSubview:blur];

    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 129, 44);
    [backBtn setImage:pngImagePath(@"btn_back_normal") forState:UIControlStateNormal];
    [backBtn setImage:pngImagePath(@"btn_back_pressed") forState:UIControlStateHighlighted];
    backBtn.imageView.contentMode = UIViewContentModeCenter;
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -32, 0, 0);
    [backBtn addTarget:self action:@selector(backItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //下一级
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(0, 0, 44, 44);
    [nextBtn setImage:pngImagePath(@"btn_ok_normal") forState:UIControlStateNormal];
    [nextBtn setImage:pngImagePath(@"btn_ok_pressed") forState:UIControlStateHighlighted];
    nextBtn.imageView.contentMode = UIViewContentModeCenter;
    nextBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -32);
    [nextBtn addTarget:self action:@selector(rightItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:nextBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 320, 320, iPhone5()?154:116)];
    backView.backgroundColor = colorWithHexString(@"#202225", 1.f);
    [self.view addSubview:backView];
    
    FTF_DirectionView *toolBarView = [[FTF_DirectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 104)];
    toolBarView.center = CGPointMake(160, backView.frame.size.height/2);
    [toolBarView loadDirectionItools];
    toolBarView.delegate = self;
    [backView addSubview:toolBarView];
    
    eventArray = @[@"adjust_normal",@"adjust_left",@"adjust_up",@"adjust_right",@"adjust_down",@"adjust_big",@"adjust_small",@"adjust_ronateleft",@"adjust_ronateright"];
    
}

#pragma mark -
#pragma mark 初始化视图
- (void)loadAdjustViews:(UIImage *)image
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    backView.layer.masksToBounds = YES;
    [self.view addSubview:backView];
    
    //相册里选取的图片
    if (image.size.width > image.size.height)
    {
        libaryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width * (320.f/[FTF_Global shareGlobal].smallValue), 320)];
    }
    else
    {
        libaryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, image.size.height * (320.f/[FTF_Global shareGlobal].smallValue))];
    }
    
    libaryImageView.center = CGPointMake(160, 160);
    libaryImageView.userInteractionEnabled = YES;
    libaryImageView.image = image;
    libaryImageView.layer.shouldRasterize = NO;
    [self addGestureRecognizerToView:libaryImageView];
    [backView addSubview:libaryImageView];
    
    //脸图
    UIImageView *faceModelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 320, 320)];
    faceModelImageView.image = [UIImage zoomImageWithImage:pngImagePath(@"iosFocus") isLibaryImage:NO];
    [backView addSubview:faceModelImageView];
}

- (void)addGestureRecognizerToView:(UIView *)view
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    pan.delegate = self;
    [pan addTarget:self action:@selector(panView:changePoint:)];
    [view addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] init];
    pin.delegate = self;
    [pin addTarget:self action:@selector(pinView:changeScale:)];
    [view addGestureRecognizer:pin];
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:changeRotate:)];
    rotationGesture.delegate = self;
    [view addGestureRecognizer:rotationGesture];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
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
    
    imageScale *= scale;
    
    CGAffineTransform newTransform = CGAffineTransformScale(imageView.transform, scale, scale);
    [imageView setTransform:newTransform];
    
    lastScale = [recognizer scale];
}

#pragma mark -
#pragma mark 旋转
- (void)rotateView:(UIRotationGestureRecognizer *)recognizer changeRotate:(float)tinyScale
{
    libaryImageView.layer.shouldRasterize = YES;
    
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
    
    [FTF_Global shareGlobal].rorationDegree += rotation;
    
    CGAffineTransform currentTransform = imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    [imageView setTransform:newTransform];

    recordedRotation = [recognizer rotation];
    if([recognizer state] == UIGestureRecognizerStateEnded)
    {
        recordedRotation = recordedRotation - [recognizer rotation];
    }
}

- (void)rightItemClick:(UIBarButtonItem *)item
{
    libaryImageView.transform = CGAffineTransformMakeRotation(0);
    CGAffineTransform newTransform = CGAffineTransformScale(libaryImageView.transform, imageScale, imageScale);
    [libaryImageView setTransform:newTransform];
    
    FTF_EditFaceViewController *editFace = [[FTF_EditFaceViewController alloc] initWithNibName:@"FTF_EditFaceViewController" bundle:nil];
    editFace.libaryImage = libaryImageView.image;
    editFace.imageRect = libaryImageView.frame;
    [self.navigationController pushViewController:editFace animated:YES];
    
    CGAffineTransform transform = CGAffineTransformRotate(libaryImageView.transform,[FTF_Global shareGlobal].rorationDegree);
    [libaryImageView setTransform:transform];
}

- (void)backItemClick:(UIBarButtonItem *)item
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 
#pragma mark DirectionDelegate
- (void)directionBtnClick:(NSUInteger)tag
{
    [FTF_Global event:eventArray[tag] label:@"Edit"];
    if (tag == 0)
    {
        libaryImageView.layer.shouldRasterize = NO;
        
        [FTF_Global shareGlobal].rorationDegree = 0;
        imageScale = 1.f;

        libaryImageView.transform = CGAffineTransformMakeRotation(0);
        if ([FTF_Global shareGlobal].compressionImage.size.width > [FTF_Global shareGlobal].compressionImage.size.height)
        {
            libaryImageView.frame = CGRectMake(0, 0, [FTF_Global shareGlobal].compressionImage.size.width * (320.f/[FTF_Global shareGlobal].smallValue), 320);
        }
        else
        {
            libaryImageView.frame = CGRectMake(0, 0, 320, [FTF_Global shareGlobal].compressionImage.size.height * (320.f/[FTF_Global shareGlobal].smallValue));
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
                float scale = 1 + (tag == 5 ? 0.01 : -0.01);
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
                UIRotationGestureRecognizer *rotationNumber = (UIRotationGestureRecognizer *)recognizer;
                float scale = tag == 7 ? -0.006 : 0.006;
                isTiny = YES;
                [self rotateView:rotationNumber changeRotate:scale];
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
                    point = CGPointMake(0, tag == 2 ? -2 : 2);
                }
                else
                {
                    point = CGPointMake(tag == 1 ? -2 : 2, 0);
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
    
}

@end
