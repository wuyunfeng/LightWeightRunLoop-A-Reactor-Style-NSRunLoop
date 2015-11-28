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


static pthread_key_t mTLSKey;

@implementation LWMessageQueue
{
    LWMessage *_messages;
    NSRecursiveLock *_lock;
    LWNativeLoop *_nativeRunLoop;
    BOOL _isBlocked;
}

void threadDestructor()
{
    NSLog(@"********** LWMessageQueue destructor *******");
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
        //nop
        _lock = [[NSRecursiveLock alloc] init];
        _lock.name = @"MessageQueueLock";
        _nativeRunLoop = [[LWNativeLoop alloc] init];
    }
    return self;
}

#pragma mark  - bug point?  lock is necessary or not?
- (void)enqueueMessage:(LWMessage *)message
{
    [_lock lock];
    if (!_messages) {
        _messages = message;
    } else {
        LWMessage *pointer;
        pointer = _messages;
        while (pointer.next != nil) {
            pointer = pointer.next;
        }
        pointer.next = message;
    }
    [_lock unlock];
}

- (BOOL)enqueueMessage:(LWMessage *)msg when:(NSInteger)when
{
    @synchronized(self) {
        msg.when = when;
        LWMessage *p = _messages;
        BOOL needWake = NO;
        if (p == nil || when == 0 || when < p.when) {
            msg.next = p;
            _messages = msg;
            needWake = _isBlocked;
        } else {
            needWake = _isBlocked & (p.mTarget == nil);
            LWMessage *preMsg;
            while (true) {
                preMsg = p;
                p = p.next;
                if (p == nil || when < p.when) {
                    break;
                }
            }
            msg.next = p;
            preMsg.next = msg;
        }
        if (needWake) {
            [_nativeRunLoop nativeWakeRunLoop];
        }
    }
    return YES;
}



- (LWMessage *)next
{
    
    NSInteger nextTimeoutMillis = 0;

    while (true) {
        
        [_nativeRunLoop nativeRunLoopFor:nextTimeoutMillis];
        
        NSInteger now = (NSInteger)([NSProcessInfo processInfo].systemUptime * 1000);
        LWMessage *preMsg = nil;
        LWMessage *msg = _messages;
        if (msg != nil && msg.mTarget) {
            _isBlocked = NO;
        }
        
        if (msg != nil) {
            if (now < msg.when) {
                nextTimeoutMillis = msg.when - now;
            } else {
                _isBlocked = NO;
            }
            
        } else {
            nextTimeoutMillis = -1;
        }

        if (true) {
            break;
        }
    }
    LWMessage *result;
    if (_messages == nil) {
        return nil;
    }
    
    result = _messages;
    _messages = _messages.next;
    
    return result;
}

- (NSInteger)count
{
    LWMessage *pointer = _messages;
    NSInteger count = 0;
    while (pointer != nil) {
        pointer = pointer.next;
        count++;
    }
    return count;
}


- (void)performActionsForThisLoop
{
    while (YES) {
//        NSLog(@"[ %@ %@]", [self class], NSStringFromSelector(_cmd));
        LWMessage *msg = [[LWMessageQueue defaultInstance] next];
        if (msg) {
            [msg performSelectorForTarget];
        } else {
            break;
        }
    }
    
//    LWMessage *msg = [[LWMessageQueue defaultInstance] next];
//    [msg performSelectorForTarget];

}


- (void)dealloc
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

@end
