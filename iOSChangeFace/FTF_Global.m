//
//  FTF_Global.m
//  iOSChangeFace
//
//  Created by gaoluyangrc on 14-7-26.
//  Copyright (c) 2014年 rcplatform. All rights reserved.
//

#import "FTF_Global.h"
#import "MobClick.h"
#import "Flurry.h"
#import "FTF_MaterialView.h"

@implementation FTF_Global

- (void)dealloc
{
    self.compressionImage = nil;
    self.modelImage = nil;
    self.bannerView = nil;
    self.bigImage = nil;
}

+ (instancetype)shareGlobal
{
    static FTF_Global *_public_Global;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _public_Global = [[[self class] alloc] init];
        _public_Global.isOn = YES;
        _public_Global.modelType = (MaterialModelType)0;
    });
    
    return _public_Global;
}

+ (void)event:(NSString *)eventID label:(NSString *)label
{
    //友盟
    [MobClick event:eventID label:label];
    
    //Flurry
    [Flurry logEvent:eventID];
}

@end
