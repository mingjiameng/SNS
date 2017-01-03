//
//  SNSWideScanArea.m
//  SNS
//
//  Created by 梁志鹏 on 2017/1/3.
//  Copyright © 2017年 overcode. All rights reserved.
//

#import "SNSWideScanArea.h"

#import "SNSEarthPoint.h"

@implementation SNSWideScanArea

+ (BOOL)earthPoint:(SNSEarthPoint *)earthPoint inArea:(SNSWideScanArea *)area
{
    // 纬度
    if (!(area.bottom <= earthPoint.latitude && earthPoint.latitude <= area.up)) {
        return NO;
    }
    
    // 经度
    if (area.right > 0) {
        if (!(area.left <= earthPoint.longitude && earthPoint.longitude <= area.right)) {
            return NO;
        }
    }
    else {
        if (area.left < 0) {
            if (!(area.left <= earthPoint.longitude && earthPoint.longitude <= area.right)) {
                return NO;
            }
        }
        else {
            if (!(earthPoint.longitude > area.left || earthPoint.longitude < area.right)) {
                return NO;
            }
        }
    }
    
    return YES;
}

@end
