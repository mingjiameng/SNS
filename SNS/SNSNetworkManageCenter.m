//
//  SNSNetworkManageCenter.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSNetworkManageCenter.h"

#import "SNSDelaySatelliteAntenna.h"
#import "SNSSGDataPackgeCollection.h"

@interface SNSNetworkManageCenter ()

@property (nonatomic, strong, nonnull) NSMutableArray<SNSSGDataPackgeCollection *> *dpcTransporting;

@end


@implementation SNSNetworkManageCenter

+ (instancetype)sharedNetworkManageCenter
{
    static dispatch_once_t onceToken;
    static SNSNetworkManageCenter *networkManageCenter = nil;
    
    dispatch_once(&onceToken, ^{
        networkManageCenter = [[SNSNetworkManageCenter alloc] init];
    });
    
    return networkManageCenter;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _dpcTransporting = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)satellite:(SNSUserSatellite *)userSatellite didSendPackageCollection:(SNSSGDataPackgeCollection *)dpc
{
    [_dpcTransporting addObject:dpc];
}

- (BOOL)schedualDPCTransmission:(SNSSGDPCTTaskExecution *)dataTransmissionTask forSatellite:(SNSUserSatellite *)userSatellite
{
    //NSLog(@"begin schedual connection");
    SNSSatelliteTime minimumTimeCost = 0x3f3f3f3f;
    SNSSatelliteTime timeCost;
    SNSDelaySatelliteAntenna *theAntenna = nil;
    for (SNSDelaySatellite *delaySatellite in self.delaySatellites) {
        for (SNSDelaySatelliteAntenna *antenna in delaySatellite.antennas) {
            // 天线的功能应该是接受数据，且没有固定的邻接点
            if (antenna.functionType != SNSAntennaFunctionTypeReceiveData || antenna.sideHop != nil) {
                continue;
            }
            
            timeCost = [antenna timeCostToUndertakenDataTransmissionTask:dataTransmissionTask];
            if (timeCost < 0) {
                continue;
            }
            else if (timeCost < minimumTimeCost) {
                theAntenna = antenna;
            }
        }
    }
    
    if (theAntenna != nil) {
        if ([theAntenna schedualDataTransmissionTask:dataTransmissionTask]) {
            return YES;
        }
    }
    
    return NO;
    
}

@end
