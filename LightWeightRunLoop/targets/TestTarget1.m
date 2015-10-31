//
//  TestTarget1.m
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/10/31.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import "TestTarget1.h"

@implementation TestTarget1

- (void)performTest
{
    NSLog(@"* [ Object: %@ performSelector: ( %@ ) on Thread : %@ ] *", [self class], NSStringFromSelector(_cmd), [NSThread currentThread].name);
}

- (void)dealloc
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

@end
