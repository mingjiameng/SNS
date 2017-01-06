//
//  SNSWideScanArea.h
//  SNS
//
//  Created by 梁志鹏 on 2017/1/3.
//  Copyright © 2017年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNSEarthPoint;

@interface SNSWideScanArea : NSObject

@property (nonatomic, strong, nonnull) NSString *name;

@property (nonatomic) double left;
@property (nonatomic) double right;
@property (nonatomic) double up;
@property (nonatomic) double bottom;

+ (BOOL)earthPoint:(SNSEarthPoint *)earthPoint inArea:(SNSWideScanArea *)area;

@end
