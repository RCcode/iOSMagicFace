//
//  FTF_DirectionView.m
//  iOSChangeFace
//
//  Created by gaoluyangrc on 14-8-5.
//  Copyright (c) 2014年 rcplatform. All rights reserved.
//

#import "FTF_DirectionView.h"
#import "FTF_Button.h"
#import "CMethods.h"
#import "FTF_Global.h"

#define Btn_Width 30.f
#define Btn_Height 30.f
#define Btn_Distance 26.f

@implementation FTF_DirectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //ZVolumeSlide 自定义Slide控件
        volumeSlide = [[FTF_VolumeSlide alloc]initWithFrame:CGRectMake(17.5, 57, 285, 44)];
        volumeSlide.delegate = self;
        [self setVolumeSlideValue:0.2f];
        
        lindeSlider = [[UISlider alloc]initWithFrame:CGRectMake(17.5f, 57, 285, 44)];
        [lindeSlider setMaximumTrackTintColor:colorWithHexString(@"#999999", 1.0f)];
        [lindeSlider setMinimumTrackTintColor:colorWithHexString(@"#D9AF20", 1.0f)];
        [lindeSlider setThumbImage:pngImagePath(@"switch_btn_line_normal") forState:UIControlStateNormal];
        [lindeSlider setThumbImage:pngImagePath(@"switch_btn_line_pressed") forState:UIControlStateHighlighted];
        lindeSlider.value = .5f;
        lindeSlider.tag = 0;
        [lindeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)dealloc
{
    lindeSlider = nil;
    volumeSlide = nil;
}

- (void)setVolumeSlideValue:(float)value
{
    [volumeSlide setSlideValue:value];
}

- (void)loadDirectionItools
{
    for (UIView *subView in [self subviews])
    {
        [subView removeFromSuperview];
    }
    
    UIView *blur = [[UIView alloc] initWithFrame:self.bounds];
    blur.userInteractionEnabled = YES;
    blur.backgroundColor = colorWithHexString(@"#202225", 0.7f);

    //恢复原始
    FTF_Button *resetBtn = [[FTF_Button alloc]initWithFrame:CGRectMake(Btn_Distance, 37, Btn_Width, Btn_Height)];
    resetBtn.toolImageView.frame = CGRectMake(0, 0, Btn_Width, Btn_Height);
    resetBtn.toolImageView.image = pngImagePath(@"btn_reset_normal");
    [resetBtn setNormelName:@"btn_reset_normal"];
    [resetBtn setSelectName:@"btn_reset_pressed"];
    resetBtn.tag = 0;
    [resetBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [blur addSubview:resetBtn];
    
    //上下左右
    NSArray *array = @[@[@"btn_left_normal",@"btn_up_normal",@"btn_right_normal",@"btn_down_normal"],
                       @[@"btn_left_pressed",@"btn_up_pressed",@"btn_right_pressed",@"btn_down_pressed"]];
    
    for (int i = 0; i < 4; i++)
    {
        FTF_Button *btn = [[FTF_Button alloc]initWithFrame:CGRectMake(89, 37, Btn_Width, Btn_Height)];
        if (i == 1)
        {
            [btn setFrame:CGRectMake(122, 6, Btn_Width, Btn_Height)];
        }
        else if (i == 2)
        {
            [btn setFrame:CGRectMake(155, 37, Btn_Width, Btn_Height)];
        }
        else if (i == 3)
        {
            [btn setFrame:CGRectMake(122, 68, Btn_Width, Btn_Height)];
        }
        btn.tag = i + 1;
        btn.toolImageView.frame = CGRectMake(0, 0, Btn_Width, Btn_Height);
        btn.toolImageView.image = pngImagePath([array[0] objectAtIndex:i]);
        [btn setNormelName:[array[0] objectAtIndex:i]];
        [btn setSelectName:[array[1] objectAtIndex:i]];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [blur addSubview:btn];
 
    }
    
    NSArray *dataArray = @[@[@"btn_big_normal",@"btn_small_normal",@"btn_ronate01_normal",@"btn_ronate02_normal"],
                           @[@"btn_big_pressed",@"btn_small_pressed",@"btn_ronate01_pressed",@"btn_ronate02_pressed"]];
    
    //放大缩小和旋转
    int i = 0;
    while (i < 4) {
        
        FTF_Button *btn = [[FTF_Button alloc]initWithFrame:CGRectMake(215 + 52 * (i%2), 13 + (Btn_Width + 22) * (i/2), Btn_Width, Btn_Height)];
        btn.toolImageView.frame = CGRectMake(0, 0, Btn_Width, Btn_Height);
        btn.toolImageView.image = pngImagePath([dataArray[0] objectAtIndex:i]);
        [btn setNormelName:[dataArray[0] objectAtIndex:i]];
        [btn setSelectName:[dataArray[1] objectAtIndex:i]];
        btn.tag = i + 5;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [blur addSubview:btn];
        
        i++;
    }
    
    [self addSubview:blur];
}

- (void)loadModelStyleItools
{
    for (UIView *subView in [self subviews])
    {
        [subView removeFromSuperview];
    }
    
    UIView *blur = [[UIView alloc] initWithFrame:self.bounds];
    blur.userInteractionEnabled = YES;
    blur.backgroundColor = colorWithHexString(@"#202225", 0.7f);
    
    //脸部样式
    NSArray *array = @[@[@"switch_icon_left_normal",@"switch_icon_right_normal",@"switch_icon_up_normal",@"switch_icon_down_normal"],
                       @[@"switch_icon_left_pressed",@"switch_icon_right_pressed",@"switch_icon_up_pressed",@"switch_icon_down_pressed"]];
    
    int i = 0;
    while (i < 4) {
        
        FTF_Button *btn = [[FTF_Button alloc]initWithFrame:CGRectMake(37 + 72 * i, 15, Btn_Width, Btn_Height)];
        btn.toolImageView.frame = CGRectMake(0, 0, Btn_Width, Btn_Height);
        btn.toolImageView.image = pngImagePath([array[0] objectAtIndex:i]);
        [btn setNormelName:[array[0] objectAtIndex:i]];
        [btn setSelectName:[array[1] objectAtIndex:i]];
        btn.tag = i + 10;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [blur addSubview:btn];
        
        if (i == _direction_Type)
        {
            [btn changeBtnImage];
        }
        
        i++;
    }
    
    //分割线
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 52, 300, 1)];
    lineView.backgroundColor = colorWithHexString(@"#666666", 1.0f);
    [blur addSubview:lineView];
    
    [blur addSubview:lindeSlider];
    
    [self addSubview:blur];
}

- (void)loadCropItools
{
    for (UIView *subView in [self subviews])
    {
        [subView removeFromSuperview];
    }
    
    UIView *blur = [[UIView alloc] initWithFrame:self.bounds];
    blur.userInteractionEnabled = YES;
    blur.backgroundColor = colorWithHexString(@"#202225", 0.7f);
    
    //脸部样式
    NSArray *array = @[@[@"icon_reset_normal",@"icon_shadow01_normal",@"icon_shadow02_normal",@"icon_shadow03_normal"],
                       @[@"icon_reset_pressed",@"icon_shadow01_pressed",@"icon_shadow02_pressed",@"icon_shadow03_pressed"]];
    
    int i = 0;
    while (i < 4) {
        
        FTF_Button *btn = [[FTF_Button alloc]initWithFrame:CGRectMake(49 + 65 * i, 15, Btn_Width, Btn_Height)];
        btn.toolImageView.frame = CGRectMake(0, 0, Btn_Width, Btn_Height);
        btn.toolImageView.image = pngImagePath([array[0] objectAtIndex:i]);
        [btn setNormelName:[array[0] objectAtIndex:i]];
        [btn setSelectName:[array[1] objectAtIndex:i]];
        btn.tag = i + 20;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [blur addSubview:btn];
        
        if (i != 0 && i == _model_Type)
        {
            [btn changeBtnImage];
        }
        
        i++;
    }
    
    //分割线
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 52, 300, 1)];
    lineView.backgroundColor = colorWithHexString(@"#666666", 1.0f);
    [blur addSubview:lineView];
    
    
    [blur addSubview:volumeSlide];
    
    [self addSubview:blur];
}

- (void)loadFilerItools
{
    for (UIView *subView in [self subviews])
    {
        [subView removeFromSuperview];
    }
    
    UIView *blur = [[UIView alloc] initWithFrame:self.bounds];
    blur.userInteractionEnabled = YES;
    blur.backgroundColor = colorWithHexString(@"#202225", 0.7f);
    
    UIScrollView *filterScroller = [[UIScrollView alloc]initWithFrame:blur.bounds];
    [filterScroller setContentSize:CGSizeMake(80 * 30, 0)];
    [filterScroller setContentOffset:CGPointMake(0, 0)];
    filterScroller.showsVerticalScrollIndicator = NO;
    filterScroller.backgroundColor = [UIColor clearColor];
    [blur addSubview:filterScroller];
    
    NSArray *array = @[@"Normal",@"Emily",@"Madison",@"Isabella",@"Ava",@"Sophia",@"Kaitlyn",@"Hannah",@"Hailey",@"Olivia",@"Sarah",@"Abigail",@"Madeline",@"Lily",@"Kaylee",@"Ella",@"Riley",@"Brianna",@"Alyssa",@"Samantha",@"Lauren",@"Mia",@"Alexis",@"Chloe",@"Ashley",@"Grace",@"Jessica",@"Elizabeth",@"Taylor",@"Makayla",];
    
    for (int i = 0; i < 30; i++)
    {
        FTF_Button *btn = [[FTF_Button alloc]initWithFrame:CGRectMake(80 * i, 0, 80, 104)];
        btn.toolImageView.frame = CGRectMake(10, 6, 70, 70);
        btn.toolImageView.image = pngImagePath([NSString stringWithFormat:@"IMG_%d",i]);
        [btn setNormelName:[NSString stringWithFormat:@"IMG_%d",i]];
        [btn setSelectName:[NSString stringWithFormat:@"IMG_%d",i]];
        btn.contentLabel.frame = CGRectMake(0, 82, btn.bounds.size.width, 16);
        btn.contentLabel.text = array[i];
        btn.tag = i + 100;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [filterScroller addSubview:btn];
        
        if (i == [FTF_Global shareGlobal].filterType)
        {
            [btn changeBtnImage];
            btn.contentLabel.textColor = colorWithHexString(@"#D9AF20", 1.0);
        }
    }
    
    [self addSubview:blur];
}

- (void)btnClick:(FTF_Button *)btn
{
    for (UIView *subView in [btn.superview subviews])
    {
        if ([subView isKindOfClass:[FTF_Button class]])
        {
            FTF_Button *button = (FTF_Button *)subView;
            [button btnHaveClicked];
            button.contentLabel.textColor = [UIColor whiteColor];
        }
    }
    
    [btn changeBtnImage];
    btn.contentLabel.textColor = colorWithHexString(@"#D9AF20", 1.0);
    if (btn.tag < 10 || btn.tag == 20)
    {
        [btn performSelector:@selector(btnHaveClicked) withObject:nil afterDelay:.15f];
    }
    [self.delegate directionBtnClick:btn.tag];
}

- (void)sliderValueChanged:(UISlider *)slider
{
    [self.delegate directionSlider:slider];
}

#pragma mark -
#pragma mark SliderVolumeSlideDelegate
- (void)slideChange:(UISlider *)slider
{
    [self.delegate directionSlider:slider];
}

@end
