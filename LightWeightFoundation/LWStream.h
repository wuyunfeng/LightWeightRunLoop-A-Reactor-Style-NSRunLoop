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

@class LWStream;
@class LWRunLoop;


typedef NS_OPTIONS(NSUInteger, LWStreamEvent) {
    LWStreamEventNone = 0,
    LWStreamEventOpenCompleted = 1UL << 0,
    LWStreamEventHasBytesAvailable = 1UL << 1,
    LWStreamEventHasSpaceAvailable = 1UL << 2,
    LWStreamEventErrorOccurred = 1UL << 3,
    LWStreamEventEndEncountered = 1UL << 4
};

@interface LWStream : NSObject


/**
 *  Opens the Stream.
 */
- (void)open;

/**
 *  Closes the Stream.
 */
- (void)close;

/**
 *  Schedules the receiver on a given lw run loop in a given mode.
 *
 *  @param aRunLoop The LWRunLoop on which to schedule the receiver.
 *  @param mode     The mode for the LWRunLoop.
 */
- (void)scheduleInRunLoop:(LWRunLoop * _Nonnull)aRunLoop forMode:(NSString * _Nonnull)mode;


/**
 *  Removes the receiver from a given run loop running in a given mode.
 *
 *  @param aRunLoop The LWRunLoop on which the receiver was scheduled.
 *  @param mode     The mode for the run loop.
 */
- (void)removeFromRunLoop:(LWRunLoop * _Nonnull)aRunLoop forMode:(NSString * _Nonnull)mode;

@end

@protocol LWStreamDelegate <NSObject>
@optional
- (void)lw_stream:(LWStream * _Nonnull)aStream handleEvent:(LWStreamEvent)eventCode;
@end

@interface LWInputStream : LWStream

@property (weak, nonatomic, nullable) id<LWStreamDelegate> delegate;

- (NSInteger)read:(uint8_t * _Nonnull)buffer maxLength:(NSUInteger)len;

@end


@interface LWOutputStream : LWStream

@property (weak, nonatomic, nullable) id<LWStreamDelegate> delegate;

- (NSInteger)write:(const uint8_t * _Nonnull)buffer maxLength:(NSUInteger)len;

//- (nullable instancetype)initWithFileAtPath:(NSString * _Nonnull)path;

@end


@interface LWInputStream (LWInputStreamExtensions)

+ (nullable instancetype)inputStreamWithFileAtPath:(NSString * _Nonnull)path;

@end

@interface LWOutputStream (LWOutputStreamExtensions)

+ (nullable instancetype)outputStreamToFileAtPath:(NSString * _Nonnull)path append:(BOOL)shouldAppend;

@end


