//
//  SNSSatellite.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSatelliteAntenna.h"

@class SNSSatellite;

typedef NS_ENUM(NSInteger, SNSSatelliteType) {
    SNSSatelliteTypeDetailDetection = 1, // 详查
    SNSSatelliteTypeWideAreaScan = 2, // 普查
    SNSSatelliteTypeRelay = 3, // 中继
};

typedef struct {
    double raan; // 右升交点赤经
    double aop; // 近地点幅角
    double oi; // 轨道倾角
    double sma; // 长半轴
    double e; // 离心率
    double ta; // 真近点角
}SNSSatelliteOrbit;


@interface SNSSatellite : NSObject

@property (nonatomic) NSUInteger uniqueID;
@property (nonatomic) SNSSatelliteType type;
@property (nonatomic) SNSSatelliteOrbit orbit;
// 缓冲区大小 暂不考虑缓冲区大小的限制
//@property (nonatomic) SNSNetworkFlowSize bufferSize;

// 以下参数衍生自轨道参数
@property (nonatomic) SNSAngle angleSpeed;
@property (nonatomic) SNSSatelliteTime orbitPeriod;
//@property (nonatomic, strong, nonnull) SNSSpaceVector *orbitNormalVector;

// 以下参数是卫星的运行时参数
@property (nonatomic) SNSSatelliteTime satelliteTime; // 卫星运行时间
//@property (nonatomic, strong, nonnull) SNSSpaceVector *currentSpacePosition; // 当前空间位置
@property (nonatomic) SNSAngle currentTheta; // 卫星当前在轨道上的位置
@property (nonatomic) SNSNetworkFlowSize bufferedDataSize; // 缓冲区已缓存的数据量

// 天线
@property (nonatomic, strong, nonnull) NSArray<SNSSatelliteAntenna *> *antennas;




- (void)updateState;

@end
