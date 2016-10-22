/********************************************************************
 * (C) wuyunfeng 2015-2016
 *
 * The project is available from https://github.com/wuyunfeng/LightWeightRunLoop-A-Reactor-Style-NSRunLoop
 *
 ********************************************************************/

#import "LWSystemClock.h"

@implementation LWSystemClock

+ (NSInteger)uptimeMillions
{
    NSInteger now = (NSInteger)([NSProcessInfo processInfo].systemUptime * 1000);
    return now;
}

@end
