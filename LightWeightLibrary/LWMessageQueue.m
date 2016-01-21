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
    LWMessage *_preMessages;
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
        _allowStop = NO;
        [self addObserver:self forKeyPath:@"queueRunMode" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:"modechange"];
    }
    return self;
}

// when queuemode changed in current loop, preposition _messages
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"queueRunMode"] && strcmp("modechange", (char *)context)) {
        _messages = _preMessages;//runtime change
        //TODO:  should wake kernel
    }
}

- (NSString *)queueRunMode
{
    if (!_queueRunMode) {
        _queueRunMode = @"LWDefaultRunLoop";
    }
    return _queueRunMode;
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
    _messages = _preMessages;
    while (YES) {
        [_nativeRunLoop nativeRunLoopFor:nextWakeTimeoutMillis];
        @synchronized(self) {
            NSInteger now = [LWSystemClock uptimeMillions];
            LWMessage *msg = _messages;
            //find the head message, assign it to _preMessages for preposition
            if (msg && !_preMessages) {
                _preMessages = msg;
            }
            if (msg != nil) {
                if (now < msg.when) {
                    nextWakeTimeoutMillis = msg.when - now;
                } else {
                    _isCurrentLoopBlock = NO;
                    _messages = msg.next;
                    msg.next = nil;
                    return msg;
                }
            } else {
                nextWakeTimeoutMillis = -1;
            }
            _isCurrentLoopBlock = YES;
        }
    }
}

- (LWMessage *)next:(NSString *)mode
{
    NSInteger nextWakeTimeoutMillis = 0;
    while (YES) {
        [_nativeRunLoop nativeRunLoopFor:nextWakeTimeoutMillis];
        @synchronized(self) {
            NSInteger now = [LWSystemClock uptimeMillions];
            LWMessage *msg = _messages;
            if (msg != nil) {
                if (![self isMsgModesHit:msg.modes]) {
                    // can not discard, but may use in mode's changing
                    _messages = msg.next;
                    continue;// enter into next loop
                } else {
                    if (now < msg.when) {
                        nextWakeTimeoutMillis = msg.when - now;
                    } else {
                        _isCurrentLoopBlock = NO;
                        _messages = msg.next;
                        msg.next = nil;
                        return msg;
                    }
                }
            } else {
                nextWakeTimeoutMillis = -1;
            }
            _isCurrentLoopBlock = YES;
        }
    }
}

- (BOOL)isMsgModesHit:(NSArray *)modes
{
    for (NSString *mode in modes) {
        if ([@"LWRunLoopCommonModes" isEqualToString:mode]) {
            return YES;
        } else if([mode isEqualToString:self.queueRunMode]) {
            return YES;
        }
    }
    return NO;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"queueRunMode"];
    [self destoryRunLoop];
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

@end
