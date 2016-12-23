//
//  SNSSatelliteGraphicDataPackage.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSatelliteGraphicDataPackage.h"

@implementation SNSSatelliteGraphicDataPackage

- (void)setTaskExecution:(SNSSatelliteGraphicTaskExecution *)taskExecution
{
    _taskExecution = taskExecution;
    
    _size = _taskExecution.dataProduced;
}

@end
