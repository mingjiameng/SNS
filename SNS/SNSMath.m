//
//  SNSMath.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/23.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSMath.h"

@implementation SNSMath

+ (unsigned int)randomIntegerBetween:(unsigned int)baseFactor and:(unsigned int)modifyFactor
{
    modifyFactor = modifyFactor - baseFactor + 1;
    int tmpFactor = arc4random() % modifyFactor;
    return tmpFactor + modifyFactor;
}

@end
