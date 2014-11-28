//
//  UIImage+Zoom.m
//  ChangeSlowly
//
//  Created by gaoluyangrc on 14-7-24.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import "UIImage+Zoom.h"
#import "FTF_Global.h"

@implementation UIImage (Zoom)

+ (UIImage *)zoomImageWithImage:(UIImage *)image isLibaryImage:(BOOL)isLibary
{
    static UIImage *newImage;
    
    float smallValue = 0.f;
    if (isLibary)
    {
        if (image.size.width/image.size.height > 2.0f)
        {
            [FTF_Global shareGlobal].smallValue = 320.f;
            smallValue = 320.f;
        }
        else
        {
            [FTF_Global shareGlobal].smallValue = 640.f;
            smallValue = 640.f;
        }
    }
    else
    {
        smallValue = 640.f;
    }
    
    if (image.size.width > smallValue || image.size.height > smallValue)
    {
        if (image.size.width >= image.size.height)
        {
            float scale = image.size.height/smallValue;
            float width = image.size.width/scale;
            newImage = [image imageByScalingToSize:CGSizeMake(width, smallValue)];
            
        }
        else
        {
            float scale = image.size.width/smallValue;
            float height = image.size.height/scale;
            newImage = [image imageByScalingToSize:CGSizeMake(smallValue, height)];
        }
    }
    else
    {
        if (image.size.width >=  image.size.height)
        {
            float scale = smallValue/image.size.height;
            float width = image.size.width*scale;
            newImage = [image imageByScalingToSize:CGSizeMake(width, smallValue)];
        }
        else
        {
            float scale = smallValue/image.size.width;
            float height = image.size.height*scale;
            newImage = [image imageByScalingToSize:CGSizeMake(smallValue, height)];
        }
    }
    
    return newImage;
}

+ (UIImage *)zoomImage:(UIImage *)image toSize:(CGSize)size
{
    static UIImage *newImage;
    if (image.size.width > size.width || image.size.height > size.height)
    {
        if (image.size.width >=  image.size.height)
        {
            float scale = image.size.height/size.height;
            float width = image.size.width/scale;
            newImage = [image imageByScalingToSize:CGSizeMake(width, size.height)];
        }
        else
        {
            float scale = image.size.width/size.width;
            float height = image.size.height/scale;
            newImage = [image imageByScalingToSize:CGSizeMake(size.width, height)];
        }
    }
    else
    {
        if (image.size.width >=  image.size.height)
        {
            float scale = size.height/image.size.height;
            float width = image.size.width*scale;
            newImage = [image imageByScalingToSize:CGSizeMake(width, size.height)];
        }
        else
        {
            float scale = size.width/image.size.width;
            float height = image.size.height*scale;
            newImage = [image imageByScalingToSize:CGSizeMake(size.width, height)];
        }
    }
    
    return newImage;
}

- (UIImage *)imageByScalingToSize:(CGSize)targetSize{
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    return newImage ;
}

- (UIImage *)rescaleImage:(UIImage *)img ToSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    [img drawInRect:rect]; // scales image to rect
    UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resImage;
}

- (UIImage *)getImageFromImage
{
    //大图bigImage
    //定义myImageRect，截图的区域
    CGRect myImageRect = CGRectMake(10.0, 10.0, 57.0, 57.0);
    UIImage* bigImage= [UIImage imageNamed:@"k00030.jpg"];
    CGImageRef imageRef = bigImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = 57.0;
    size.height = 57.0;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
}

- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{
    UIGraphicsBeginImageContext(image1.size);
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    // Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

+ (UIImage *)imageFromView:(UIView *)theView
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

const CGFloat kReflectPercent = -0.25f;
const CGFloat kReflectOpacity = 0.3f;
const CGFloat kReflectDistance = 10.0f;
+ (void)addSimpleReflectionToView:(UIView *)theView
{
    CALayer *reflectionLayer = [CALayer layer];
    reflectionLayer.contents = [theView layer].contents;
    reflectionLayer.opacity = kReflectOpacity;
    reflectionLayer.frame = CGRectMake(0.0f,0.0f,theView.frame.size.width,theView.frame.size.height*kReflectPercent);
    //倒影层框架设置，其中高度是原视图的百分比
    CATransform3D stransform = CATransform3DMakeScale(1.0f,-1.0f,1.0f);
    CATransform3D transform = CATransform3DTranslate(stransform,0.0f,-(kReflectDistance + theView.frame.size.height),0.0f);
    reflectionLayer.transform = transform;
    reflectionLayer.sublayerTransform = reflectionLayer.transform;
    [[theView layer] addSublayer:reflectionLayer];
}

+ (CGImageRef)createGradientImage:(CGSize)size
{
    CGFloat colors[] = {0.0,1.0,1.0,1.0};
    //在灰色设备色彩上建立一渐变
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil,size.width,size.height,8,0,colorSpace,kCGImageAlphaNone);
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,colors,NULL,2);
    CGColorSpaceRelease(colorSpace);
    //绘制线性渐变
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointMake(0,size.height);
    CGContextDrawLinearGradient(context,gradient,p1,p2,kCGGradientDrawsAfterEndLocation);
    //Return the CGImage
    CGImageRef theCGImage = CGBitmapContextCreateImage(context);
    CFRelease(gradient); CGContextRelease(context);
    return theCGImage;
}


@end
