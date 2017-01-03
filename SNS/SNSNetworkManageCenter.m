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

- (void)outputDpcRouteRecord
{
    FILE *route_record_log = fopen("", "w");
    assert(route_record_log != NULL);
    
    fprintf(route_record_log, "%ld\n", _dpcTransporting.count);
    for (SNSSGDataPackgeCollection *dpc in _dpcTransporting) {
        fprintf(route_record_log, "dpc carries %ld dp with %lf MB data\n", dpc.dataPackageCollection.count, dpc.size);
        for (SNSSatelliteGraphicDataPackage *dp in dpc.dataPackageCollection) {
            fprintf(route_record_log, "task-%d execution at time %lf produced %lf MB data\n", dp.taskExecution.uniqueID, dp.taskExecution.imageAction.startTime, dp.size);
        }
        
        fprintf(route_record_log, "route log %ld\n", dpc.routeRecords.count);
        for (SNSRouteRecord *record in dpc.routeRecords) {
            fprintf(route_record_log , "route %d at time %lf\n", record.routerID, record.timeStamp);
        }
        
        fprintf(route_record_log, "\n");
    }
    
    fclose(route_record_log);
}

@end
