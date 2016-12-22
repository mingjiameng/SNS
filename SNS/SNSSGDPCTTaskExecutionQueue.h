//
//  SNSSGDPCTTaskExecutionQueue.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSGDPCTTaskExecution.h"

@interface SNSSGDPCTTaskExecutionQueue : NSObject

- (nullable SNSSGDPCTTaskExecution *)pop;
- (void)addTransmissionTask:(nonnull SNSSGDPCTTaskExecution *)task;

@end
