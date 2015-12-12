#Overview:  
Each NSThread object, `excluding the application’s main thread`, can own an `LWRunLoop` object. You can get the current thread’s  `LWRunLoop`, through the class method *`currentLWRunLoop`*. Subsequently code snippet shows how configure LWRunLoop for NSThread and make the NSThread `_lwRunLoopThread` entering into `Event-Driver-Mode:`


     NSThread *_lwRunLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(lightWeightRunloopThreadEntryPoint:) object:nil];
        - (void)lightWeightRunloopThreadEntryPoint:(id)data {
    @autoreleasepool {
        LWRunLoop *looper = [LWRunLoop currentLWRunLoop];
        [looper run];
        // or
        //[[LWRunLoop currentLWRunLoop] run];
        }
    }
       
##To enqueue a selector to be performed on a different thread than your own 
you can use the category of NSObject(post)

> -(void)postSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg;

such as:


      [self postSelector:@selector(execute) onThread:_lwRunLoopThread withObject:nil];
      
      
##To schedule a selector to be executed at some point in the future

you can use the category of NSObject(post)
> -(void)postSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg afterDelay:(NSInteger)delay;
           
such as:

    [self postSelector:@selector(execute) onThread:_lwRunLoopThread withObject:nil afterDelay:1000];

##You use the LWTimer class to create timer objects or, more simply, timers. 
A timer waits until a certain time interval has elapsed and then fires, sending a specified message to a target object. 


> +(LWTimer * _Nonnull)scheduledLWTimerWithTimeInterval:(NSTimeInterval)interval target:(nonnull id)aTarget selector:(nonnull SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

> +(LWTimer * _Nonnull)timerWithTimeInterval:(NSTimeInterval)interval target:(nonnull id)aTarget selector:(nonnull SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;


fire the LWTimer using `- (void)fire` and invalidate the LWTimer using `- (void)invalidate`

####For example:

run the `- (void)genernateLWTimer` on `_lwRunLoopThread`:

    [self postSelector:@selector(genernateLWTimer) onThread:_lwRunLoopThread withObject:nil];
    
    - (void)genernateLWTimer
    {
        _count = 0;
        LWTimer *timer = [LWTimer timerWithTimeInterval:1000 target:self selector:@selector(bindLWTimerWithSelector:) userInfo:nil repeats:YES];
    [timer fire];
       //gTimer = [LWTimer scheduledLWTimerWithTimeInterval:2000 target:self selector:@selector(bindLWTimerWithSelector:) userInfo:nil repeats:YES];
    }
    
the selector for `LWTimer` to be executed:
    
    - (void)bindLWTimerWithSelector:(LWTimer *)timer
    {
        _count++;
        NSLog(@"* [ LWTimer : %@ performSelector: ( %@ ) on Thread : %@ ] *", [self class], NSStringFromSelector(_cmd), [NSThread currentThread].name);
        if (_count == 4) {
            [timer invalidate];
        }
    }   
##An LWURLConnection(v0.1) object lets you load the contents of a URL by providing a URL request object.
Step1: Perform `LWURLConnection` on `_lwRunLoopThread`:

	- (void)executeURLConnection:(UIButton *)button
	{
       [self postSelector:@selector(performURLConnectionOnRunLoopThread) onThread:_lwRunLoopThread withObject:nil];
	}
	
Step2: Create `LWURLConnection`, schedule `LWURLConnection` to `_lwRunLoopThread` such as following code snippet:

	- (void)performURLConnectionOnRunLoopThread
	{
        NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.8:8888/post.php"]];
       request.HTTPMethod = @"POST";
       NSString *content = @"name=john&address=beijing&mobile=140005";
       request.HTTPBody = [content dataUsingEncoding:NSUTF8StringEncoding];
       LWURLConnection *conn = [[LWURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
       [conn scheduleInRunLoop:_lwRunLoopThread.looper];
       [conn start];
    }
Step3: Implement the delegate methods on host Target:

	@protocol LWURLConnectionDataDelegate <NSObject>

	- (void)lw_connection:(LWURLConnection * _Nonnull)connection didReceiveData:(NSData * _Nullable)data;
	- (void)lw_connection:(LWURLConnection * _Nonnull)connection didFailWithError:(NSError * _Nullable)error;
	- (void)lw_connectionDidFinishLoading:(LWURLConnection * _Nonnull)connection;
	@end



###If you want to john me, cantact me with <wyfsky888@126.com> or fork this project <https://github.com/wuyunfeng/LightWeightRunLoop> and create a pull-request
