//
//  LWPort.h
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 16/8/28.
//  Copyright © 2016年 com.wuyunfeng.open. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LWPortMessage;
@class LWRunLoop;

typedef NS_OPTIONS(NSUInteger, LWSocketPortRoleType) {
    LWSocketPortRoleTypeLeader = 0,
    LWSocketPortRoleTypeFollower = 1
};

typedef struct LWPortContext {
    void * _Nullable info;
    void (* _Nullable LWPortReceiveDataCallBack)(int fd, void * _Nullable info, void * _Nullable data, int length);
}LWPortContext;

@protocol LWPortDelegate <NSObject>

@optional

- (void)handlePortMessage:(LWPortMessage * _Nullable )message;

@end


@interface LWPort : NSObject

@property (nullable, assign, nonatomic) id<LWPortDelegate> delegate;

@property (readonly) LWPortContext context;

+ (LWPort * _Nullable)port;

- (void)invalidate;

@property (readonly, getter=isValid) BOOL valid;

- (void)scheduleInRunLoop:(LWRunLoop * _Nonnull)runLoop forMode:(LWRunLoop * _Nonnull)mode;

- (void)removeFromRunLoop:(LWRunLoop * _Nonnull)runLoop forMode:(LWRunLoop * _Nonnull)mode;

@end

/**
 *  Only support LWSocketPort at present
 */
@interface LWPortMessage : NSObject

@property (nullable, readonly, copy) NSArray *components;
@property (nullable, readonly, retain) LWPort *receivePort;
@property (nullable, readonly, retain) LWPort *sendPort;

@property uint32_t msgid; //The identifier for the receiver

/**
 *  Attempts to send the message before aDate, returning YES if successful or NO if the operation times out.
 *
 *  @param delay The delay second before which the message should be sent.
 *
 *  @return YES true if the operation is successful, otherwise NO false (for example, if the operation times out). 
 *  @note Always return true.
 *
 */
- (BOOL)sendBeforeDate:(NSInteger)delay;

/**
 *  Initializes a newly allocated LWPortMessage object to send given data on a given port and to receiver replies on another given port.
 *
 *  @param sendPort   The port on which the message is sent.
 *  @param replyPort  The port on which replies to the message arrive.
 *  @param components The data to send in the message
 *
 *  @return An LWPortMessage object initialized to send components on sendPort and to receiver replies on receivePort.
 */
- (_Nullable instancetype)initWithSendPort:(nullable NSPort *)sendPort receivePort:(nullable NSPort *)replyPort components:(nullable NSArray *)components;

@end


@interface LWSocketPort : LWPort

- (nullable instancetype)initWithTCPPort:(unsigned short)port;

// AF_INET AF_UNIX
@property (readonly) int protocolFamily;

//current support TCP socket, not support Unix Domain Socket
@property (readonly) int socketType;

@property (readonly) int protocol;

@property (nullable, readonly, copy) NSData *address;

//int act as NSSocketNativeHandle(typedef int )
@property (readonly) int socket;


@property (readonly) LWSocketPortRoleType roleType;

@end



