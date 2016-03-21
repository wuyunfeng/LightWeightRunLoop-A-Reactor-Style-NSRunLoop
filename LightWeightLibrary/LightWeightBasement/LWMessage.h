//
//  LWMessage.h
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/10/31.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import <Foundation/Foundation.h>


#define  MSG_TIME_NOW 0
@interface LWMessage : NSObject

/**
 *  improve this class in future
 *
 *  @param aTarget anObject that which selector to be executed.
 *  @param aSel    the selector to be executed
 *  @param arg     the arguments for the selector
 *  @param when    seconds unit.
 *
 *  @return LWMessage instance
 */
- (instancetype _Nonnull)initWithTarget:(id _Nullable)aTarget aSel:(SEL _Nullable)aSel withArgument:(id _Nullable)arg at:(NSInteger)when;

- (void)performSelectorForTarget;


@property (strong, nonatomic, nullable) id mTarget;

@property (strong, nonatomic, nullable) NSArray< NSString *> *modes;

@property NSInteger when;

@property (strong, nonatomic, nullable) LWMessage *next;

@property (weak, nonatomic, nullable) id data;

@end
