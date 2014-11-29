//
//  RosterViewController.m
//  即时通讯
//
//  Created by sen5labs on 14-9-19.
//  Copyright (c) 2014年 sen5labs. All rights reserved.
//

#import "RosterViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "ChatViewController.h"
@interface RosterViewController ()<NSFetchedResultsControllerDelegate,UIAlertViewDelegate>
{
    NSFetchedResultsController *_fetchedResultsController;
    XMPPJID                    *_toRemovedJID;
}
@end

@implementation RosterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self dataBinding];

}

- (void)dataBinding
{
    NSManagedObjectContext *context = xmppDelegate.xmppRosterCoreDataStorage.mainThreadManagedObjectContext;
    
    // 2. 查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];

    // 3. 排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    
    request.sortDescriptors = @[sort];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"sectionNum" cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    
    if (![_fetchedResultsController performFetch:&error]) {
        DDLogError(@"%@",error.localizedDescription);
    }
}

-  (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    
    if ([identifier isEqualToString:@"ChatSegue"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        XMPPUserCoreDataStorageObject *user = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        ChatViewController *controller = segue.destinationViewController;
        controller.bareJID = user.jid;
    }
}

#pragma mark - 查询结果控制器的代理方法
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // 数据内容变化时，刷新表格数据
    [self.tableView reloadData];
}



#pragma mark - 数据源方法
// 分组数量
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _fetchedResultsController.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> info = _fetchedResultsController.sections[section];
    
    int state = [[info name] intValue];
    
    NSString *title = nil;
    switch (state) {
        case 0:
            title = @"在线";
            break;
        case 1:
            title = @"离开";
            break;
        case 2:
            title = @"离线";
            break;
        default:
            title = @"未知";
            break;
            
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> info = _fetchedResultsController.sections[section];
    
    return [info numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"RosterCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    // 取用户记录
    XMPPUserCoreDataStorageObject *user = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = user.displayName;
    
    cell.detailTextLabel.text = user.primaryResource.status;
    
    return cell;
}

#pragma mark 表格代理方法
#pragma mark 选中表格行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ChatSegue" sender:indexPath];
}


#pragma mark 表格代理方法
 -(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 判断修改表格的方式，是否为删除
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        
        XMPPUserCoreDataStorageObject *user = [_fetchedResultsController objectAtIndexPath:indexPath];
        _toRemovedJID = user.jid;
        NSString *msg = [NSString stringWithFormat:@"是否确认删除%@?",user.jid];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1==buttonIndex) {
        
        [xmppDelegate.xmppRoster removeUser:_toRemovedJID];
        
        _toRemovedJID = nil;
    }
}


@end
