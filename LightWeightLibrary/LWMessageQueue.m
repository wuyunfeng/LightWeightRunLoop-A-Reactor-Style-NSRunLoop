//
//  LWMessageQueue.m
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/10/31.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import "LWMessageQueue.h"
#include <pthread.h>
#import "LWNativeLoop.h"
#import "LWSystemClock.h"

static pthread_key_t mTLSKey;

@implementation LWMessageQueue
{
    LWMessage *_messages;
    LWNativeLoop *_nativeRunLoop;
    volatile BOOL _isCurrentLoopBlock;
}

+ (instancetype)defaultInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_key_create(&mTLSKey, threadDestructor);
    });
    
    LWMessageQueue *queue = (__bridge LWMessageQueue *)(pthread_getspecific(mTLSKey));
    if (queue == nil) {
        queue = [[LWMessageQueue alloc] init];
        pthread_setspecific(mTLSKey, (__bridge const void *)(queue));
    }
    return queue;
}

- (instancetype)init
{
    if (self = [super init]) {
        _nativeRunLoop = [[LWNativeLoop alloc] init];
    }
    return self;
}

void threadDestructor(void *data)
{
    NSLog(@"********** LWMessageQueue destructor *******");
    LWMessageQueue *currentQueue = (__bridge LWMessageQueue *)data;
    [currentQueue destoryRunLoop];
}

- (void)destoryRunLoop
{
    [_nativeRunLoop nativeDestoryKernelFds];
}

#pragma mark  - enqueue message
- (BOOL)enqueueMessage:(LWMessage *)msg when:(NSInteger)when
{
    @synchronized(self) {
        msg.when = when;
        LWMessage *p = _messages;
        BOOL needInterruptBolckingState = NO;
        
        if (p == nil /*|| when == 0 */|| when < p.when) {
            msg.next = p;
            _messages = msg;
            needInterruptBolckingState = _isCurrentLoopBlock;
        } else {
            LWMessage *prev = nil;
            while (p != nil && p.when <= when) {
                prev = p;
                p = p.next;
            }
            msg.next = prev.next;
            prev.next = msg;
            needInterruptBolckingState = false;
        }
        if (needInterruptBolckingState) {
            [_nativeRunLoop nativeWakeRunLoop];
        }
    }
    return YES;
}

#pragma mark - obtain message
- (LWMessage *)next
{
    NSInteger nextWakeTimeoutMillis = 0;
    while (YES) {
        [_nativeRunLoop nativeRunLoopFor:nextWakeTimeoutMillis];
        @synchronized(self) {
            NSInteger now = [LWSystemClock uptimeMillions];
            LWMessage *msg = _messages;
            if (msg != nil) {
                if (now < msg.when) {
                    nextWakeTimeoutMillis = msg.when - now;
                } else {
                    _isCurrentLoopBlock = NO;
                    _messages = msg.next;
                    msg.next = nil;
//                    NSLog(@"return msg : %@", msg);
                    return msg;
                }
            } else {
                nextWakeTimeoutMillis = -1;
//                _isCurrentLoopBlock = YES;
            }
            _isCurrentLoopBlock = YES;
        }
    }
}

- (void)dealloc
{
    [self destoryRunLoop];
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

@end
