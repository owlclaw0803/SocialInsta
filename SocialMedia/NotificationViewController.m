//
//  NotificationViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 08/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "NotificationViewController.h"
#import "AsyncImageView.h"
#import "TabbarControllerViewController.h"
#import "SnapShowViewController.h"
#import "UIImageView+WebCache.h"

@interface NotificationViewController ()

-(CGSize) SizeForCrop: (float) image_width
          imageHeight:(float) image_height
       containerWidth: (float)container_width
      containerHeight: (float) container_width;

@end

@implementation NotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(CGSize) SizeForCrop: (float) image_width
          imageHeight:(float) image_height
       containerWidth: (float)container_width
      containerHeight: (float) container_height{
    
    float container_ratio = container_height/ container_width;
    float image_ratio = image_height/ image_width;
    float crop_width, crop_height;
    
    if (container_ratio < image_ratio) {
        // Crop height
        crop_width = image_width;
        crop_height = image_width * container_ratio;
    }
    else {
        
        crop_height = image_height;
        crop_width = image_height / container_ratio;
    }
    return CGSizeMake(crop_width, crop_height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
	// Do any additional setup after loading the view.
    
    tableViewObj.tableFooterView = [[UIView alloc] init];
    
    activityArray = [[NSMutableArray alloc]init];
    fameArray = [[NSMutableArray alloc]init];
    followersArray = [[NSMutableArray alloc] init];
    followersPendingArray = [[NSMutableArray alloc] init];
    followingArray = [[NSMutableArray alloc] init];
    followingPendingArray = [[NSMutableArray alloc] init];
    
    isFollowing = NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost==YES) {
        [self.tabBarController setSelectedIndex:0];
    }
    [self getApiData];
}

-(void)populateCollection:(NSMutableDictionary *)collectionDictonary completionBlock:(void (^)(BOOL result)) return_block {
    
    fameArray = nil;
    activityArray = nil;
    
    fameArray = [[NSMutableArray alloc] init];
    activityArray = [[NSMutableArray alloc] init];
    NSMutableArray *followingArr = [[NSMutableArray alloc] init];
    activityArray = [[collectionDictonary objectForKey:@"news1"] mutableCopy];
    followingArr = [[collectionDictonary objectForKey:@"news2"] mutableCopy];
    NSString *ownerId = [[NSUserDefaults standardUserDefaults] objectForKey:@"id"];
    int i;
    for (i=0;i<[followingArr count];i++) {
        NSMutableDictionary *dic = (NSMutableDictionary *)[followingArr objectAtIndex:i];
        if (!([[dic valueForKey:@"user_id1"] isEqualToString:ownerId] || [[dic valueForKey:@"user_id2"] isEqualToString:ownerId])) {
            [fameArray addObject:dic];
        }
    }
    NSLog(@"news1 = %@",[[collectionDictonary objectForKey:@"news1"] mutableCopy]);
    NSLog(@"news2 = %@",[[collectionDictonary objectForKey:@"news2"] mutableCopy]);
    
    return_block(true);
}

-(IBAction)followingandnewsSegmentedSelect:(id)sender{
    
    [self HidePhotoView];
    [tableViewObj reloadData];
}

- (IBAction)dissmissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (segmentedController.selectedSegmentIndex == 0) {
        if ([activityArray count]<40) {
            return [activityArray count];
        }
        else {
            return 40;
        }
    }
    else {
        if ([fameArray count]<40) {
            return [fameArray count];
        }
        else {
            return 40;
        }
    }
}

// Start Code From Khalid

#pragma mark - UITableView Delegate/Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"followCell";
    NotificationCustomCell *cell = (NotificationCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[NotificationCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (segmentedController.selectedSegmentIndex==0) {
        
        NSMutableDictionary *tempDic = (NSMutableDictionary *)[activityArray objectAtIndex:indexPath.row];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg",[tempDic valueForKey:@"user_id"]]]; //The image URL goes here.
        cell.profileImageView.image = nil;
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [cell.profileImageView setImageWithURLRequest:request
                                     placeholderImage:nil
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  
                                                  cell.profileImageView.image = image;
                                                  [cell setNeedsLayout];
                                                  
                                              } failure:nil];

        NSLog(@"Activity is %@",[tempDic valueForKey:@"activity"]);
        if ([[tempDic valueForKey:@"activity"] length]>55) {
            [cell.dotLabel setHidden:NO];
        }
        else {
            [cell.dotLabel setHidden:YES];
        }
        if ([[tempDic valueForKey:@"activity"] rangeOfString:@"request"].location != NSNotFound && [followersPendingArray containsObject:[tempDic valueForKey:@"user_id"]]) {
            [cell.notificationView setHidden:NO];
            [cell.acceptButton setHidden:NO];
            [cell.rejectButton setHidden:NO];
            [cell.acceptButton setTag:[[tempDic valueForKey:@"user_id"] intValue]];
            [cell.rejectButton setTag:[[tempDic valueForKey:@"user_id"] intValue]];
            [cell.acceptButton addTarget:self action:@selector(btnAcceptClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.rejectButton addTarget:self action:@selector(btnRejectClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentImageView setImage:nil];
            [cell.notificationImage setImage:nil];
        }
        else if (([[tempDic valueForKey:@"activity"] rangeOfString:@"following"].location != NSNotFound) && (!([followingArray containsObject:[tempDic valueForKey:@"user_id"]] || [followingPendingArray containsObject:[tempDic valueForKey:@"user_id"]]))) {
            [cell.notificationView setHidden:YES];
            [cell.acceptButton setHidden:YES];
            [cell.rejectButton setHidden:YES];
            isFollowing = NO;
            [cell.contentImageView setImage:nil];
            [cell.notificationImage setImage:[UIImage imageNamed:@"notificationRequest"]];
            [cell.contentButton setTag:[[tempDic valueForKey:@"user_id"] intValue]];
            [cell.contentButton removeTarget:self action:@selector(handleTapFromactivity:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnPendingRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnFollowClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton addTarget:self action:@selector(btnSendRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (([[tempDic valueForKey:@"activity"] rangeOfString:@"following"].location != NSNotFound) && [followingPendingArray containsObject:[tempDic valueForKey:@"user_id"]]) {
            [cell.notificationView setHidden:YES];
            [cell.acceptButton setHidden:YES];
            [cell.rejectButton setHidden:YES];
            [cell.contentImageView setImage:nil];
            [cell.notificationImage setImage:[UIImage imageNamed:@"notificationPending"]];
            [cell.contentButton setTag:[[tempDic valueForKey:@"user_id"] intValue]];
            [cell.contentButton removeTarget:self action:@selector(handleTapFromactivity:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnSendRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnFollowClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton addTarget:self action:@selector(btnPendingRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (([[tempDic valueForKey:@"activity"] rangeOfString:@"following"].location != NSNotFound) && [followingArray containsObject:[tempDic valueForKey:@"user_id"]]) {
            [cell.notificationView setHidden:YES];
            [cell.acceptButton setHidden:YES];
            [cell.rejectButton setHidden:YES];
            isFollowing = YES;
            [cell.contentImageView setImage:nil];
            [cell.notificationImage setImage:[UIImage imageNamed:@"notificationAccept"]];
            [cell.contentButton setTag:[[tempDic valueForKey:@"user_id"] intValue]];
            [cell.contentButton removeTarget:self action:@selector(handleTapFromactivity:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnSendRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnPendingRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton addTarget:self action:@selector(btnFollowClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if ([[tempDic valueForKey:@"activity"] rangeOfString:@"liked"].location != NSNotFound) {
            [cell.notificationView setHidden:YES];
            [cell.acceptButton setHidden:YES];
            [cell.rejectButton setHidden:YES];
            
            NSURL *contenUrl;
            if ([[tempDic valueForKey:@"image_type"] isEqualToString:@"p"]) {
                contenUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/thumb/panorama/%@-%@.jpg",[tempDic valueForKey:@"owner_id"],[tempDic valueForKey:@"image_id"]]];
            } else {
                contenUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",[tempDic valueForKey:@"owner_id"],[tempDic valueForKey:@"image_id"]]];
            }
            [cell.notificationImage setImage:nil];
            //The image URL goes here.
            cell.contentImageView.image = nil;
            NSURLRequest *request = [NSURLRequest requestWithURL:contenUrl];
            [cell.contentImageView setImageWithURLRequest:request
                                         placeholderImage:nil
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                      cell.contentImageView.image = image;
                                                      [cell setNeedsLayout];
                                                  } failure:nil];

            [cell.contentButton setTag:indexPath.row];
            [cell.contentButton removeTarget:self action:@selector(btnFollowClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnSendRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnPendingRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton addTarget:self action:@selector(handleTapFromactivity:) forControlEvents:UIControlEventTouchUpInside];
        }else if ([[tempDic valueForKey:@"activity"] rangeOfString:@"left a comment on"].location != NSNotFound) {
            [cell.notificationView setHidden:YES];
            [cell.acceptButton setHidden:YES];
            [cell.rejectButton setHidden:YES];
            
            NSURL *contenUrl;
            if ([[tempDic valueForKey:@"image_type"] isEqualToString:@"p"]) {
                contenUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/thumb/panorama/%@-%@.jpg",[tempDic valueForKey:@"owner_id"],[tempDic valueForKey:@"image_id"]]];
            } else {
                contenUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",[tempDic valueForKey:@"owner_id"],[tempDic valueForKey:@"image_id"]]];
            }
            [cell.notificationImage setImage:nil];
            //The image URL goes here.
            cell.contentImageView.image = nil;
            NSURLRequest *request = [NSURLRequest requestWithURL:contenUrl];
            [cell.contentImageView setImageWithURLRequest:request
                                         placeholderImage:nil
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                      cell.contentImageView.image = image;
                                                      [cell setNeedsLayout];
                                                  } failure:nil];
            
            [cell.contentButton setTag:indexPath.row];
            [cell.contentButton removeTarget:self action:@selector(btnFollowClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnSendRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnPendingRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton addTarget:self action:@selector(handleTapFromactivity:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        NSString *aUsername = [tempDic valueForKey:@"username"];
        NSString *aText = [tempDic valueForKey:@"activity"];
        if(aText.length + aUsername.length >= 54){
            aText = [aText substringToIndex:54 - aUsername.length-2];
            aText = [NSString stringWithFormat:@"%@ ...",aText];
        }
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",aUsername,aText]];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0] range:NSMakeRange(0,[aUsername length])];
        cell.commentTextView.attributedText = attributedString;
        
        MyTapGestureRecognizer *tap = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
        tap.userid = [NSString stringWithFormat:@"%d",indexPath.row];
        [cell.commentTextView setTextColor:[UIColor whiteColor]];
        [cell.commentTextView addGestureRecognizer:tap];
        cell.timeLabel.text = [tempDic valueForKey:@"dt"];
        [cell.profileButton setTag:indexPath.row];
        [cell.profileButton addTarget:self action:@selector(handleTapFromactivityprofile:) forControlEvents:UIControlEventTouchUpInside];
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width/2;
        cell.profileImageView.layer.masksToBounds = YES;
    } else {
        [cell.notificationView setHidden:YES];
        [cell.notificationImage setImage:nil];
        NSMutableDictionary *tempDic = (NSMutableDictionary *)[fameArray objectAtIndex:indexPath.row];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg",[tempDic valueForKey:@"user_id1"]]]; //The image URL goes here.
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [cell.profileImageView setImageWithURLRequest:request
                                     placeholderImage:nil
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  
                                                  cell.profileImageView.image = image;
                                                  [cell setNeedsLayout];
                                                  
                                              } failure:nil];
        
        if ([[tempDic valueForKey:@"activity"] length]>55) {
            [cell.dotLabel setHidden:NO];
        }
        else {
            [cell.dotLabel setHidden:YES];
        }
        if ([[tempDic valueForKey:@"activity"] rangeOfString:@"following"].location != NSNotFound) {
            [cell.contentImageView setImage:nil];
            [cell.notificationImage setImage:[UIImage imageNamed:@"notificationAccept"]];
            [cell.contentButton setTag:[[tempDic valueForKey:@"user_id"] intValue]];
            [cell.contentButton removeTarget:self action:@selector(handleTapFromactivity:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnSendRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnPendingRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnFollowClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            
            NSURL *contenUrl;
            if ([[tempDic valueForKey:@"image_type"] isEqualToString:@"p"]) {
                contenUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/thumb/panorama/%@-%@.jpg",[tempDic valueForKey:@"user_id1"],[tempDic valueForKey:@"image_id"]]];
            } else {
                contenUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",[tempDic valueForKey:@"user_id1"],[tempDic valueForKey:@"image_id"]]];
            }
            NSURLRequest *contenRequest = [NSURLRequest requestWithURL:contenUrl cachePolicy:YES timeoutInterval:0.0]; //timeout can be adjusted
            [cell.contentImageView setImageWithURLRequest:contenRequest
                                         placeholderImage:nil
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                      cell.contentImageView.image = image;
                                                      [cell setNeedsLayout];
                                                      
                                                  } failure:nil];
            [cell.contentButton setTag:indexPath.row];
            [cell.contentButton removeTarget:self action:@selector(handleTapFromactivity:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnSendRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton removeTarget:self action:@selector(btnPendingRequestClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentButton addTarget:self action:@selector(handleTapFromactivity:) forControlEvents:UIControlEventTouchUpInside];
        }

        NSString *text = [NSString stringWithFormat:@"%@ %@ %@",[tempDic valueForKey:@"username1"],[tempDic valueForKey:@"activity"],[tempDic valueForKey:@"username2"]];
        
        int totalLength = [text length];
        int user1Length = [[tempDic valueForKey:@"username1"] length];
        int user2Length = [[tempDic valueForKey:@"username2"] length];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0] range:NSMakeRange(0,user1Length)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0] range:NSMakeRange(totalLength-user2Length,user2Length)];
        cell.commentTextView.attributedText = attributedString;
        MyTapGestureRecognizer *tap = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
        tap.userid = [NSString stringWithFormat:@"%d",indexPath.row];
        [cell.commentTextView setTextColor:[UIColor whiteColor]];
        [cell.commentTextView addGestureRecognizer:tap];
        cell.timeLabel.text = [tempDic valueForKey:@"dt"];
        [cell.profileButton setTag:indexPath.row];
        [cell.profileButton addTarget:self action:@selector(handleTapFromactivityprofile:) forControlEvents:UIControlEventTouchUpInside];
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width/2;
        cell.profileImageView.layer.masksToBounds = YES;
    }

    return cell;
}

- (void)textTapped:(MyTapGestureRecognizer *)recognizer
{
    UITextView *textView = (UITextView *)recognizer.view;
    
    // Location of the tap in text-container coordinates
    
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [recognizer locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    
    NSLog(@"location: %@", NSStringFromCGPoint(location));
    NSInteger tag = [[recognizer userid] integerValue];
    
    // Find the character that's been tapped on
    
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
                                           inTextContainer:textView.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < textView.textStorage.length) {
        
        if (segmentedController.selectedSegmentIndex==0) {
            //NSInteger tag = [[recognizer valueForKey:@"Index"] integerValue];
            NSMutableDictionary *tempDic = (NSMutableDictionary *)[activityArray objectAtIndex:tag];
            if (characterIndex<[[tempDic valueForKey:@"username"] length]) {
                [self handleProfileWithTag:tag];
            }
        }
        else {
            NSMutableDictionary *tempDic = (NSMutableDictionary *)[fameArray objectAtIndex:tag];
            NSString *text = [NSString stringWithFormat:@"%@ %@ %@",[tempDic valueForKey:@"username1"],[tempDic valueForKey:@"activity"],[tempDic valueForKey:@"username2"]];
            if (characterIndex<[[tempDic valueForKey:@"username1"] length]) {
                [self handleProfileWithTag:tag];
            }
            else if (characterIndex>([text length]-[[tempDic valueForKey:@"username2"] length]-1) && characterIndex<[text length]) {
                UIStoryboard *storyboard = self.navigationController.storyboard;
                ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
                fllowerPrfile.userId = [[fameArray objectAtIndex:tag] objectForKey:@"user_id2"];
                [self.navigationController pushViewController:fllowerPrfile animated:YES];
            }
        }
    }
}

-(void)handleTapFromactivity:(UIButton *)button {
    [self HidePhotoView];
    int tag = button.tag;
    
    if (segmentedController.selectedSegmentIndex==0) {
        UIStoryboard *storyboard = self.navigationController.storyboard;
        PhotoDescriptionViewController *detailPage = [storyboard
                                                      instantiateViewControllerWithIdentifier:@"photoDescriptin"];
        detailPage.strImageid=[[activityArray objectAtIndex:tag] objectForKey:@"image_id"] ;
        detailPage.strUserid=[[activityArray objectAtIndex:tag] objectForKey:@"owner_id" ];
        [self.navigationController pushViewController:detailPage animated:YES];
    }
    else {
        UIStoryboard *storyboard = self.navigationController.storyboard;
        PhotoDescriptionViewController *detailPage = [storyboard
                                                      instantiateViewControllerWithIdentifier:@"photoDescriptin"];
        detailPage.strImageid=[[fameArray objectAtIndex:tag] objectForKey:@"image_id"] ;
        detailPage.strUserid=[[fameArray objectAtIndex:tag] objectForKey:@"user_id2" ];
        [self.navigationController pushViewController:detailPage animated:YES];
    }
}

-(void)handleTapFromactivityprofile:(UIButton *)sender {
    
    int tag = sender.tag;
    [self handleProfileWithTag:tag];
}

- (void)handleProfileWithTag:(NSInteger)tag {
    [self HidePhotoView];
    if (segmentedController.selectedSegmentIndex==0) {
        UIStoryboard *storyboard = self.navigationController.storyboard;
        
        ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
        NSMutableDictionary *tempDic = (NSMutableDictionary *)[activityArray objectAtIndex:tag];
        fllowerPrfile.userId=[tempDic objectForKey:@"user_id"];
        [self.navigationController pushViewController:fllowerPrfile animated:YES];
    }
    else {
        UIStoryboard *storyboard = self.navigationController.storyboard;
        
        ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
        fllowerPrfile.userId = [[fameArray objectAtIndex:tag] objectForKey:@"user_id1"];
        
        [self.navigationController pushViewController:fllowerPrfile animated:YES];
    }
}

// End Code By Khalid

 -(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //[self HidePhotoView];
}

-(void)HidePhotoView
{
    TabbarControllerViewController *tab = (TabbarControllerViewController*)self.tabBarController;
    [tab hidePhotoView];
}

#pragma mark - API's

- (void)getApiData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_news.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        if(root != NULL)
        {
            [self populateCollection:root completionBlock:^(BOOL result) {
                if(result) {
                    [self callFollowingApi];
                }
            }];
        }
    }];
    
    [request setFailedBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:5.0];
    }];
}

-(void)FollowUnfollowApiCall:(void (^)(BOOL result)) return_block {
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/follow_check.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (root != nil) {
            [followersArray removeAllObjects];
            [followersPendingArray removeAllObjects];
            [followingArray removeAllObjects];
            [followingPendingArray removeAllObjects];
            
            [followersArray addObjectsFromArray:[root valueForKey:@"followers"]];
            [followersPendingArray addObjectsFromArray:[root valueForKey:@"followers_pending"]];
            [followingArray addObjectsFromArray:[root valueForKey:@"following"]];
            [followingPendingArray addObjectsFromArray:[root valueForKey:@"following_pending"]];
            return_block(TRUE);
        }
    }];
    [request setFailedBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:5.0];
    }];
}

-(void)sendFollowRequestApiCall:(NSString*)followString toUser:(NSString *)followId completionBlock:(void (^)(BOOL result)) return_block {
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/follow_users.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    [request setPostValue:followId forKey:@"follow_id"];
    [request setPostValue:followString forKey:@"follow"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        if([root[@"status"]isEqualToString:@"success"]) {
            return_block(TRUE);
        }
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

-(void)acceptRejectApiCall:(NSString*)followString toUser:(NSString *)followId completionBlock:(void (^)(BOOL result)) return_block {
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/follow.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    [request setPostValue:followId forKey:@"user_id2"];
    [request setPostValue:followString forKey:@"follow"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
        if (root != nil) {
            [self callFollowingApi];
            return_block(TRUE);
        }
    }];
    [request setFailedBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:5.0];
    }];
}

- (void)callFollowingApi {
    [self FollowUnfollowApiCall:^(BOOL result) {
        if (result) {
             [tableViewObj reloadData];
        }
    }];
}

- (IBAction)btnSendRequestClicked:(id)sender {
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIButton *btnType = (UIButton *)sender;
    if (![followingArray containsObject:[NSString stringWithFormat:@"%d",btnType.tag]]) {
        [self sendFollowRequestApiCall:@"1" toUser:[NSString stringWithFormat:@"%d",btnType.tag] completionBlock:^(BOOL result) {
            //[MBProgressHUD hideHUDForView:self.view animated:YES];
            if (result) {
                [self getApiData];
            }
        }];
    }
}

- (IBAction)btnPendingRequestClicked:(id)sender {
    UIButton *btnType = (UIButton *)sender;
    if (![followingArray containsObject:[NSString stringWithFormat:@"%d",btnType.tag]] && ![followingPendingArray containsObject:[NSString stringWithFormat:@"%d",btnType.tag]]) {
        
        NSLog(@"Pending");
    }
}

- (IBAction)btnFollowClicked:(id)sender {
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIButton *btnType = (UIButton *)sender;
    if ([followingArray containsObject:[NSString stringWithFormat:@"%d",btnType.tag]])  {
        [self sendFollowRequestApiCall:@"0" toUser:[NSString stringWithFormat:@"%d",btnType.tag] completionBlock:^(BOOL result) {
            //[MBProgressHUD hideHUDForView:self.view animated:YES];
            if (result) {
                [self getApiData];
            }
        }];
    }
}

- (IBAction)btnAcceptClicked:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIButton *btnType = (UIButton *)sender;
    [self acceptRejectApiCall:@"1" toUser:[NSString stringWithFormat:@"%d",btnType.tag] completionBlock:^(BOOL result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (result) {
            [self getApiData];
        }
    }];
}

- (IBAction)btnRejectClicked:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UIButton *btnType = (UIButton *)sender;
    [self acceptRejectApiCall:@"0" toUser:[NSString stringWithFormat:@"%d",btnType.tag] completionBlock:^(BOOL result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (result) {
            [self getApiData];
        }
    }];
}

@end
