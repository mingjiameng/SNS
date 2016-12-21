//
//  SNSCoreCenter.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSCoreCenter : NSObject

@property (nonatomic, readonly) SNSSatelliteTime systemTime;

+ (nonnull instancetype)sharedCoreCenter;

- (void)fire;

@end
