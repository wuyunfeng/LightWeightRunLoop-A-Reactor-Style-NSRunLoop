//
//  LWMessageQueue.m
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/10/31.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import "LWMessageQueue.h"
@implementation LWMessageQueue
{
    LWMessage *_head;
//    NSLock *_lock;
    NSRecursiveLock *_lock;
}


static LWMessageQueue *queue = nil;

+ (instancetype)defaultInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[[self class] alloc] init];
    });
    return queue;
}

+ (void)destoryMessageQueue
{
    queue = nil;
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

- (void)enqueueMessage:(LWMessage *)message
{
    [_lock tryLock];
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
}


- (void)dealloc
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

@end
