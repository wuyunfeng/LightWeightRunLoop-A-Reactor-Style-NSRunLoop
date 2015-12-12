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

+ (instancetype)currentLWRunLoop;

- (void)run;

/**
 *  execute selector for target after when
 *
 *  @param target the reveiver
 *  @param aSel   the selector
 *  @param when   unit ms
 */
- (void)postTarget:(id)target withAction:(SEL)aSel withObject:(id)arg afterDelay:(NSInteger)delayMillis;

- (void)postMessage:(LWMessage *)msg;

@end
