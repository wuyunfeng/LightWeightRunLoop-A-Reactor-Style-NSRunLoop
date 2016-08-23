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
    NSAssert(false, @"Must be implemented in subclass");
}
//implemented in subclass
- (void)removeFromRunLoop:(LWRunLoop *)aRunLoop forMode:(NSString *)mode
{
    NSAssert(false, @"Must be implemented in subclass");
}
@end

@implementation LWInputStream
{
    LWRunLoop *_runloop;
    NSString *_runMode;
}

- (void)setDelegate:(id<LWStreamDelegate>)delegate
{
    _delegate = delegate;
}

- (void)open
{
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
}

/**
 *  Reads an array of count elements, each one with a size of size bytes, from the stream and stores them in the block of memory specified by ptr
 *
 *  @param buffer Pointer to a block of memory with a size of at least (size*count) bytes
 *  @param len    Number of elements, each one with a size of size bytes.
 *                size_t is an unsigned integral type.
 *
 *  @return The total number of elements successfully read is returned
 */
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    return -1;
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


@interface LWFileInputStream : LWInputStream

@end

@implementation LWFileInputStream
{
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

- (void)entryRoutine
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
    [self entryRoutine];
}

- (void)close
{
    [super close];
    if (_fp) {
        fclose(_fp);
    }
}

- (void)removeFromRunLoop:(LWRunLoop *)aRunLoop forMode:(NSString *)mode
{
    [super removeFromRunLoop:aRunLoop forMode:mode];
    if (_fp) {
        fclose(_fp);
    }
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    if (feof(_fp)) {
        LWStreamEvent streamEvent = LWStreamEventEndEncountered;
        [self sendDelegateMessage:&streamEvent];
        return -1;
    }
    size_t nRead = fread(buffer, sizeof(uint8_t), len, _fp);
    if (ferror(_fp)) {
        LWStreamEvent streamEvent = LWStreamEventErrorOccurred;
        [self sendDelegateMessage:&streamEvent];
        return -1;
    }

    LWStreamEvent streamEvent = LWStreamEventHasBytesAvailable;
    [self sendDelegateMessage:&streamEvent];
    return nRead;
}

@end


@implementation LWOutputStream
{
    LWRunLoop *_runloop;
    NSString *_runMode;
}

- (void)open
{
}

- (void)close
{
    LWStreamEvent streamEvent = LWStreamEventEndEncountered;
    [self sendDelegateMessage:&streamEvent];
    if (self.delegate) {
        self.delegate = nil;
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
}

/**
 *  Write block of data to stream (implemented in subclass)
 *
 *  @param buffer Pointer to the array of elements to be written
 *  @param len    Number of elements, each one with a size of size bytes
 *
 *  @return The total number of elements successfully written is returned
 */
- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len
{
    return -1;
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

@interface LWFileOutputStream : LWOutputStream

-(nullable instancetype)initWithFileAtPath:(NSString * _Nonnull)path append:(BOOL)shouldAppend;
@end

@implementation LWFileOutputStream
{
    BOOL _shouldAppend;
    NSString *_fileAtPath;
    FILE *_fp;
}

-(nullable instancetype)initWithFileAtPath:(NSString * _Nonnull)path append:(BOOL)shouldAppend
{
    if (self = [super init]) {
        _shouldAppend = shouldAppend;
        _fileAtPath = path;
    }
    return self;
}

- (void)entryRoutine
{
    if (_shouldAppend) {
        _fp = fopen([_fileAtPath UTF8String], "a");
    } else {
        _fp = fopen([_fileAtPath UTF8String], "w");
    }
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
    [self entryRoutine];
}

- (void)close
{
    [super close];
    if (_fp) {
        fclose(_fp);
    }
}

- (void)removeFromRunLoop:(LWRunLoop *)aRunLoop forMode:(NSString *)mode
{
    [super removeFromRunLoop:aRunLoop forMode:mode];
    if (_fp) {
        fclose(_fp);
    }
}

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len
{
    size_t nWrite = fwrite(buffer, sizeof(uint8_t), len, _fp);
    if (nWrite < len && ferror(_fp)) {
        LWStreamEvent streamEvent = LWStreamEventErrorOccurred;
        [self sendDelegateMessage:&streamEvent];
        return -1;
    }
    LWStreamEvent streamEvent = LWStreamEventEndEncountered;
    [self sendDelegateMessage:&streamEvent];
    return nWrite;
}

@end



@implementation LWInputStream (LWInputStreamExtensions)

+ (nullable instancetype)inputStreamWithFileAtPath:(NSString * _Nonnull)path
{
    LWFileInputStream *fileInputStream = [[LWFileInputStream alloc] initWithFileAtPath:path];
    return fileInputStream;
}
@end

@implementation LWOutputStream (LWOutputStreamExtensions)

+ (nullable instancetype)outputStreamToFileAtPath:(NSString * _Nonnull)path append:(BOOL)shouldAppend
{
    LWFileOutputStream *fileOutputStream = [[LWFileOutputStream alloc] initWithFileAtPath:path append:shouldAppend];
    return fileOutputStream;
}

@end