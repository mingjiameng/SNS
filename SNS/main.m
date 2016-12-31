//
//  main.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSatellite.h"
#import "SNSMath.h"
#import "SNSCoreCenter.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
//        SNSSatellite *satellite = [[SNSSatellite alloc] init];
//        SNSSatelliteOrbit orbit;
//        orbit.raan = M_PI_4;
//        orbit.aop = M_PI / 3;
//        orbit.oi = M_PI / 3;
//        orbit.sma = 7151;
//        orbit.e = 0.2;
//        orbit.ta = 0;
//        satellite.orbit = orbit;
//        
//        //NSLog(@"%@", satellite);
//        
//        SNSEarthPoint *earthPoint = nil;
//        double max_lati = 0;
//        for (double t = 0; t < 7000; t += 10) {
//            earthPoint = [SNSMath subSatellitePoint:satellite atTime:t];
//            if (earthPoint.latitude > max_lati) {
//                max_lati = earthPoint.latitude;
//            }
//        }
//        
//        NSLog(@"max_lati:%lf", max_lati);
        
        SNSCoreCenter *center = [SNSCoreCenter sharedCoreCenter];
        //[center fire];
        
    }
    return 0;
}
