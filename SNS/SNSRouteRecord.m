//
//  SNSRouteRecord.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/30.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSRouteRecord.h"

@implementation SNSRouteRecord

- (NSString *)description
{
    return [NSString stringWithFormat:@"%lf %d", self.timeStamp, self.routerID];
}

@end
