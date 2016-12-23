//
//  SNSEarthPoint.m
//  SNTG
//
//  Created by 梁志鹏 on 2016/11/18.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSEarthPoint.h"

@interface SNSEarthPoint ()

@property (nonatomic) double longitude;
@property (nonatomic) double latitude;

@end


@implementation SNSEarthPoint

- (instancetype)initWithLongitude:(double)longitude andLatitude:(double)latitude
{
    self = [super init];
    
    if (self) {
        self.longitude = longitude;
        self.latitude = latitude;
    }
    
    return self;
}

@end
