//
//  SNSSatellite.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSatellite.h"

#import "SNSMath.h"

@interface SNSSatellite ()

@property (nonatomic) FILE *satelliteLog;

@end



@implementation SNSSatellite

- (void)updateState
{
//    //NSLog(@"satellite-%ld update state ", self.uniqueID);
//    NSLog(@"satellite-%ld buffered %lf MB data", self.uniqueID, self.bufferedDataSize);
//    if (self.bufferedDataSize < 0) {
//        NSLog(@"satellite-%ld buffered unormal data size %lf", self.uniqueID, self.bufferedDataSize);
//    }
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _bufferedDataSize = 0;
    }
    
    return self;
}

- (void)setOrbit:(SNSSatelliteOrbit)orbit
{
    _orbit = orbit;
    _orbitPeriod = [SNSMath orbitPeriodOfSatelliteOrbit:orbit];
    _orbitRadianSpeed = 2 * M_PI / _orbitPeriod;
}

- (SNSRadian)currentTheta
{
    return [SNSMath thetaOfSatellite:self atTime:SYSTEM_TIME];
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

- (void)stop
{
    
}

- (NSString *)spaceBufferedDataDescription
{
    SNSSpacePoint *point = [SNSMath spacePointOfSatellite:self atTime:SYSTEM_TIME];
    NSString *log = [NSString stringWithFormat:@"satellite-%d buffered %lf MB data at position <%lf, %lf, %lf>", self.uniqueID, self.bufferedDataSize, point.x, point.y, point.z];
    //NSLog(@"%@", log);
    return log;
}


@end
