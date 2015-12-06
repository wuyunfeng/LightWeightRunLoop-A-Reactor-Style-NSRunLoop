//
//  NSObject+post.h
//  lwrunloop
//
//  Created by wuyunfeng on 15/10/29.
//  Copyright © 2015年 wuyunfeng open source. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (post)

/**
 *  Invokes a method of the receiver on the specified thread using the default mode.
 *
 *  @param aSelectore A selector that identifies the method to invoke. The method should not have a significant return value and should take a single argument of type id, or no arguments.
 *  @param thread     The thread on which to execute aSelector.
 *  @param arg        The argument to pass to the method when it is invoked. Pass nil if the method does not take an argument.
 */
- (void)postSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg;

/**
 *  Invokes a method of the receiver on the specified thread using the default mode after the number of delay milliseconds.
 *
 *  @param aSelectore aSelectore A selector that identifies the method to invoke
 *  @param thread     The thread on which to execute aSelector.
 *  @param arg        The argument to pass to the method when it is invoked. Pass nil if the method does not take an argument
 *  @param delay      The minimum time before which the message is sent. Specifying a delay of 0 does not necessarily cause the selector to be performed immediately. The selector is still queued on the thread’s run loop and performed as soon as possible
 */
- (void)postSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg afterDelay:(NSInteger)delay;

@end
