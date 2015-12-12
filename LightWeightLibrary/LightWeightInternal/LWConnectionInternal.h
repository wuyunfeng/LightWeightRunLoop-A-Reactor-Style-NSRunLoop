//
//  LWConnectionInternal.h
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/12/12.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LWConnectionInternal;
@protocol LWConnectionInternalDelegate <NSObject>

- (void)internal_connection:(LWConnectionInternal * _Nonnull)connection didReceiveData:(NSData * _Nullable)data;

- (void)internal_connection:(LWConnectionInternal * _Nonnull)connection didFailWithError:(NSError * _Nullable)error;

- (void)internal_connectionDidFinishLoading:(LWConnectionInternal * _Nonnull)connection;

@end
@interface LWConnectionInternal : NSObject

@property (readonly, nonnull, nonatomic) NSMutableURLRequest *request;

@property (strong, nonatomic, nullable) id<LWConnectionInternalDelegate> delegate;

- (instancetype _Nonnull)initWithRequest:(NSMutableURLRequest * _Nullable)request;

- (void)start;

- (void)cancel;

@end
