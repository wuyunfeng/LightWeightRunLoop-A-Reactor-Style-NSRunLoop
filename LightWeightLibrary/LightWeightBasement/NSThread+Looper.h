/********************************************************************
 * (C) wuyunfeng 2015-2016
 *
 * The project is available from https://github.com/wuyunfeng/LightWeightRunLoop-A-Reactor-Style-NSRunLoop
 *
 ********************************************************************/

#import <Foundation/Foundation.h>
#import "LWRunLoop.h"

@interface NSThread (Looper)

/**
 *  @note private method
 *  set LWRunLoop instance to a NSThread
 *
 *  @param looper LWRunLoop
 */
- (void)setLooper:(LWRunLoop *)looper;

/**
 *  @note private method
 *
 *  @return The LWRunLoop we set
 */
- (LWRunLoop *)looper;

@end
