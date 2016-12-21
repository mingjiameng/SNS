//
//  SNSSatelliteAction.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SNSSatelliteActionType) {
    SNSSatelliteActionTypeAdjusting = 1, // 姿态调整
    SNSSatelliteActionTypeImaging // 成像
};


@interface SNSSatelliteAction : NSObject

@property (nonatomic) SNSSatelliteActionType *type;

@property (nonatomic) SNSSatelliteTime expectedTimeCost; // 理论上要花费的时间
@property (nonatomic) SNSSatelliteTime timeUsed; // 已经花费的时间

@property (nonatomic) SNSSatelliteTime startTime;
@property (nonatomic) SNSSatelliteTime endTime;

@end
