//
//  LWNativeLoop.h
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/11/28.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWNativeLoop : NSObject

- (void)nativeRunLoopFor:(NSInteger)timeoutMillis;

- (void)nativeWakeRunLoop;

- (void)nativeDestoryKernelFds;

@end
