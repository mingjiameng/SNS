//
//  SNSGroundStation.m
//  SNS
//
//  Created by 梁志鹏 on 2017/1/1.
//  Copyright © 2017年 overcode. All rights reserved.
//

#import "SNSGroundStation.h"

#import "SNSSGDataPackgeCollection.h"
#import "SNSDelaySatelliteAntenna.h"

@interface SNSGroundStation ()

@property (nonatomic, nonnull) FILE *dpcReceiveLog;

@end


@implementation SNSGroundStation

- (void)antenna:(SNSAntenna *)antenna didReceiveDataPackageCollection:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    [self recordDpcReceive:dataPackageCollection];
}

- (BOOL)antenna:(SNSGroundStationAntenna *)antenna confirmConnectionWithAntenna:(SNSAntenna *)anotherAntenna
{
    if ([anotherAntenna isKindOfClass:[SNSDelaySatelliteAntenna class]]) {
        SNSDelaySatelliteAntenna *sideAntenna = (SNSDelaySatelliteAntenna *)anotherAntenna;
        if (sideAntenna.sideHop.uniqueID == antenna.uniqueID) {
            return YES;
        }
    }
    
    return NO;
}

- (void)recordDpcReceive:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    NSString *overview = [NSString stringWithFormat:@"receive dpc with %ld dp and %lf MB data at time %lf", dataPackageCollection.dataPackageCollection.count, dataPackageCollection.size, SYSTEM_TIME];
    fprintf(self.dpcReceiveLog, "%s\n", [overview cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (FILE *)dpcReceiveLog
{
    if (_dpcReceiveLog == NULL) {
        _dpcReceiveLog = fopen("/Users/zkey/Desktop/science/sns_output/ground_station_dpc_receive_log.txt", "w");
        assert(_dpcReceiveLog != NULL);
    }
    
    return _dpcReceiveLog;
}

@end
