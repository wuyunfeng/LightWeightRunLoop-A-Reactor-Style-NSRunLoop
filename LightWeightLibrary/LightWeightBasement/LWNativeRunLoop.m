/********************************************************************
 * (C) wuyunfeng 2015-2016
 *
 * The project is available from https://github.com/wuyunfeng/LightWeightRunLoop-A-Reactor-Style-NSRunLoop
 *
 ********************************************************************/

#import "LWNativeRunLoop.h"
// unix standard
#include <sys/unistd.h>

//SYNOPSIS For Kevent
#include <sys/event.h>
#include <sys/types.h>
#include <sys/time.h>

#include <fcntl.h>
#include <pthread.h>
#include <sys/errno.h>
#include <sys/socket.h>
#include <netinet/in.h>
#import "LWPortClientInfo.h"
#include "lw_nativerunloop_util.h"

typedef struct PortWrapper {
    int fd;
    LWNativeRunLoopFdType type;
    LWNativeRunLoopCallBack callback;
    void *info;
}PortWrapper;

#define MAX_EVENT_COUNT 32

@implementation LWNativeRunLoop
{
    int _mReadPipeFd;
    int _mWritePipeFd;
    int _kq;
    NSMutableArray *_fds;
    NSMutableDictionary *_requests;
    NSMutableDictionary *_portClients;
    int _leader;
    int _follower;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self prepareLWRunLoop];
    }
    return self;
}

#pragma mark - Main Runloop
- (void)nativeRunLoopFor:(NSInteger)timeoutMillis
{
    struct kevent events[MAX_EVENT_COUNT];
    struct timespec *waitTime = NULL;
    if (timeoutMillis == -1) {
        waitTime = NULL;
    } else {
        waitTime = (struct timespec *)malloc(sizeof(struct timespec));
        waitTime->tv_sec = timeoutMillis / 1000;
        waitTime->tv_nsec = timeoutMillis % 1000 * 1000 * 1000;
    }
    int ret = kevent(_kq, NULL, 0, events, MAX_EVENT_COUNT, waitTime);
    NSAssert(ret != -1, @"Failure in kevent().  errno=%d", errno);
    free(waitTime);
    waitTime = NULL; // avoid wild pointer
    for (int i = 0; i < ret; i++) {
        int fd = (int)events[i].ident;
        int event = events[i].filter;
        if (fd == _mReadPipeFd) { // for pipe read fd
            if (event & EVFILT_READ) {
                //must read mReadWakeFd, or result in readwake always wake
                [self nativePollRunLoop];
            } else {
                continue;
            }
        } else if (_leader == fd){//for LWPort leader fd
            if (event & EVFILT_READ) {
                [self handleAccept:fd];
            }
        } else if (_follower == fd) {// leader -> follower
            if (![self handleLeaderToFollower:fd]) {
                continue;
            }
        } else { // follower -> leader read for LWPort follower fd, then notify leader
            if (![self handleFollowerToLeader:event fd:fd]) {
                continue;
            }
        }
    }
}


//for LWPort leader fd `accept` ->  ('port','fd') -> (8080, 20)
- (void)handleAccept:(int)fd
{
    struct sockaddr_in clientAddr;
    socklen_t len = sizeof(struct sockaddr);
    int client = accept(fd, (struct sockaddr *)&clientAddr, &len);
    LWPortClientInfo *portInfo = [LWPortClientInfo new];
    portInfo.port = clientAddr.sin_port;
    portInfo.fd = client;
    [_portClients setValue:portInfo forKey:[NSString stringWithFormat:@"%d", clientAddr.sin_port]];
    lwutil_make_socket_nonblocking(client);
    [self kevent:client filter:EVFILT_READ action:EV_ADD];
}

// leader -> follower
- (BOOL)handleLeaderToFollower:(int)fd
{
    int length = 0;
    ssize_t nRead;
    do {
        nRead = read(fd, &length, sizeof(int));
    } while (nRead == -1 && EINTR == errno);
    if (nRead == -1 && EAGAIN == errno) {
        //The file was marked for non-blocking I/O, and no data were ready to be read.
        return false;
    }
    //buffer `follower` LWPort send `buffer` to `leader` LWPort
    char *buffer = malloc(length);
    do {
        nRead = read(fd, buffer, length);
    } while (nRead == -1 && EINTR == errno);
    NSValue *data = [_requests objectForKey:@(_follower)];
    PortWrapper request;
    [data getValue:&request];
    //! notify follower,actually in `follower` thread just one follower
    if (request.callback) {
        request.callback(fd, request.info, buffer, length);
    }
    free(buffer);
    buffer = NULL;
    return true;
}

// follower -> leader read for LWPort follower fd, then notify leader
- (BOOL)handleFollowerToLeader:(int)event fd:(int)fd
{
    if (event & EVFILT_READ) {
        int length = 0;
        ssize_t nRead;
        do {
            nRead = read(fd, &length, sizeof(int));
        } while (nRead == -1 && EINTR == errno);
        if (nRead == -1 && EAGAIN == errno) {
            //The file was marked for non-blocking I/O, and no data were ready to be read.
            return false;
        }
        //buffer `follower` LWPort send `buffer` to `leader` LWPort
        char *buffer = malloc(length);
        do {
            nRead = read(fd, buffer, length);
        } while (nRead == -1 && EINTR == errno);
        NSValue *data = [_requests objectForKey:@(_leader)];
        PortWrapper request;
        [data getValue:&request];
        //notify leader
        if (request.callback) {
            request.callback(fd, request.info, buffer, length);
        }
        //remember release malloc memory
        free(buffer);
        buffer = NULL;
        struct sockaddr_in sockaddr;
        socklen_t len;
        int ret = getpeername(fd, (struct sockaddr *)&sockaddr, &len);
        if (ret < 0) {
            return false;
        }
        LWPortClientInfo *info = [_portClients valueForKey:[NSString stringWithFormat:@"%d", sockaddr.sin_port]];
        if (info.cacheSend && info.cacheSend.length > 0) {
            //write cached on next event
            [self kevent:fd filter:EVFILT_WRITE action:EV_ADD];
        }
    } else if (event & EVFILT_WRITE) {
        struct sockaddr_in sockaddr;
        socklen_t len;
        int ret = getpeername(fd, (struct sockaddr *)&sockaddr, &len);
        if (ret < 0) {
            return false;
        }
        LWPortClientInfo *info = [_portClients valueForKey:[NSString stringWithFormat:@"%d", sockaddr.sin_port]];
        if (info.cacheSend && info.cacheSend.length > 0) {
            ssize_t nWrite;
            do {
                nWrite = write(fd, [info.cacheSend bytes], info.cacheSend.length);
            } while (nWrite == -1 && errno == EINTR);
            
            if (nWrite != 1 && errno != EAGAIN) {
                    return false;
            }
            //clean the sending cache
            info.cacheSend = nil;
        } else {
            return false;
        }
    }
    return true;
}

#pragma mark - Process two fds generated by pipe()
- (void)nativeWakeRunLoop
{
    ssize_t nWrite;
    do {
        nWrite = write(_mWritePipeFd, "w", 1);
    } while (nWrite == -1 && errno == EINTR);
}

- (void)nativePollRunLoop
{
    char buffer[16];
    ssize_t nRead;
    do {
        nRead = read(_mReadPipeFd, buffer, sizeof(buffer));
    } while ((nRead == -1 && errno == EINTR) || nRead == sizeof(buffer));
}

#pragma mark -provide interface for LWRunLoop
- (void)addFd:(int)fd type:(LWNativeRunLoopFdType)type filter:(LWNativeRunLoopEventFilter)filter callback:(LWNativeRunLoopCallBack)callback data:(void *)info
{
    lwutil_make_socket_nonblocking(fd);
    PortWrapper request;
    request.fd = fd;
    request.type = type;
    request.callback = callback;
    request.info = info;
    //temporary return
    if ([_requests objectForKey:@(fd)]) {
        return;
    }
    _requests[@(fd)]= [NSValue value:&request withObjCType:@encode(PortWrapper)];
    if (LWNativeRunLoopFdSocketServerType == type) {
        _leader = fd;
    } else {
        _follower = fd;
    }
    
    if (LWNativeRunLoopEventFilterRead == filter) {
        [self kevent:fd filter:EVFILT_READ action:EV_ADD];
    } else if (LWNativeRunLoopEventFilterWrite == filter) {
        [self kevent:fd filter:EVFILT_WRITE action:EV_ADD];
    }
}


- (void)removeFd:(int)fd filter:(LWNativeRunLoopEventFilter)filter
{
    struct kevent changes[1];
    EV_SET(changes, fd, filter, EV_DELETE, 0, 0, NULL);
    kevent(_kq, changes, 1, NULL, 0, NULL);
}

#pragma mark - convience method to operate `fd`
- (int)kevent:(int)fd filter:(int)filter action:(int)action
{
    struct kevent changes[1];
    EV_SET(changes, fd, filter, EV_ADD, 0, 0, NULL);
    int ret = kevent(_kq, changes, 1, NULL, 0, NULL);
    return ret;
}

#pragma mark -
- (void)send:(NSData *)data toPort:(ushort)port
{
    LWPortClientInfo *info = [_portClients valueForKey:[NSString stringWithFormat:@"%d", port]];
    ssize_t nWrite;
    do {
        nWrite = write(info.fd, [data bytes], [data length]);
    } while (nWrite == -1 && errno == EINTR);
    
    if (nWrite != [data length] && errno != EAGAIN) {
        NSLog(@"Error Happened in toPort! errno=%d", errno);
    }
    
    data = nil;
}

- (void)send:(NSData *)data toFd:(int)fd
{
    ssize_t nWrite;
    do {
        nWrite = write(fd, [data bytes], [data length]);
    } while (nWrite == -1 && errno == EINTR);
    
    if (nWrite != [data length] && errno != EAGAIN) {
        NSLog(@"Error Happened in toFd! errno=%d", errno);
    }
}

#pragma mark - initialize the configuration for Event-Drive-Mode
- (void)prepareLWRunLoop
{
    int fds[2];
    
    int result = pipe(fds);
    
    _mReadPipeFd = fds[0];
    _mWritePipeFd = fds[1];
    
    int rflags;
    if ((rflags = fcntl(_mReadPipeFd, F_GETFL, 0)) < 0) {
        NSLog(@"Failure in fcntl F_GETFL");
    };
    rflags |= O_NONBLOCK;
    result = fcntl(_mReadPipeFd, F_SETFL, rflags);
    
    int wflags;
    if ((wflags = fcntl(_mWritePipeFd, F_GETFL, 0)) < 0) {
        NSLog(@"Failure in fcntl F_GETFL");
    };
    wflags |= O_NONBLOCK;
    result = fcntl(_mWritePipeFd, F_SETFL, wflags);
    
    _kq = kqueue();
    
    struct kevent changes[1];
    EV_SET(changes, _mReadPipeFd, EVFILT_READ, EV_ADD, 0, 0, NULL);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    int ret = kevent(_kq, changes, 1, NULL, 0, NULL);
    NSAssert(ret != -1, @"Failure in kevent().  errno=%d", errno);
#pragma clang diagnostic pop
    
    _fds = [[NSMutableArray alloc] init];
    _requests = [[NSMutableDictionary alloc] init];
    _portClients = [[NSMutableDictionary alloc] init];
}

#pragma mark - dispose the kqueue and pipe fds
- (void)nativeDestoryKernelFds
{
    close(_kq);
    close(_mReadPipeFd);
    close(_mWritePipeFd);
}

- (void)dealloc
{
    [self nativeDestoryKernelFds];
}

@end
