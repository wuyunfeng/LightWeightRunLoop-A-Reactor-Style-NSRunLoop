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

//implemented in subclass
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
        LWStreamEvent streamEvent = LWStreamEventErrorOccurred;
        [self sendDelegateMessage:&streamEvent];
        return;
    }
    LWStreamEvent streamEvent = LWStreamEventOpenCompleted;
    [self sendDelegateMessage:&streamEvent];
    //run read loop
    streamEvent = LWStreamEventHasBytesAvailable;
    [self sendDelegateMessage:&streamEvent];
}

- (void)open
{
    [self threadEntryRoutine];
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
    if (self.delegate) {
        self.delegate = nil;
    }
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
    size_t nRead = fread(buffer, len, 1, _fp);
    if (ferror(_fp)) {
        LWStreamEvent streamEvent = LWStreamEventErrorOccurred;
        [self sendDelegateMessage:&streamEvent];
        fclose(_fp);
        return -1;
    }
    if (feof(_fp)) {
        LWStreamEvent streamEvent = LWStreamEventEndEncountered;
        [self sendDelegateMessage:&streamEvent];
        fclose(_fp);
    } else {
        LWStreamEvent streamEvent = LWStreamEventHasBytesAvailable;
        [self sendDelegateMessage:&streamEvent];
    }
    return nRead;
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


@implementation LWOutputStream
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

- (void)threadEntryRoutine
{
    _fp = fopen([_fileAtPath UTF8String], "w+");
    if (_fp == NULL) {
        LWStreamEvent streamEvent = LWStreamEventErrorOccurred;
        [self sendDelegateMessage:&streamEvent];
        return;
    }
    LWStreamEvent streamEvent = LWStreamEventOpenCompleted;
    [self sendDelegateMessage:&streamEvent];
    //run read loop
    streamEvent = LWStreamEventHasSpaceAvailable;
    [self sendDelegateMessage:&streamEvent];
}

- (void)open
{
    [self threadEntryRoutine];
}

- (void)close
{
    LWStreamEvent streamEvent = LWStreamEventEndEncountered;
    [self sendDelegateMessage:&streamEvent];
    if (self.delegate) {
        self.delegate = nil;
    }
    if (_fp) {
        fclose(_fp);
    }
}

- (void)scheduleInRunLoop:(LWRunLoop *)aRunLoop forMode:(NSString *)mode
{
    _runloop = aRunLoop;
    _runMode = mode;
}

- (void)removeFromRunLoop:(LWRunLoop *)aRunLoop forMode:(NSString *)mode
{
    if (self.delegate) {
        self.delegate = nil;
    }
    if (_fp) {
        fclose(_fp);
    }
}

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len
{
    size_t nWrite = fwrite(buffer, len, 1, _fp);
    if (nWrite < len) {
        LWStreamEvent streamEvent = LWStreamEventErrorOccurred;
        [self sendDelegateMessage:&streamEvent];
        fclose(_fp);
        return -1;
    }
    LWStreamEvent streamEvent = LWStreamEventHasSpaceAvailable;
    [self sendDelegateMessage:&streamEvent];
    return nWrite;
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