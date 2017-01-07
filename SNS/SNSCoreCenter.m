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
@property (nonatomic, strong, nonnull) NSMutableArray<SNSUserSatellite *> *userSatellites;

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
        _wideAreaScanSatellites = [[NSMutableArray alloc] init];
        _delaySatellites = [[NSMutableArray alloc] init];
        _antennas = [[NSMutableArray alloc] init];
        _groundStations = [[NSMutableArray alloc] init];
        
        [self readInUserSatellitesParam];
        [self readInDelaySatellitesParam];
        [self readInGroundStationParam];
        [self readInNetworkParam];
        
        _networkManageCenter.delaySatellites = _delaySatellites;
        _userSatellites = [[NSMutableArray alloc] init];
        [_userSatellites addObjectsFromArray:_detailDetectSatellites];
        [_userSatellites addObjectsFromArray:_wideAreaScanSatellites];
        NSLog(@"read in %ld user satellites", _userSatellites.count);
        _networkManageCenter.userSatellites = _userSatellites;
        
    }
    
    return self;
}

- (void)readInGroundStationParam
{
    NSString *path = [FILE_INPUT_PATH_PREFIX_STRING stringByAppendingString:@"ground_station_param.txt"];
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
        station.uniqueID = ground_station_tag;
        antenna.owner = station;
        antenna.delegate = station;
        station.antennas = @[antenna];
        [_antennas addObject:antenna];
        [_groundStations addObject:station];
    }
    
    fclose(param);
}

- (void)readInUserSatellitesParam
{
    NSString *wide_area_satellite_param_file = @"wide_area_scan_satellite_param.txt";
    NSString *detail_detect_satellite_param_file = @"detail_detect_satellite_param.txt";
    NSArray *param_files = @[detail_detect_satellite_param_file, wide_area_satellite_param_file];
    
    int n;
    double raan, aop, oi, sma, e, ta;
    int retrograde;
    double scan_width, resolution;
    int satellite_id;
    int antenna_num;
    int antenna_id, antenna_type;
    double antenna_bandWidth;
    
    for (NSString *param_file_name in param_files) {
        NSMutableArray *_satellites = _detailDetectSatellites;
        if ([param_file_name isEqualToString:wide_area_satellite_param_file]) {
            _satellites = _wideAreaScanSatellites;
        }
        NSString *path = [FILE_INPUT_PATH_PREFIX_STRING stringByAppendingString:param_file_name];
        FILE *param = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "r");
        assert(param != NULL);
        fscanf(param, "%d", &n);
        while (n--) {
            SNSUserSatellite *satellite = [self newUserSatelliteWithParamFileName:param_file_name];
            fscanf(param, "%d", &satellite_id);
            //NSLog(@"satellite_id %d", satellite_id);
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
            //NSLog(@"antenna_num %d", antenna_num);
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
            
            [_satellites addObject:satellite];
        }
        
        NSLog(@"read in %ld user satellites", _satellites.count);
        
        fclose(param);
    }
}

- (SNSUserSatellite *)newUserSatelliteWithParamFileName:(NSString *)fileName
{
    if ([fileName containsString:@"detail_detect"]) {
        return [[SNSDetailDetectSatellite alloc] init];
    }
    else {
        return [[SNSWideAreaScanSatellite alloc] init];
    }
    
    return nil;
}

- (void)readInDelaySatellitesParam
{
    NSString *path = [FILE_INPUT_PATH_PREFIX_STRING stringByAppendingString:@"delay_satellite_param.txt"];
    FILE *param = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "r");
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

        satellite.antennas = antenna_arr;
        [_delaySatellites addObject:satellite];
    }
    
    
    fclose(param);
}

- (void)readInNetworkParam
{
    NSString *path = [FILE_INPUT_PATH_PREFIX_STRING stringByAppendingString:@"network_topology_param.txt"];
    FILE *param = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "r");
    assert(param != NULL);
    
    int w;
    fscanf(param, "%d", &w);
    int p, q; // 由p 到 q的边
    while (w--) {
        fscanf(param, "%d %d", &p, &q);
        SNSAntenna *antennaP = [self antennaWithID:p];
        SNSAntenna *antennaQ = [self antennaWithID:q];
        if (300 < p && p < 400) {
            ((SNSDelaySatelliteAntenna *)antennaP).sideHop = antennaQ;
        }
        else {
            ((SNSGroundStationAntenna *)antennaP).sideHop = antennaQ;
        }
        
        if (300 < q && q < 400) {
            ((SNSDelaySatelliteAntenna *)antennaQ).sideHop = antennaP;
        }
        else {
            ((SNSGroundStationAntenna *)antennaQ).sideHop = antennaP;
        }
    }
}

- (SNSAntenna *)antennaWithID:(SNSAntennaTag)uniqueID
{
    for (SNSAntenna *antenna in self.antennas) {
        if (antenna.uniqueID == uniqueID) {
            return antenna;
        }
    }
    
    NSLog(@"warning! nil antenna with id %d", uniqueID);
    
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
            
            for (SNSGroundStation *station in self.groundStations) {
                [station updateState];
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
        NSString *path = [FILE_OUTPUT_PATH_PREFIX_STRING stringByAppendingString:@"detail_detect_satellite_buffered_data_log.txt"];
        _detailDetectSatelliteLog = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w");
        assert(_detailDetectSatelliteLog != NULL);
    }
    
    return _detailDetectSatelliteLog;
}

- (FILE *)delaySatelliteLog
{
    if (_delaySatelliteLog == NULL) {
        NSString *path = [FILE_OUTPUT_PATH_PREFIX_STRING stringByAppendingString:@"delay_satellite_buffered_data_log.txt"];
        _delaySatelliteLog = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w");
        assert(_delaySatelliteLog != NULL);
    }
    
    return _delaySatelliteLog;
}


@end
