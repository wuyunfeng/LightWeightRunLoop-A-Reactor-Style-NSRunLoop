/********************************************************************
 * (C) wuyunfeng 2015-2016
 *
 * The project is available from https://github.com/wuyunfeng/LightWeightRunLoop-A-Reactor-Style-NSRunLoop
 *
 ********************************************************************/

#import <Foundation/Foundation.h>
#import "LWMessage.h"
#import "LWPort.h"
extern NSString * const  LWDefaultRunLoop;
extern NSString * const  LWRunLoopCommonModes;

extern NSString * const  LWRunLoopModeReserve1;
extern NSString * const  LWRunLoopModeReserve2;
extern NSString * const  LWTrackingRunLoopMode;


@interface LWRunLoop : NSObject


@property (readonly, copy) NSString *currentMode;


/**
 *  change the runloop's mode to `targetMode`
 *
 *  @param targetMode the mode you want to run.
 */
- (void)changeRunLoopMode:(NSString *)targetMode;


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

/**
 *  add LWPort to LWRunLoop
 *
 *  @param aPort LWPort instance
 *  @param mode  LWRunLoop Run Mode
 */
- (void)addPort:(LWPort *)aPort forMode:(NSString *)mode;


- (void)send:(NSData *)data toPort:(ushort)port;


- (void)send:(NSData *)data toFd:(int)fd;


@end
