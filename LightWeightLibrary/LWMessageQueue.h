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

+ (void)destoryMessageQueue;

- (void)enqueueMessage:(LWMessage *)message;

- (LWMessage *)next;

- (NSInteger)count;

@end
