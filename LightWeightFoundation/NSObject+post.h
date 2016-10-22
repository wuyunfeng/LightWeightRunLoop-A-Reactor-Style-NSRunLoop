/********************************************************************
 * (C) wuyunfeng 2015-2016
 *
 * The project is available from https://github.com/wuyunfeng/LightWeightRunLoop-A-Reactor-Style-NSRunLoop
 *
 * The code is intended as a illustration of the NSRunLoopp Foundation at work and
 * is not suitable for use in production code (some error handling has been strongly
 * simplified).
 *
 ********************************************************************/

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


/**
 *  Invokes a method of the receiver on the specified thread using the default mode after the number of delay milliseconds.
 *
 *  @param aSelectore aSelectore A selector that identifies the method to invoke
 *  @param thread     The thread on which to execute aSelector.
 *  @param arg        The argument to pass to the method when it is invoked. Pass nil if the method does not take an argument
 *  @param delay      The minimum time before which the message is sent. Specifying a delay of 0 does not necessarily cause the selector to be performed immediately. The selector is still queued on the thread’s run loop and performed as soon as possible
 
 *  @param modes An array of strings that identify the modes to associate with the timer that performs the selector. This array must contain at least one string. If you specify nil or an empty array for this parameter, this method returns without performing the specified selector
 */
- (void)postSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg afterDelay:(NSInteger)delay modes:(NSArray<NSString *> *)modes;

@end
