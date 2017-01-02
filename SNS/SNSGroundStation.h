//
//  SNSGroundStation.h
//  SNS
//
//  Created by 梁志鹏 on 2017/1/1.
//  Copyright © 2017年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSGroundStationAntenna.h"

@interface SNSGroundStation : NSObject <SNSGroundStationAntennaDelegate>

@property (nonatomic) SNSGroundStationTag uniqueID;

@end
