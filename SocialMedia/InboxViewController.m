//
//  InboxViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 08/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "InboxViewController.h"
#import "AppDelegate.h"
#import "AsyncImageView.h"
#import "ProfileViewController.h"
#import "TabbarControllerViewController.h"
#import "SVPullToRefresh.h"

@interface InboxViewController ()

@end

@implementation InboxViewController


BOOL bCommentExpand[10000];
int bBackViewExpand[10000];

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    tblView.tableFooterView = [[UIView alloc] init];
	// Do any additional setup after loading the view.
    //[tblView.tableHeaderView setHidden:YES];
    
    [tblView addPullToRefreshWithActionHandler:^{
        
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        [tblView setTableHeaderView:headerView];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_chat_count.php"]];
        _request.shouldAttemptPersistentConnection   = NO;
        __unsafe_unretained ASIFormDataRequest *request = _request;
        
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        NSString *myuserid = [[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
        [request setPostValue:myuserid forKey:@"user_id"];
        
        [request startAsynchronous];
        [request setCompletionBlock:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
            NSLog(@"News Root %@",root);
            NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id str, NSDictionary *unused) {
                return ![[str objectForKey:@"username"] isEqualToString:@"<null>"];
            }];
            NSArray *filtered = [[[root filteredArrayUsingPredicate:pred] reverseObjectEnumerator] allObjects];
            
            if(root!=NULL)
            {
                mutArray = nil;
                mutArray = [[NSMutableArray alloc] init];
                for (int i = 0; i < [filtered count]; i++) {
                    BOOL bFlag = YES;
                    for(int j = 0 ; j < i ; j++){
                        if((([[[filtered objectAtIndex:i] objectForKey:@"sender_username"] isEqualToString:[[filtered objectAtIndex:j] objectForKey:@"sender_username"]]) && ([[[filtered objectAtIndex:i] objectForKey:@"reciver_username"] isEqualToString:[[filtered objectAtIndex:j] objectForKey:@"reciver_username"]])) || (([[[filtered objectAtIndex:i] objectForKey:@"sender_username"] isEqualToString:[[filtered objectAtIndex:j] objectForKey:@"reciver_username"]]) && ([[[filtered objectAtIndex:i] objectForKey:@"reciver_username"] isEqualToString:[[filtered objectAtIndex:j] objectForKey:@"sender_username"]]))) {
                            bFlag = NO;
                            break;
                        }
                    }
                    if(bFlag == YES)
                        [mutArray addObject:[filtered objectAtIndex:i]];
                }
                if ([mutArray count] == 0) {
                    [tblView setHidden:YES];
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Opssss" message:@"no messages " delegate:NULL cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                    [alert show];
                }else{
                    [tblView reloadData];
                }
            }
            [tblView.pullToRefreshView stopAnimating];
        }];
        [request setFailedBlock:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSError *error = [request error];
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:error.localizedDescription
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:5.0];
        }];
    }];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)LoadMore:(NSString *)postID completionBlock:(void (^)(BOOL result)) return_block{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_chat_count.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    NSString *myuserid = [[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
    [request setPostValue:myuserid forKey:@"user_id"];
    
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id str, NSDictionary *unused) {
            return ![[str objectForKey:@"username"] isEqualToString:@"<null>"];
        }];
        NSArray *filtered = [[[root filteredArrayUsingPredicate:pred] reverseObjectEnumerator] allObjects];
        
        if(root!=NULL)
        {
            mutArray = nil;
            mutArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [filtered count]; i++) {
                BOOL bFlag = YES;
                for(int j = 0 ; j < i ; j++){
                    if((([[[filtered objectAtIndex:i] objectForKey:@"sender_username"] isEqualToString:[[filtered objectAtIndex:j] objectForKey:@"sender_username"]]) && ([[[filtered objectAtIndex:i] objectForKey:@"reciver_username"] isEqualToString:[[filtered objectAtIndex:j] objectForKey:@"reciver_username"]])) || (([[[filtered objectAtIndex:i] objectForKey:@"sender_username"] isEqualToString:[[filtered objectAtIndex:j] objectForKey:@"reciver_username"]]) && ([[[filtered objectAtIndex:i] objectForKey:@"reciver_username"] isEqualToString:[[filtered objectAtIndex:j] objectForKey:@"sender_username"]]))) {
                        bFlag = NO;
                        break;
                    }
                }
                if(bFlag == YES)
                    [mutArray addObject:[filtered objectAtIndex:i]];
            }
            if ([mutArray count] == 0) {
                [tblView setHidden:YES];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Opssss" message:@"no messages " delegate:NULL cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                [alert show];
            }else{
                [tblView reloadData];
            }
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSError *error = [request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:5.0];
    }];

}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost==YES) {
        [self.tabBarController setSelectedIndex:0];
    }
    
    [tblView setAllowsMultipleSelection:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_chat_count.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    NSString *myuserid = [[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
    [request setPostValue:myuserid forKey:@"user_id"];
    
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id str, NSDictionary *unused) {
            return ![[str objectForKey:@"username"] isEqualToString:@"<null>"];
        }];
        NSArray *filtered = [[[root filteredArrayUsingPredicate:pred] reverseObjectEnumerator] allObjects];
        
        if(root!=NULL)
        {
            mutArray = nil;
            mutArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [filtered count]; i++) {
                BOOL bFlag = YES;
                for(int j = 0 ; j < i ; j++){
                    if ((([[[filtered objectAtIndex:i] objectForKey:@"sender_username"] isEqualToString:[[filtered objectAtIndex:j] objectForKey:@"sender_username"]]) && ([[[filtered objectAtIndex:i] objectForKey:@"reciver_username"] isEqualToString:[[filtered objectAtIndex:j] objectForKey:@"reciver_username"]])) || (([[[filtered objectAtIndex:i] objectForKey:@"sender_username"] isEqualToString:[[filtered objectAtIndex:j] objectForKey:@"reciver_username"]]) && ([[[filtered objectAtIndex:i] objectForKey:@"reciver_username"] isEqualToString:[[filtered objectAtIndex:j] objectForKey:@"sender_username"]]))) {
                        bFlag = NO;
                        break;
                    }
                }
                if(bFlag == YES)
                [mutArray addObject:[filtered objectAtIndex:i]];
            }
            if ([mutArray count] == 0) {
                [tblView setHidden:YES];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Opssss" message:@"no messages " delegate:NULL cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                [alert show];
            }else{
                [tblView reloadData];
            }
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSError *error = [request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:5.0];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mutArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    InboxCustomCell *cell = (InboxCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[InboxCustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSDictionary *dic = (NSDictionary *)[mutArray objectAtIndex:indexPath.row];
    NSString *url;
    NSString *myuserid = [[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
    if ([[dic valueForKey:@"sender_id"] isEqualToString:myuserid]) {
        cell.nameLabel.text = [dic valueForKey:@"reciver_username"];
        url = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/thumb/%@-profile.jpg",[dic valueForKey:@"reciver_id"]];
    } else {
        cell.nameLabel.text = [dic valueForKey:@"sender_username"];
        url = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/thumb/%@-profile.jpg",[dic valueForKey:@"sender_id"]];
    }
    cell.mesgLabel.text = [dic valueForKey:@"msg"];
    cell.timeLabel.text = [dic valueForKey:@"dt"];
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width/2;
    cell.profileImageView.layer.masksToBounds = YES;
//    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.0]; //timeout can be adjusted
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
//     {
//         if (!connectionError) {
//             UIImage *image = [UIImage imageWithData:data];
//             [cell.profileImageView setImage:image];
//         }
//         else {
//             [cell.profileImageView setImage:[UIImage imageNamed:@"DefaultUser.png"]];
//         }
//     }];
    //cell.imageView.image = [UIImage imageNamed:@"DefaultUser.png"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [cell.profileImageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       cell.profileImageView.image = image;
                                       [cell setNeedsLayout];
                                       
                                   } failure:nil];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self HidePhotoView];
    NSDictionary *dic = (NSDictionary *)[mutArray objectAtIndex:indexPath.row];
    chatViewController *chat = [self.storyboard instantiateViewControllerWithIdentifier:@"chat"];
    NSString *myuserid = [[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
    if ([[dic valueForKey:@"sender_id"] isEqualToString:myuserid]) {
        chat.userid = [dic valueForKey:@"reciver_id"];
        chat.username = [dic valueForKey:@"reciver_username"];
    } else {
        chat.userid = [dic valueForKey:@"sender_id"];
        chat.username = [dic valueForKey:@"sender_username"];
    }
    [self.navigationController pushViewController:chat animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/delete_groupchat.php"]];
        _request.shouldAttemptPersistentConnection   = NO;
        __unsafe_unretained ASIFormDataRequest *request = _request;
        
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        NSString *myuserid = [[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
        NSDictionary *dic = (NSDictionary *)[mutArray objectAtIndex:indexPath.row];
        
        if ([[dic valueForKey:@"sender_id"] isEqualToString:myuserid]) {
            [request setPostValue:[dic valueForKey:@"sender_id"] forKey:@"me_id"];
            [request setPostValue:[dic valueForKey:@"reciver_id"] forKey:@"other_id"];
        } else {
            [request setPostValue:[dic valueForKey:@"sender_id"] forKey:@"other_id"];
            [request setPostValue:[dic valueForKey:@"reciver_id"] forKey:@"me_id"];
        }
        
        [request startAsynchronous];
        [request setCompletionBlock:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [mutArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        [request setFailedBlock:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSError *error = [request error];
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:error.localizedDescription
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:5.0];
        }];
    }
}

-(void)HidePhotoView
{
    TabbarControllerViewController *tab = (TabbarControllerViewController*)self.tabBarController;
    [tab hidePhotoView];
}

- (IBAction)writeNewMesssageClicked:(id)sender {
    ComposeInboxViewController *compose = [self.storyboard instantiateViewControllerWithIdentifier:@"compose"];
    [self.navigationController pushViewController:compose animated:YES];
}

@end
