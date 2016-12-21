//
//  SNSSGTaskExecutionQueue.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSGTaskExecutionQueue.h"

@interface SNSSGTaskExecutionQueue ()

@property (nonatomic, strong, nonnull) NSMutableArray *taskExecutionArray;

@end


@implementation SNSSGTaskExecutionQueue

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _taskExecutionArray = [NSMutableArray arrayWithCapacity:10];
    }
    
    return self;
}

- (SNSSatelliteGraphicTaskExecution *)pop
{
    SNSSatelliteGraphicTaskExecution *e = [_taskExecutionArray firstObject];
    
    if (e != nil) {
        [_taskExecutionArray removeObjectAtIndex:0];
    }
    
    return e;
}

- (void)add:(NSArray<SNSSatelliteGraphicTaskExecution *> *)taskExecutions
{
    [_taskExecutionArray addObjectsFromArray:taskExecutions];
    
    for (SNSSatelliteGraphicTaskExecution *e in _taskExecutionArray) {
        e.state = SNSSatelliteGraphicTaskExecutionStateQueueing;
    }
}

@end
