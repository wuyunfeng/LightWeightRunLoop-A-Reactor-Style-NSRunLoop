//
//  LWNativeLoop.h
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/11/28.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef int (*LWRunLoop_callbackfunc)(int fd, int events, void* data);

@interface LWNativeLoop : NSObject

- (void)nativeRunLoopFor:(NSInteger)timeoutMillis;

- (void)nativeWakeRunLoop;

- (void)nativeDestoryKernelFds;

- (void)addFd:(int)fd filter:(int)filter callback:(LWRunLoop_callbackfunc)callback data:(void *)data;

@end
