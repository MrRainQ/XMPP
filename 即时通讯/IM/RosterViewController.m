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

@interface RosterViewController ()<NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_fetchedResultsController;
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
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
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
    if ([identifier isEqualToString:@"AddFriendSegue"]) {
        
    }
}

#pragma mark - 查询结果控制器的代理方法
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // 数据内容变化时，刷新表格数据
    [self.tableView reloadData];
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
    
    return cell;
}



@end
