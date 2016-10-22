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

@interface LWTimer : NSObject


@property (readonly, getter=isValid) BOOL valid;

@property (nullable, readonly, retain) id userInfo;

@property (readonly) NSTimeInterval timeInterval;

@property (readonly) BOOL repeat;

/**
 *  Creates and returns a new LWTimer object and schedules it on the current LWRunloop.
 *  @param interval  The number of milliseconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead
 *  @param aTarget   the object to which to send the message specified by aSelector when the timer fires.
 *  @param aSelector The message to send to target when the timer fires.
 *  @param userInfo  The user info for the timer.
 *  @param yesOrNo   If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 *
 *  @return A new LWTimer object, configured according to the specified parameters.
 */
+ ( LWTimer * _Nonnull)scheduledLWTimerWithTimeInterval:(NSTimeInterval)interval target:(nonnull id)aTarget selector:(nonnull SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

/**
 *  Creates and returns a new LWTimer object and schedules it on the current LWRunloop.
 *
 *  @param interval  The number of milliseconds between firings of the timer.
 *  @param aTarget   the object to which to send the message specified by aSelector when the timer fires
 *  @param aSelector The message to send to target when the timer fires.
 *  @param userInfo  The user info for the timer.
 *  @param yesOrNo   If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires
 *
 *  @return A new LWTimer object, configured according to the specified parameters.
 */
+ (LWTimer * _Nonnull)timerWithTimeInterval:(NSTimeInterval)interval target:(nonnull id)aTarget selector:(nonnull SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;
/**
 *  You can use this method to fire a repeating timer without interrupting its regular firing schedule. If the timer is non-repeating, it is automatically invalidated after firing, even if its scheduled fire date has not arrived.
 */
- (void)fire;

/**
 *  Stops the receiver from ever firing again and requests its removal from its run loop.
 */
- (void)invalidate;
@end
