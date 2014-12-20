//
//  ME_AppInfo.m
//  IOSMirror
//
//  Created by gaoluyangrc on 14-7-14.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import "RC_AppInfo.h"

@implementation RC_AppInfo

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    
    if (self)
    {
        self.bannerUrl = @"";
        self.iconUrl = @"";
        self.openUrl = @"";
        self.downUrl = @"";
        
        [self setValuesForKeysWithDictionary:dic];
    }
    
    return self;
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
    NSLog(@"keyedValues......%@",keyedValues);
    
    for (NSString *key in [keyedValues allKeys])
    {
        if ([key isEqualToString:@"openUrl"] && [[keyedValues objectForKey:@"openUrl"] isKindOfClass:[NSNull class]])
        {
            self.openUrl = @"";
        }
        else if ([key isEqualToString:@"iconUrl"] && [[keyedValues objectForKey:@"iconUrl"] isKindOfClass:[NSNull class]])
        {
            self.iconUrl = @"";
        }
        else if ([key isEqualToString:@"bannerUrl"] && [[keyedValues objectForKey:@"bannerUrl"] isKindOfClass:[NSNull class]])
        {
            self.bannerUrl = @"";
        }
        else if ([key isEqualToString:@"downUrl"] && [[keyedValues objectForKey:@"downUrl"] isKindOfClass:[NSNull class]])
        {
            self.downUrl = @"";
        }
        else if (![[keyedValues objectForKey:key] isKindOfClass:[NSNull class]])
        {
            [self setValue:[keyedValues objectForKey:key] forKey:key];
        }
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
