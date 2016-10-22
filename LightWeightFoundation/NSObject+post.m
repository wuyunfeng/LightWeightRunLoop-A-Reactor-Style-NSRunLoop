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

#import "NSObject+post.h"
#import "NSThread+Looper.h"
#import "LWRunLoop.h"
@implementation NSObject (post)

- (void)postSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg;
{
    __weak __typeof(self) weakSelf = self;
    LWRunLoop *loop = [thread looper];
    NSAssert(loop != nil, @"be sure LWLoop is initialized for thread");
    [loop postTarget:weakSelf withAction:aSelector withObject:arg afterDelay:0];
}

- (void)postSelector:(SEL)aSelector onThread:(NSThread *)thread
          withObject:(id)arg afterDelay:(NSInteger)delay
{
    __weak __typeof(self) weakSelf = self;
    LWRunLoop *loop = [thread looper];
    NSAssert(loop != nil, @"be sure LWLoop is initialized for thread");
    [loop postTarget:weakSelf withAction:aSelector withObject:arg afterDelay:delay];
}

- (void)postSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg afterDelay:(NSInteger)delay modes:(NSArray<NSString *> *)modes
{
    __weak __typeof(self) weakSelf = self;
    LWMessage *message = [[LWMessage alloc] initWithTarget:weakSelf aSel:aSelector withArgument:arg at:delay];
    message.modes = modes;
    LWRunLoop *loop = [thread looper];
    NSAssert(loop != nil, @"be sure LWLoop is initialized for thread");
    [loop postMessage:message];
}

@end
