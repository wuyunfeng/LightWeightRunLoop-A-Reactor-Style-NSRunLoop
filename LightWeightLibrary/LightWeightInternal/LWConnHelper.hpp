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

#ifndef LWConnHelper_hpp
#define LWConnHelper_hpp

#include <stdio.h>

typedef struct LWConnHelperContext {
    void *info;
    void (*LWConnectionTimeOutCallBack)(void *info);
    void (*LWConnectionReceiveCallBack)(void *info, void *data, int length);
    void (*LWConnectionFinishCallBack)(void *info);
    void (*LWConnectionFailureCallBack)(void *info, int code);
}LWConnHelperContext;

class LWConnHelper {
    
private:
    LWConnHelperContext *mContext;
    char targetIp[32];
    int mSockFd;
    
public:
    LWConnHelper() : mContext(NULL){};
    ~LWConnHelper();
    void setLWConnHelperContext(LWConnHelperContext *context);
    char *resolveHostName(const char *hostName);
    bool establishSocket(const char *ip, const int port);
    void sendMsg(const char *content, int length);
    void createHttpRequest(int timeoutMills);
    void closeConn();
    int readLine(int sock, char *buf, int size);
};


#endif /* LWConnHelper_hpp */
