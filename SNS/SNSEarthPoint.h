//
//  SNSEarthPoint.h
//  SNTG
//
//  Created by 梁志鹏 on 2016/11/18.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSEarthPoint : NSObject

@property (nonatomic, readonly) double longitude;
@property (nonatomic, readonly) double latitude;

- (nonnull instancetype)initWithLongitude:(double)longitude andLatitude:(double)latitude;

@end
