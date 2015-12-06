//
//  LWRunLoop.m
//  lwrunloop
//
//  Created by wuyunfeng on 15/10/27.
//  Copyright © 2015年 wuyunfeng open source. All rights reserved.
//

#import "LWRunLoop.h"
#include <sys/unistd.h>
#include <pthread.h>
#import "NSThread+Looper.h"
#import "LWMessageQueue.h"
#import "LWSystemClock.h"
#import "LWTimer.h"
static pthread_once_t mTLSKeyOnceToken = PTHREAD_ONCE_INIT;
static pthread_key_t mTLSKey;


NSString * const  LWDefaultRunLoop = @"LWDefaultRunLoop";
NSString * const  LWRunLoopCommonModes = @"LWRunLoopCommonModes";
NSString * const  LWRunLoopModeReserve1 = @"LWRunLoopModeReserve1";
NSString * const  LWRunLoopModeReserve2 = @"LWRunLoopModeReserve2";
NSString * const  LWTrackingRunLoopMode = @"LWTrackingRunLoopMode";

@implementation LWRunLoop
{
    LWMessageQueue *_queue;
    NSString *_currentRunLoopMode;
}

void initTLSKey(void)
{
    pthread_key_create(&mTLSKey, destructor);
}

void destructor(void * data)
{
    LWRunLoop *pSelf = (__bridge LWRunLoop *)data;
    [pSelf destoryFds];
}

- (void)destoryFds
{
    _queue = nil;
}

#pragma mark - Public Method
+ (instancetype)currentLWRunLoop
{
    int result = pthread_once(& mTLSKeyOnceToken, initTLSKey);
    NSAssert(result == 0, @"pthread_once failure");
    LWRunLoop *instance = (__bridge LWRunLoop *)pthread_getspecific(mTLSKey);
    if (instance == nil) {
        instance = [[[self class] alloc] init];
        [[NSThread currentThread] setLooper:instance];
        pthread_setspecific(mTLSKey, (__bridge const void *)(instance));
    }
    return instance;
}

#pragma mark run this loop forever
- (void)run
{
    while (true) {
        LWMessage *msg = [_queue next];
        [msg performSelectorForTarget];
        [self necessaryInvocationForThisLoop:msg];
    }
}

- (void)necessaryInvocationForThisLoop:(LWMessage *)msg
{
    if ([msg.data isKindOfClass:[LWTimer class]]) { // LWTimer: periodical perform selector
        LWTimer *timer = msg.data;
        if (timer.repeat) {
            msg.when = timer.timeInterval; // must
            [self postMessage:msg];
        }
    }
}


#pragma mark - Private
- (instancetype)init
{
    if (self = [super init]) {
        _queue = [LWMessageQueue defaultInstance];
    }
    
    return self;
}

#pragma mark - Post
- (void)postTarget:(id)target withAction:(SEL)aSel when:(NSInteger)when
{
    when += [LWSystemClock uptimeMillions];
    LWMessage *message = [[LWMessage alloc] initWithTarget:target aSel:aSel withArgument:nil at:when];
    [_queue enqueueMessage:message when:when];
}

- (void)postMessage:(LWMessage *)msg
{
    NSInteger when = msg.when + [LWSystemClock uptimeMillions];
    [_queue enqueueMessage:msg when:when];
}

- (void)dealloc
{

}

@end
