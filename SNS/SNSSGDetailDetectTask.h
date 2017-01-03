//
//  SNSSGDetailDetectTask.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/23.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSHotArea.h"

@interface SNSSGDetailDetectTask : NSObject

@property (nonatomic, strong, nonnull) SNSHotArea *hotArea;
@property (nonatomic) NSUInteger expectedExecutedCount;
@property (nonatomic) SNSTaskExecutionTag uniqueID;

@end
