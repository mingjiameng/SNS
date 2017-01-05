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
#import "SNSWideAreaScanSatellite.h"
#import "SNSGroundStation.h"

@interface SNSCoreCenter ()

@property (nonatomic, strong, nonnull) SNSTaskDistributionCenter *taskDistributionCenter;
@property (nonatomic, strong, nonnull) SNSNetworkManageCenter *networkManageCenter;

@property (nonatomic) SNSSatelliteTime systemTime;

@property (nonatomic, strong, nonnull) NSMutableArray<SNSDetailDetectSatellite *> *detailDetectSatellites;
@property (nonatomic, strong, nonnull) NSMutableArray<SNSWideAreaScanSatellite *> *wideAreaScanSatellites;
@property (nonatomic, strong, nonnull) NSMutableArray<SNSDelaySatellite *> *delaySatellites;
@property (nonatomic, strong, nonnull) NSMutableArray<SNSAntenna *> *antennas;
@property (nonatomic, strong, nonnull) NSMutableArray<SNSGroundStation *> *groundStations;

@property (nonatomic) FILE *detailDetectSatelliteLog;
@property (nonatomic) FILE *delaySatelliteLog;

@end


@implementation SNSCoreCenter

+ (instancetype)sharedCoreCenter
{
    static dispatch_once_t onceToken;
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
        //_groundStations = [[NSMutableArray alloc] init];
        
        [self readInUserSatellitesParam];
        [self readInDelaySatellitesParam];
        [self readInGroundStationParam];
        [self readInNetworkParam];
        
        _networkManageCenter.delaySatellites = _delaySatellites;
        NSMutableArray *userSatellites = [NSMutableArray arrayWithArray:_detailDetectSatellites];
        [userSatellites addObjectsFromArray:_wideAreaScanSatellites];
        _networkManageCenter.userSatellites = userSatellites;
        
        
    }
    
    return self;
}

- (void)readInGroundStationParam
{
    NSString *path = [FILE_INPUT_PATH_PREFIX_STRING stringByAppendingString:@""];
    FILE *param = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "r");
    assert(param != NULL);
    
    int n;
    fscanf(param, "%d", &n);
    
    int ground_station_tag, antenna_tag, antenna_type;
    double antenna_bandwidth;
    while(n--) {
        fscanf(param, "%d", &ground_station_tag);
        fscanf(param, "%d %d %lf", &antenna_tag, &antenna_type, &antenna_bandwidth);
        SNSGroundStationAntenna *antenna = [[SNSGroundStationAntenna alloc] init];
        antenna.functionType = antenna_type;
        antenna.uniqueID = antenna_tag;
        antenna.bandWidth = antenna_bandwidth;
        SNSGroundStation *station = [[SNSGroundStation alloc] init];
        antenna.owner = station;
        station.antennas = @[antenna];
        [_antennas addObject:antenna];
        [_groundStations addObject:station];
    }
    
    fclose(param);
}

- (void)readInUserSatellitesParam
{
    NSArray *param_files = @[@"wide_area_scan_satellite_param.txt", @"detail_detect_satellite_param_4.txt"];
    
    int n;
    double raan, aop, oi, sma, e, ta;
    int retrograde;
    double scan_width, resolution;
    int satellite_id;
    int antenna_num;
    int antenna_id, antenna_type;
    double antenna_bandWidth;
    
    for (NSString *param_file_name in param_files) {
        NSString *path = [FILE_INPUT_PATH_PREFIX_STRING stringByAppendingString:param_file_name];
        FILE *param = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "r");
        assert(param != NULL);
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
                antenna.functionType = antenna_type;
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
}

- (void)readInDelaySatellitesParam
{
    FILE *param = fopen("/Users/zkey/Desktop/science/sns_input/delay_satellite_param.txt", "r");
    assert(param != NULL);
    
    int m;
    double raan, aop, oi, sma, e, ta;
    int satellite_id;
    int antenna_num;
    int antenna_id, antenna_type;
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
            fscanf(param, "%d %d %lf", &antenna_id, &antenna_type, &antenna_bandWidth);
            SNSDelaySatelliteAntenna *antenna = [[SNSDelaySatelliteAntenna alloc] init];
            antenna.uniqueID = antenna_id;
            antenna.functionType = antenna_type;
            antenna.bandWidth = antenna_bandWidth;
            antenna.owner = satellite;
            antenna.delegate = satellite;
            [antenna_arr addObject:antenna];
            [_antennas addObject:antenna];
        }
        //fscanf(param, "\n");
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

//- (void)readInGroundStationParam
//{
//    FILE *param = fopen("/Users/zkey/Desktop/science/sns_input/ground_station_param.txt", "r");
//    assert(param != NULL);
//    
//    int n, antenna_type;
//    int station_unique_id, antenna_unique_id;
//    double antenna_band_width;
//    fscanf(param, "%d", &n);
//    while (n--) {
//        fscanf(param, "%d", &station_unique_id);
//        SNSGroundStation *station = [[SNSGroundStation alloc] init];
//        station.uniqueID = station_unique_id;
//        
//        fscanf(param, "%d %d %lf", &antenna_unique_id, &antenna_type, &antenna_band_width);
//        SNSDelaySatelliteAntenna *antenna = [[SNSDelaySatelliteAntenna alloc] init];
//        antenna.uniqueID = antenna_unique_id;
//        antenna.type = antenna_type;
//        antenna.bandWidth = antenna_band_width;
//        antenna.delegate = station;
//        [_antennas addObject:antenna];
//        
//        station.antenna = antenna;
//        [_groundStations addObject:station];
//    }
//    
//    fclose(param);
//}

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
        [self.networkManageCenter updateState];
        _systemTime += SIMULATION_TIME_STEP;
        dispatch_sync(globalQueue, ^{
            for (SNSSatellite *satellite in self.detailDetectSatellites) {
                [satellite updateState];
            }
            
            for (SNSSatellite *satellite in self.wideAreaScanSatellites) {
                [satellite updateState];
            }
            
            for (SNSSatellite *satellite in self.delaySatellites) {
                [satellite updateState];
            }
        });
    }
    
    for (SNSSatellite *satellite in self.detailDetectSatellites) {
        [satellite stop];
    }
    
    for (SNSSatellite *satellite in self.wideAreaScanSatellites) {
        [satellite stop];
    }
    
    for (SNSSatellite *satellite in self.delaySatellites) {
        [satellite stop];
    }
    
    [self.networkManageCenter stop];
    
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
