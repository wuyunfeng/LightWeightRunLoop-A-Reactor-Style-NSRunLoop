//
//  LWRunLoop.h
//  lwrunloop
//
//  Created by wuyunfeng on 15/10/27.
//  Copyright © 2015年 wuyunfeng open source. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWRunLoop : NSObject


+ (instancetype)currentLWRunLoop;


- (void)run;



- (void)postTarget:(id)target withAction:(SEL)aSel;

@end
