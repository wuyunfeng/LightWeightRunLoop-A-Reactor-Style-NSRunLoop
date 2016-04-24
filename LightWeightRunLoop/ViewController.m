//
//  ViewController.m
//  LightWeightRunLoop
//
//  Created by wuyunfeng on 15/10/30.
//  Copyright © 2015年 com.wuyunfeng.open. All rights reserved.
//

#import "ViewController.h"
#import "LightWeightRunLoop.h"
#import "UIViewAdditions.h"
#import "TestTarget1.h"
#import "TestTarget2.h"
#import "LWTimer.h"
#import "LWURLConnection.h"
#import "LWURLResponse.h"
#import "LWStream.h"

#define TEST_FILE (@"test.txt")
@interface ViewController ()<LWURLConnectionDataDelegate, LWStreamDelegate>
{
    UIButton *_button1;
    UIButton *_button2;
    UIButton *_button3;
    UIButton *_button4;
    UIButton *_button5;
    UIButton *_button6;
    UIButton *_button7;
    UIButton *_button8;
    UIButton *_button9;

    
    NSThread *_thread;
    NSThread *_lwRunLoopThread;
    
    NSThread *_lwModeRunLoopThread;
    
    TestTarget1 *_target1;
    TestTarget2 *_target2;
    
    NSInteger _count;
    LWTimer *gTimer;
    NSInputStream *_inputStream;
    NSMutableData *_responseData;
    LWInputStream *_lwInputStream;
    LWOutputStream *_lwOutputStream;
    
    NSMutableData *_inputStreamData;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContentView];
    [self testInputStream];

    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(lightWeightRunloopThreadEntryPoint:) object:nil];
    _thread.name = @"Thead 1";
    [_thread start];

    _lwRunLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(lightWeightRunloopThreadEntryPoint2:) object:nil];
    _lwRunLoopThread.name = @"LWRunLoopThread";
    [_lwRunLoopThread start];
    
    _lwModeRunLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(lightWeightRunloopThreadEntryPoint3:) object:nil];
    _lwModeRunLoopThread.name = @"LWRunLoopThread-Mode";
    [_lwModeRunLoopThread start];
}

- (void)testInputStream
{
    NSString *content = @"name=john&address=beijing&mobile=140005&age=1200";

    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    _inputStream = [[NSInputStream alloc] initWithData:data];
}

#pragma mark - layout all subviews
- (void)setContentView
{
    [self.view setBackgroundColor:[UIColor grayColor]];
    self.title = @"Realize RunLoop";
    
    _target1 = [[TestTarget1 alloc] init];
    _target2 = [[TestTarget2 alloc] init];
    
    _button1 = [UIButton new];
    _button1.width = self.view.width - 10;
    _button1.height = 40;
    _button1.top = 65;
    _button1.centerX = self.view.centerX;
    _button1.layer.borderColor = [UIColor yellowColor].CGColor;
    _button1.layer.cornerRadius = 4.0f;
    _button1.layer.masksToBounds = YES;
    _button1.backgroundColor = [UIColor whiteColor];
    [_button1 setTitle:@"MainThread -> LWRunLoop-Thread" forState:UIControlStateNormal];
    [_button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button1 setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_button1 addTarget:self action:@selector(executeMainThreadSelectorOnRunLoopThread:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button1];
    
    _button2 = [UIButton new];
    _button2.width = self.view.width - 10;
    _button2.height = 40;
    _button2.top = _button1.bottom + 5;
    _button2.centerX = self.view.centerX;
    _button2.layer.cornerRadius = 4.0f;
    _button2.layer.borderColor = [UIColor yellowColor].CGColor;
    _button2.layer.masksToBounds = YES;
    _button2.backgroundColor = [UIColor whiteColor];
    [_button2 setTitle:@"AsyncThread -> LWRunLoop-Thread" forState:UIControlStateNormal];
    [_button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button2 setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_button2 addTarget:self action:@selector(executeThreadSelectorOnRunLoopThread:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button2];
    
    _button3 = [UIButton new];
    _button3.width = self.view.width - 10;
    _button3.height = 40;
    _button3.top = _button2.bottom + 5;
    _button3.centerX = self.view.centerX;
    _button3.layer.cornerRadius = 4.0f;
    _button3.layer.borderColor = [UIColor yellowColor].CGColor;
    _button3.layer.masksToBounds = YES;
    _button3.backgroundColor = [UIColor whiteColor];
    [_button3 setTitle:@"MixedThread -> LWRunLoop-Thread" forState:UIControlStateNormal];
    [_button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button3 setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_button3 addTarget:self action:@selector(executeMixedSelectorOnRunLoopThread:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button3];
    
    _button4 = [UIButton new];
    _button4.width = self.view.width - 10;
    _button4.height = 40;
    _button4.top = _button3.bottom + 5;
    _button4.centerX = self.view.centerX;
    _button4.layer.cornerRadius = 4.0f;
    _button4.layer.borderColor = [UIColor yellowColor].CGColor;
    _button4.layer.masksToBounds = YES;
    _button4.backgroundColor = [UIColor whiteColor];
    [_button4 setTitle:@"LWTimer -> LWRunLoop-Thread" forState:UIControlStateNormal];
    [_button4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button4 setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_button4 addTarget:self action:@selector(executeTimerOnRunLoopThread:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button4];
    
    _button5 = [UIButton new];
    _button5.width = self.view.width - 10;
    _button5.height = 40;
    _button5.top = _button4.bottom + 5;
    _button5.centerX = self.view.centerX;
    _button5.layer.cornerRadius = 4.0f;
    _button5.layer.borderColor = [UIColor yellowColor].CGColor;
    _button5.layer.masksToBounds = YES;
    _button5.backgroundColor = [UIColor whiteColor];
    [_button5 setTitle:@"LWURLConnection" forState:UIControlStateNormal];
    [_button5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button5 setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_button5 addTarget:self action:@selector(executeURLConnection:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button5];
    
    _button6 = [UIButton new];
    _button6.width = self.view.width - 10;
    _button6.height = 40;
    _button6.top = _button5.bottom + 5;
    _button6.centerX = self.view.centerX;
    _button6.layer.cornerRadius = 4.0f;
    _button6.layer.borderColor = [UIColor yellowColor].CGColor;
    _button6.layer.masksToBounds = YES;
    _button6.backgroundColor = [UIColor whiteColor];
    [_button6 setTitle:@"MainThread > LWRunLoop-Thread(mode)" forState:UIControlStateNormal];
    [_button6 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button6 setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_button6 addTarget:self action:@selector(executeSelectorForMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button6];
    
    _button7 = [UIButton new];
    _button7.width = self.view.width - 10;
    _button7.height = 40;
    _button7.top = _button6.bottom + 5;
    _button7.centerX = self.view.centerX;
    _button7.layer.cornerRadius = 4.0f;
    _button7.layer.borderColor = [UIColor yellowColor].CGColor;
    _button7.layer.masksToBounds = YES;
    _button7.backgroundColor = [UIColor whiteColor];
    [_button7 setTitle:@"Change LWRunLoop-Thread mode" forState:UIControlStateNormal];
    [_button7 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button7 setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_button7 addTarget:self action:@selector(changeLWRunLoopMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button7];
    
    _button8 = [UIButton new];
    _button8.width = self.view.width - 10;
    _button8.height = 40;
    _button8.top = _button7.bottom + 5;
    _button8.centerX = self.view.centerX;
    _button8.layer.cornerRadius = 4.0f;
    _button8.layer.borderColor = [UIColor yellowColor].CGColor;
    _button8.layer.masksToBounds = YES;
    _button8.backgroundColor = [UIColor whiteColor];
    [_button8 setTitle:@"LWInputStread write" forState:UIControlStateNormal];
    [_button8 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button8 setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_button8 addTarget:self action:@selector(prepareLWOutputStream:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button8];
    
    _button9 = [UIButton new];
    _button9.width = self.view.width - 10;
    _button9.height = 40;
    _button9.top = _button8.bottom + 5;
    _button9.centerX = self.view.centerX;
    _button9.layer.cornerRadius = 4.0f;
    _button9.layer.borderColor = [UIColor yellowColor].CGColor;
    _button9.layer.masksToBounds = YES;
    _button9.backgroundColor = [UIColor whiteColor];
    [_button9 setTitle:@"LWInputStread read" forState:UIControlStateNormal];
    [_button9 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button9 setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_button9 addTarget:self action:@selector(prepareLWInputStream:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button9];
}

#pragma mark - test perform selector on LWRunLoop Thread without delay
- (void)executeMainThreadSelectorOnRunLoopThread:(UIButton *)button
{
    [self postSelector:@selector(execute) onThread:_lwRunLoopThread withObject:nil afterDelay:1000];
    [_target1 postSelector:@selector(performTest) onThread:_lwRunLoopThread withObject:nil];
    [_target2 postSelector:@selector(performTest) onThread:_lwRunLoopThread withObject:nil afterDelay:2000];
}

#pragma mark - test perform selector on LWRunLoop Thread without delay
- (void)executeThreadSelectorOnRunLoopThread:(UIButton *)button
{
    [self postSelector:@selector(execute) onThread:_lwRunLoopThread withObject:nil afterDelay:1000];
    [_target1 postSelector:@selector(performTest) onThread:_lwRunLoopThread withObject:nil];
    [_target2 postSelector:@selector(performTest) onThread:_lwRunLoopThread withObject:nil afterDelay:2000];
}

#pragma mark - test perform selector on LWRunLoop Thread without delay
- (void)executeMixedSelectorOnRunLoopThread:(UIButton *)button
{
    [self postSelector:@selector(execute) onThread:_lwRunLoopThread withObject:nil afterDelay:1000];
    [_target1 postSelector:@selector(performTest) onThread:_lwRunLoopThread withObject:nil];
    [_target2 postSelector:@selector(performTest) onThread:_lwRunLoopThread withObject:nil afterDelay:2000];
    [NSThread detachNewThreadSelector:@selector(asyncExecuteMethodOnThread:) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(asyncExecuteMethodOnThread:) toTarget:self withObject:nil];
}

#pragma mark - post method from new-thread to _thread
- (void)asyncExecuteMethodOnThread:(id)args
{
//    sleep(2);
    [_target1 postSelector:@selector(performTest) onThread:_lwRunLoopThread withObject:nil];
//    sleep(1);
    [_target2 postSelector:@selector(performTest) onThread:_lwRunLoopThread withObject:nil afterDelay:3000];
//    sleep(2);
    [self postSelector:@selector(execute) onThread:_lwRunLoopThread withObject:nil afterDelay:1000];
}

#pragma mark - Thread EntryPoint
- (void)lightWeightRunloopThreadEntryPoint:(id)data
{
    @autoreleasepool {
        [[LWRunLoop currentLWRunLoop] run];
    }
}


- (void)lightWeightRunloopThreadEntryPoint2:(id)data
{
    @autoreleasepool {
        LWRunLoop *looper = [LWRunLoop currentLWRunLoop];
        [looper run];
    }
}

- (void)lightWeightRunloopThreadEntryPoint3:(id)data
{
    @autoreleasepool {
        LWRunLoop *looper = [LWRunLoop currentLWRunLoop];
        [looper runMode:LWRunLoopModeReserve1];
    }
}
#pragma mark - post method from main-thread to _thread
- (void)execute
{
    NSLog(@"* [ Object: %@ performSelector: ( %@ ) on Thread : %@ ] *", [self class], NSStringFromSelector(_cmd), [NSThread currentThread].name);
}

#pragma mark - perform LWTimer Test on LWRunLoop Thread
- (void)executeTimerOnRunLoopThread:(UIButton *)button
{
    [self postSelector:@selector(genernateLWTimer) onThread:_lwRunLoopThread withObject:nil];
}

- (void)genernateLWTimer
{
    _count = 0;
    LWTimer *timer = [LWTimer timerWithTimeInterval:1000 target:self selector:@selector(bindLWTimerWithSelector:) userInfo:nil repeats:YES];
    [timer fire];
//    gTimer = [LWTimer scheduledLWTimerWithTimeInterval:2000 target:self selector:@selector(bindLWTimerWithSelector:) userInfo:nil repeats:YES];
}

- (void)bindLWTimerWithSelector:(LWTimer *)timer
{
    _count++;
    NSLog(@"* [ LWTimer : %@ performSelector: ( %@ ) on Thread : %@ ] *", [self class], NSStringFromSelector(_cmd), [NSThread currentThread].name);
    if (_count >= 4) {
        [timer invalidate];
    }
}

#pragma mark - perform URLConnection Test on LWRunLoop Thread
- (void)executeURLConnection:(UIButton *)button
{
    [self postSelector:@selector(performURLConnectionOnRunLoopThread) onThread:_lwRunLoopThread withObject:nil];
}

- (void)performURLConnectionOnRunLoopThread
{
    NSLog(@"[%@ %@]", [self class], NSStringFromSelector(_cmd));
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.11:8080/v1/list/post"]];
    request.HTTPMethod = @"POST";
    NSString *content = @"name=john&address=beijing&mobile=140005";
    request.HTTPBody = [content dataUsingEncoding:NSUTF8StringEncoding];
    LWURLConnection *conn = [[LWURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [conn scheduleInRunLoop:_lwRunLoopThread.looper];
    [conn start];
}

#pragma mark - LWURLConnectionDataDelegate
- (void)lw_connection:(LWURLConnection * _Nonnull)connection didReceiveData:(NSData * _Nullable)data
{
    if (!_responseData) {
        _responseData = [[NSMutableData alloc] init];
    }
    NSLog(@"**Thread : %@ --[%@ %@]**",[NSThread currentThread].name, [self class], NSStringFromSelector(_cmd));
    [_responseData appendData:data];
}
- (void)lw_connection:(LWURLConnection * _Nonnull)connection didFailWithError:(NSError * _Nullable)error
{
    NSLog(@"**Thread : %@ --[%@ %@]**",[NSThread currentThread].name, [self class], NSStringFromSelector(_cmd));
}

- (void)lw_connectionDidFinishLoading:(LWURLConnection * _Nonnull)connection
{
    NSLog(@"**Thread : %@ --[%@ %@]**",[NSThread currentThread].name, [self class], NSStringFromSelector(_cmd));
//    NSString *response = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    LWURLResponse *response = [[LWURLResponse alloc] initWithData:_responseData];
    NSLog(@"responseHeader = %@", [response allHeaderFields]);
    NSLog(@"statusCode = %lu",(long)[response statusCode]);
    NSLog(@"statusMsg = %@", [response statusMsg]);
    NSLog(@"responseBody = %@", [response responseBody]);
}

#pragma mark - performSelector for mode 
- (void)executeSelectorForMode:(NSString *)mode
{
    [self postSelector:@selector(executeSpecialModeSelectorOnModeThread4s:) onThread:_lwModeRunLoopThread withObject:nil afterDelay:4000 modes:@[LWRunLoopCommonModes]];
        [self postSelector:@selector(executeSpecialModeSelectorOnModeThread1s:) onThread:_lwModeRunLoopThread withObject:nil afterDelay:20000 modes:@[LWRunLoopModeReserve2]];
    [self postSelector:@selector(executeSpecialModeSelectorOnModeThread1s:) onThread:_lwModeRunLoopThread withObject:nil afterDelay:8000 modes:@[LWRunLoopModeReserve2]];
    [self postSelector:@selector(executeSpecialModeSelectorOnModeThread2s:) onThread:_lwModeRunLoopThread withObject:nil afterDelay:9000 modes:@[LWRunLoopModeReserve2]];
}

- (void)changeLWRunLoopMode
{
    LWRunLoop *runLoop = [_lwModeRunLoopThread looper];
    [runLoop changeRunLoopMode:LWRunLoopModeReserve2];
}


- (void)executeSpecialModeSelectorOnModeThread4s:(UIButton *)button
{
    NSLog(@"^o^ Mode **Thread : %@ --[%@ %@]**",[NSThread currentThread].name, [self class], NSStringFromSelector(_cmd));
}

- (void)executeSpecialModeSelectorOnModeThread1s:(UIButton *)button
{
    NSLog(@"^o^ ^o^ Mode **Thread : %@ --[%@ %@]**",[NSThread currentThread].name, [self class], NSStringFromSelector(_cmd));
}

- (void)executeSpecialModeSelectorOnModeThread2s:(UIButton *)button
{
    NSLog(@"^o^ ^o^ ^o^ Mode **Thread : %@ --[%@ %@]**",[NSThread currentThread].name, [self class], NSStringFromSelector(_cmd));
}

#pragma mark - LWInputStream
- (void)prepareLWInputStream:(UIButton *)button
{
    _inputStreamData = [[NSMutableData alloc] init];
    [self postSelector:@selector(executeLWInputStream) onThread:_lwModeRunLoopThread withObject:nil afterDelay:0 modes:@[LWRunLoopCommonModes]];//    [self executeLWInputStream];
}

- (void)executeLWInputStream
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [path stringByAppendingPathComponent:TEST_FILE];

    _lwInputStream = [[LWInputStream alloc]initWithFileAtPath:filePath];
    _lwInputStream.delegate = self;
    [_lwInputStream scheduleInRunLoop:[_thread looper] forMode:LWDefaultRunLoop];
    [_lwInputStream open];
}

#pragma mark - LWOutputStream
- (void)prepareLWOutputStream:(UIButton *)button
{
    [self postSelector:@selector(executeLWOutputStream) onThread:_lwModeRunLoopThread withObject:nil afterDelay:0 modes:@[LWRunLoopCommonModes]];//    [self executeLWInputStream];
}

- (void)executeLWOutputStream
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [path stringByAppendingPathComponent:TEST_FILE];
    
    _lwOutputStream = [[LWOutputStream alloc]initWithFileAtPath:filePath];
    _lwOutputStream.delegate = self;
    [_lwOutputStream scheduleInRunLoop:[_thread looper] forMode:LWDefaultRunLoop];
    [_lwOutputStream open];
}

#pragma mark - LWStreamDelegate
- (void)lw_stream:(LWStream * _Nonnull)aStream handleEvent:(LWStreamEvent)eventCode
{
    if ([aStream isKindOfClass:[LWInputStream class]]) {
        switch (eventCode) {
            case LWStreamEventOpenCompleted:
                 NSLog(@"LWInputStream Mode **Thread : %@ LWStreamEventOpenCompleted",[NSThread currentThread].name);
                 break;
            case LWStreamEventHasBytesAvailable:
            {
                uint8_t buffer[1];
                NSUInteger len = [(LWInputStream *)aStream read:buffer maxLength:sizeof(buffer)];
                [_inputStreamData appendBytes:buffer length:len];
            }
                break;
            case LWStreamEventEndEncountered:
            {
                NSLog(@"LWInputStream Mode **Thread : %@ LWStreamEventEndEncountered",[NSThread currentThread].name);
                NSString *content = [[NSString alloc] initWithData:_inputStreamData encoding:NSUTF8StringEncoding];
                NSLog(@"content = %@", content);
                [(LWInputStream *)aStream close];
            }
                break;
            default:
                break;
        }
    }
    
    if ([aStream isKindOfClass:[LWOutputStream class]]) {
        switch (eventCode) {
            case LWStreamEventOpenCompleted:
                NSLog(@"LWOutputStream Mode **Thread : %@ LWStreamEventOpenCompleted",[NSThread currentThread].name);
                break;
            case LWStreamEventHasSpaceAvailable:
            {
                uint8_t buffer[50] = "abcdefghijklmnopqrstuvwxyz";
                NSUInteger len = [(LWOutputStream *)aStream write:buffer maxLength:50];
                [_inputStreamData appendBytes:buffer length:len];
                [(LWOutputStream *)aStream close];
            }
                break;
            case LWStreamEventEndEncountered:
            {
                NSLog(@"LWOutputStream Mode **Thread : %@ LWStreamEventEndEncountered",[NSThread currentThread].name);
            }
                break;
            default:
                break;
        }
    }
}

@end
