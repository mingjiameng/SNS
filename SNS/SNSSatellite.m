//
//  SNSSatellite.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSatellite.h"

#import "SNSMath.h"

@implementation SNSSatellite

- (void)updateState
{
    //NSLog(@"satellite-%ld update state ", self.uniqueID);
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.bufferedDataSize = 0;
    }
    
    return self;
}

- (void)setOrbit:(SNSSatelliteOrbit)orbit
{
    _orbit = orbit;
    _orbitPeriod = [SNSMath orbitPeriodOfSatelliteOrbit:orbit];
    _orbitRadianSpeed = 2 * M_PI / _orbitPeriod;
}

//- (NSString *)description
//{
//    SNSSpacePoint *point = [SNSMath spacePointOfSatellite:self];
//    return [NSString stringWithFormat:@"satellite-%ld buffered data %lf MB at <%lf, %lf, %lf>", self.uniqueID, self.bufferedDataSize, point.x, point.y, point.z];
//}

//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"satellite-%ld with orbit peroid:%lf", self.uniqueID, self.orbitPeriod];
//}

- (NSString *)spaceBufferedData
{
    SNSSpacePoint *point = [SNSMath spacePointOfSatellite:self atTime:SYSTEM_TIME];
    return [NSString stringWithFormat:@"%lf %lf %lf %lf", point.x, point.y, point.z, self.bufferedDataSize];
}

@end
