//
//  NSThread+Looper.m
//  lwrunloop
//
//  Created by wuyunfeng on 15/10/29.
//  Copyright © 2015年 wuyunfeng open source. All rights reserved.
//

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
