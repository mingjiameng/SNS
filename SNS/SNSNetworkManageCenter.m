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
#import "SNSSGDPCTTaskExecution.h"

@interface SNSNetworkManageCenter ()

@property (nonatomic, strong, nonnull) NSMutableArray<SNSSGDataPackgeCollection *> *dpcTransporting;
@property (nonatomic, nonnull) FILE *bufferedDataLog;
@property (atomic) SNSDataPackageTag dpTag;

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
        _dpTag = 1;
    }
    
    return self;
}

- (SNSDataPackageTag)newDpTag
{
    return _dpTag++;
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

// TODO 任务传输规划策略
- (SNSSGDPCTTaskExecution *)schedualDataTransmissionForSatellite:(SNSUserSatellite *)userSatellite withSendingAntenna:(SNSUserSatelliteAntenna *)sendingAntenna
{
    //NSLog(@"receive data transmission schedual request");
    
    double maximumCostPerformance = 0;
    SNSSatelliteTime costPerformance;
    SNSDelaySatelliteAntenna *theAntenna = nil;
    for (SNSDelaySatellite *delaySatellite in self.delaySatellites) {
        for (SNSDelaySatelliteAntenna *antenna in delaySatellite.antennas) {
            // 天线的功能应该是接受数据，且没有固定的邻接点
            //NSLog(@"delay antenna id %d", antenna.uniqueID);
            if (antenna.functionType != SNSAntennaFunctionTypeReceiveData || antenna.sideHop != nil) {
                continue;
            }
            
            //NSLog(@"usable delay antenna id %d", antenna.uniqueID);
            costPerformance = [antenna costPerformanceToSchedualTransmissionForUserSatellite:userSatellite withSendingAntenna:sendingAntenna];
            //NSLog(@"satellite-%d antenna-%d costPerformance:%lf", userSatellite.uniqueID, antenna.uniqueID, costPerformance);
            if (costPerformance > maximumCostPerformance) {
                theAntenna = antenna;
                maximumCostPerformance = costPerformance;
            }
        }
    }
    
    if (theAntenna != nil) {
        SNSSGDPCTTaskExecution *dpct = [theAntenna schedualTransmissionForUserSatellite:userSatellite withSendingAntenna:sendingAntenna];
        return dpct;
    }
    
    NSLog(@"userSatellite-%d fail to get connection", userSatellite.uniqueID);
    
    return nil;
}

- (void)updateState
{
    [self recordBufferedData];
}

- (void)recordBufferedData
{
    // record buffered data
    if ((NSUInteger)SYSTEM_TIME % 60 == 0) {
        SNSNetworkFlowSize user_satellite_buffered_data_size, delay_satellite_buffered_data_size;
        user_satellite_buffered_data_size = 0;
        //NSLog(@"buffered flow in %ld user satellites and %ld delay satellites", self.userSatellites.count, self.delaySatellites.count);
        for (SNSSatellite *satellite in self.userSatellites) {
            //fprintf(self.detailDetectSatelliteLog, "%s\n", [[satellite spaceBufferedDataDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            //NSLog(@"satellite-%d buffered %lf data at time %lf", satellite.uniqueID, satellite.bufferedDataSize, SYSTEM_TIME);
            user_satellite_buffered_data_size += satellite.bufferedDataSize;
        }
        
        delay_satellite_buffered_data_size = 0;
        for (SNSSatellite *satellite in self.delaySatellites) {
            //fprintf(self.delaySatelliteLog, "%s\n", [[satellite spaceBufferedDataDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            delay_satellite_buffered_data_size += satellite.bufferedDataSize;
            //NSLog(@"satellite-%d buffered %lf data at time %lf", satellite.uniqueID, satellite.bufferedDataSize, SYSTEM_TIME);
        }
        
        fprintf(self.bufferedDataLog, "user satellite buffered %lf MB data and delay satellite buffered %lf MB data at time %lf\n", user_satellite_buffered_data_size, delay_satellite_buffered_data_size, SYSTEM_TIME);
    }
}

- (void)stop
{
    fclose(self.bufferedDataLog);
    [self outputDpcRouteRecord];
}

- (void)outputDpcRouteRecord
{
    NSString *path = [FILE_OUTPUT_PATH_PREFIX_STRING stringByAppendingString:@"route_record_log.txt"];
    FILE *route_record_log = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w");
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



- (FILE *)bufferedDataLog
{
    if (_bufferedDataLog == NULL) {
        NSString *path = [FILE_OUTPUT_PATH_PREFIX_STRING stringByAppendingString:@"buffered_data_log.txt"];
        _bufferedDataLog = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w");
        assert(_bufferedDataLog != NULL);
    }
    
    return _bufferedDataLog;
}

@end
