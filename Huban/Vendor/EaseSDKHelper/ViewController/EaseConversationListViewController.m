//
//  EaseConversationListViewController.m
//  Huban
//
//  Created by sean on 15/11/22.
//  Copyright © 2015年 sean. All rights reserved.
//

#define kTopInfoListFileName @"topInfoList.plist"

#import "EaseConversationListViewController.h"

#import "ChatMessageListCell.h"
#import "ToMessageCell.h"
#import "EaseConversationModel.h"
#import "ChatViewController.h"
#import "NotificationViewController.h"

@interface EaseConversationListViewController () <IChatManagerDelegate, SWTableViewCellDelegate>
@end

@implementation EaseConversationListViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self tableViewDidTriggerHeaderRefresh];
    [self registerNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kMyTabbarControl_Height, 0);
    [self.tableView registerClass:[ChatMessageListCell class] forCellReuseIdentifier:kCellIdentifier_ChatMessageListCell];
    [self.tableView registerClass:[ToMessageCell class] forCellReuseIdentifier:kCellIdentifier_ToMessage];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = self.dataArray.count;
    NSInteger badgeValue = [self numberOfUnreadCommentNotification]; //评论通知的未读取量
    if (badgeValue > 0) {
        return row + 1;
    }
    [self.view configBlankPage:EaseBlankPageTypeMessageList hasData:(row > 0) hasError:nil reloadButtonBlock:nil];
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.dataArray.count) {
        NSInteger badgeValue = [self numberOfUnreadCommentNotification]; //评论通知的未读取量
        if (badgeValue > 0) {
            ToMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ToMessage forIndexPath:indexPath];
            cell.type = ToMessageTypeComment;
            cell.unreadCount = [[DataBaseManager shareInstance] numberOfCommentNotification];
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:8.f];
            return cell;
        }
    }
    id<IConversationModel> model = [self.dataArray objectAtIndex:indexPath.row];
    ChatMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ChatMessageListCell forIndexPath:indexPath];
    [cell setRightUtilityButtons:[self rightButtonsAtIndex:indexPath] WithButtonWidth:[ChatMessageListCell cellHeight]];
    cell.delegate = self;
    cell.conversation = model;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:8.f];
    return cell;
}

- (NSArray *)rightButtonsAtIndex:(NSIndexPath *)indexPath
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    id<IConversationModel> model = [self.dataArray objectAtIndex:indexPath.row];
    NSDictionary *ext = model.conversation.ext;
    if (ext) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] title:@"取消置顶"];
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xff5846"] title:@"删除"];
    } else {
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xe6e6e6"] title:@"置顶"];
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xff5846"] title:@"删除"];
    }
    return rightUtilityButtons;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChatMessageListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == self.dataArray.count) {
        NotificationViewController *vc = [[NotificationViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        id<IConversationModel> model = [self.dataArray objectAtIndex:indexPath.row];
        ChatViewController *vc = [[ChatViewController alloc] initWithConversationChatter:model.conversation.chatter conversationType:eConversationTypeChat];
        vc.contactCode = model.conversation.chatter;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - SWTableViewCellDelegate

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (index) {
        case 0: { //置顶
            [self topConversationAtIndexPath:indexPath];
        }
            break;
        case 1: { //删除
            [self deleteConversationAtIndexPath:indexPath];
        }
            break;
            
        default:
            break;
    }
}


- (void)deleteConversationAtIndexPath:(NSIndexPath *)indexPath
{
    id<IConversationModel> model = [self.dataArray objectAtIndex:indexPath.row];
    [[EaseMob sharedInstance].chatManager removeConversationByChatter:model.conversation.chatter deleteMessages:YES append2Chat:YES];
    [self.dataArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)topConversationAtIndexPath:(NSIndexPath *)indexPath
{
    id<IConversationModel> model = [self.dataArray objectAtIndex:indexPath.row];
    NSDictionary *topInfo = model.conversation.ext;
    BOOL hasTop = [topInfo[@"top"] boolValue];
    if (hasTop) { //如果已经置顶,取消置顶
        model.conversation.ext = nil;
        [self tableViewDidTriggerHeaderRefresh];
    } else { //置顶
        model.conversation.ext = @{@"top":@1,@"topDate":@([[NSDate date] timeIntervalSince1970])};
        [self.tableView beginUpdates];
        [self.dataArray removeObject:model];
        [self.dataArray insertObject:model atIndex:0];
        [self.tableView reloadData];
        [self.tableView endUpdates];
    }
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSArray* sorted = [conversations sortedArrayUsingComparator:
                       ^(EMConversation *obj1, EMConversation* obj2){
                           //比较
                           if (obj1.ext && !obj2.ext) { //如果一个被置顶,一个没有被置顶
                               return (NSComparisonResult)NSOrderedAscending;
                           } else if (obj2.ext && !obj1.ext) {
                               return(NSComparisonResult)NSOrderedDescending;
                           } else if (obj1.ext && obj2.ext) { //如果两个都被置顶,则比较置顶的时间
                               NSDate *topDate1 = [NSDate dateWithTimeIntervalSince1970:[obj1.ext[@"topDate"] doubleValue]];
                               NSDate *topDate2 = obj2.ext[@"topDate"];
                               return [topDate2 compare:topDate1];
                           }
                           //如果两个都没有被置顶,默认排序
                           EMMessage *message1 = [obj1 latestMessage];
                           EMMessage *message2 = [obj2 latestMessage];
                           if(message1.timestamp > message2.timestamp) {
                               return(NSComparisonResult)NSOrderedAscending;
                           }else {
                               return(NSComparisonResult)NSOrderedDescending;
                           }
                       }];
    
    
    
    [self.dataArray removeAllObjects];
    for (EMConversation *converstion in sorted) {
        EaseConversationModel *model = nil;
        if (_dataSource && [_dataSource respondsToSelector:@selector(conversationListViewController:modelForConversation:)]) {
            model = [_dataSource conversationListViewController:self
                                           modelForConversation:converstion];
        }
        else{
            model = [[EaseConversationModel alloc] initWithConversation:converstion];
        }
        
        if (model) {
            [self.dataArray addObject:model];
        }
    }
    
    [self tableViewDidFinishTriggerHeader:YES reload:YES];
}

#pragma mark - IChatMangerDelegate

-(void)didUnreadMessagesCountChanged
{
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    [self tableViewDidTriggerHeaderRefresh];
}

#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc{
    [self unregisterNotifications];
}

#pragma mark - private
- (NSString *)_latestMessageTitleForConversationModel:(id<IConversationModel>)conversationModel
{
    NSString *latestMessageTitle = @"";
    EMMessage *lastMessage = [conversationModel.conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                latestMessageTitle = NSLocalizedString(@"message.image1", @"[image]");
            } break;
            case eMessageBodyType_Text:{
                NSString *didReceiveText = ((EMTextMessageBody *)messageBody).text;
                latestMessageTitle = didReceiveText;
            } break;
            case eMessageBodyType_Voice:{
                latestMessageTitle = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
            case eMessageBodyType_Location: {
                latestMessageTitle = NSLocalizedString(@"message.location1", @"[location]");
            } break;
            case eMessageBodyType_Video: {
                latestMessageTitle = NSLocalizedString(@"message.video1", @"[video]");
            } break;
            case eMessageBodyType_File: {
                latestMessageTitle = NSLocalizedString(@"message.file1", @"[file]");
            } break;
            default: {
            } break;
        }
    }
    return latestMessageTitle;
}

- (NSString *)_latestMessageTimeForConversationModel:(id<IConversationModel>)conversationModel
{
    NSString *latestMessageTime = @"";
    EMMessage *lastMessage = [conversationModel.conversation latestMessage];;
    if (lastMessage) {
        double timeInterval = lastMessage.timestamp ;
        if(timeInterval > 140000000000) {
            timeInterval = timeInterval / 1000;
        }
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        latestMessageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }
    return latestMessageTime;
}

#pragma mark - Private
//评论通知的未读取量
- (NSInteger)numberOfUnreadCommentNotification {
    return [[DataBaseManager shareInstance] numberOfCommentNotification].integerValue;
}
@end
