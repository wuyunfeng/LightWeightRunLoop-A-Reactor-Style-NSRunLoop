//
//  LWConnHelper.hpp
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/12/12.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

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
    char *resolveHostName(const char *hostName);
    void establishSocket(const char *ip, const int port);
    void sendHttpHeader(const char *ptrHeader, int length);
    void sendHttpBody(const char *ptrBody, int lenght);
    void createHttpRequest(int timeoutMills, LWConnHelperContext *context);
    void closeConn();
};


#endif /* LWConnHelper_hpp */
