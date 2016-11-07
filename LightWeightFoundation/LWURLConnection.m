/********************************************************************
 * (C) wuyunfeng 2015-2016
 *
 * The project is available from https://github.com/wuyunfeng/LightWeightRunLoop-A-Reactor-Style-NSRunLoop
 *
 * The code is intended as a illustration of the NSRunLoopp Foundation at work and
 * is not suitable for use in production code (some error handling has been strongly
 * simplified).
 *
 ********************************************************************/

#import "LWURLConnection.h"
#import "LWConnectionInternal.h"
#import "LWMessage.h"
#import "LWRunLoop.h"

@interface LWURLConnection()<LWConnectionInternalDelegate>
{
    LWConnectionInternal *_internal;
    LWRunLoop *_runloop;
    BOOL _startImmediately;
}

@end

@implementation LWURLConnection

- (instancetype _Nonnull)initWithRequest:(NSMutableURLRequest * _Nullable)request delegate:(nullable id)delegate startImmediately:(BOOL)startImmediately
{
    if (self = [super init]) {
        _internal = [[LWConnectionInternal alloc] initWithRequest:request];
        _internal.delegate = self;
        _startImmediately = startImmediately;
        _delegate = delegate;
        //not used at present
        if (_startImmediately) {
            //....
        }
    }
    return self;
}

- (void)scheduleInRunLoop:(LWRunLoop * _Nonnull)aRunLoop
{
    _runloop = aRunLoop;
}

- (void)start
{
    [_internal start];
}

- (void)cancel
{
    [_internal cancel];
    self.delegate = nil;
}

#pragma mark - LWConnectionInternalDelegate
- (void)internal_connection:(LWConnectionInternal * _Nonnull)connection didReceiveData:(NSData * _Nullable)data
{
    //The new object must have its selector set with setSelector: and its arguments set with setArgument:atIndex: before it can be invoked. Do not use the alloc/init approach to create NSInvocation objects.
    if ([self.delegate respondsToSelector:@selector(lw_connection:didReceiveData:)]) {
        id target = self.delegate;
        NSMethodSignature *sig = [target methodSignatureForSelector:@selector(lw_connection:didReceiveData:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        invocation.target = self.delegate;
        invocation.selector = @selector(lw_connection:didReceiveData:);
        id argument = self;
        [invocation setArgument:&argument atIndex:2];
        [invocation setArgument:&data atIndex:3];
        [invocation retainArguments];
        LWMessage *msg = [[LWMessage alloc] initWithTarget:invocation aSel:@selector(invoke) withArgument:nil at:0];
        [_runloop postMessage:msg];
    }
}

- (void)internal_connection:(LWConnectionInternal * _Nonnull)connection didFailWithError:(NSError * _Nullable)error
{
    if ([self.delegate respondsToSelector:@selector(lw_connection:didFailWithError:)]) {
        id target = self.delegate;
        NSMethodSignature *sig = [target methodSignatureForSelector:@selector(lw_connection:didFailWithError:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        invocation.target = self.delegate;
        invocation.selector = @selector(lw_connection:didFailWithError:);
        id argument = self;
        [invocation setArgument:&argument atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation retainArguments];
        LWMessage *msg = [[LWMessage alloc] initWithTarget:invocation aSel:@selector(invoke) withArgument:nil at:0];
        [_runloop postMessage:msg];
    }
}

- (void)internal_connectionDidFinishLoading:(LWConnectionInternal * _Nonnull)connection
{
    if ([self.delegate respondsToSelector:@selector(lw_connectionDidFinishLoading:)]) {
        id target = self.delegate;
        NSMethodSignature *sig = [target methodSignatureForSelector:@selector(lw_connectionDidFinishLoading:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        invocation.target = self.delegate;
        invocation.selector = @selector(lw_connectionDidFinishLoading:);
        id argument = self;
        [invocation setArgument:&argument atIndex:2];
        [invocation retainArguments];
        LWMessage *msg = [[LWMessage alloc] initWithTarget:invocation aSel:@selector(invoke) withArgument:nil at:0];
        [_runloop postMessage:msg];
    }
}


@end
