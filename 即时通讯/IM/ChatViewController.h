//
//  ChatViewController.h
//  即时通讯
//
//  Created by qiupeng on 14-9-22.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface ChatViewController : UIViewController
// 聊天的好友JID
@property (nonatomic, strong) XMPPJID *bareJID;

@end
