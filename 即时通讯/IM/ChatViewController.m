//
//  ChatViewController.m
//  即时通讯
//
//  Created by qiupeng on 14-9-22.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import "ChatViewController.h"
#import <CoreData/CoreData.h>
@interface ChatViewController ()<UITableViewDataSource,NSFetchedResultsControllerDelegate,UITextFieldDelegate>
{
    // 查询结果控制器
    NSFetchedResultsController *_fetchResultsController;
    
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[NSNotificationCenter  defaultCenter] addObserver:self selector:@selector(keyboardStateChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    // 绑定数据
    [self dataBinding];
}

#pragma mark - 绑定数据
- (void)dataBinding
{
    // 1. 数据库的上下文
    NSManagedObjectContext *context = xmppDelegate.xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext;
    
    // 2. 定义查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    // 3. 定义排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    [request setSortDescriptors:@[sort]];
    
    // 4. 需要过滤查询条件，谓词，过滤当前对话双发的聊天记录，将“lisi”的聊天内容取出来
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", _bareJID.bare];
    [request setPredicate:predicate];
    
    // 5. 实例化查询结果控制器
    _fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    // 设置代理，接收到数据变化时，刷新表格
    _fetchResultsController.delegate = self;
    
    // 6. 执行查询
    NSError *error = nil;
    if (![_fetchResultsController performFetch:&error]) {
        DDLogError(@"%@", error.localizedDescription);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *str = [textField.text trimString];
    if (str.length > 0) {
        XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:_bareJID];
        [message addBody:str];
        
        [xmppDelegate.xmppStream sendElement:message];
    }
    return YES;
}


#pragma mark - 滚动到表格的末尾
- (void)scrollToTableBottom
{
    id<NSFetchedResultsSectionInfo> info = _fetchResultsController.sections[0];
    
    int count = [info numberOfObjects];
    
    if (count <= 0) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(count - 1) inSection:0];
    
    [_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
}

#pragma mark - 查询结果控制器代理方法 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [_tableView reloadData];
    
    [self scrollToTableBottom];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> info = _fetchResultsController.sections[0];
    NSLog(@"[info numberOfObjects] %d",[info numberOfObjects]);
    return [info numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"ChatCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    XMPPMessageArchiving_Message_CoreDataObject *message = [_fetchResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = message.body;
    return cell;
}

- (void)keyboardStateChanged:(NSNotification *)notifcation
{
    CGRect rect = [notifcation.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _inputViewConstraint.constant = rect.size.height;
    
    NSTimeInterval duration = [notifcation.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    [self scrollToTableBottom];
}
@end
