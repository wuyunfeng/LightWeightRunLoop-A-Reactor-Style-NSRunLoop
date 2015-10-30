//
//  NSThread+Looper.h
//  lwrunloop
//
//  Created by wuyunfeng on 15/10/29.
//  Copyright © 2015年 wuyunfeng open source. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWRunLoop.h"

@interface NSThread (Looper)

- (void)setLooper;
- (LWRunLoop *)looper;


@end
