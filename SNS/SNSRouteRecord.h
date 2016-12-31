//
//  SNSRouteRecord.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/30.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSRouteRecord : NSObject

@property (nonatomic) SNSSatelliteTime timeStamp;
@property (nonatomic) SNSRouterHopTag routerID;

@end
