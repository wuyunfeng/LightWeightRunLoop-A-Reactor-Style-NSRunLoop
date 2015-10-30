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
@interface ViewController ()
{
    UIButton *_button;
    NSThread *_thread;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContentView];
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(lightWeightRunloopThreadEntryPoint:) object:nil];
    _thread.name = @"com.wyf.opensource.thread";
    [_thread start];
}

#pragma mark - layout all subviews
- (void)setContentView
{
    [self.view setBackgroundColor:[UIColor grayColor]];
    self.title = @"Realize RunLoop";
    
    _button = [UIButton new];
    _button.width = self.view.width / 4;
    _button.height = 50;
    _button.top = 100;
    _button.centerX = self.view.centerX;
    [_button setTitle:@"Perform" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [_button addTarget:self action:@selector(executePost:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

#pragma mark - button action
- (void)executePost:(UIButton *)button
{
    [self postSelector:@selector(execute) onThread:_thread withObject:nil];
}

#pragma mark - Thread EntryPoint
- (void)lightWeightRunloopThreadEntryPoint:(id)data
{
    [[LWRunLoop currentLWRunLoop] run];
}

#pragma mark - Execute Selector, must declared in ***.h
- (void)execute
{
    
    NSLog(@"* [ Object: %@ performSelector: ( %@ ) on Thread : %@ ] *", [self class], NSStringFromSelector(_cmd), [NSThread currentThread].name);
    
}

#pragma mark - MemoryWaring
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
