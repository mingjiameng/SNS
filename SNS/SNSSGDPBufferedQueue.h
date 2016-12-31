//
//  SNSSGDPBufferedQueue.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSatelliteGraphicDataPackage.h"
#import "SNSSatelliteGraphicDataPackage.h"

@interface SNSSGDPBufferedQueue : NSObject



@property (nonatomic, readonly) SNSNetworkFlowSize bufferedFlowSize;

- (void)insertDataPackage:(nonnull NSArray<SNSSatelliteGraphicDataPackage *> *)dataPackage;
- (void)addDataPackage:(nonnull SNSSatelliteGraphicDataPackage *)dataPackage;
//- (nonnull NSArray<SNSSatelliteGraphicDataPackage *> *)productDataPackageCollection;
- (void)removeDataPackage:(nonnull NSArray<SNSSatelliteGraphicDataPackage *> *)dataPackages;


@end
