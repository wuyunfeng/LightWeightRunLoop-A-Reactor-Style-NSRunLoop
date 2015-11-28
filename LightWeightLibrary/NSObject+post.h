//
//  NSObject+post.h
//  lwrunloop
//
//  Created by wuyunfeng on 15/10/29.
//  Copyright © 2015年 wuyunfeng open source. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (post)

- (void)postSelector:(SEL)aSelectore onThread:(NSThread *)thread withObject:(id)arg;

- (void)postSelector:(SEL)aSelectore onThread:(NSThread *)thread withObject:(id)arg afterDelay:(NSTimeInterval)delay;

@end
