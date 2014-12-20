//
//  ZVolumeSlide.m
//  AppTestSlide
//
//  Created by ZStart on 13-8-16.
//  Copyright (c) 2013年 ZStart. All rights reserved.
//

#import "FTF_VolumeSlide.h"
#import "CMethods.h"

@implementation FTF_VolumeSlide

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor]; //背景颜色设置，设置为clearColor 背景透明
        
        width = frame.size.width;
        height= frame.size.height;
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 17, self.bounds.size.width, 10)];
        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot01"]];
        [self addSubview:view];
        
        _processView = [[UIView alloc]init];
        _processView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot02"]];
        _processView.frame = CGRectMake(0, 0, width * .8, height);
        
        [self addSubview:_processView];
        
        _slideView = [[UISlider alloc]initWithFrame:self.bounds];
        _slideView.tag = 1;
        _slideView.value = 0;
        [_slideView setThumbImage:pngImagePath(@"slider") forState:UIControlStateNormal];
        
        [_slideView setMaximumTrackImage:[UIImage imageNamed:@"clearBack.png"] forState:UIControlStateNormal];
        [_slideView setMinimumTrackImage:[UIImage imageNamed:@"clearBack.png"] forState:UIControlStateNormal];
        
        [_slideView addTarget:self action:@selector(slideValueChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_slideView];
    }
    return self;
}

- (void)setSlideValue:(CGFloat) value
{
    [_slideView setValue:value];
    [self slideValueChanged];
}

- (void)slideValueChanged
{
    CGFloat value = _slideView.value;
    _processView.frame = CGRectMake(0, 17, width * value, 10);
    [_delegate slideChange:_slideView];
}

@end
