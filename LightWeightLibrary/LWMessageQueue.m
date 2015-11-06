//
//  LWMessageQueue.m
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/10/31.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import "LWMessageQueue.h"
#include <pthread.h>


static pthread_key_t mTLSKey;

@implementation LWMessageQueue
{
    LWMessage *_head;
    NSRecursiveLock *_lock;
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
    }
    return self;
}

#pragma mark  - bug point?  lock is necessary or not?
- (void)enqueueMessage:(LWMessage *)message
{
    [_lock lock];
    if (!_head) {
        _head = message;
    } else {
        LWMessage *pointer;
        pointer = _head;
        while (pointer.next != nil) {
            pointer = pointer.next;
        }
        pointer.next = message;
    }
    [_lock unlock];
}



- (LWMessage *)next
{
    LWMessage *result;
    if (_head == nil) {
        return nil;
    }
    
    result = _head;
    _head = _head.next;
    
    return result;
}

- (NSInteger)count
{
    LWMessage *pointer = _head;
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
