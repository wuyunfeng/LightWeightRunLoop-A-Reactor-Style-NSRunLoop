//
//  lw_nativerunloop_util.c
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 16/9/24.
//  Copyright © 2016 com.wuyunfeng.open. All rights reserved.
//

#include "lw_nativerunloop_util.h"
#include <fcntl.h>

int lwutil_make_socket_nonblocking(int fd)
{
    int flags;
    if ((flags = fcntl(fd, F_GETFL, NULL)) < 0) {
        return -1;
    }
    if (fcntl(fd, F_SETFL, flags | O_NONBLOCK) == -1) {
        return -1;
    }
    return 0;
}