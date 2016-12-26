//
//  SNSCoreCenter.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSCoreCenter.h"

#import "SNSNetworkManageCenter.h"
#import "SNSTaskDistributionCenter.h"

#import "SNSDetailDetectSatellite.h"
#import "SNSDelaySatellite.h"
#import "SNSUserSatelliteAntenna.h"
#import "SNSDelaySatelliteAntenna.h"


@interface SNSCoreCenter ()

@property (nonatomic, strong, nonnull) SNSTaskDistributionCenter *taskDistributionCenter;
@property (nonatomic, strong, nonnull) SNSNetworkManageCenter *networkManageCenter;

@property (nonatomic) SNSSatelliteTime systemTime;

@property (nonatomic, strong, nonnull) NSMutableArray<SNSDetailDetectSatellite *> *detailDetectSatellites;
@property (nonatomic, strong, nonnull) NSMutableArray<SNSDelaySatellite *> *delaySatellites;
@property (nonatomic, strong, nonnull) NSMutableArray<SNSSatelliteAntenna *> *antennas;

@property (nonatomic) FILE *detailDetectSatelliteLog;
@property (nonatomic) FILE *delaySatelliteLog;

@end


@implementation SNSCoreCenter

+ (instancetype)sharedCoreCenter
{
    dispatch_once_t onceToken;
    static SNSCoreCenter *coreCenter = nil;
    
    dispatch_once(&onceToken, ^{
        coreCenter = [[SNSCoreCenter alloc] init];
    });
    
    return coreCenter;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _taskDistributionCenter = [SNSTaskDistributionCenter sharedTaskDistributionCenter];
        _networkManageCenter = [SNSNetworkManageCenter sharedNetworkManageCenter];
        
        _detailDetectSatellites = [[NSMutableArray alloc] init];
        _delaySatellites = [[NSMutableArray alloc] init];
        _antennas = [[NSMutableArray alloc] init];
        
        [self readInUserSatellites];
        [self readInDelaySatellitesParam];
        [self readInNetworkParam];
    }
    
    return self;
}

- (void)readInUserSatellites
{
    FILE *param = fopen("/Users/zkey/Desktop/science/satellite_param/user_satellite_param.txt", "r");
    assert(param != NULL);
    
    int n;
    double raan, aop, oi, sma, e, ta;
    int retrograde;
    double scan_width, resolution;
    int satellite_id;
    int antenna_num;
    int antenna_id, antenna_type;
    double antenna_bandWidth;
    
    fscanf(param, "%d", &n);
    while (n--) {
        SNSDetailDetectSatellite *satellite = [[SNSDetailDetectSatellite alloc] init];
        fscanf(param, "%d", &satellite_id);
        satellite.uniqueID = satellite_id;
        
        fscanf(param, "%lf %lf %lf %lf %lf %lf %d", &raan, &aop, &oi, &sma, &e, &ta, &retrograde);
        SNSSatelliteOrbit orbit;
        orbit.raan = raan;
        orbit.aop = aop;
        orbit.oi = oi;
        orbit.sma = sma;
        orbit.e = e;
        orbit.ta = ta;
        satellite.orbit = orbit;
        orbit.retrograde = retrograde;
        fscanf(param, "%lf %lf", &resolution, &scan_width);
        satellite.resolution = resolution;
        satellite.scanWidth = scan_width;
        
        fscanf(param, "%d", &antenna_num);
        NSMutableArray *antenna_arr = [NSMutableArray arrayWithCapacity:antenna_num];
        while (antenna_num--) {
            fscanf(param, "%d %d %lf", &antenna_id, &antenna_type, &antenna_bandWidth);
            SNSUserSatelliteAntenna *antenna = [[SNSUserSatelliteAntenna alloc] init];
            antenna.uniqueID = antenna_id;
            antenna.type = antenna_type;
            antenna.bandWidth = antenna_bandWidth;
            antenna.owner = satellite;
            antenna.delegate = satellite;
            [antenna_arr addObject:antenna];
            [_antennas addObject:antenna];
        }
        
        satellite.antennas = antenna_arr;
        satellite.taskQueueDataSource = _taskDistributionCenter;
        satellite.flowTransportDelegate = _networkManageCenter;
        
        [_detailDetectSatellites addObject:satellite];
    }
    
    fclose(param);
}

- (void)readInDelaySatellitesParam
{
    FILE *param = fopen("/Users/zkey/Desktop/science/sns_input/delay_satellite_param.txt", "r");
    assert(param != NULL);
    
    int m;
    double raan, aop, oi, sma, e, ta;
    int satellite_id;
    int antenna_num;
    int antenna_id;
    double antenna_bandWidth;
    
    fscanf(param, "%d", &m);
    while (m--) {
        SNSDelaySatellite *satellite = [[SNSDelaySatellite alloc] init];
        fscanf(param, "%d", &satellite_id);
        satellite.uniqueID = satellite_id;
        
        fscanf(param, "%lf %lf %lf %lf %lf %lf", &raan, &aop, &oi, &sma, &e, &ta);
        SNSSatelliteOrbit orbit;
        orbit.raan = raan;
        orbit.aop = aop;
        orbit.oi = oi;
        orbit.sma = sma;
        orbit.e = e;
        orbit.ta = ta;
        orbit.retrograde = false;
        satellite.orbit = orbit;
    
        fscanf(param, "%d", &antenna_num);
        NSMutableArray *antenna_arr = [NSMutableArray arrayWithCapacity:antenna_num];
        while (antenna_num--) {
            fscanf(param, "%d %lf", &antenna_id, &antenna_bandWidth);
            SNSDelaySatelliteAntenna *antenna = [[SNSDelaySatelliteAntenna alloc] init];
            antenna.uniqueID = antenna_id;
            antenna.bandWidth = antenna_bandWidth;
            antenna.owner = satellite;
            antenna.delegate = satellite;
            [antenna_arr addObject:antenna];
            [_antennas addObject:antenna];
        }
        
        satellite.antennas = antenna_arr;
        [_delaySatellites addObject:satellite];
    }
    
    fclose(param);
}

- (void)readInNetworkParam
{
    FILE *param = fopen("/Users/zkey/Desktop/science/sns_input/network_topology_param.txt", "r");
    assert(param != NULL);
    
    int w;
    fscanf(param, "%d", &w);
    int p, q; // 由p 到 q的边
    while (w--) {
        fscanf(param, "%d %d", &p, &q);
        SNSDelaySatelliteAntenna *antennaP = (SNSDelaySatelliteAntenna *)[self antennaWithID:p];
        SNSDelaySatelliteAntenna *antennaQ = (SNSDelaySatelliteAntenna *)[self antennaWithID:q];
        antennaP.sideHop = antennaQ;
        antennaQ.sideHop = antennaP;
    }
}

- (SNSSatelliteAntenna *)antennaWithID:(SNSAntennaTag)uniqueID
{
    for (SNSSatelliteAntenna *antenna in self.antennas) {
        if (antenna.uniqueID == uniqueID) {
            return antenna;
        }
    }
    
    return nil;
}

- (void)fire
{
    _systemTime = 0;
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    while (_systemTime < EXPECTED_SIMULATION_TIME) {
        if ((NSUInteger)_systemTime % 60 == 0) {
            for (SNSSatellite *satellite in self.detailDetectSatellites) {
                fprintf(self.detailDetectSatelliteLog, "%s\n", [[satellite spaceBufferedDataDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
            for (SNSSatellite *satellite in self.delaySatellites) {
                fprintf(self.delaySatelliteLog, "%s\n", [[satellite spaceBufferedDataDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        }
        
        _systemTime += SIMULATION_TIME_STEP;
        dispatch_sync(globalQueue, ^{
            for (SNSSatellite *satellite in self.detailDetectSatellites) {
                [satellite updateState];
            }
            
            for (SNSSatellite *satellite in self.delaySatellites) {
                [satellite updateState];
            }
        });
    }
    
    fclose(self.detailDetectSatelliteLog);
    fclose(self.delaySatelliteLog);
}

- (FILE *)detailDetectSatelliteLog
{
    if (_detailDetectSatelliteLog == NULL) {
        _detailDetectSatelliteLog = fopen("/Users/zkey/Desktop/science/sns_output/detail_detect_satellite_buffered_data_log.txt", "w+");
        assert(_detailDetectSatelliteLog != NULL);
    }
    
    return _detailDetectSatelliteLog;
}

- (FILE *)delaySatelliteLog
{
    if (_delaySatelliteLog == NULL) {
        _delaySatelliteLog = fopen("/Users/zkey/Desktop/science/sns_output/delay_satellite_buffered_data_log.txt", "w+");
        assert(_delaySatelliteLog != NULL);
    }
    
    return _delaySatelliteLog;
}


@end
