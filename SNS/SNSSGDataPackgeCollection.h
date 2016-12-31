//
//  SNSSGDataPackgeCollection.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/23.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSatelliteGraphicDataPackage.h"

#import "SNSRouteRecord.h"

@interface SNSSGDataPackgeCollection : NSObject

@property (nonatomic, strong, nonnull) NSArray<SNSSatelliteGraphicDataPackage *> *dataPackageCollection;
@property (nonatomic) SNSNetworkFlowSize size;

- (void)clearRouteRecord;
- (void)addRouteRecord:(nonnull SNSRouteRecord *)record;

@end
