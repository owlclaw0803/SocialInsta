//
//  ComposeInboxViewController.m
//  SocialMedia
//
//  Created by Khalid  on 30/09/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "ComposeInboxViewController.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "TabbarControllerViewController.h"

@interface ComposeInboxViewController ()

@end

@implementation ComposeInboxViewController

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
    
    followingArray = [[NSMutableArray alloc] init];
    filteredArray = [[NSMutableArray alloc] init];
    
    [serchbar becomeFirstResponder];
    
    // Do any additional setup after loading the view.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost==YES) {
        [self.tabBarController setSelectedIndex:0];
    }
    
    //[followingTableView setAllowsMultipleSelection:NO];
    isSearch=NO;
    // Following TableView
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIFormDataRequest *_requestFollow = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_following.php"]];
    _requestFollow.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *requestFollow = _requestFollow;
    
    NSString *myuserid = [[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
    [requestFollow addRequestHeader:@"Content-Type" value:@"application/json"];
    [requestFollow setPostValue:myuserid forKey:@"user_id"];
    
    [requestFollow startAsynchronous];
    [requestFollow setCompletionBlock:^{
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[requestFollow responseData] options:0 error:nil];
        //  int k;
        [followingArray removeAllObjects];
        //        for (k=0;k<[root count];k++) {
        //            NSMutableDictionary *dic = (NSMutableDictionary *)[root objectAtIndex:k];
        //            [followingArray addObject:dic];
        //        }
        [followingArray addObjectsFromArray:root];
        [followingTableView reloadData];
    }];
    
    [requestFollow setFailedBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSError *error = [requestFollow error];
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

#pragma mark - UITableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearch==NO) {
        return [followingArray count];
    } else {
        return [filteredArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    InboxCustomCell *customCell = (InboxCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (customCell == nil) {
        customCell = [[InboxCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *dic;
    if (isSearch==NO) {
        dic = (NSDictionary *)[followingArray objectAtIndex:indexPath.row];
    } else {
        dic = (NSDictionary *)[filteredArray objectAtIndex:indexPath.row];
    }
    customCell.nameLabel.text = [dic valueForKey:@"username"];
    customCell.mesgLabel.text=[dic valueForKey:@"display_name"];
    customCell.profileImageView.layer.cornerRadius = customCell.profileImageView.frame.size.width/2;
    customCell.profileImageView.layer.masksToBounds = YES;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/thumb/%@-profile.jpg",[dic valueForKey:@"user_id"]]]; //The image URL goes here.
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@"DefaultUser.png"];
    [customCell.profileImageView setImageWithURLRequest:request
                                 placeholderImage:placeholderImage
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              customCell.profileImageView.image = image;
                                              [customCell setNeedsLayout];
                                              
                                          } failure:nil];
    
    return customCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic;
    if (isSearch==NO) {
        dic = (NSDictionary *)[followingArray objectAtIndex:indexPath.row];
    } else {
        dic = (NSDictionary *)[filteredArray objectAtIndex:indexPath.row];
    }
    chatViewController *chat = [self.storyboard instantiateViewControllerWithIdentifier:@"chat"];
    chat.userid = [dic valueForKey:@"user_id"];
    chat.username = [dic valueForKey:@"username"];
    [self.navigationController pushViewController:chat animated:YES];
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return YES if you want the specified item to be editable.
//    return YES;
//}
//
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //add code here for when you hit delete
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/delete_groupchat.php"]];
//        _request.shouldAttemptPersistentConnection   = NO;
//        __unsafe_unretained ASIFormDataRequest *request = _request;
//        
//        [request addRequestHeader:@"Content-Type" value:@"application/json"];
//        NSString *myuserid = [[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
//        NSDictionary *dic;
//        
//        if (isSearch==NO) {
//            dic = (NSDictionary *)[followingArray objectAtIndex:indexPath.row];
//        } else {
//            dic = (NSDictionary *)[filteredArray objectAtIndex:indexPath.row];
//        }
//        
//        if ([[dic valueForKey:@"sender_id"] isEqualToString:myuserid]) {
//            [request setPostValue:[dic objectForKey:myuserid] forKey:@"from_id"];
//            [request setPostValue:@"reciver_id" forKey:@"to_id"];
//        } else {
//            [request setPostValue:[dic objectForKey:@"sender_id"] forKey:@"from_id"];
//            [request setPostValue:myuserid forKey:@"to_id"];
//        }
//        
//        [request startAsynchronous];
//        [request setCompletionBlock:^{
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            
//            NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
//            NSString* dic = [root objectForKey:@"status"];
//            if([dic isEqual:@"success"]){
//                if (isSearch==NO) {
//                    [followingArray removeObjectAtIndex:indexPath.row];
//                } else {
//                    [filteredArray removeObjectAtIndex:indexPath.row];
//                }
//                [followingTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            }
//            else {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Fail to delete Row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert show];
//            }
//        }];
//    }
//}

#pragma mark - UITextField Delegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([searchStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0) {
        //beginswith
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"username CONTAINS[c] %@",[searchStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [filteredArray removeAllObjects];
        [filteredArray addObjectsFromArray:[followingArray filteredArrayUsingPredicate:searchPredicate]];
        isSearch = YES;
        [followingTableView reloadData];
    }
    else {
        isSearch = NO;
        [followingTableView reloadData];
    }
    return YES;
}

-(IBAction)hideKeyboardOnReturnTap:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0) {
        //beginswith
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"username CONTAINS[c] %@",[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [filteredArray removeAllObjects];
        [filteredArray addObjectsFromArray:[followingArray filteredArrayUsingPredicate:searchPredicate]];
        isSearch = YES;
        [followingTableView reloadData];
    }
    else {
        isSearch = NO;
        [followingTableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
//    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/search.php"]];
//    __unsafe_unretained ASIFormDataRequest *request = _request;
//    
//    [request addRequestHeader:@"Content-Type" value:@"application/json"];
//    //[request setpoValue:searchBar.text forKey:@"search"];
//    [request setPostValue:searchBar.text forKey:@"search"];
//    
//    [request startAsynchronous];
//    [request setCompletionBlock:^{
//        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
//        NSLog(@"News Root %@",root);
//        if(root!=NULL)
//        {
//            [self populateCollection:root completionBlock:^(BOOL result) {
//                if(result){
//                    [self.view endEditing:YES];
//                    [tblview reloadData];
//                }
//            }];
//        }
//        
//    }];
//    
//    [request setFailedBlock:^{
//        NSError *error=[request error];
//        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
//                                        type:AJNotificationTypeRed
//                                       title:error.localizedDescription
//                             linedBackground:AJLinedBackgroundTypeDisabled
//                                   hideAfter:5.0];
//    }];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    
    [serchbar resignFirstResponder];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
