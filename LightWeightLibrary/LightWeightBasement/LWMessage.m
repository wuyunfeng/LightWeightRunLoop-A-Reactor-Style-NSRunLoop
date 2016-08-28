//
//  LWMessage.m
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/10/31.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import "LWMessage.h"

@interface LWMessage()
{
    
}
@property SEL mSelector;
@property id mArgument;

@end

@implementation LWMessage


- (instancetype)initWithTarget:(id)aTarget aSel:(SEL)aSel withArgument:(id)arg at:(NSInteger)when
{
    if (self = [super init]) {
        _mTarget = aTarget;
        _mSelector = aSel;
        _mArgument = arg;
        _when = when;
    }
    return self;
}

- (void)performSelectorForTarget
{
    
    if (_mTarget == nil) {
        NSLog(@"------%@ is released !", _mTarget);
    }

    if ([_mTarget respondsToSelector:_mSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_mTarget performSelector:_mSelector withObject:_mArgument];
#pragma clang diagnostic pop
    } else {
        NSLog(@"Perform %@  failure! Because selector does not exists.", NSStringFromSelector(_mSelector));
    }
}


- (void)dealloc
{
//    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

- (NSString *)description
{
    NSString *result = [[NSString alloc] initWithFormat:@"%@ :[ target =  %@, selector = %@, when = %ld]", [self class], [self.mTarget class], NSStringFromSelector(_mSelector), self.when];
    return result;
}

@end
