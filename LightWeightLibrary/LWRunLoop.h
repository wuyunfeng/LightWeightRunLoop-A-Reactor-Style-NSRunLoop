//
//  LWRunLoop.h
//  lwrunloop
//
//  Created by wuyunfeng on 15/10/27.
//  Copyright © 2015年 wuyunfeng open source. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWMessage.h"

extern NSString * const  LWDefaultRunLoop;
extern NSString * const  LWRunLoopCommonModes;

extern NSString * const  LWRunLoopModeReserve1;
extern NSString * const  LWRunLoopModeReserve2;
extern NSString * const  LWTrackingRunLoopMode;


@interface LWRunLoop : NSObject

/**
 *  Get The LWRunLoop for The Thread
 *
 *  @return LWRunLoop
 */
+ (instancetype)currentLWRunLoop;

/**
 *  make Thread entering into event-driver-mode
 */
- (void)run;

/**
 *  make Thread entering into event-driver-mode at specific mode
 *
 *  @param mode the loop run in specific mode
 */
- (void)runMode:(NSString *)mode;

/**
 *  execute selector for target after when
 *
 *  @param target the reveiver
 *  @param aSel   the selector
 *  @param when   unit ms
 */
- (void)postTarget:(id)target withAction:(SEL)aSel withObject:(id)arg afterDelay:(NSInteger)delayMillis;

/**
 *  post message
 *
 *  @param msg LWMessage
 */
- (void)postMessage:(LWMessage *)msg;

@end
