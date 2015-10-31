//
//  LWRunLoop.m
//  lwrunloop
//
//  Created by wuyunfeng on 15/10/27.
//  Copyright © 2015年 wuyunfeng open source. All rights reserved.
//

#import "LWRunLoop.h"
// unix standard
#include <sys/unistd.h>

//SYNOPSIS For Kevent
#include <sys/event.h>
#include <sys/types.h>
#include <sys/time.h>

#include <fcntl.h>


#include <pthread.h>
#include <sys/errno.h>

#import "NSThread+Looper.h"
#import "LWMessageQueue.h"


#define MAX_EVENT_COUNT 16

static pthread_once_t mTLSKeyOnceToken = PTHREAD_ONCE_INIT;
static pthread_key_t mTLSKey;
static LWRunLoop *instance;

int _mWakeReadPipeFd;
int _mWakeWritePipeFd;
int _kq;

@implementation LWRunLoop
{
    SEL _action;
    id _target;
    LWMessageQueue *_queue;
}


void initTLSKey(void)
{
    pthread_key_create(&mTLSKey, destructor);
}

void destructor()
{
    NSLog(@"destructor");
    instance = nil;
    [LWMessageQueue destoryMessageQueue];
    close(_kq);
    close(_mWakeReadPipeFd);
    close(_mWakeWritePipeFd);
}


#pragma mark - Public Method
+ (instancetype)currentLWRunLoop
{
    
    int result = pthread_once(& mTLSKeyOnceToken, initTLSKey);
    NSAssert(result == 0, @"pthread_once failure");

    instance = (__bridge LWRunLoop *)pthread_getspecific(mTLSKey);

    if (instance == nil) {
        instance = [[[self class] alloc] init];
        pthread_setspecific(mTLSKey, (__bridge const void *)(instance));
    }
    
    return instance;
}

- (void)run
{
    [[NSThread currentThread] setLooper];
    
    struct kevent events[MAX_EVENT_COUNT];
    while (true) {
        
        int ret = kevent(_kq, NULL, 0, events, MAX_EVENT_COUNT, NULL);
        
        for (int i = 0; i < ret; i++)
        {
            int eventFd = (int)events[i].ident;
            if (eventFd == _mWakeReadPipeFd) {
                [self handleReadWake];
                [self registerFds];
                break;
            }
        }
    }
}

#pragma mark - Private
- (instancetype)init
{
    if (self = [super init]) {
        [self innerInit];
    }
    
    return self;
}


- (void)innerInit
{
    int wakeFds[2];
    
    int result = pipe(wakeFds);
    NSAssert(result == 0, @"Failure in pipe().  errno=%d", errno);
    
    _mWakeReadPipeFd = wakeFds[0];
    _mWakeWritePipeFd = wakeFds[1];
    
    result = fcntl(_mWakeReadPipeFd, F_SETFL, O_NONBLOCK);
    NSAssert(result == 0, @"Failure in fcntl() for read wake fd.  errno=%d", errno);
    
    result = fcntl(_mWakeWritePipeFd, F_SETFL, O_NONBLOCK);
    NSAssert(result == 0, @"Failure in fcntl() for write wake fd.  errno=%d", errno);
    
    _kq = kqueue();
    NSAssert(_kq != -1, @"Failure in kqueue().  errno=%d", errno);

    [self registerFds];

}

- (void)registerFds
{
    struct kevent changes[1];
    EV_SET(changes, _mWakeReadPipeFd, EVFILT_READ, EV_ADD, 0, 0, NULL);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    int ret = kevent(_kq, changes, 1, NULL, 0, NULL);
    NSAssert(ret != -1, @"Failure in kevent().  errno=%d", errno);
#pragma clang diagnostic pop
}

- (void)handleReadWake
{
    char buffer[16];
    ssize_t nRead;
    do {
        nRead = read(_mWakeReadPipeFd, buffer, sizeof(buffer));
//        if ([_target respondsToSelector:_action]) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//            [_target performSelector:_action withObject:nil];
//#pragma clang diagnostic pop
//        }
        
        [[[LWMessageQueue defaultInstance] next] performSelectorForTarget];
    } while ((nRead == -1 && errno == EINTR) || nRead == sizeof(buffer));
}

- (void)handleWriteWake
{
    ssize_t nWrite;
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));

    do {
        nWrite = write(_mWakeWritePipeFd, "W", 1);
    } while (nWrite == -1 && errno == EINTR);
    
    if (nWrite != 1) {
        if (errno != EAGAIN) {
            NSLog(@"Could not write wake signal, errno=%d", errno);
        }
    }
}

- (void)postTarget:(id)target withAction:(SEL)aSel
{
    LWMessage *message = [[LWMessage alloc] initWithTarget:target aSel:aSel withArgument:nil at:MSG_TIME_NOW];
    [[LWMessageQueue defaultInstance] enqueueMessage:message];
    [self handleWriteWake];
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
