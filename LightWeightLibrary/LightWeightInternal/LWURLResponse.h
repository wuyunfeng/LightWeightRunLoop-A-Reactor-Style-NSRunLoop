//
//  LWURLResponse.h
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/12/12.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWURLResponse : NSObject


@property (readonly, strong, nullable) NSData *responseData;

@property (readonly ,strong, nullable) NSString *responseBody;

@property (readonly) NSInteger statusCode;

@property (readonly, nullable) NSString *statusMsg;

@property (readonly, strong, nullable) NSDictionary *allHeaderFields;

//may have bug
- (instancetype _Nullable)initWithData:(NSData * _Nullable)data;


@end
