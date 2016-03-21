//
//  LWMessageQueue.h
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/10/31.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWMessage.h"

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

/**
 *  obtain message @see LWMessage
 *
 *  @return the message to be executed
 */
- (LWMessage *)next;

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


@end
