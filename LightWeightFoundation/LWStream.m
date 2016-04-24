//
//  LWStream.m
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 16/4/24.
//  Copyright © 2016年 com.wuyunfeng.open. All rights reserved.
//

#import "LWStream.h"
#import <stdio.h>
#import <pthread/pthread.h>
#import "LWMessage.h"
#import "LWRunLoop.h"
@implementation LWStream
{
}
- (void)open
{
    
}

- (void)close
{
    
}

- (void)scheduleInRunLoop:(LWRunLoop *)aRunLoop forMode:(NSString *)mode
{
    
}

- (void)removeFromRunLoop:(LWRunLoop *)aRunLoop forMode:(NSString *)mode
{
    
}
@end


@implementation LWInputStream
{
    LWRunLoop *_runloop;
    NSString *_runMode;
    NSString *_fileAtPath;
    FILE *_fp;
}

- (nullable instancetype)initWithFileAtPath:(NSString * _Nonnull)path
{
    if (self = [super init]) {
        _fileAtPath = path;
    }
    return self;
}

- (void)setDelegate:(id<LWStreamDelegate>)delegate
{
    _delegate = delegate;
}

- (void)threadEntryRoutine
{
    _fp = fopen([_fileAtPath UTF8String], "r");
    if (_fp == NULL) {
        NSLog(@"open %@ failure", _fileAtPath);
        LWStreamEvent streamEvent = LWStreamEventErrorOccurred;
        [self sendDelegateMessage:&streamEvent];
        return;
    }
    LWStreamEvent streamEvent = LWStreamEventOpenCompleted;
    [self sendDelegateMessage:&streamEvent];
}

- (void)open
{
    [NSThread detachNewThreadSelector:@selector(threadEntryRoutine) toTarget:self withObject:nil];
}

- (void)close
{
    
}

- (void)scheduleInRunLoop:(LWRunLoop *)aRunLoop forMode:(NSString *)mode
{
    _runloop = aRunLoop;
    _runMode = mode;
}

- (void)removeFromRunLoop:(LWRunLoop *)aRunLoop forMode:(NSString *)mode
{
    
    if (_fp) {
        fclose(_fp);
    }
}

- (void)dealloc
{
    if (_fp) {
        fclose(_fp);
    }
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    
    return 0;
}


#pragma mark -
- (void)sendDelegateMessage:(LWStreamEvent *)sEvent
{
    if ([self.delegate respondsToSelector:@selector(lw_stream:handleEvent:) ]){
        id target = self.delegate;
        NSMethodSignature *sig = [target methodSignatureForSelector:@selector(lw_stream:handleEvent:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        invocation.target = self.delegate;
        invocation.selector = @selector(lw_stream:handleEvent:);
        id argument = self;
        [invocation setArgument:&argument atIndex:2];
        [invocation setArgument:sEvent atIndex:3];
        [invocation retainArguments];
        LWMessage *msg = [[LWMessage alloc] initWithTarget:invocation aSel:@selector(invoke) withArgument:nil at:0];
        [_runloop postMessage:msg];
    }
}


@end
