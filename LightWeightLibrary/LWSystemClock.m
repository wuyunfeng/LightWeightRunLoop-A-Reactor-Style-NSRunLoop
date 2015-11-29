//
//  LWSystemClock.m
//  LightWeightRunLoop
//
//  Created by 武云峰 on 15/11/29.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import "LWSystemClock.h"

@implementation LWSystemClock

+ (NSInteger)uptimeMillions
{
    NSInteger now = (NSInteger)([NSProcessInfo processInfo].systemUptime * 1000);
    return now;
}

@end
