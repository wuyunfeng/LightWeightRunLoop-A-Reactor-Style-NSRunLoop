/********************************************************************
 * (C) wuyunfeng 2015-2016
 *
 * The project is available from https://github.com/wuyunfeng/LightWeightRunLoop-A-Reactor-Style-NSRunLoop
 *
 ********************************************************************/

#import "NSThread+Looper.h"
#import <objc/runtime.h>

@implementation NSThread (Looper)


static char kLWRunLoopTLsKey;

- (void)setLooper:(LWRunLoop *)looper
{
    LWRunLoop *loop = objc_getAssociatedObject(self, &kLWRunLoopTLsKey);
    if (!loop) {
        loop = looper;
        objc_setAssociatedObject(self, &kLWRunLoopTLsKey, loop, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (LWRunLoop *)looper
{
    LWRunLoop *loop = objc_getAssociatedObject(self, &kLWRunLoopTLsKey);
    return loop;
}

@end
