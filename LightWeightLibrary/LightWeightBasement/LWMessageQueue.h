/********************************************************************
 * (C) wuyunfeng 2015-2016
 *
 * The project is available from https://github.com/wuyunfeng/LightWeightRunLoop-A-Reactor-Style-NSRunLoop
 *
 ********************************************************************/

#import <Foundation/Foundation.h>
#import "LWMessage.h"
@class LWNativeRunLoop;
@interface LWMessageQueue : NSObject

@property (nonatomic) NSString *queueRunMode;

@property (nonatomic, assign) BOOL allowStop;

/**
 *  LWMessageQueue instance
 *  @note one thread one instance
 *
 *  @return LWMessageQueue instance
 */
+ (instancetype)defaultInstance;

/**
 *  enqueue message @see LWMessage
 *
 *  @param msg  LWMessage
 *  @param when the time to be executed
 *
 *  @return if enqueue success return true, otherwise false
 */
- (BOOL)enqueueMessage:(LWMessage *)msg when:(NSInteger)when;

///**
// *  obtain message @see LWMessage
// *
// *  @return the message to be executed
// */
//- (LWMessage *)next;

/**
 *
 *  @note we will replace @selector(next) in future with this selector
 *
 *  obtain message for specific mode
 *
 *  @param mode @see LWRunLoop modes
 *
 *  @return the message to be executed for specific mode
 */
- (LWMessage *)next:(NSString *)mode;


/**
 *  Just for `LWRunLoop` use
 *
 *  @return LWNativeRunLoop
 */
- (LWNativeRunLoop *)nativeRunLoop;


@end
