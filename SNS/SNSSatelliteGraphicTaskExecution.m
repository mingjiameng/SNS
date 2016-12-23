//
//  SNSSatelliteGraphicTaskExecution.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSatelliteGraphicTaskExecution.h"

#import "SNSDetailDetectSatellite.h"
#import "SNSMath.h"

@implementation SNSSatelliteGraphicTaskExecution

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        // 初始化工作
        _state = SNSSatelliteGraphicTaskExecutionStateQueueing;
        _dataProduced = -1;
    }
    
    return self;
}

- (void)continueAction
{
    if (self.state == SNSSatelliteGraphicTaskExecutionStateQueueing) {
        self.state = SNSSatelliteGraphicTaskExecutionStateAdjusting;
    }
    else if (self.state == SNSSatelliteGraphicTaskExecutionStateAdjusting) {
        SNSSatelliteTime time = SYSTEM_TIME;
        if (time >= self.imageAction.ExpectedStartTime) {
            self.state = SNSSatelliteGraphicTaskExecutionStateImaging;
            self.imageAction.startTime = time;
        }
    }
    else if (self.state == SNSSatelliteGraphicTaskExecutionStateImaging) {
        SNSSatelliteTime time = SYSTEM_TIME;
        if (time >= self.imageAction.startTime + self.imageAction.expectedTimeCost) {
            self.state = SNSSatelliteGraphicTaskExecutionStateCompleted;
            self.imageAction.endTime = time;
        }
    }
}

- (SNSNetworkFlowSize)dataProduced
{
    if (_dataProduced < 0) {
        double pixels = self.executor.scanWidth * self.task.hotArea.areaLength / (self.executor.resolution * self.executor.resolution);
        double dataInMb = pixels * 3 / 1048576;
        dataInMb += 800.0f; // 800MB的数据量是提前开机和拖后关机共4s产生的数据量
        
        int ratioDisFactor = [SNSMath randomIntegerBetween:0 and:ceil(self.task.hotArea.areaGraphicCompressionRatioDis * 100)];
        double ratioDis = ratioDisFactor / 100;
        double ratio = self.task.hotArea.areaGraphicCompressionRatio;
        if (ratioDisFactor % 2 == 0) {
            ratio += ratioDis;
        }
        else {
            ratio -= ratioDis;
        }
        
        double dataCompressed = dataInMb / ratio;
        return dataCompressed;
    }
    
    return _dataProduced;
}



@end
