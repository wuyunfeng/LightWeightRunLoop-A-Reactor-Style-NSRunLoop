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

#import "LWTimer.h"
#import "LightWeightRunLoop.h"
#import "LWMessage.h"

@implementation LWTimer
{
    BOOL _valid;
    NSTimeInterval _interval;
    LWMessage *_tMsg;
}

- (instancetype)init
{
    if (self = [super init]) {
        _valid = YES;
    }
    return self;
}

+ (LWTimer *)scheduledLWTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    if (interval <= 0) {
        interval = 100;
    }
    LWTimer *instance = [[[self class] alloc] init];
    [instance setTimeInterval:interval];
    [instance setValid:YES];
    [instance setUserInfo:userInfo];
    [instance setRepeat:yesOrNo];
    LWMessage *msg = [[LWMessage alloc] initWithTarget:aTarget aSel:aSelector withArgument:instance at:interval];
    msg.data = instance;
    [instance setMessage:msg];
    LWRunLoop *runloop = [[NSThread currentThread] looper];
    [runloop postMessage:msg];
    return instance;
}

+ (LWTimer *)timerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    if (interval <= 0) {
        interval = 100;
    }
    LWTimer *instance = [[LWTimer alloc] init];
    [instance setTimeInterval:interval];
    [instance setValid:YES];
    [instance setUserInfo:userInfo];
    [instance setRepeat:yesOrNo];
    LWMessage *msg = [[LWMessage alloc] initWithTarget:aTarget aSel:aSelector withArgument:instance at:interval];
    msg.data = instance;
    [instance setMessage:msg];
    return instance;
}

- (void)fire
{
    LWRunLoop *runloop = [[NSThread currentThread] looper];
    [runloop postMessage:_tMsg];
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    _interval = timeInterval;
}

- (NSTimeInterval)timeInterval
{
    return _interval;
}


- (void)setMessage:(LWMessage *)msg
{
    _tMsg = msg;
}

- (void)invalidate
{
    _repeat = NO;
    _valid = NO;
    _tMsg = nil;
}

- (void)setRepeat:(BOOL)repeat
{
    _repeat = repeat;
}


- (void)setUserInfo:(id _Nullable)userInfo
{
    _userInfo = userInfo;
}

- (void)setValid:(BOOL)valid
{
    _valid = valid;
}

- (BOOL)isValid
{
    return _valid;
}

@end
