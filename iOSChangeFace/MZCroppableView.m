//
//  MZCroppableView.m
//  MZCroppableView
//
//  Created by macbook on 30/10/2013.
//  Copyright (c) 2013 macbook. All rights reserved.
//

#import "MZCroppableView.h"
#import "UIBezierPath-Points.h"
#import "ACMagnifyingView.h"

@implementation MZCroppableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

- (id)initWithImageView:(UIImageView *)imageView
{
    self = [super initWithFrame:imageView.frame];
    if (self)
    {
        self.lineWidth = 2.0f;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setClipsToBounds:YES];
        [self setUserInteractionEnabled:YES];
        self.croppingPath = [[UIBezierPath alloc] init];
        CGFloat lineDash[] = {4,2};
        [self.croppingPath setLineDash:lineDash count:2 phase:1];
        [self.croppingPath setLineWidth:self.lineWidth];
        self.lineColor = [UIColor redColor];
    }
    
    return self;
}

#pragma mark - My Methods -
+ (CGRect)scaleRespectAspectFromRect1:(CGRect)rect1 toRect2:(CGRect)rect2
{
    CGSize scaledSize = rect2.size;
    
    float scaleFactor = 1.0;
    
    CGFloat widthFactor  = rect2.size.width / rect1.size.width;
    CGFloat heightFactor = rect2.size.height / rect1.size.width;
    
    if (widthFactor < heightFactor)
        scaleFactor = widthFactor;
    else
        scaleFactor = heightFactor;
    
    scaledSize.height = rect1.size.height *scaleFactor;
    scaledSize.width  = rect1.size.width  *scaleFactor;
    
    float y = (rect2.size.height - scaledSize.height)/2;
    
    return CGRectMake(0, y, scaledSize.width, scaledSize.height);
}

+ (CGPoint)convertCGPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2
{
    point1.y = rect1.height - point1.y;
    CGPoint result = CGPointMake((point1.x*rect2.width)/rect1.width, (point1.y*rect2.height)/rect1.height);
    return result;
}

+ (CGPoint)convertPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2
{
    CGPoint result = CGPointMake((point1.x*rect2.width)/rect1.width, (point1.y*rect2.height)/rect1.height);
    return result;
}

- (void)drawRect:(CGRect)rect
{
    [self.lineColor setStroke];
    [self.croppingPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0f];
}

- (UIImage *)deleteBackgroundOfImage:(UIImageView *)imageView isLastPath:(BOOL)isLast
{
    if (!isLast)
    {
        self.points = [self.croppingPath points];
        maskedImage = nil;
    }
    
    if (self.points.count <= 1)
    {
        return nil;
    }
    
    CGRect rect = CGRectZero;
    rect.size = imageView.image.size;
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    if (maskedImage == nil)
    {
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
        {
            [[UIColor blackColor] setFill];
            UIRectFill(rect);
            [[UIColor whiteColor] setFill];
            
            CGPoint p1 = [MZCroppableView convertCGPoint:[[_points objectAtIndex:0] CGPointValue] fromRect1:imageView.frame.size toRect2:imageView.image.size];
            [aPath moveToPoint:CGPointMake(p1.x, p1.y)];
            for (uint i=1; i<_points.count; i++)
            {
                CGPoint p = [MZCroppableView convertCGPoint:[[_points objectAtIndex:i] CGPointValue] fromRect1:imageView.frame.size toRect2:imageView.image.size];
                [aPath addLineToPoint:CGPointMake(p.x, p.y)];
            }
            [aPath closePath];
            [aPath fill];
        }
        
        maskedImage = UIGraphicsGetImageFromCurrentImageContext();
        NSString *path4 = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"image"];
        [UIImagePNGRepresentation(maskedImage) writeToFile:path4 atomically:YES];
        maskedImage = [self fuzzyImage:maskedImage];
        NSString *path5 = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"image2"];
        [UIImagePNGRepresentation(maskedImage) writeToFile:path5 atomically:YES];
    }
    
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    {
        CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, maskedImage.CGImage);
        [imageView.image drawAtPoint:CGPointZero];
    }
    
    UIImage *masImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return masImage;
}

#pragma mark - Touch Methods -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BeginCropImage" object:nil];
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [self.croppingPath moveToPoint:[mytouch locationInView:self]];
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [self.croppingPath addLineToPoint:[mytouch locationInView:self]];
    [self setNeedsDisplay];
    [self.nextResponder touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EndCropImage" object:nil];
    [self.croppingPath removeAllPoints];
    [self setNeedsDisplay];
    [self.nextResponder touchesEnded:touches withEvent:event];
}

- (UIImage *)fuzzyImage:(UIImage *)mask
{
    IplImage *img1,*img2 = 0;
    
    img1 = [self CreateIplImageFromUIImage:mask];
    img2 = [self CreateIplImageFromUIImage:mask];
    cvSmooth(img1, img2,CV_BLUR,40,40);
    mask = [self UIImageFromIplImage:img2];
    cvReleaseImage(&img1);
    cvReleaseImage(&img2);
    
    return mask;
}

- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
    // Getting CGImage from UIImage
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Creating temporal IplImage for drawing
    IplImage *iplimage = cvCreateImage(
                                       cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4
                                       );
    // Creating CGContext for temporal IplImage
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    iplimage->imageData, iplimage->width, iplimage->height,
                                                    iplimage->depth, iplimage->widthStep,
                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
                                                    );
    // Drawing CGImage to CGContext
    CGContextDrawImage(
                       contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef
                       );
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Creating result IplImage
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}

- (UIImage *)UIImageFromIplImage:(IplImage *)image {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Allocating the buffer for CGImage
    NSData *data =
    [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((CFDataRef)data);
    // Creating CGImage from chunk of IplImage
    CGImageRef imageRef = CGImageCreate(
                                        image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault
                                        );
    // Getting UIImage from CGImage
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}


@end
