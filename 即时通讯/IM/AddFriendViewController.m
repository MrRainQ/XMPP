//
//  AddFriendViewController.m
//  即时通讯
//
//  Created by qiupeng on 14-9-21.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import "AddFriendViewController.h"
#import "AppDelegate.h"
@interface AddFriendViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *friendNameText;

@end

@implementation AddFriendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *friendText = [_friendNameText.text trimString];
    if (friendText.length > 0) {
        [self addFriend:nil];
    }
    return YES;
}

- (IBAction)addFriend:(id)sender {
    
    // 1. 用户没有输入
    NSString *friendText = [_friendNameText.text trimString];
    if (friendText.length == 0) {
        return;
    }
    
    // 2. 用户只输入了用户名 zhangsan => 拼接域名
    NSRange range = [friendText rangeOfString:@"@"];
    if (NSNotFound == range.location) {
        NSString *domain = [xmppDelegate.xmppStream.myJID domain];
        friendText = [NSString stringWithFormat:@"%@@%@",friendText,domain];
    }
    
    XMPPJID *jid = [XMPPJID jidWithString:friendText];
    [xmppDelegate.xmppRoster subscribePresenceToUser:jid];
    
    // 3. 不能添加自己
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"订阅请求已经发送" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
