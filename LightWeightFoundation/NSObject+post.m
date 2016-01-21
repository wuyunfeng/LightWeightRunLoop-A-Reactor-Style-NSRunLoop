//
//  NSObject+post.m
//  lwrunloop
//
//  Created by wuyunfeng on 15/10/29.
//  Copyright © 2015年 wuyunfeng open source. All rights reserved.
//

#import "NSObject+post.h"
#import "NSThread+Looper.h"
#import "LWRunLoop.h"
@implementation NSObject (post)

- (void)postSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg;
{
    __weak __typeof(self) weakSelf = self;
    LWRunLoop *loop = [thread looper];
    NSAssert(loop != nil, @"be sure LWLoop is initialized for thread");
    [loop postTarget:weakSelf withAction:aSelector withObject:arg afterDelay:0];
}

- (void)postSelector:(SEL)aSelector onThread:(NSThread *)thread
          withObject:(id)arg afterDelay:(NSInteger)delay
{
    __weak __typeof(self) weakSelf = self;
    LWRunLoop *loop = [thread looper];
    NSAssert(loop != nil, @"be sure LWLoop is initialized for thread");
    [loop postTarget:weakSelf withAction:aSelector withObject:arg afterDelay:delay];
}

- (void)postSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg afterDelay:(NSInteger)delay modes:(NSArray<NSString *> *)modes
{
    __weak __typeof(self) weakSelf = self;
    LWMessage *message = [[LWMessage alloc] initWithTarget:weakSelf aSel:aSelector withArgument:arg at:delay];
    message.modes = modes;
    LWRunLoop *loop = [thread looper];
    NSAssert(loop != nil, @"be sure LWLoop is initialized for thread");
    [loop postMessage:message];
}

@end
