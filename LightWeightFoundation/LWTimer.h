//
//  LWTimer.h
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/12/1.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWTimer : NSObject


@property (readonly, getter=isValid) BOOL valid;

@property (nullable, readonly, retain) id userInfo;

@property (readonly) NSTimeInterval timeInterval;

@property (readonly) BOOL repeat;

/**
 *  Creates and returns a new LWTimer object and schedules it on the current LWRunloop.
 *  @Discussion After interval seconds have elapsed, the timer fires, sending the message *aSelector to target.
 *  @param interval  The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead
 *  @param aTarget   the object to which to send the message specified by aSelector when the timer fires. The timer maintains a strong reference to target until it (the timer) is invalidated.
 *  @param aSelector The message to send to target when the timer fires. The selector should have the following signature: timerFireMethod: (including a colon to indicate that the method takes an argument). The timer passes itself as the argument, thus the method would adopt the following pattern: - (void)timerFireMethod:(LWTimer *)timer
 *  @param userInfo  The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be nil.
 *  @param yesOrNo   If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 *
 *  @return A new LWTimer object, configured according to the specified parameters.
 */
+ ( LWTimer * _Nonnull)scheduledLWTimerWithTimeInterval:(NSTimeInterval)interval target:(nonnull id)aTarget selector:(nonnull SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

+ (LWTimer * _Nonnull)timerWithTimeInterval:(NSTimeInterval)interval target:(nonnull id)aTarget selector:(nonnull SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;
/**
 *  You can use this method to fire a repeating timer without interrupting its regular firing schedule. If the timer is non-repeating, it is automatically invalidated after firing, even if its scheduled fire date has not arrived.
 */
- (void)fire;

- (void)invalidate;
@end
