//
//  LWRunLoop.h
//  lwrunloop
//
//  Created by wuyunfeng on 15/10/27.
//  Copyright © 2015年 wuyunfeng open source. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const  LWDefaultRunLoop;
extern NSString * const  LWRunLoopCommonModes;

extern NSString * const  LWRunLoopModeReserve1;
extern NSString * const  LWRunLoopModeReserve2;
extern NSString * const  LWTrackingRunLoopMode;


@interface LWRunLoop : NSObject

+ (instancetype)currentLWRunLoop;

- (void)run;

- (void)postTarget:(id)target withAction:(SEL)aSel when:(NSInteger)when;


@end
