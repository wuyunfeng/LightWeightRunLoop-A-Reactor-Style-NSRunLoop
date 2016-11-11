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

- (void)handlePortMessage:(NSData * _Nullable )message;

@end


@interface LWPort : NSObject

@property (nullable, assign, nonatomic) id<LWPortDelegate> delegate;

@property (readonly) LWPortContext context;

+ (LWPort * _Nullable)port;

- (void)invalidate;

@property (readonly, getter=isValid) BOOL valid;

- (void)scheduleInRunLoop:(LWRunLoop * _Nonnull)runLoop forMode:(NSString * _Nonnull)mode;

- (void)removeFromRunLoop:(LWRunLoop * _Nonnull)runLoop forMode:(NSString * _Nonnull)mode;

@end

/**
 *  Only support LWSocketPort at present
 */
@interface LWPortMessage : NSObject

@property (nullable, readonly, copy) NSData *components;
@property (nullable, readonly, retain) LWPort *receivePort;
@property (nullable, readonly, retain) LWPort *sendPort;

//not used at present,but not in future
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
- (_Nullable instancetype)initWithSendPort:(nullable LWPort *)sendPort receivePort:(nullable LWPort *)replyPort components:(nullable NSData *)components;

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

//return 127.0.0.1 at present, will be extended in future such as `Unix Local Socket`
@property (nonnull, readonly) NSString *host;


@property (readonly) LWSocketPortRoleType roleType;

@property (readonly) ushort port;

- (void)setType:(LWSocketPortRoleType)type;

@end



