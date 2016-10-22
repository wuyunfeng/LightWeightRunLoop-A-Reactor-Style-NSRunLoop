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

@class LWRunLoop;
@class LWURLConnection;
@protocol LWURLConnectionDataDelegate <NSObject>

- (void)lw_connection:(LWURLConnection * _Nonnull)connection didReceiveData:(NSData * _Nullable)data;
- (void)lw_connection:(LWURLConnection * _Nonnull)connection didFailWithError:(NSError * _Nullable)error;
- (void)lw_connectionDidFinishLoading:(LWURLConnection * _Nonnull)connection;

@end

@interface LWURLConnection : NSObject

@property (weak, nonatomic, nullable) id<LWURLConnectionDataDelegate> delegate;

/**
 *  launch a http request
 *
 *  @param request          request
 *  @param delegate          delegate
 *  @param startImmediately  do not support.
 *
 *  @return LWURLConnection
 */
- (instancetype _Nonnull)initWithRequest:(NSMutableURLRequest * _Nullable)request delegate:(nullable id)delegate startImmediately:(BOOL)startImmediately;

- (void)scheduleInRunLoop:(LWRunLoop * _Nonnull)aRunLoop;

- (void)start;

- (void)cancel;

@end
