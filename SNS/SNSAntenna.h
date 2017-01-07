//
//  SNSAntenna.h
//  SNS
//
//  Created by 梁志鹏 on 2017/1/1.
//  Copyright © 2017年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNSAntenna;
@class SNSSGDataPackgeCollection;
@class SNSSGDPCTTaskExecution;
@class SNSSGDPCTTaskExecutionQueue;

@protocol SNSAntennaDelegate <NSObject>
@optional
- (void)antenna:(nonnull SNSAntenna *)antenna didReceiveDataPackageCollection:(nonnull SNSSGDataPackgeCollection *)dataPackageCollection;
- (void)antenna:(nonnull SNSAntenna *)antenna didSendDataPackageCollection:(nonnull SNSSGDataPackgeCollection *)dataPackageCollection;
- (void)antenna:(nonnull SNSAntenna *)antenna didFailToSendDataPackageCollection:(nonnull SNSSGDataPackgeCollection *)dataPackageCollection;

@end


typedef NS_ENUM(NSInteger, SNSAntennaFunctionType) {
    SNSAntennaFunctionTypeSendData = 1,
    SNSAntennaFunctionTypeReceiveData = 2,
    SNSAntennaFunctionTypeSendAndReceiveData = 3
};

@interface SNSAntenna : NSObject

@property (nonatomic) SNSAntennaTag uniqueID;
@property (nonatomic) SNSNetworkFlowSize bandWidth;
@property (nonatomic) SNSAntennaFunctionType functionType;

@property (nonatomic, getter=isSending) BOOL sending;
@property (nonatomic, getter=isReceiving) BOOL receiving;


@property (nonatomic, strong, nullable) SNSSGDPCTTaskExecution *dpcSending;

// automatically behave
- (void)continueAction;

// choose according to SNSAntennaFunctionType
- (void)sendDataBehavior;
- (void)receiveDataBehavior;


@end
