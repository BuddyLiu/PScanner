//
//  HistoryListTableViewController.m
//  ScanDemo
//
//  Created by Paul on 13/03/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import "HistoryListTableViewController.h"

#define IOS_9_0 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 ? YES:NO)

@interface HistoryListTableViewController ()<UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) UIPasteboard *pasteboard;

@end

@implementation HistoryListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.dataArray = [NSMutableArray new];
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:HistoryListDataArray];
    if(arr && arr.count>0)
    {
        self.dataArray = [arr mutableCopy];
    }
    else
    {
        self.dataArray = [NSMutableArray new];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"HistoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    QRModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:self.dataArray[indexPath.row]];
    if(model && model.QRTitle && model.QRDetail)
    {
        cell.textLabel.text = model.QRTitle;
        cell.detailTextLabel.text = model.QRDetail;
        cell.detailTextLabel.numberOfLines = 0;
        [cell.detailTextLabel setAdjustsFontSizeToFitWidth:YES];
        if([model.QRRemark isEqual:@"0"])
        {
            cell.tintColor = [UIColor blackColor];
            [cell.textLabel setTextColor:[UIColor blackColor]];
            [cell.detailTextLabel setTextColor:[UIColor blackColor]];
        }
        else
        {
            cell.tintColor = [UIColor redColor];
            [cell.textLabel setTextColor:[UIColor redColor]];
            [cell.detailTextLabel setTextColor:[UIColor redColor]];
        }
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        //nothing to do
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:self.dataArray forKey:HistoryListDataArray];
        [self.tableView reloadData];
    }
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    QRModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:self.dataArray[indexPath.row]];
    if([model.QRRemark isEqual:@"0"])
    {
        model.QRRemark = @"1";
    }
    else
    {
        model.QRRemark = @"0";
    }
    
    [self.dataArray replaceObjectAtIndex:indexPath.row withObject:[NSKeyedArchiver archivedDataWithRootObject:model]];
    [[NSUserDefaults standardUserDefaults] setObject:self.dataArray forKey:HistoryListDataArray];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.pasteboard = [UIPasteboard generalPasteboard];
    QRModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:self.dataArray[indexPath.row]];
    self.pasteboard.string = model.QRDetail;
    if(IOS_9_0)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AlertPrompt", @"提示标题") message:NSLocalizedString(@"AlertMessage", @"提示内容") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"AlertSureBtnTitle", @"确定按钮") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.pasteboard.string]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.pasteboard.string] options:@{} completionHandler:^(BOOL success) {
                    
                }];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"AlertCancelBtnTitle", @"取消按钮") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //nothing to do
        }];
        [alert addAction:sureAction];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertPrompt", @"提示标题") message:NSLocalizedString(@"AlertMessage", @"提示内容") delegate:self cancelButtonTitle:NSLocalizedString(@"AlertSureBtnTitle", @"确定按钮") otherButtonTitles:NSLocalizedString(@"AlertCancelBtnTitle", @"取消按钮"),nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.pasteboard.string]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.pasteboard.string] options:@{} completionHandler:^(BOOL success) {
                
            }];
        }
    }
    else
    {
        //nothing to do
    }
}

@end
