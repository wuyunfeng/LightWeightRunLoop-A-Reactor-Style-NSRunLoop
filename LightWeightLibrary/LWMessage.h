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


- (instancetype _Nonnull)initWithTarget:(id _Nullable)aTarget aSel:(SEL _Nullable)aSel withArgument:(id _Nullable)arg at:(NSInteger)when;

- (void)performSelectorForTarget;



@property (strong, nonatomic,nullable) LWMessage *next;

@end
