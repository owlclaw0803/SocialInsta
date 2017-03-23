//
//  SerchViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 08/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "SerchViewController.h"
#import "AsyncImageView.h"
#import "TabbarControllerViewController.h"
#import "ExploreViewController.h"

@interface SerchViewController ()

@end

@implementation SerchViewController

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
    mutSerchArray = [[NSMutableArray alloc]init];
    [super viewDidLoad];
    bSearchPeople = YES;
    
    [self setNeedsStatusBarAppearanceUpdate];
	[serchbar becomeFirstResponder];

    tblview.tableFooterView = [[UIView alloc] init];
    [btnsearchpeople setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnsearchhash setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnsearchpeople setBackgroundColor:[UIColor colorWithRed:43.0f/255.0f green:119.0f/255.0f blue:141.0f/255.0f alpha:1.0f]];
    [btnsearchhash setBackgroundColor:[UIColor whiteColor]];
    serchbar.placeholder = @"Find your Friends";
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost == YES) {
        [self.tabBarController setSelectedIndex:0];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *url;
    NSString *searchtext = searchBar.text;
    if(bSearchPeople){
        url = @"http://192.99.7.25/~thesocialapp/social/iphone/search.php";
    }else{
        url = @"http://192.99.7.25/~thesocialapp/social/iphone/search_hashtag.php";
    }
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:searchtext forKey:@"search"];
    if(!bSearchPeople){
        [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    }
    [request startAsynchronous];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [request setCompletionBlock:^{
        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        if(root != NULL)
        {
            if(bSearchPeople){
                [self populateCollection:root completionBlock:^(BOOL result) {
                    if(result){
                        [self.view endEditing:YES];
                        [tblview reloadData];
                    }
                }];
            }else{
                hashdatas = root;
                [self.view endEditing:YES];
                [tblview reloadData];
            }
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    [request setFailedBlock:^{
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:5.0];
    }];
}

-(void)populateCollection:(NSMutableArray *)collectionArray completionBlock:(void (^)(BOOL result)) return_block{
    
    mutSerchArray = collectionArray;
    NSLog(@"%@",mutSerchArray);
    
    return_block(true);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(bSearchPeople)
        return [mutSerchArray count];
    else
        return [hashdatas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!bSearchPeople){
        return 55.0f;
    }
    return 65.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(bSearchPeople){
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg", [[mutSerchArray objectAtIndex:indexPath.row] objectForKey:@"id"]];
        AsyncImageView *imageview=(AsyncImageView*)[cell viewWithTag:1];
        imageview.layer.cornerRadius=20;
        imageview.layer.masksToBounds = YES;
        [imageview setImageURL:[NSURL URLWithString:aStrDisplyimage]];
        UILabel *userNamelbl=(UILabel*)[cell viewWithTag:2];
        userNamelbl.text=[[mutSerchArray objectAtIndex:indexPath.row] objectForKey:@"username"];
        UILabel *displayname=(UILabel*)[cell viewWithTag:3];
        displayname.text=[[mutSerchArray objectAtIndex:indexPath.row] objectForKey:@"display_name"];
        cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
        return cell;
    }else{
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        int width = [UIScreen mainScreen].bounds.size.width;
        cell.backgroundColor =  [UIColor clearColor];
        CGRect frm = CGRectMake(0, 0, width, 50);
        cell.frame = frm;
        UILabel *lblhash = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, width*0.7-15, 55)];
        lblhash.textAlignment = NSTextAlignmentLeft;
        lblhash.text = [[hashdatas objectAtIndex:indexPath.row] objectForKey:@"name"];
        lblhash.textColor = [UIColor whiteColor];
        UILabel *lblcount = [[UILabel alloc] initWithFrame:CGRectMake(width*0.7, 0, width*0.3-10, 55)];
        lblcount.textAlignment = NSTextAlignmentRight;
        int count = [[[hashdatas objectAtIndex:indexPath.row] objectForKey:@"count"] intValue];
        if(count == 1)
            lblcount.text = [NSString stringWithFormat:@"%d item", count];
        else
            lblcount.text = [NSString stringWithFormat:@"%d items", count];
        lblcount.textColor = [UIColor whiteColor];
        [cell addSubview:lblhash];
        [cell addSubview:lblcount];
        cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(bSearchPeople){
        UIStoryboard *storyboard = self.navigationController.storyboard;
    
        ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
        fllowerPrfile.userId=[[mutSerchArray objectAtIndex:indexPath.row] objectForKey:@"id"];
    
        //Push to detail View
        [self.navigationController pushViewController:fllowerPrfile animated:YES];
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIStoryboard *storyboard = self.navigationController.storyboard;
        ExploreViewController *exploreController = [storyboard instantiateViewControllerWithIdentifier:@"ExploreView"];
        [exploreController InitializeHashtag:[[hashdatas objectAtIndex:indexPath.row] objectForKey:@"name"]];
        [self.navigationController pushViewController:exploreController animated:YES];
        return;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    
    [serchbar resignFirstResponder];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)back:(id)sender {
    [self HidePhotoView];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(!bSearchPeople){
        if(searchText.length > 0){
            if([[searchText substringFromIndex:searchText.length-1] isEqualToString:@" "]){
                searchBar.text = [searchText substringToIndex:searchText.length-1];
            }else{
                if(searchText.length == 1 && ![searchText isEqualToString:@"#"])
                    searchBar.text = [NSString stringWithFormat:@"#%@", searchText];
            }
        }
    }
}

-(void)HidePhotoView
{
    TabbarControllerViewController *tab = (TabbarControllerViewController*)self.tabBarController;
    [tab hidePhotoView];
}

- (IBAction)searchpeople:(id)sender {
    if(bSearchPeople == NO){
        serchbar.text = @"";
        serchbar.placeholder = @"Find your Friends";
        bSearchPeople = YES;
        [btnsearchpeople setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnsearchhash setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnsearchpeople setBackgroundColor:[UIColor colorWithRed:43.0f/255.0f green:119.0f/255.0f blue:141.0f/255.0f alpha:1.0f]];
        [btnsearchhash setBackgroundColor:[UIColor whiteColor]];
        //[mutSerchArray removeAllObjects];
        mutSerchArray = [[NSMutableArray alloc] init];
        [tblview reloadData];
        [serchbar becomeFirstResponder];
    }
}

- (IBAction)searchhashtag:(id)sender {
    if(bSearchPeople == YES){
        serchbar.text = @"";
        serchbar.placeholder = @"#HashTag";
        bSearchPeople = NO;
        [btnsearchpeople setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnsearchhash setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnsearchpeople setBackgroundColor:[UIColor whiteColor]];
        [btnsearchhash setBackgroundColor:[UIColor colorWithRed:43.0f/255.0f green:119.0f/255.0f blue:141.0f/255.0f alpha:1.0f]];
        //[hashdatas removeAllObjects];
        hashdatas = [[NSMutableArray alloc] init];
        [tblview reloadData];
        [serchbar becomeFirstResponder];
    }
}

@end
