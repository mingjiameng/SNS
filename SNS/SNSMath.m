//
//  SNSMath.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/23.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSMath.h"

@implementation SNSMath

+ (NSUInteger)randomIntegerBetween:(NSUInteger)baseFactor and:(NSUInteger)modifyFactor
{
    modifyFactor = modifyFactor - baseFactor + 1;
    NSUInteger tmpFactor = arc4random() % modifyFactor;
    return tmpFactor + modifyFactor;
}

+ (SNSEarthPoint *)subSatellitePoint:(SNSSatellite *)satellite atTime:(SNSSatelliteTime)time
{
    double theta0 = satellite.orbit.ta;
    double theta = theta0 + satellite.orbitRadianSpeed * time; // 单位：弧度
    //NSLog(@"theta before scale:%lf", theta);
    double theta_scale = floor((theta + M_PI) / (2 * M_PI));
    //NSLog(@"theta scale:%lf", theta_scale);
    theta -= theta_scale * 2 * M_PI;
    
    double lambda0 = satellite.orbit.raan / M_PI * 180;
    double earth_rotation_angle = EARTH_AUTO_ROTATION_ANGLE_SPEED * time;
    double lambda = lambda0 + atan(cos(satellite.orbit.oi) * tan(theta)) / M_PI * 180 - earth_rotation_angle;
    if (theta < - M_PI_2) {
        lambda += (satellite.orbit.retrograde) ? (180) : (-180);
    }
    else if (theta > M_PI_2) {
        lambda += (satellite.orbit.retrograde) ? (-180) : (180);
    }
    
    double lambda_scale = floor((lambda + 180) / 360);
    lambda -= lambda_scale * 360;
    
    double fi = asin(sin(satellite.orbit.oi) * sin(theta));
    fi = fi / M_PI * 180;
    
    return [[SNSEarthPoint alloc] initWithLongitude:lambda andLatitude:fi];
}

+ (SNSSatelliteTime)orbitPeriodOfSatelliteOrbit:(SNSSatelliteOrbit)orbit
{
    SNSSatelliteTime period = 2 * M_PI * sqrt(pow(orbit.sma, 3) / KEPLER_STATIC);
    
    return period;
}

+ (SNSRadian)thetaOfSatellite:(SNSSatellite *)satellite AtTime:(SNSSatelliteTime)time
{
    double theta0 = satellite.orbit.ta;
    double theta = theta0 + satellite.orbitRadianSpeed * time; // 单位：弧度
    //NSLog(@"theta before scale:%lf", theta);
    double theta_scale = floor((theta + M_PI) / (2 * M_PI));
    //NSLog(@"theta scale:%lf", theta_scale);
    theta -= theta_scale * 2 * M_PI;
    
    return theta;
}

+ (SNSTimeRange)visibleTimeRangeBetweenSatellite:(SNSSatellite *)satellite andHotArea:(SNSHotArea *)hotArea inTimeRange:(SNSTimeRange)theTimeRange
{
    SNSTimeRange validTimeRange;
    
    SNSEarthPoint *subPoint = [SNSMath subSatellitePoint:satellite atTime:theTimeRange.beginAt];
    //SNSEarthPoint *hotPoint = [[SNSEarthPoint alloc] initWithLongitude:hotArea.earthPoint.longitude andLatitude:hotArea.earthPoint.latitude];
    
    SNSRadian longitudeDis = fabs(subPoint.longitude - hotArea.earthPoint.longitude) / 180.0f * M_PI;
    if (!satellite.orbit.retrograde) {
        longitudeDis = 2 * M_PI - longitudeDis;
    }
    
    SNSRadian subPointLongitudeSpeed = (360 / satellite.orbitPeriod - EARTH_AUTO_ROTATION_ANGLE_SPEED) / 180 * M_PI;
    SNSSatelliteTime td = longitudeDis / subPointLongitudeSpeed + theTimeRange.beginAt;
    if (td > theTimeRange.beginAt + theTimeRange.length) {
        validTimeRange.beginAt = 0;
        validTimeRange.length = 0;
        return validTimeRange;
    }
    
    SNSSatelliteTime ts = td - ((M_PI / 6.0) / subPointLongitudeSpeed);
    ts = MAX(theTimeRange.beginAt, ts);
    SNSSatelliteTime te = td + ((M_PI / 6.0) / subPointLongitudeSpeed);
    
    SNSEarthPoint *tmpSubpoint = nil;
    bool inRange = false;
    SNSSatelliteTime st = -1;
    SNSSatelliteTime et = -1;
    SNSRadian visibleRange = M_PI / 6;
    for (SNSSatelliteTime t = ts; t <= te; t += 5.0) {
        tmpSubpoint = [SNSMath subSatellitePoint:satellite atTime:t];
        inRange = ([self radianDistanceBetweenEarthPointA:tmpSubpoint andB:hotArea.earthPoint] < visibleRange);
        if (inRange && st < 0) {
            st = t;
        }
        else if (!inRange && st > 0) {
            et = t;
            break;
        }
    }
    
    if (inRange && et < 0) {
        et = te;
    }
    
    if (st < 0) {
        validTimeRange.beginAt = 0;
        validTimeRange.length = 0;
    }
    else {
        validTimeRange.beginAt = st;
        validTimeRange.length = et - st;
    }
    
    return validTimeRange;
}

+ (SNSTimeRange)nextVisibleTimeRangeBetweenUserSatellite:(SNSSatellite *)userSatellite andGeoSatellite:(SNSDelaySatellite *)geoSatellite fromTime:(SNSSatelliteTime)time
{
    SNSEarthPoint *userSubPoint = [self subSatellitePoint:userSatellite atTime:time];
    SNSEarthPoint *geoSubPoint = [self subSatellitePoint:geoSatellite atTime:time];
    
    SNSAngle longitudeDis = fabs(userSubPoint.longitude - geoSubPoint.longitude);
    if (!userSatellite.orbit.retrograde) {
        longitudeDis = 360 - longitudeDis;
    }
    
    SNSAngle subPointLongitudeSpeed = 360 / userSatellite.orbitPeriod - EARTH_AUTO_ROTATION_ANGLE_SPEED;    SNSSatelliteTime td = longitudeDis / subPointLongitudeSpeed + time;
    SNSSatelliteTime duration = 180 / subPointLongitudeSpeed;
    
    SNSTimeRange validTimeRange;
    validTimeRange.beginAt = td - duration / 2;
    validTimeRange.length = duration;
    
    return validTimeRange;
}

+ (BOOL)isVisibleBeteenBetweenUserSatellite:(SNSSatellite *)userSatellite andGeoSatellite:(SNSDelaySatellite *)geoSatellite fromTime:(SNSSatelliteTime)time
{
    SNSEarthPoint *userSubPoint = [self subSatellitePoint:userSatellite atTime:time];
    SNSEarthPoint *geoSubPoint = [self subSatellitePoint:geoSatellite atTime:time];
    
    SNSAngle longitudeDis = fabs(userSubPoint.longitude - geoSubPoint.longitude);
    longitudeDis = MIN(360 - longitudeDis, longitudeDis);
    
    return longitudeDis < 90;
}

+ (SNSRadian)radianDistanceBetweenEarthPointA:(SNSEarthPoint *)a andB:(SNSEarthPoint *)b
{
    double x = fabs(a.longitude - b.longitude);
    x = MIN(x, 360 - x);
    double y = fabs (a.latitude - b.latitude);
    return sqrt(x * x + y * y) / 180.0f * M_PI;
}

+ (SNSSpacePoint *)spacePointOfSatellite:(SNSSatellite *)satellite atTime:(SNSSatelliteTime)time
{
    SNSRadian theta = [self thetaOfSatellite:satellite AtTime:time];
    double cosOmega = cos(satellite.orbit.raan);
    double sinOmega = sin(satellite.orbit.raan);
    double cosI = cos(satellite.orbit.oi);
    double sinI = cos(satellite.orbit.oi);
    double r = satellite.orbit.sma * (1 - satellite.orbit.e * satellite.orbit.e) / (1 + cos(theta));
    double x = - r * sin(theta);
    double y = r * cos(theta) + satellite.orbit.sma * satellite.orbit.e;
    //double z = 0;
    double X = cosOmega * x + (-cosI * sinOmega) * y + 0;
    double Y = sinOmega * x + (cosI * cosOmega) * y + 0;
    double Z = 0 + sinI * y + 0;

    return [[SNSSpacePoint alloc] initWithX:X Y:Y Z:Z];
}
@end
