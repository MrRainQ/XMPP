//
//  AppDelegate.m
//  即时通讯
//
//  Created by sen5labs on 14-9-18.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import "AppDelegate.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
@interface AppDelegate()<XMPPStreamDelegate>
{
    LoginFailedBlock _faildBlock;
}
/**
 *  设置XMPPStream
 */
- (void)setupXmppStream;

/**
 *  连接到服务器
 */
- (void)connect;

/**
 *  断开连接
 */
- (void)disconnect;

/**
 *  用户上线
 */
- (void)goOnline;

/**
 *  用户下线
 */
- (void)goOffline;

@end

@implementation AppDelegate


#pragma mark - 切换Storyboard
- (void)showStoryboard
{
    // 实例化MainStoryboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // 在主线程中更新Storyboard
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.window.rootViewController = storyboard.instantiateInitialViewController;
    });
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 设置颜色日志
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:LOG_FLAG_INFO];
    
    
    // 1 实例化XMPPStream
    [self setupXmppStream];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self disconnect];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self connect];
}

#pragma mark - 成员方法
- (void)connectOnFailed:(LoginFailedBlock)falid
{
    _faildBlock = falid;
    
    // 断开已经存在服务器的长连接，先断开服务器的连接
    if (!_xmppStream.isDisconnected) {
        [_xmppStream disconnect];
    }
    [self connect];
}

#pragma mark - XMPP 相关方法
- (void)setupXmppStream
{
    NSAssert(_xmppStream == nil, @"XMPPStream被重复实例化");
    // 1. 实例化
    _xmppStream = [[XMPPStream alloc]init];
    
    // 2. 设置代理
    // 提示：使用类似框架时，包括看网络开源代码，大多数会使用dispatch_get_main)queue()
    // 使用主线程队列通常不容易出错，自己开发时，一定要用多线程
    // 一旦出问题，通常是UI更新问题，此时对于理解多线程的工作非常有帮助
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)connect
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *hostName = [defaults stringForKey:KXMPPLoginHostNameKey];
    NSString *userName = [defaults stringForKey:kXMPPLoginUserNameKey];
    
    if (hostName.length == 0 || userName.length == 0) {
        return;
    }
    
    // 设置XMPPStream的hostName&JID
    _xmppStream.hostName  = hostName;
    _xmppStream.myJID = [XMPPJID jidWithUser:userName domain:hostName resource:nil];
    
    // GCDAsnycSocket框架中,所有的网络通讯都是异步的
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        DDLogInfo(@"%@", error.localizedDescription);
    } else {
        DDLogInfo(@"发送连接请求成功");
    }
}

- (void)disconnect
{
    // 通知服务器，下线
    [self goOffline];
    
    [_xmppStream disconnect];
}

- (void)goOnline
{
    DDLogInfo(@"用户上线");
    // 通知服务器用户上线，服务器知道用户上线后，可以根据服务器记录的好友关系，
    // 通知该用户的其他好友，当前用户上线
    XMPPPresence *presence = [XMPPPresence presence];
    DDLogInfo(@"%@",presence);
    [_xmppStream sendElement:presence];
}

- (void)goOffline
{
    DDLogInfo(@"用户下线");
    // 通知用户下线
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
    
    DDLogInfo(@"%@",presence);
}

#pragma mark - XMPPStream协议代理方法
#pragma mark 完成连接
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogInfo(@"连接成功");
    // 登录到服务器，将用户密码发送到服务器验证身份
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPLoginPasswordKey];
    if (_isRegisterUser) { // 注册
        [_xmppStream registerWithPassword:password error:nil];
    }else{ // 登录
        [_xmppStream authenticateWithPassword:password error:nil];
    }
    
}
#pragma mark 断开连接
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogInfo(@"断开连接");
    if (_faildBlock && error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _faildBlock(kLoginNotConnection);
        });
    }
}

#pragma mark 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    [self goOnline];
    [self showStoryboard];
}
#pragma mark 注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    if (_faildBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _faildBlock(kLoginRegisterError);
        });
    }
}


#pragma mark 身份验证成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogInfo(@"身份验证成功");
    // 通知服务器用户上线，QQ头像“亮”是客户端干的，
    [self goOnline];
    
    // 显示Main.storyboard
    [self showStoryboard];
}

#pragma mark 用户名或者密码错误
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    DDLogInfo(@"用户名或者密码错误");
    if (_faildBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _faildBlock(kLoginLogonError);
        });
    }
    
    // 如果用户名或密码错误，将系统偏好中的内容清除
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kXMPPLoginUserNameKey];
    [defaults removeObjectForKey:kXMPPLoginPasswordKey];
    [defaults removeObjectForKey:KXMPPLoginHostNameKey];
    [defaults synchronize];
}

@end
