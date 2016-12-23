//
//  SNSSpacePoint.h
//  SNTG
//
//  Created by 梁志鹏 on 2016/11/30.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSSpacePoint : NSObject

@property (nonatomic, readonly) double x;
@property (nonatomic, readonly) double y;
@property (nonatomic, readonly) double z;


- (instancetype)initWithX:(double)x Y:(double)y Z:(double)z;

@end
