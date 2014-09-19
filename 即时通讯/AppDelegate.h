//
//  AppDelegate.h
//  即时通讯
//
//  Created by sen5labs on 14-9-18.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

#define kXMPPLoginUserNameKey @"xmppUserName"
#define kXMPPLoginPasswordKey @"xmppPassword"
#define KXMPPLoginHostNameKey @"xmppHostName"

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


@property (nonatomic,assign) BOOL isRegisterUser;

- (void)connectOnFailed:(LoginFailedBlock)falid;
@end
