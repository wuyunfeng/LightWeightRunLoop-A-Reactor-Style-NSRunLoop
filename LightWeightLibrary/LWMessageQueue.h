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

@end
