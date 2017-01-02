//
//  SNSSatelliteAntenna.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/22.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSAntenna.h"

@class SNSSatellite;

@interface SNSSatelliteAntenna : SNSAntenna

@property (nonatomic, weak, nullable) SNSSatellite *owner;

@end
