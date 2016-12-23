//
//  SNSSpacePoint.m
//  SNTG
//
//  Created by 梁志鹏 on 2016/11/30.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSpacePoint.h"

@interface SNSSpacePoint ()

@property (nonatomic) double x;
@property (nonatomic) double y;
@property (nonatomic) double z;

@end


@implementation SNSSpacePoint

- (instancetype)initWithX:(double)x Y:(double)y Z:(double)z
{
    self = [super init];
    
    if (self) {
        self.x = x;
        self.y = y;
        self.z = z;
    }
    
    return self;
}

@end
