//
//  SNSNetworkManageCenter.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSNetworkManageCenter.h"

@implementation SNSNetworkManageCenter

+ (instancetype)sharedNetworkManageCenter
{
    dispatch_once_t onceToken;
    static SNSNetworkManageCenter *networkManageCenter = nil;
    
    dispatch_once(&onceToken, ^{
        networkManageCenter = [[SNSNetworkManageCenter alloc] init];
    });
    
    return networkManageCenter;
}

@end
