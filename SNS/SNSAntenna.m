//
//  SNSAntenna.m
//  SNS
//
//  Created by 梁志鹏 on 2017/1/1.
//  Copyright © 2017年 overcode. All rights reserved.
//

#import "SNSAntenna.h"

#import "SNSSGDPCTTaskExecutionQueue.h"

@implementation SNSAntenna

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _sending = NO;
        _receiving = NO;
    }
    
    return self;
}

- (void)setFunctionType:(SNSAntennaFunctionType)functionType
{
    _functionType = functionType;
}

- (void)continueAction
{
    if (_functionType == SNSAntennaFunctionTypeSendData) {
        [self sendDataBehavior];
        //NSLog(@"continue sending data action");
    }
    else if (_functionType == SNSAntennaFunctionTypeReceiveData) {
        [self receiveDataBehavior];
    }
    else if (_functionType == SNSAntennaFunctionTypeSendAndReceiveData) {
        [self receiveDataBehavior];
        [self sendDataBehavior];
    }
}

- (void)receiveDataBehavior
{
    
}

- (void)sendDataBehavior
{
    
}

@end
