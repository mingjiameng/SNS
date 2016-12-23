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
@property (nonatomic, readonly) double areaLength;
@property (nonatomic, readonly) double areaGeoValue;
@property (nonatomic, readonly) double areaGraphicCompressionRatio;
@property (nonatomic, readonly) double areaGraphicCompressionRatioDis;



@end
