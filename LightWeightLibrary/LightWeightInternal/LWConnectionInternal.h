//
/********************************************************************
 * (C) wuyunfeng 2015-2016
 *
 * The project is available from https://github.com/wuyunfeng/LightWeightRunLoop-A-Reactor-Style-NSRunLoop
 *
 * The code is intended as a illustration of the NSRunLoopp Foundation at work and
 * is not suitable for use in production code (some error handling has been strongly
 * simplified).
 *
 ********************************************************************/
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
