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

#include "LWConnHelper.hpp"

#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h> //for socket
#include <netinet/in.h> //for struct sockaddr_in
#include <arpa/inet.h> //for inet_addr inet_ntop
#include <sys/types.h>
#include <netdb.h> //for gethostbyname
#include <sys/errno.h>
#include <sys/select.h>
#include <sys/fcntl.h>
void LWConnHelper::setLWConnHelperContext(LWConnHelperContext *context)
{
    this->mContext = context;
}
char * LWConnHelper::resolveHostName(const char *hostName)
{
    if (hostName == NULL) {
        return NULL;
    }
    struct hostent *hptr= gethostbyname(hostName);
    if (!hptr) {
        printf("ip resolve failure\n");
    }
    char **pptr = hptr->h_aliases;
//    for(pptr = hptr->h_aliases; *pptr != NULL; pptr++)
//        printf(" alias:%s\n",*pptr);
    
    switch(hptr->h_addrtype)
    {
        case AF_INET:
        case AF_INET6:
            pptr = hptr->h_addr_list;
            inet_ntop(hptr->h_addrtype, hptr->h_addr, targetIp, sizeof(targetIp));
//            for(; *pptr!=NULL; pptr++)
//                printf(" address:%s\n", inet_ntop(hptr->h_addrtype, *pptr, targetIp, sizeof(targetIp)));
            break;
        default:
            printf("unknown address type\n");
            break;
    }
    return targetIp;
}

bool LWConnHelper::establishSocket(const char *ip, const int port)
{
    struct sockaddr_in serverAddr;
    serverAddr.sin_len = sizeof(struct sockaddr_in);
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(port);
    if (inet_aton(ip, &serverAddr.sin_addr) == 0) {
        printf("address error\n");
        return false;
    }
    inet_aton(ip, &serverAddr.sin_addr);
    
    this->mSockFd = socket(AF_INET, SOCK_STREAM, 0);
//    if (connect(this->mSockFd, (struct sockaddr *)&serverAddr, sizeof(struct sockaddr)) < 0) {
//        printf("errno = %d\n", errno);
//    }
    int flag = fcntl(this->mSockFd, F_GETFL, NULL);
    flag |= O_NONBLOCK;
    fcntl(this->mSockFd, F_SETFL, flag);
    int ret = connect(this->mSockFd, (struct sockaddr *)&serverAddr, sizeof(struct sockaddr));
    struct timeval tv = {15, 0};
    fd_set writeset;
    FD_ZERO(&writeset);
    if (ret < 0) {
        if (errno == EINPROGRESS) {
            printf("errno = EINPROGRESS in connect() - do `select()` \n");
            do {
                FD_SET(this->mSockFd, &writeset);
                ret = select(this->mSockFd + 1, NULL, &writeset, NULL, &tv);
                if (ret < 0 && errno != EINTR) {
                    printf("Error connecting %d\n", errno);
                    return false;
                } else if (ret > 0) {
                    int optval;
                    socklen_t optlen = sizeof(socklen_t);
                    if (getsockopt(this->mSockFd, SOL_SOCKET, SO_ERROR, (void *)(&optval), &optlen) < 0) {
                        printf("Error in getsockopt() %d\n", errno);
                        return false;
                    }
                    if (optval) {
                        printf("Error in delayed connection()\n");
                        return false;
                    }
                } else {
                    printf("timeout in select() - Cancelling!\n");
                    return false;
                }
            } while (ret == -1 && errno == EINTR);
        } else {
            //ENETUNREACH	51		/* Network is unreachable */
            printf("Error in connecting %d\n", errno);
            return false;
        }
    }
//    flag = fcntl(this->mSockFd, F_GETFL, NULL);
//    flag &= (~O_NONBLOCK);
//    fcntl(this->mSockFd, F_SETFL, flag);
    return true;
}

void LWConnHelper::sendMsg(const char *content, int length)
{
    if (content == NULL) {
        return;
    }
    ssize_t mWrite;
    do {
        mWrite = write(this->mSockFd, content, length);
    } while (mWrite == -1 && errno == EINTR);
}

void LWConnHelper::createHttpRequest(int timeoutMills)
{
    fd_set readfds;
    struct timeval timeout;
    timeout.tv_sec = timeoutMills / 1000;
    timeout.tv_usec = timeoutMills % 1000 * 1000;
    int maxfd = -1;
    FD_ZERO(&readfds);
    maxfd = this->mSockFd + 1;
    int ret;
    do {
        FD_SET(this->mSockFd, &readfds);
        ret = select(maxfd, &readfds, NULL, NULL, &timeout);
        
        if (0 == ret) {
            if (this->mContext->LWConnectionTimeOutCallBack != NULL) {
                this->mContext->LWConnectionTimeOutCallBack(this->mContext->info);
            }
        }
        if (FD_ISSET(this->mSockFd, &readfds)) {
            char buffer[4 * 1024];
            ssize_t nRead;
//            int length = -1;
//            while ((length = readLine(this->mSockFd, buffer, sizeof(buffer))) != 0) {
//                printf("buffer = %s\n", buffer);
//            }
            do {
                nRead = read(this->mSockFd, buffer, sizeof(buffer));
                if (this->mContext->LWConnectionReceiveCallBack != NULL) {
                    this->mContext->LWConnectionReceiveCallBack(this->mContext->info, buffer, (int)nRead);
                }
            } while ((nRead == -1 && errno == EINTR) || nRead == sizeof(buffer));
            if (this->mContext->LWConnectionFinishCallBack) {
                this->mContext->LWConnectionFinishCallBack(this->mContext->info);
            }
        }
    } while (-1 == ret && errno == EINTR);
    
    if (-1 == ret) {
        if (this->mContext->LWConnectionFailureCallBack != NULL) {
            this->mContext->LWConnectionFailureCallBack(this->mContext->info, -1);
        }
    }
    closeConn();
}

void LWConnHelper::closeConn()
{
    close(this->mSockFd);
}

LWConnHelper::~LWConnHelper()
{
    mContext = NULL;
    closeConn();
}

int LWConnHelper::readLine(int sock, char *buf, int size)
{
    int i = 0;
    char c = '\0';
    ssize_t n;
    
    while ((i < size - 1) && (c != '\n')) {
        n = recv(sock, &c, 1, 0);
        if (n > 0) {
            if (c == '\r') {
                n = recv(sock, &c, 1, MSG_PEEK);
                if ((n > 0) && (c == '\n')) {
                    recv(sock, &c, 1, 0);
                    break; // add `break` to avoid add '\n' to buffer[len - 2]
                } else {
                    c = '\n';
                }
            }
            buf[i] = c;
            i++;
        } else {
            c = '\n';
        }
    }
    buf[i] = '\0';// add '\0' to buffer[len - 1]
    return(i);
}



