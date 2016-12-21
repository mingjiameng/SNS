//
//  SNSSatelliteGraphicTaskExecution.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSatelliteGraphicTaskExecution.h"



@implementation SNSSatelliteGraphicTaskExecution

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        // 初始化工作
        _state = SNSSatelliteGraphicTaskExecutionStateQueueing;
    }
    
    return self;
}

- (void)continueAction
{
    
}

@end
