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
    void setLWConnHelperContext(LWConnHelperContext *context);
    char *resolveHostName(const char *hostName);
    bool establishSocket(const char *ip, const int port);
    void sendMsg(const char *content, int length);
    void createHttpRequest(int timeoutMills);
    void closeConn();
};


#endif /* LWConnHelper_hpp */
