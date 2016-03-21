//
//  NSThread+Looper.h
//  lwrunloop
//
//  Created by wuyunfeng on 15/10/29.
//  Copyright © 2015年 wuyunfeng open source. All rights reserved.
//

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
