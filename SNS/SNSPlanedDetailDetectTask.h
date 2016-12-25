//
//  SNSPlanedDetailDetectTask.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/25.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSGDetailDetectTask.h"

@interface SNSPlanedDetailDetectTask : NSObject

@property (nonatomic, strong, nonnull) SNSSGDetailDetectTask *task;
@property (nonatomic) SNSTimeRange visibleTimeRange;


@end
