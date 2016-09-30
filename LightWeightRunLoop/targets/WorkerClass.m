//
//  WorkerClass.m
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 16/9/24.
//  Copyright © 2016年 com.wuyunfeng.open. All rights reserved.
//

#import "WorkerClass.h"
#import "LWRunLoop.h"
#import "NSThread+Looper.h"
@interface WorkerClass()<LWPortDelegate>

@end

@implementation WorkerClass
{
    LWSocketPort *_distantPort;
    LWSocketPort *_localPort;
}

- (void)launchThreadWithPort:(LWPort *)port
{
    @autoreleasepool {
//        WorkerClass *obj = [[WorkerClass alloc] init];
//        [obj send:port];
        [self send:port];
    }
}

- (void)send:(LWPort *)port
{
    [NSThread currentThread].name = @"workerPortLoopThread";
    _distantPort = (LWSocketPort *)port;
    _localPort = [[LWSocketPort alloc] initWithTCPPort:8082];
    _localPort.delegate = self;
    [_localPort setType:LWSocketPortRoleTypeFollower];
    NSString *content = @"This_Is_A_Follower_To_Leader_Message_Data";
    int length = (int)[content length];
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendBytes:&length length:sizeof(int)];
    [data appendData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    LWPortMessage *messge = [[LWPortMessage alloc] initWithSendPort:_localPort receivePort:_distantPort components:data];
    [messge sendBeforeDate:0];
    LWRunLoop *_currentRunLoop = [[NSThread currentThread] looper];
    [_currentRunLoop addPort:_localPort forMode:LWDefaultRunLoop];
    [_currentRunLoop runMode:LWDefaultRunLoop];
}

- (LWPort *)localPort
{
    return _localPort;
}

#pragma mark - LWPortDelegate
- (void)handlePortMessage:(NSData * _Nullable )message
{
    NSString *msg = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
    NSLog(@"**[NSThread name = %@] [leader -> follower : %@] **", [NSThread currentThread].name, msg);
}

@end
