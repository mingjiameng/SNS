//
//  SNSNatureDisaster.m
//  SNS
//
//  Created by 梁志鹏 on 2017/1/3.
//  Copyright © 2017年 overcode. All rights reserved.
//

#import "SNSNatureDisaster.h"

@implementation SNSNatureDisaster

- (NSString *)description
{
    return [NSString stringWithFormat:@"disaster happen at %@ with frequency %d per year", self.area.name, self.amountPerYear];
}

@end
