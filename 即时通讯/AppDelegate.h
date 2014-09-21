//
//  AppDelegate.h
//  即时通讯
//
//  Created by sen5labs on 14-9-18.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

// 全局AppDelegate代理的宏
#define xmppDelegate    ((AppDelegate *)[[UIApplication sharedApplication] delegate])

typedef enum {
    kLoginLogonError,       // 无法连接
    kLoginNotConnection,    // 用户名或密码错误
    kLoginRegisterError     // 用户注册失败
}kLoginErrorType;

typedef void(^LoginFailedBlock)(kLoginErrorType type);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
/**
 *  全局共享的XMPPStream对象
 *  之所以设置成readonly，对外部封闭，对内部开放
    XMPPStream属性的修改，仅能在AppDelegate中进行，其他调用方只能使用，不能修改，从而保证XMPPStream的安全
 */
@property (nonatomic,strong,readonly) XMPPStream *xmppStream;
@property (nonatomic,strong,readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic,strong,readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterCoreDataStorage;
/**
 *  注册用户标记
 */
@property (nonatomic,assign) BOOL isRegisterUser;


/**
 *  有登录界面调用，登录到服务器
 */
- (void)connectOnFailed:(LoginFailedBlock)falid;

/**
 *  用户注销
 */
- (void)logout;

@end
