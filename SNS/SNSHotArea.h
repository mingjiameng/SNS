//
//  SNSHotArea.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/23.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSEarthPoint.h"


@interface SNSHotArea : NSObject

@property (nonatomic, strong, nonnull) SNSEarthPoint *earthPoint;
@property (nonatomic) double areaLength;
@property (nonatomic) double areaGeoValue;
@property (nonatomic) double areaGraphicCompressionRatio;
@property (nonatomic) double areaGraphicCompressionRatioDis;



@end
