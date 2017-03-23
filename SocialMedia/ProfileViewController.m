//
//  ProfileViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 02/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "ProfileViewController.h"
#import "AsyncImageView.h"
#import "TabbarControllerViewController.h"
#import "SVPullToRefresh.h"
#import "GKImagePicker.h"
#import "UIImage+FixOrientation.h"
#import "ExploreViewController.h"

@interface ProfileViewController () <GKImagePickerDelegate> {
    GKImagePicker *picker;
}
@property (nonatomic, retain) GKImagePicker *picker;
@end

@implementation ProfileViewController
@synthesize picker = _picker;
@synthesize mutArrayProfileImages,mutDictProfileInfo, actionShare,profilePicAction,picMutArray,profileCoverPicAction,croppedPhoto;

BOOL bCmtExpand[1000];
int bBackViewExpand[1000];
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
    
    userImageview.layer.cornerRadius = userImageview.frame.size.width/2;
    userImageview.layer.masksToBounds = YES;
    _imagePickerObj=[[UIImagePickerController alloc]init];
    _imagePickerObj.delegate = self;
    
    coverString = [[NSMutableString alloc] init];
    followersArray = [[NSMutableArray alloc] init];
    followersPendingArray = [[NSMutableArray alloc] init];
    followingArray = [[NSMutableArray alloc] init];
    followingPendingArray = [[NSMutableArray alloc] init];

    actionShare = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Share",@"Share on Instagram", @"Delete", nil];
    [self.view addSubview:actionShare];
    profilePicAction = [[UIActionSheet alloc]initWithTitle:@"Change Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Current Photo" otherButtonTitles:@"Take Photo", @"Choose from Library", nil];
    
    _changeCoverPicAction = [[UIActionSheet alloc]initWithTitle:@"Change Cover Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Current Photo" otherButtonTitles:@"Take Photo", @"Choose from Library", nil];
    
    profileCoverPicAction = [[UIActionSheet alloc]initWithTitle:@"Edit Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:NULL otherButtonTitles:@"Edit User name", nil];
    [self.view addSubview:profilePicAction];
    [self.view addSubview:_changeCoverPicAction];
    hidden = NO;
    if ([self.userId intValue] != [[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] intValue]) {
        [viewHederNavigation setHidden:NO];
        [myviewHederNavigation setHidden:YES];
        [btnmsz setHidden:NO];
        isMyProfile = NO;
    }
    else{
        [myviewHederNavigation setHidden:NO];
        [viewHederNavigation setHidden:YES];
        UITapGestureRecognizer *changeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeProfilePicture:)];
        [userImageview addGestureRecognizer:changeTap];
        userImageview.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *coverTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeCoverPicture:)];
        [coverpageImage addGestureRecognizer:coverTap];
        coverpageImage.userInteractionEnabled = YES;
        
        [btnmsz setHidden:YES];
        isMyProfile = YES;
    }
    
    landscapeView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 548)];
    [landscapeView setBackgroundColor:[UIColor blackColor]];
    
    [tblview addPullToRefreshWithActionHandler:^ {
        NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg", self.userId];
        [self downloadImageWithURL:[NSURL URLWithString:aStrDisplyimage] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                [userImageview setImage:image];
            }
        }];
        [self getCoverApiCall:^(BOOL result) {
            if ([coverString isEqualToString:@"default_cover.png"]) {
                [coverpageImage setImage:[UIImage imageNamed:@"backgroundimage@2x.png"]];
            }
            else {
                NSString *aStrDisplyCoverimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@",coverString];
                [self downloadImageWithURL:[NSURL URLWithString:aStrDisplyCoverimage] completionBlock:^(BOOL succeeded, UIImage *image) {
                    if (succeeded) {
                        [coverpageImage setImage:image];
                    }
                }];
            }
            NSLog(@"Result is");
            
        }];
        
        if (self.userId == NULL || [self.userId isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"id"]]) {
            
            NSLog(@"Current User");
        }
        else {
            [self callFollowingApi];
        }
        
        [self profileApiCall:^(BOOL result) {
            NSString *username;
            if ([[mutDictProfileInfo objectForKey:@"display_name"] length]>0) {
                username = [mutDictProfileInfo objectForKey:@"display_name"];
            } else {
                username = [mutDictProfileInfo objectForKey:@"username"];
            }
            //NSString *displayName=[mutDictProfileInfo objectForKey:@"display_name"];
            NSString *followers = [mutDictProfileInfo objectForKey:@"followers"];
            NSString *following = [mutDictProfileInfo objectForKey:@"following"];
            NSString *post = [mutDictProfileInfo objectForKey:@"posts"];
            NSString *aboutme = [mutDictProfileInfo objectForKey:@"about_me"];
            NSString *totallikes = [mutDictProfileInfo objectForKey:@"user_images_likes"];
            lblLIkes.text = totallikes;
            lblProfileName.text = username;
            //self.userlableTwo.text=displayName;
            lblFollower.text = followers;
            Following.text = following;
            lblPost.text = post;
            lblAboutMe.text = [mutDictProfileInfo objectForKey:@"bio"];
            lblAboutMe.lineBreakMode = NSLineBreakByWordWrapping;
            [lblAboutMe setNumberOfLines:0];
            [lblWebsite setTitle:[mutDictProfileInfo objectForKey:@"setting_website"] forState:UIControlStateNormal];
            privateProfile = [mutDictProfileInfo objectForKey:@"isPrivate"];
            
            [lblAboutMe setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0f]];
            mutArrayProfileImages = nil;
            mutArrayProfileImages = [[mutDictProfileInfo objectForKey:@"user_timeline"] mutableCopy] ;
            
            NSArray* reversedArray = [[mutArrayProfileImages reverseObjectEnumerator] allObjects];
            
            mutArrayProfileImages = [NSMutableArray arrayWithArray:reversedArray];
            
            for(int i = 0 ; i < [mutArrayProfileImages count] ; i++){
                bCmtExpand[i] = NO;
                bBackViewExpand[i] = 1;
            }
            if ([privateProfile isEqualToString:@"1"] && (isMyProfile==NO && ![followingArray containsObject:self.userId])) {
                [privateProfileImageView setHidden:NO];
                [tblview setScrollEnabled:NO];
                hederview.frame = CGRectMake(hederview.bounds.origin.x, hederview.bounds.origin.y, hederview.bounds.size.width, 500);
                tblview.tableHeaderView = hederview;
            }
            else {
                [privateProfileImageView setHidden:YES];
                [tblview setScrollEnabled:YES];
                hederview.frame = CGRectMake(hederview.bounds.origin.x, hederview.bounds.origin.y, hederview.bounds.size.width, 312);
                tblview.tableHeaderView = hederview;
            }
            [btntable setSelected:YES];
            [btnCollection setSelected:NO];
            [tblview reloadData];
            [tblview.pullToRefreshView stopAnimating];
        }];
    }];
    
    [privateProfileImageView setHidden:YES];
    [privateProfileImageView setImage:[UIImage imageNamed:@"PrivateProfile"]];
    
    isPhotoFromLibrary = NO;
    isComment = NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    hidden = NO;
    
    [self showTabBar:self.tabBarController];
    
    if(!isMyProfile){
        //[viewHederNavigation setFrame:CGRectMake(0, 0, 320,70)];
        [viewHederNavigation  setHidden:NO];
    }else{
        //[myviewHederNavigation setFrame:CGRectMake(0, 0, 320,70)];
        [myviewHederNavigation  setHidden:NO];
    }
    
    [UIView animateWithDuration:0.2 animations:^ {
        
        if(!isMyProfile) {
            [viewHederNavigation setFrame:CGRectMake(0, 20, 320,50)];
        }
        else {
            [myviewHederNavigation setFrame:CGRectMake(0, 20, 320,50)];
        }
        [tblview setContentInset:UIEdgeInsetsMake(70,0,0,0)];
    } completion:^(BOOL finished) {
    
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost==YES) {
        [self.tabBarController setSelectedIndex:0];
    }
    
    if ([self.userId intValue] != [[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] intValue]) {
        isMyProfile = NO;
    }
    else {
        isMyProfile = YES;
    }
    
    [tblview setContentInset:UIEdgeInsetsMake(70,0,0,0)];
    
    if (isPhotoFromLibrary==NO) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self getCoverApiCall:^(BOOL result) {
            if ([coverString isEqualToString:@"default_cover.png"]) {
                [coverpageImage setImage:[UIImage imageNamed:@"backgroundimage@2x.png"]];
            }
            else {
                NSString *aStrDisplyCoverimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@",coverString];
                [self downloadImageWithURL:[NSURL URLWithString:aStrDisplyCoverimage] completionBlock:^(BOOL succeeded, UIImage *image) {
                    if (succeeded) {
                        [coverpageImage setImage:image];
                    }
                }];
            }
            
        }];
    }
    else {
        isPhotoFromLibrary = NO;
    }
    
    //[AsyncImageLoader sharedLoader].cache = nil;
    
    NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg", [[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
    NSLog(@"aStrDisplyimage = %@",aStrDisplyimage);
    
    
    if ([self.userId intValue] == [[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] intValue])  {
        NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg", [[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
        [self downloadImageWithURL:[NSURL URLWithString:aStrDisplyimage] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                [userImageview setImage:image];
            }
        }];
    }
    else{
        NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg", self.userId];
        [self downloadImageWithURL:[NSURL URLWithString:aStrDisplyimage] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                [userImageview setImage:image];
            }
        }];
    }
    
    if (self.userId == NULL || [self.userId isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"id"]]) {
        
        NSLog(@"Current User");
    }
    else {
        [self callFollowingApi];
    }
    
    [self gettingApiData];
//    if (isComment==YES || self.userId != NULL) {
//        [self gettingApiData];
//        isComment = NO;
//    }
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

- (void)gettingApiData {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self profileApiCall:^(BOOL result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSString *username;
        if ([[mutDictProfileInfo objectForKey:@"display_name"] length]>0) {
            username = [mutDictProfileInfo objectForKey:@"display_name"];
        } else {
            username = [mutDictProfileInfo objectForKey:@"username"];
        }
        NSString *followers = [mutDictProfileInfo objectForKey:@"followers"];
        NSString *following = [mutDictProfileInfo objectForKey:@"following"];
        NSString *post = [mutDictProfileInfo objectForKey:@"posts"];
        NSString *aboutme = [mutDictProfileInfo objectForKey:@"about_me"];
        NSString *totallikes = [mutDictProfileInfo objectForKey:@"user_images_likes"];
        lblLIkes.text = totallikes;
        lblProfileName.text = username;
        lblFollower.text = followers;
        Following.text = following;
        lblPost.text = post;
        lblAboutMe.text = [mutDictProfileInfo objectForKey:@"bio"];
        lblAboutMe.lineBreakMode = NSLineBreakByWordWrapping;
        [lblAboutMe setNumberOfLines:0];
        [lblWebsite setTitle:[mutDictProfileInfo objectForKey:@"setting_website"] forState:UIControlStateNormal];
        privateProfile = [mutDictProfileInfo objectForKey:@"isPrivate"];
        if ([privateProfile isEqualToString:@"1"] && (isMyProfile==NO && ![followingArray containsObject:self.userId])) {
            [privateProfileImageView setHidden:NO];
            [tblview setScrollEnabled:NO];
            hederview.frame = CGRectMake(hederview.bounds.origin.x, hederview.bounds.origin.y, hederview.bounds.size.width, 500);
            tblview.tableHeaderView = hederview;
        }
        else {
            [privateProfileImageView setHidden:YES];
            [tblview setScrollEnabled:YES];
            hederview.frame = CGRectMake(hederview.bounds.origin.x, hederview.bounds.origin.y, hederview.bounds.size.width, 312);
            tblview.tableHeaderView = hederview;
        }
        
        [lblAboutMe setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0f]];
        mutArrayProfileImages = nil;
        mutArrayProfileImages = [[mutDictProfileInfo objectForKey:@"user_timeline"] mutableCopy] ;
        
        NSArray* reversedArray = [[mutArrayProfileImages reverseObjectEnumerator] allObjects];
        
        mutArrayProfileImages = [NSMutableArray arrayWithArray:reversedArray];
        
        
        
        for(int i = 0 ; i < [mutArrayProfileImages count] ; i++){
            bCmtExpand[i] = NO;
            bBackViewExpand[i] = 1;
        }
        
        [btntable setSelected:YES];
        [btnCollection setSelected:NO];
        [tblview reloadData];
//        if ([[[mutDictProfileInfo objectForKey:@"follow_id"] description] isEqual:@"0"] && [[[mutDictProfileInfo objectForKey:@"isPrivate"] description] isEqual:@"0"]) {
//            [followButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//        }
//        else if (([[[mutDictProfileInfo objectForKey:@"follow_id"] description] isEqual:@"1"] && [[[mutDictProfileInfo objectForKey:@"isPrivate"] description] isEqual:@"0"]) || ([[[mutDictProfileInfo objectForKey:@"follow_id"] description] isEqual:@"0"] && [[[mutDictProfileInfo objectForKey:@"isPrivate"] description] isEqual:@"1"])) {
//            [followButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//        }
    }];
}

- (void)callFollowingApi {
    [self FollowUnfollowApiCall:^(BOOL result) {
        if ([followingArray containsObject:self.userId]) {
            [btnFollowRequest setTag:2];
            [btnFollowRequest setImage:[UIImage imageNamed:@"notificationAccept"] forState:UIControlStateNormal];
        }
        else if ([followingPendingArray containsObject:self.userId]) {
            [btnFollowRequest setTag:1];
            [btnFollowRequest setImage:[UIImage imageNamed:@"notificationPending"] forState:UIControlStateNormal];
        }
        else {
            [btnFollowRequest setTag:0];
            [btnFollowRequest setImage:[UIImage imageNamed:@"notificationRequest"] forState:UIControlStateNormal];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

-(void)updatesView {
    
    [tblview reloadData];
}

-(void)collectionTypeViewMethod
{
    [self HidePhotoView];
    picMutArray=Nil;
    picMutArray=[[NSMutableArray alloc]init];
    for (int i=0; i<[mutArrayProfileImages count]; i++) {
        
        NSString *userID=[[mutArrayProfileImages objectAtIndex:i] objectForKey:@"user_id"] ;
        NSString *astrImageid=[[mutArrayProfileImages  objectAtIndex:i] objectForKey:@"image_id"];
        NSString *imageLink=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",userID, astrImageid ];
        NSURL *imageURL=[NSURL URLWithString:imageLink];
        [picMutArray addObject:imageURL];
    }
    NSLog(@"%@",picMutArray);
    [tblview reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([btnCollection isSelected]){
        return 1;
    }
    else if ([privateProfile isEqualToString:@"1"] && (isMyProfile==NO && ![followingArray containsObject:self.userId])) {
        return 0;
    }
    else{
        return [mutArrayProfileImages count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([btnCollection isSelected]) {
        return 0;
    }
    else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([btnCollection isSelected]) {
        return NULL;
    }
    else {
        //tableView.sectionHeaderHeight=90;
        UIView *aViewSection = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320,60)];
        aViewSection.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"profilepicbackground.png"]];
        NSString *astr = [[mutArrayProfileImages objectAtIndex:section] objectForKey:@"user_id"];
        NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg", astr ];
        NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
        AsyncImageView *aImageViewInSectionView=[[AsyncImageView alloc]initWithFrame:CGRectMake(10,10, 35 , 35)];
        aImageViewInSectionView.layer.cornerRadius = aImageViewInSectionView.frame.size.width/2;
        aImageViewInSectionView.layer.masksToBounds = YES;
        [aImageViewInSectionView setImageURL:aimageurl];

        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(53.0, 16, 200, 20)];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        headerLabel.font = [UIFont boldSystemFontOfSize:13];
        headerLabel.textColor=[UIColor blackColor];
        headerLabel.text=[[mutArrayProfileImages objectAtIndex:section] objectForKey:@"display_name"];
    
        UIImageView *aImageViewClock=[[UIImageView alloc]initWithFrame:CGRectMake(273,18, 15 , 15)];
        aImageViewClock.image=[UIImage imageNamed:@"clockicon"];
        UILabel *clockLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 18, 30, 15)];
        [clockLabel setBackgroundColor:[UIColor clearColor]];
        clockLabel.font = [UIFont systemFontOfSize:11];
        clockLabel.textColor = [UIColor grayColor];
        clockLabel.text=[[mutArrayProfileImages objectAtIndex:section] objectForKey:@"upload_dt"];
        
        UIImageView *aImageViewPhoto;
        if ([[[mutArrayProfileImages objectAtIndex:section] objectForKey:@"post_type"]isEqualToString:@"p"]) {
            aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(234,19, 29 , 13)];
            aImageViewPhoto.image=[UIImage imageNamed:@"PanoramicIcon"];
        }
        else if ([[[mutArrayProfileImages objectAtIndex:section]objectForKey:@"post_type"]isEqualToString:@"v"]) {
            aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(242,19, 21 , 13)];
            aImageViewPhoto.image=[UIImage imageNamed:@"VideoIcon"];
        }
        else {
            aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(249,19, 14 , 13)];
            aImageViewPhoto.image=[UIImage imageNamed:@"PhotoIcon"];
        }
        
        [aViewSection addSubview:aImageViewClock];
        [aViewSection addSubview:aImageViewPhoto];
        [aViewSection addSubview:headerLabel];
        [aViewSection addSubview:aImageViewInSectionView];
        [aViewSection addSubview:clockLabel];
        return aViewSection;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([btnCollection isSelected]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collectioncell"];
        float x = 5.0;
        float y = 5.0;
        float width = (self.view.frame.size.width-4*5)/3;
        float height = width*4/3;
        for (int i = 0 ; i < [picMutArray count] ; i++) {
            AsyncImageView *imageview = [[AsyncImageView alloc]initWithFrame:CGRectMake(x, y,width,height)];
            if ([[[mutArrayProfileImages objectAtIndex:i] objectForKey:@"post_type"]isEqualToString:@"p"]) {
                imageview.FeedType = 1;
                imageview.bNormalShow = NO;
            }else if ([[[mutArrayProfileImages objectAtIndex:i] objectForKey:@"post_type"]isEqualToString:@"v"]){
                imageview.FeedType = 2;
                imageview.bNormalShow = NO;
            }else{
                imageview.FeedType = 3;
                imageview.bNormalShow = NO;
            }
            
            [imageview setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
            [cell.contentView addSubview:imageview];
            imageview.tag = i;
            NSURL *imageURL = [picMutArray objectAtIndex:i];
            [imageview setImageURL:imageURL];
            x = x+imageview.frame.size.width+5;
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
            [imageview addGestureRecognizer:tapGestureRecognizer];
            imageview.userInteractionEnabled = YES;
            if(x >= (float)self.view.frame.size.width-10)
            {
                y = y+height+5;
                x = 5.0;
            }
        }
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        for (UIView *view in cell.contentView.subviews) {
            // if (view.tag!=10 && view.tag!=1) {
            [view removeFromSuperview];
            //}
        }
        
        UIView *aViewSection = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320,50)];
        [aViewSection setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
        
        NSString *astr = [[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"user_id"];
        NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg", astr];
        NSLog(@"aStrDisplyimage = %@",aStrDisplyimage);
        NSURL *aimageurl = [NSURL URLWithString:aStrDisplyimage];
        
        UIImageView *aImageViewInSectionView=[[UIImageView alloc]initWithFrame:CGRectMake(10,10, 35 , 35)];
        aImageViewInSectionView.layer.cornerRadius = aImageViewInSectionView.frame.size.width/2;
        aImageViewInSectionView.layer.masksToBounds = YES;
        [self downloadImageWithURL:[NSURL URLWithString:aStrDisplyimage] completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                [aImageViewInSectionView setImage:image];
            }
        }];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(53.0, 16, 200, 20)];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        headerLabel.font = [UIFont boldSystemFontOfSize:13];
        headerLabel.textColor=[UIColor whiteColor];
        headerLabel.text=[[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"display_name"];
        
        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn addTarget:self action:@selector(pushImageDescription:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTag:indexPath.section+1];
        [aViewSection addSubview:btn];
        
        UIImageView *aImageViewClock=[[UIImageView alloc]initWithFrame:CGRectMake(273,18, 15 , 15)];
        aImageViewClock.image=[UIImage imageNamed:@"clockicon"];
        UILabel *clockLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 18, 30, 15)];
        [clockLabel setBackgroundColor:[UIColor clearColor]];
        clockLabel.font = [UIFont systemFontOfSize:11];
        clockLabel.textColor=[UIColor whiteColor];
        clockLabel.text=[[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"upload_dt"];
        
        UIImageView *aImageViewPhoto;
        if ([[[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"post_type"]isEqualToString:@"p"]) {
            aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(234,19, 29 , 13)];
            aImageViewPhoto.image=[UIImage imageNamed:@"PanoramicIcon"];
        }
        else if ([[[mutArrayProfileImages objectAtIndex:indexPath.section]objectForKey:@"post_type"]isEqualToString:@"v"]) {
            aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(242,19, 21 , 13)];
            aImageViewPhoto.image=[UIImage imageNamed:@"VideoIcon"];
        }
        else {
            aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(249,19, 14 , 13)];
            aImageViewPhoto.image=[UIImage imageNamed:@"PhotoIcon"];
        }
        
        [aViewSection addSubview:aImageViewClock];
        [aViewSection addSubview:aImageViewPhoto];
        [aViewSection addSubview:headerLabel];
        [aViewSection addSubview:aImageViewInSectionView];
        [aViewSection addSubview:clockLabel];

        //[[cell viewWithTag:10]removeFromSuperview];
        float totalSize = 0.0;
        AsyncImageView *imageIcon = [[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 450)];
        [imageIcon setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
        imageIcon.layer.cornerRadius = 0;
        imageIcon.layer.masksToBounds = YES;
        [cell.contentView addSubview:imageIcon];
        [imageIcon setTag:10];
        NSString *astrUserid = [[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"user_id"];
        NSString *astrImageid = [[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"image_id"];
        aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, astrImageid];
        aimageurl = [NSURL URLWithString:aStrDisplyimage];
    
        if ([[[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"post_type"]isEqualToString:@"p"]) {
            AsyncImageView *pano=[[AsyncImageView alloc]init];
            [pano setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];//[UIColor clearColor]];
            pano.FeedType = 1;
            pano.bNormalShow = YES;
            
            UIScrollView *scroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,320,450)];
            [pano setFrame:CGRectMake(0, 0, pano.image.size.width, scroll.frame.size.height)];
            
            UITapGestureRecognizer *panoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panoProfileGestureClicked:)];
            panoGesture.numberOfTapsRequired=1;
            [scroll addGestureRecognizer:panoGesture];
            [scroll setTag:indexPath.section];
            
            [cell.contentView addSubview:scroll];
            [scroll setBounces:NO];
            [scroll addSubview:pano];
            [scroll setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
            pano.tempscroll = scroll;
            [pano setImageURL:aimageurl];
            totalSize = totalSize+scroll.frame.size.height+3;
            [imageIcon setHidden:YES];
        }
        else if ([[[mutArrayProfileImages objectAtIndex:indexPath.section]objectForKey:@"post_type"]isEqualToString:@"v"])
        {
            imageIcon=Nil;
            [[cell viewWithTag:8] removeFromSuperview];
            AsyncImageView *aImage = [[AsyncImageView alloc]initWithFrame:CGRectMake(0 ,0,320,450)];
            aImage.FeedType = 2;
            aImage.bNormalShow = YES;
            [aImage setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
            [aImage setImageURL:aimageurl];
            [cell.contentView addSubview:aImage];
            UIImageView *videoImage = [[UIImageView alloc]initWithFrame:CGRectMake(110 , 80,100, 100)];
            videoImage.image = [UIImage imageNamed:@"video.png"];
            [cell.contentView addSubview:videoImage];
            totalSize=totalSize+aImage.frame.size.height+3;
        }
        
        else{
            imageIcon.FeedType = 3;
            imageIcon.bNormalShow = YES;
            [imageIcon setImageURL:aimageurl];
            totalSize=totalSize+imageIcon.frame.size.height+3;
            [imageIcon setHidden:NO];
        }
        totalSize -= 97;
        
    if(bBackViewExpand[indexPath.section] != 2){
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
        [backView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
        [cell.contentView addSubview:backView];
        
        int backViewheight = 5;
        
    UILabel *likes = [[UILabel alloc]init];
    [likes setTag:8];
    [backView addSubview:likes];
    [likes setTextColor:[UIColor whiteColor]];
    [likes setFont:[UIFont boldSystemFontOfSize:13.0]];
    
    NSMutableArray *likearry=[[NSMutableArray alloc]init];
    likearry = [[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"likes"];
    NSMutableString* mutString = [[NSMutableString alloc] init];
    int k = 0;
    for (int i = 1 ; i <= [likearry count]; i++) {
        if (i == [likearry count]) {
            [mutString appendString:[NSString stringWithFormat:@"%@",[[likearry objectAtIndex:k] objectForKey:@"display_name"]]];
        }else{
            [mutString appendString:[NSString stringWithFormat:@"%@, ",[[likearry objectAtIndex:k] objectForKey:@"display_name"]]];
        }
        k++;
    }
    
    likes.text = mutString;
    
    CGSize Likesize = CGSizeMake(290,999);
    CGSize textRect =[likes.text boundingRectWithSize: Likesize options: NSStringDrawingUsesLineFragmentOrigin
                                           attributes: @{NSFontAttributeName:likes.font} context: nil].size ;
    [likes setFrame:CGRectMake(28,backViewheight,textRect.width, textRect.height)];
    likes.numberOfLines=0;
    likes.lineBreakMode = NSLineBreakByWordWrapping;
    
    UIButton *btnlikeStatic=[[UIButton alloc]init];
    [btnlikeStatic setFrame:CGRectMake(9 ,backViewheight, 13, 13)];
    [btnlikeStatic setImage:[UIImage imageNamed:@"likeicon.png"] forState:UIControlStateNormal];
    [btnlikeStatic setTag:5];
    [backView addSubview:btnlikeStatic];
    backViewheight=backViewheight+likes.frame.size.height;
    NSLog(@"%@",mutString);
    
    [[cell viewWithTag:555] removeFromSuperview];
    
    UILabel *profilename = [[UILabel alloc]init];
    profilename.numberOfLines = 0;
    profilename.lineBreakMode = NSLineBreakByWordWrapping;
        profilename.userInteractionEnabled = YES;
        
    NSString *stringprofileName = [[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"display_name"];
    int aprofileNametCount = [stringprofileName length];
    NSString *stringCaption = [[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"caption"];
    int aCaptionCount = [stringCaption length];
    
    NSMutableString *aAllActivity = [NSMutableString stringWithFormat:@"%@ %@",stringprofileName,stringCaption];
    NSMutableAttributedString *aAtributedCaptionStr = [[NSMutableAttributedString alloc]initWithString:aAllActivity];
    [aAtributedCaptionStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:NSMakeRange(0, aprofileNametCount)];
    [aAtributedCaptionStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(aprofileNametCount+1, aCaptionCount)];
    [aAtributedCaptionStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]range:NSMakeRange(0, aprofileNametCount)];
            [aAtributedCaptionStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]range:NSMakeRange(aprofileNametCount+1, aCaptionCount)];
    NSMutableArray *hashtags = [self getHashUsernameRange:aAllActivity];
    for(int l = 0 ; l < [hashtags count] ; l++){
        NSRange range = NSRangeFromString([hashtags objectAtIndex:l]);
        [aAtributedCaptionStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:39.0f/256.0f green:199.0f/256.0f blue:246.0f/256.0f alpha:1.0f] range:range];
    }
        
    [profilename setAttributedText:aAtributedCaptionStr];
    
    [profilename setTag:555];
    
        MyTapGestureRecognizer *tapGestureRecognizer4 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(CommentLabelClicked:)];
        profilename.userInteractionEnabled = YES;
        tapGestureRecognizer4.eventLabel = profilename;
        [profilename addGestureRecognizer:tapGestureRecognizer4];
        
    CGSize profilsize = CGSizeMake(290,999);
    CGSize profiletextRect =[profilename.text boundingRectWithSize: profilsize options: NSStringDrawingUsesLineFragmentOrigin
                                                        attributes: @{NSFontAttributeName:profilename.font} context: nil].size ;
    
    [profilename setFrame:CGRectMake(28,backViewheight, profiletextRect.width+10, profiletextRect.height+11)];
    [backView addSubview:profilename];
        
        UIButton *btn = [[UIButton alloc] init];
        CGSize usernameRect1 =[stringprofileName boundingRectWithSize: profilsize options: NSStringDrawingUsesLineFragmentOrigin
                                                           attributes: @{NSFontAttributeName:profilename.font} context: nil].size ;
        [btn setFrame:CGRectMake(profilename.frame.origin.x, backViewheight, usernameRect1.width, usernameRect1.height+10)];
        [btn setBackgroundColor:[UIColor clearColor]];
        MyTapGestureRecognizer *tapGestureRecognizer1 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoProfilePage:)];
        tapGestureRecognizer1.userid = [[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"user_id"];
        [btn addGestureRecognizer:tapGestureRecognizer1];
        [backView addSubview:btn];
        
    backViewheight=backViewheight+profiletextRect.height+3;
    
    UIButton *btnCommentStatic=[[UIButton alloc]init];
    [btnCommentStatic setFrame:CGRectMake(9 ,profilename.frame.origin.y+8, 13, 13)];
    [btnCommentStatic setImage:[UIImage imageNamed:@"commenticon.png"] forState:UIControlStateNormal];
    [btnCommentStatic setTag:2];
    [btnCommentStatic setTitle:[NSString stringWithFormat:@"%d", indexPath.section] forState:UIControlStateNormal];
    [btnCommentStatic setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    //[btnCommentStatic addTarget:self action:@selector(CommentExpand:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:btnCommentStatic];

    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    int scrollheight = 0;
    //if(bCmtExpand[indexPath.section]){
        backViewheight += 5;
        NSMutableArray *mutComment=[[NSMutableArray alloc]init];
        mutComment=[[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"comments"];
        NSLog(@"%@",mutComment);
    
        if ([mutComment count]==0) {
            for (int i=0; i<=20; i++) {
                [[cell viewWithTag:100+i] removeFromSuperview];
                [[cell viewWithTag:200+i] removeFromSuperview];
            }
        }
        
        for (int i=1; i<=5; i++)
        {
            [[cell viewWithTag:100+i] removeFromSuperview];
            [[cell viewWithTag:200+i] removeFromSuperview];
        }
    
        int totalcount = [mutComment count];
        //if(bBackViewExpand[indexPath.section] == 3 && totalcount <= 5){
        //    bBackViewExpand[indexPath.section] = 1;
        //}
        int j;
        j = totalcount-1;
        if(totalcount > 3 && bBackViewExpand[indexPath.section] == 1) {
            j = 3-1;
            totalcount = 3;
        }
        for (int i=1; i<=totalcount; i++) {

            UILabel *aUserNamecomment = [[UILabel alloc]init];
            aUserNamecomment.lineBreakMode = NSLineBreakByWordWrapping;
            aUserNamecomment.numberOfLines = 0;
            aUserNamecomment.textColor=[UIColor whiteColor];
            
            NSString *stringName = [[mutComment objectAtIndex:j]objectForKey:@"display_name"];
            int aUserCount = [stringName length];
            NSString *stringComment = [[mutComment objectAtIndex:j]objectForKey:@"user_comment"];
            int aActivity=[stringComment length];
            
            NSMutableString *aAllActivity;
            NSMutableAttributedString *aAtributedStr;
            aAllActivity=[NSMutableString stringWithFormat:@"%@ %@",stringName,stringComment];
            if(aAllActivity.length > 88){
                aAllActivity=[NSMutableString stringWithFormat:@"%@ ...",[aAllActivity substringToIndex:84]];
                aActivity = aAllActivity.length-aUserCount-1;
            }
            if (i<totalcount) {
                aAtributedStr=[[NSMutableAttributedString alloc]initWithString:aAllActivity];
                [aAtributedStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:NSMakeRange(0, aUserCount)];
                [aAtributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(aUserCount+1, aActivity)];
            }
            else {
                aAtributedStr=[[NSMutableAttributedString alloc]initWithString:aAllActivity];
                [aAtributedStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:NSMakeRange(0, aUserCount)];
                [aAtributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(aUserCount+1, aActivity)];
            }
            if ((bBackViewExpand[indexPath.section] != 4 && i==3) && [mutComment count]>3) {
                [aAtributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n....."]];
            }
            
            hashtags = [self getHashUsernameRange:aAllActivity];
            for(int l = 0 ; l < [hashtags count] ; l++){
                NSRange range = NSRangeFromString([hashtags objectAtIndex:l]);
                [aAtributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:39.0f/256.0f green:199.0f/256.0f blue:246.0f/256.0f alpha:1.0f] range:range];
            }
            
            [aUserNamecomment setAttributedText:aAtributedStr];
            float twolineheight = aUserNamecomment.font.lineHeight*2.2;
            CGSize usernamesize = CGSizeMake(250,twolineheight);
            CGSize usernameRect =[aUserNamecomment.text boundingRectWithSize: usernamesize options: NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:aUserNamecomment.font} context: nil].size ;
            [aUserNamecomment setFrame :CGRectMake(28, scrollheight,usernameRect.width+10 , usernameRect.height+10)];
            [aUserNamecomment setTag:100+i];
            
            
            MyTapGestureRecognizer *tapGestureRecognizer = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(CommentLabelClicked:)];
            aUserNamecomment.userInteractionEnabled = YES;
            tapGestureRecognizer.eventLabel = aUserNamecomment;
            [aUserNamecomment addGestureRecognizer:tapGestureRecognizer];
            [scrollview addSubview:aUserNamecomment];
            
            UIButton *btn1 = [[UIButton alloc] init];
            CGSize usernameRect1 =[stringName boundingRectWithSize: profilsize options: NSStringDrawingUsesLineFragmentOrigin
                                                        attributes: @{NSFontAttributeName:aUserNamecomment.font} context: nil].size ;
            [btn1 setFrame:CGRectMake(aUserNamecomment.frame.origin.x, aUserNamecomment.frame.origin.y, usernameRect1.width, usernameRect1.height+10)];
            [btn1 setBackgroundColor:[UIColor clearColor]];
            MyTapGestureRecognizer *tapGestureRecognizer2 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoProfilePage:)];
            tapGestureRecognizer2.userid = [[mutComment objectAtIndex:j]objectForKey:@"user_id"];
            [btn1 addGestureRecognizer:tapGestureRecognizer2];
            [scrollview addSubview:btn1];
            j--;
            scrollheight=scrollheight+usernameRect.height+3;
        }
        [backView addSubview:scrollview];
        if(scrollheight > 0){
            scrollheight += 5;
            int offset = 0;
            if(backViewheight+scrollheight > 328){
                offset = backViewheight+scrollheight-328;
            }
            scrollview.frame = CGRectMake(0, backViewheight, 280, scrollheight-offset);
            scrollview.contentSize = CGSizeMake(0, scrollheight);
            backViewheight += scrollheight-offset;
        }else{
            backViewheight -= 5;
        }
    //}
    [[cell viewWithTag:19] removeFromSuperview];
    [[cell viewWithTag:600] removeFromSuperview];
    [[cell viewWithTag:300] removeFromSuperview];
    
    UIButton *btnlike=[[UIButton alloc]initWithFrame:CGRectMake(10, backViewheight+15, 55, 25)];
    [backView addSubview:btnlike];
    [btnlike setTag:19];
    
    if ([btnlike isSelected]) {
        [btnlike setBackgroundImage:[UIImage imageNamed:@"likeinwhite.png"] forState:UIControlStateNormal];
        [btnlike setSelected:NO];
    }
    else{
        [btnlike setBackgroundImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        [btnlike setSelected:YES];
    }
    if ([[[[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"user_liked"] description]isEqualToString:@"1"]) {
        [btnlike setBackgroundImage:[UIImage imageNamed:@"likeinwhite.png"] forState:UIControlStateSelected];
        [btnlike setSelected:YES];
    }
    [btnlike addTarget:self action:@selector(likebtn:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buzzButton = [[UIButton alloc]initWithFrame:CGRectMake(70, btnlike.frame.origin.y, 87, 25)];
    [buzzButton setTag:300];
    [buzzButton setImage:[UIImage imageNamed:@"comment.png" ] forState:UIControlStateNormal];
    //[btnShare setFrame:CGRectMake(90, totalSize, 65, 25)];
    [buzzButton addTarget:self action:@selector(buzzAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:buzzButton];
    
    UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(240, btnlike.frame.origin.y, 55, 20)];
    [btnShare setTag:600];
    [btnShare setImage:[UIImage imageNamed:@"threedot.png"] forState:UIControlStateNormal];
    //[btnShare setFrame:CGRectMake(235, totalSize, 65, 21)];
   [btnShare addTarget:self action:@selector(shareImage:) forControlEvents:UIControlEventTouchUpInside];
    backViewheight=backViewheight+btnlike.frame.size.height;
    [backView addSubview:btnShare];
        backView.userInteractionEnabled = NO;
    [cell.contentView addSubview:aViewSection];
        
            UIButton *btnBackViewExpand = [[UIButton alloc]init];
            if([mutComment count] > 5 && bBackViewExpand[indexPath.section] == 1){
                [btnBackViewExpand setImage:[UIImage imageNamed:@"UpArrow.png"] forState:UIControlStateNormal];
            }else{
                [btnBackViewExpand setImage:[UIImage imageNamed:@"DownArrow.png"] forState:UIControlStateNormal];
                bBackViewExpand[indexPath.section] = 3;
            }
            [btnBackViewExpand setTitle:[NSString stringWithFormat:@"%d", indexPath.section] forState:UIControlStateNormal];
            [btnBackViewExpand setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btnBackViewExpand addTarget:self action:@selector(BackViewExpand:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:btnBackViewExpand];
            
        backViewheight = backViewheight+25;
        if(backViewheight > 428)
            backViewheight = 428;
        backView.frame = CGRectMake(0, 450-backViewheight, 320,  backViewheight);
        aViewSection.frame = CGRectMake(0,450-backViewheight-50,320,50);
            btnBackViewExpand.frame = CGRectMake(0,450-backViewheight-50-22,320,22);
        }else{
            UIButton *btnBackViewExpand = [[UIButton alloc]init];
            [btnBackViewExpand setImage:[UIImage imageNamed:@"UpArrow.png"] forState:UIControlStateNormal];
            [btnBackViewExpand setTitle:[NSString stringWithFormat:@"%d", indexPath.section] forState:UIControlStateNormal];
            [btnBackViewExpand setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btnBackViewExpand addTarget:self action:@selector(BackViewExpand:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:btnBackViewExpand];
            btnBackViewExpand.frame = CGRectMake(0,428,320,22);
        }
    return cell;
    }
}

- (IBAction)pushImageDescription:(id)sender {
    [self HidePhotoView];
    //    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:tableViewObj];
    //    NSIndexPath *hitIndex = [tableViewObj indexPathForRowAtPoint:hitPoint];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:[[sender superview] tag]];
    NSLog(@"%ld",(long)indexPath.row);
    NSString *str=[[mutArrayProfileImages objectAtIndex:indexPath.row-1] objectForKey:@"user_id"];
    
    UIStoryboard *storyboard = self.navigationController.storyboard;
    ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
    fllowerPrfile.userId=str;
    [self.navigationController pushViewController:fllowerPrfile animated:YES];
    [self showTabBar:self.tabBarController];
    hidden = NO;
}

- (IBAction)CommentExpand:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    int index = [btn.titleLabel.text intValue];
    bCmtExpand[index] = !bCmtExpand[index];
    [tblview reloadData];
}

- (IBAction)BackViewExpand:(id)sender
{
    [self HidePhotoView];
    UIButton *btn = (UIButton*)sender;
    int index = [btn.titleLabel.text intValue];
    bBackViewExpand[index]--;
    if(bBackViewExpand[index] == 0)
        bBackViewExpand[index] = 4;
    [tblview reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self HidePhotoView];
    UITableViewCell *tvCell = (UITableViewCell *)[tblview cellForRowAtIndexPath:indexPath];
    
    if ([[[mutArrayProfileImages objectAtIndex:indexPath.section]objectForKey:@"post_type"]isEqualToString:@"v"]) {
        NSString *astrUserid = [[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"user_id"];
        NSString *astrImageid = [[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"image_id"];
        NSString *astrExt = [[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"ext"];
        NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/vids/user/%@-%@.%@",astrUserid, astrImageid ,astrExt];
        NSURL *avideourl = [NSURL URLWithString:aStrDisplyimage];
        
        self.player = [[MPMoviePlayerController alloc] initWithContentURL:avideourl];
        [self.player.view setHidden:YES];
        self.player.controlStyle=MPMovieControlStyleNone;
        [self.player setScalingMode:MPMovieScalingModeAspectFill];
        [self.player.view setFrame:CGRectMake(0, 0,320, 450)];
        
        //[self.player setContentURL:avideourl];
        [self.player prepareToPlay];
        [self.player play];
        
        [self.player.view setHidden:NO];
        [tvCell.contentView addSubview:self.player.view];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(playbackEnded:)
         name:MPMoviePlayerPlaybackDidFinishNotification
         object:self.player];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayerPlayState:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playbackEnded:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
    }
    else {
        UIStoryboard *storyboard = self.navigationController.storyboard;
        PhotoDescriptionViewController *detailPage = [storyboard instantiateViewControllerWithIdentifier:@"photoDescriptin"];
        detailPage.strImageid=[[mutArrayProfileImages objectAtIndex:indexPath.section] objectForKey:@"image_id"] ;
        detailPage.strUserid=[[mutArrayProfileImages objectAtIndex:indexPath.section]objectForKey:@"user_id" ];
        //set the product
        
        //Push to detail View
        [self.navigationController pushViewController:detailPage animated:YES];
    }
}

- (void)panoProfileGestureClicked:(UIGestureRecognizer*)sender {
    
    [self hideTabBar:self.tabBarController];
    
    UIScrollView *scroll = (UIScrollView *)[sender view];
    int sectionId = [scroll tag];
    NSString *astrUserid = [[mutArrayProfileImages objectAtIndex:sectionId] objectForKey:@"user_id"];
    NSString *astrImageid = [[mutArrayProfileImages objectAtIndex:sectionId] objectForKey:@"image_id"];
    NSString *aStrDisplyimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, astrImageid];
    NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
    
    __block UIImageView *pano=[[UIImageView alloc]init];
    [pano setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
    UIScrollView *landscapeScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,320,548)];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] init];
    activityView.center = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height / 2.0f);
    [activityView startAnimating];
    [pano addSubview:activityView];
    
    NSURLRequest *contentRequest = [NSURLRequest requestWithURL:aimageurl];
    [pano setImageWithURLRequest:contentRequest
                placeholderImage:nil
     
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                             pano.transform = CGAffineTransformMakeRotation(M_PI_2);
                             [landscapeScroll setContentSize:CGSizeMake(320, image.size.width*320/image.size.height)];
                             [pano setFrame:CGRectMake(0, 0, 320,image.size.width*320/image.size.height)];
                             pano.image = image;
                             [activityView stopAnimating];
                             [activityView hidesWhenStopped];
                         } failure:nil];
    
    [landscapeScroll addSubview:pano];
    
    UITapGestureRecognizer *panoDismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panoProfileDismissGestureClicked:)];
    panoDismissGesture.numberOfTapsRequired=1;
    [landscapeScroll addGestureRecognizer:panoDismissGesture];
    
    [landscapeView addSubview:landscapeScroll];
    [landscapeScroll setBounces:NO];
    [landscapeScroll setScrollEnabled:YES];
    [landscapeScroll setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
    [self.view addSubview:landscapeView];
    NSLog(@"Pano Clicked");
}

- (void)panoProfileDismissGestureClicked:(UIGestureRecognizer*)sender {
    [landscapeView removeFromSuperview];
    [self showTabBar:self.tabBarController];
}

- (void)playbackEnded:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MPMoviePlayerPlaybackDidFinishNotification" object:nil];
    
    [self.player stop];
    //self.player=Nil;
    [self.player.view removeFromSuperview];
}

- (void)moviePlayerPlayState:(NSNotification *)noti {
    
    if (noti.object == self.player) {
        
        MPMoviePlaybackState reason = self.player.playbackState;
        
        if (reason==MPMoviePlaybackStatePlaying) {
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name: MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                while (self.player.view.hidden)
                {
                    NSLog(@"not ready");
                    if (self.player.readyForDisplay) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            NSLog(@"show");
                            self.player.view.hidden=NO;
                        });
                        
                    }
                    usleep(50);
                }
            });
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([btnCollection isSelected]) {
        int count = [picMutArray count];
        float width = (self.view.frame.size.width-4*5)/3;
        float height = width*4/3;
        int rows = count / 3;
        if(rows*3 < count)
            rows++;
        return 5 + rows*(height+5);
    }
    else{
        return 450;
    }
    
}

-(IBAction)buzzAction:(id)sender{
    [self HidePhotoView];
    isComment = YES;
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:tblview];
    NSIndexPath *hitIndex = [tblview indexPathForRowAtPoint:hitPoint];
    NSLog(@"%ld",(long)hitIndex.section);
    CommntViewController *buzz = [self.storyboard instantiateViewControllerWithIdentifier:@"comment"];
    buzz.strimageid=[[mutArrayProfileImages objectAtIndex:hitIndex.section]objectForKey:@"image_id"];
    buzz.strUserid=[[mutArrayProfileImages objectAtIndex:hitIndex.section]objectForKey:@"user_id"];
    [self.navigationController pushViewController:buzz animated:YES];
}

#pragma mark: ShareimageAction

-(IBAction)shareImage:(id)sender{
    [self HidePhotoView];
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:tblview];
    NSIndexPath *ahitIndex = [tblview indexPathForRowAtPoint:hitPoint];
    indexpath=ahitIndex.section;
    NSLog(@"%ld",(long)ahitIndex.section);
    NSString *astrUserid=[[mutArrayProfileImages objectAtIndex:indexpath] objectForKey:@"user_id"];
    NSString *imageid =[[mutArrayProfileImages objectAtIndex:indexpath]objectForKey:@"image_id"];
    deleteImageId=imageid;
    [actionShare showInView:self.view];
    NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, imageid ];
    NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
    shareimage=[UIImage imageWithData:[NSData dataWithContentsOfURL:aimageurl]];
    
    if ([[[[mutArrayProfileImages objectAtIndex:ahitIndex.section]objectForKey:@"user_id"] description]isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"]]) {
        // [actionSheetCurrentUser showInView:self.view];
    }
    else
    {
        //[actionSheetOtherUser showInView:self.view];
    }
    [actionShare showInView:self.view];
}

-(IBAction)likebtn:(id)sender{
    [self HidePhotoView];
    UIButton *btnTemp = (UIButton *)sender;
    if([btnTemp isSelected])
    {
        [btnTemp setBackgroundImage:[UIImage imageNamed:@"likeinwhite.png"] forState:UIControlStateNormal];
        [btnTemp setSelected:NO];
    }
    else
    {
        [btnTemp setBackgroundImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        [btnTemp setSelected:YES];
    }

    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:tblview];
    NSIndexPath *hitIndex = [tblview indexPathForRowAtPoint:hitPoint];
    NSLog(@"%ld",(long)hitIndex.section);
    NSString *aStrLike=[[mutArrayProfileImages objectAtIndex:hitIndex.section] objectForKey:@"image_id"];
    
    [self LikeApicall:(NSString *)aStrLike completionBlock:^(BOOL result) {
        [self gettingApiData];
        //[self viewWillAppear:NO];
    }];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    if (isCoverPhoto==YES) {
        
//        SSPhotoCropperViewController *photoCropper =
//        [[SSPhotoCropperViewController alloc] initWithPhoto:image
//                                                   delegate:self
//                                                     uiMode:SSPCUIModePresentedAsModalViewController
//                                            showsInfoButton:YES];
//        [photoCropper setMinZoomScale:0.75f];
//        [photoCropper setMaxZoomScale:1.50f];
//        [self.navigationController pushViewController:photoCropper animated:YES];
        
        
        //UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:photoCropper];
        //[self presentModalViewController:nc animated:YES];
        UIImage* image1 = [image fixOrientation];
        NSData *img = UIImageJPEGRepresentation(image1, 0.3f);
        NSString *imagestring = [Base64 encode:img];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self updatecoverpicApi:imagestring completionBlock:^(BOOL result) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(result){
            NSString *aStrDisplyCoverimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@",coverString];
            //[self downloadImageWithURL:[NSURL URLWithString:aStrDisplyCoverimage] completionBlock:^(BOOL succeeded, UIImage *image) {
            //    if (succeeded) {
                    [coverpageImage setImage:image];
            //    }
            //}];
            }
        }];
    }
    else {
        //userImageview.image = image;
        UIImage* image1 = [image fixOrientation];
        NSData *img=UIImageJPEGRepresentation(image1, 0.3f);
        NSString *imagestring=[Base64 encode:img];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [self updateprofilepicApi:imagestring completionBlock:^(BOOL result) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(result){
            //NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg", [[NSUserDefaults standardUserDefaults]objectForKey:@"id" ]];
            //[self downloadImageWithURL:[NSURL URLWithString:aStrDisplyimage] completionBlock:^(BOOL succeeded, UIImage *image) {
            //    if (succeeded) {
                [userImageview setImage:image1];
                [tblview reloadData];
            //    }
            //}];
            }
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController.viewControllers count] == 3)
    {
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        
        UIView *plCropOverlay = [[[viewController.view.subviews objectAtIndex:1]subviews] objectAtIndex:0];
        
        plCropOverlay.hidden = YES;
        
        int position = 0;
        
        if (screenHeight == [UIScreen mainScreen].bounds.size.height)
        {
            position = 124;
        }
        else
        {
            position = 80;
        }
        
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        
        UIBezierPath *path2;
        
        if (isCoverPhoto==YES) {
            path2 = [UIBezierPath bezierPathWithRect:
                     CGRectMake(0.0f, position, 320.0f, 320)];
        }
        else {
            path2 = [UIBezierPath bezierPathWithOvalInRect:
                     CGRectMake(0.0f, position, 320.0f, 320.0f)];
        }
        [path2 setUsesEvenOddFillRule:YES];
        
        [circleLayer setPath:[path2 CGPath]];
        
        [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
        UIBezierPath *path;
        if (isCoverPhoto==YES) {
            path= [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 320, screenHeight-72)];
        }
        else {
            path= [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 320, screenHeight-72) cornerRadius:0];
        }
        
        [path appendPath:path2];
        [path setUsesEvenOddFillRule:YES];
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = [UIColor blackColor].CGColor;
        fillLayer.opacity = 0.8;
        [viewController.view.layer addSublayer:fillLayer];
        
        UILabel *moveLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 50)];
        [moveLabel setText:@"Move and Scale"];
        [moveLabel setTextAlignment:NSTextAlignmentCenter];
        [moveLabel setTextColor:[UIColor whiteColor]];
        
        [viewController.view addSubview:moveLabel];
    }
}
#pragma  mark- UIactionsheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet==actionShare) {
        if (buttonIndex == 0) {
            UIActivityViewController *controller= [[UIActivityViewController alloc]initWithActivityItems:@[shareimage]applicationActivities:nil];
            [self presentViewController:controller animated:YES completion:nil];
        }
        else if (buttonIndex ==2){
            
            [self postDelete:(NSString*)deleteImageId completionBlock:^(BOOL result) {
                [self viewWillAppear:NO];
                //[scrollView setContentSize:CGSizeMake(320,500)];
            }];
        }
        else if (buttonIndex==1){
            //            NSString *astrUserid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"user_id"];
            //            NSString *astrImageid=[[mutTimeline objectAtIndex:indexpath] objectForKey:@"image_id"];
            //            NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, astrImageid ];
            //            NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
            
            // UIImage *img=[UIImage imageWithData:[NSData dataWithContentsOfURL:aimageurl]];
            NSData *imageData = UIImagePNGRepresentation(shareimage); //convert image into .png format.
            
            NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
            
            NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
            
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"insta.igo"]]; //add our image to the path
            
            [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
            
            NSLog(@"image saved");
            
            
            CGRect rect = CGRectMake(0 ,0 , 0, 0);
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
            [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIGraphicsEndImageContext();
            NSString *fileNameToSave = [NSString stringWithFormat:@"Documents/insta.igo"];
            NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:fileNameToSave];
            NSLog(@"jpg path %@",jpgPath);
            NSString *newJpgPath = [NSString stringWithFormat:@"file://%@",jpgPath]; //[[NSString alloc] initWithFormat:@"file://%@", jpgPath] ];
            NSLog(@"with File path %@",newJpgPath);
            NSURL *igImageHookFile = [[NSURL alloc] initFileURLWithPath:newJpgPath];
            NSLog(@"url Path %@",igImageHookFile);
            
            self.doc.UTI = @"com.instagram.exclusivegram";
            self.doc = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
            self.doc=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
            [self.doc presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
            
            
            //Tag Photo
        }
        else if (buttonIndex==3){
            //Copy Share URL
        }
    }
    if (actionSheet==profilePicAction) {
        if (buttonIndex == 0){
            UIImage *aImage=[UIImage imageNamed:@"DefaultUser.png"];
            //userImageview.image=aImage;
            NSData *img=UIImageJPEGRepresentation(aImage, 0.3f);
            NSString *imagestring=[Base64 encode:img];
            [self updateprofilepicApi:imagestring completionBlock:^(BOOL result) {
                if (result) {
                    NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg", [[NSUserDefaults standardUserDefaults]objectForKey:@"id" ]];
                    //[self downloadImageWithURL:[NSURL URLWithString:aStrDisplyimage] completionBlock:^(BOOL succeeded, UIImage *image) {
                    //    if (succeeded) {
                            [userImageview setImage:aImage];
                    //    }
                    //}];
                }
            }];
        }
        else if (buttonIndex == 1) {
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
                _imagePickerObj.sourceType = UIImagePickerControllerSourceTypeCamera;
                _imagePickerObj.allowsEditing=YES;
                [self presentViewController:_imagePickerObj animated:YES completion:nil];
            }
            else {
                UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"Camera" message:@"Camera is Not Available" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alt show];
            }
        }
        else if (buttonIndex == 2){
            
            _imagePickerObj.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            _imagePickerObj.allowsEditing=YES;
            [self presentViewController:_imagePickerObj animated:YES completion:NULL];
        }
    }
    else if (actionSheet==_changeCoverPicAction) {
        if (buttonIndex == 0){
            UIImage *aImage=[UIImage imageNamed:@"backgroundimage@2x.png"];
            [coverpageImage setImage:nil];
            NSData *img=UIImageJPEGRepresentation(aImage, 0.3f);
            NSString *imagestring=[Base64 encode:img];
            // Update Cover Page
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self updatecoverpicApi:imagestring completionBlock:^(BOOL result) {
                if (result) {
                    NSString *aStrDisplyCoverimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@",coverString];
                    [self downloadImageWithURL:[NSURL URLWithString:aStrDisplyCoverimage] completionBlock:^(BOOL succeeded, UIImage *image) {
                        if (succeeded) {
                            [coverpageImage setImage:image];
                        }
                    }];
                }
            }];
        }
        else if (buttonIndex == 1) {
//            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
//                _imagePickerObj.sourceType = UIImagePickerControllerSourceTypeCamera;
//                _imagePickerObj.allowsEditing=YES;
//                isPhotoFromLibrary = YES;
//                [self presentViewController:_imagePickerObj animated:YES completion:nil];
//            }
//            else{
//                UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"Camera" message:@"Camera is Not Available" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//                [alt show];
//            }
            self.picker = [[GKImagePicker alloc] init];
            self.picker.delegate = self;
            self.picker.cropper.cropSize = CGSizeMake(320.0,320.0);
            self.picker.cropper.rescaleImage = YES;
            self.picker.cropper.rescaleFactor = 2.0;
            self.picker.cropper.dismissAnimated = YES;
            self.picker.cropper.overlayColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:0.7];
            self.picker.cropper.innerBorderColor = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:0.7];
            [self hideTabBar:self.tabBarController];
            [self.picker presentPicker:YES];
        }
        else if (buttonIndex == 2) {
            self.picker = [[GKImagePicker alloc] init];
            self.picker.delegate = self;
            self.picker.cropper.cropSize = CGSizeMake(320.0,320.0);
            self.picker.cropper.rescaleImage = YES;
            self.picker.cropper.rescaleFactor = 2.0;
            self.picker.cropper.dismissAnimated = YES;
            self.picker.cropper.overlayColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:0.7];
            self.picker.cropper.innerBorderColor = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:0.7];
            [self hideTabBar:self.tabBarController];
            [self.picker presentPicker:NO];
        }
    }
    
     if (actionSheet==profileCoverPicAction)
     {
     
     if (buttonIndex == 0)
     {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EDIT USER NAME"
                                                         message:NULL
                                                        delegate:self
                                               cancelButtonTitle:@"Done"
                                               otherButtonTitles:nil];
         alert.alertViewStyle = UIAlertViewStylePlainTextInput;
         [alert show];
     }
     }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@"%@", [alertView textFieldAtIndex:0].text);
}

-(IBAction)changeProfilePicture:(id)sender {
    [self HidePhotoView];
    isCoverPhoto = NO;
    [profilePicAction showInView:self.view];
}

-(IBAction)changeCoverPicture:(id)sender{
    [self HidePhotoView];
    isCoverPhoto = YES;
    [_changeCoverPicAction showInView:self.view];
}

-(IBAction)openActionSheet:(id)sender{
    [self HidePhotoView];
    [actionShare showInView:self.view];
}

- (IBAction)serch1:(id)sender {
    [self HidePhotoView];
    //SerchViewController *serchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"serch"];
    //[self.navigationController pushViewController:serchVC animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)settings:(id)sender {
    [self HidePhotoView];
    //[profileCoverPicAction showInView:self.view];
    
    SocialSettingViewController *setting = [self.storyboard instantiateViewControllerWithIdentifier:@"setting"];
    [setting setUserName:[mutDictProfileInfo valueForKey:@"username"]];
    [setting setDisplayName:[mutDictProfileInfo valueForKey:@"display_name"]];
    [setting setWebsite:[mutDictProfileInfo valueForKey:@"website"]];
    [setting setEmail:[mutDictProfileInfo valueForKey:@"email"]];
    [self.navigationController pushViewController:setting animated:YES];
}

- (IBAction)serch:(id)sender {
    [self HidePhotoView];
    //SerchViewController *serchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"serch"];
    //[self.navigationController pushViewController:serchVC animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

//- (IBAction)switchController:(id)sender {
//    [self HidePhotoView];
//     ///UISwitch *mySwitch = (UISwitch *)sender;
//    [self FollowUnfollowApiCall:^(BOOL result) {
////        if ([sender isOn]) {
////            [sender setOn:NO];
////        }
////        else{
////        [sender setOn:YES];
////        }
//    }];
//}

- (IBAction)GoToMsz:(id)sender {
    [self HidePhotoView];

    chatViewController *chat = [self.storyboard instantiateViewControllerWithIdentifier:@"chat"];
    chat.userid=[mutDictProfileInfo objectForKey:@"user_id"];
    chat.username=[mutDictProfileInfo objectForKey:@"display_name"];
    [self.navigationController pushViewController:chat animated:YES];
}

- (IBAction)callection:(id)sender {
    [self HidePhotoView];
    UIButton *button = (id)sender;
    [button setSelected:YES];
    [btntable setSelected:NO];
    [self collectionTypeViewMethod];
}

- (IBAction)tableview:(id)sender {
    [self HidePhotoView];
    UIButton *button = (id)sender;
    [button setSelected:YES];
    [btnCollection setSelected:NO];
    [self updatesView];
}

- (IBAction)mapview:(id)sender {
    MapviewViewController *aMap = [self.storyboard instantiateViewControllerWithIdentifier:@"map"];
    aMap.userid=[mutDictProfileInfo objectForKey:@"user_id"];
    [self.navigationController pushViewController:aMap animated:YES];
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
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:5.0];
    }];
}

-(void)sendFollowRequestApiCall:(NSString*)followString completionBlock:(void (^)(BOOL result)) return_block {
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/follow_users.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    [request setPostValue:self.userId forKey:@"follow_id"];
    [request setPostValue:followString forKey:@"follow"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSString *str = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
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

-(void)getCoverApiCall:(void (^)(BOOL result)) return_block{
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_cover.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    if (self.userId == NULL) {
        [request addPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id"] forKey:@"user_id"];
    }
    else{
        [request addPostValue:self.userId forKey:@"user_id"];
    }
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"Login Root %@",root);
        if (root[@"active"]!=NULL) {
            coverString = [root valueForKey:@"active"];
            return_block(TRUE);
        }
        else{
        }
    }];
}

-(void)profileApiCall:(void (^)(BOOL result)) return_block{
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_profile.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    //[request addPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id" ] forKey:@"user_id"];
    if (self.userId == NULL) {
        [request addPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id"] forKey:@"user_id"];
    }
    else{
        [request addPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id"] forKey:@"user_id2"];
        [request addPostValue:self.userId forKey:@"user_id"];
    }
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"Login Root %@",root);
        if (root[@"user_timeline"]!=NULL) {
            mutDictProfileInfo=[root mutableCopy];
            NSArray *nulleys = [mutDictProfileInfo allKeysForObject:[NSNull null]];
            [mutDictProfileInfo removeObjectsForKeys:nulleys];
            return_block(TRUE);
        }
        else{
        }
    }];
}

-(void)LikeApicall:(NSString *)imageID completionBlock:(void (^)(BOOL result)) return_block{
    [self HidePhotoView];
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/post_like.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    [request setPostValue:imageID forKey:@"image_id"];
    
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        if([root[@"status"]isEqualToString:@"success"])
        {
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

-(void)postDelete:(NSString *)imageID completionBlock:(void (^)(BOOL result)) return_block{
    [self HidePhotoView];
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/post_delete.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    //[request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    [request setPostValue:imageID forKey:@"image_id"];
    
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        if([root[@"status"]isEqualToString:@"success"])
        {
            //coverString = [root valueForKey:@"active"];
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

-(void)updateprofilepicApi:(NSString *)image  completionBlock:(void (^)(BOOL result)) return_block{
    [self HidePhotoView];
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/change_profile_pic.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addPostValue:image forKey:@"photo"];
    [request addPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id" ] forKey:@"user_id"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"update Root final %@",root);
        
        return_block(TRUE);
    }];
    [request setFailedBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:4.0];
    }];
}

-(void)updatecoverpicApi:(NSString *)image  completionBlock:(void (^)(BOOL result)) return_block{
    
    [self HidePhotoView];
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/change_cover.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addPostValue:image forKey:@"photo"];
    [request addPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"id" ] forKey:@"user_id"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"update Root final %@",root);
        coverString = [root valueForKey:@"url"];
        
        return_block(TRUE);
    }];
    [request setFailedBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSError *error=[request error];
        [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                        type:AJNotificationTypeRed
                                       title:error.localizedDescription
                             linedBackground:AJLinedBackgroundTypeDisabled
                                   hideAfter:4.0];
    }];
}

-(void)expand
{
    if(hidden)
        return;
    
    hidden = YES;
    
    [self hideTabBar:self.tabBarController];
    
    [UIView animateWithDuration:0.2 animations:^{
        if(!isMyProfile){
            [viewHederNavigation setFrame:CGRectMake(0, -50, 320,50)];
        }else{
            [myviewHederNavigation setFrame:CGRectMake(0, -50, 320,50)];
        }
        [tblview setContentInset:UIEdgeInsetsMake(0,0,0,0)];
    }completion:^(BOOL finished){
//        if(!isMyProfile){
//            //[viewHederNavigation setFrame:CGRectMake(0, 0, 320, 0)];
//            [viewHederNavigation setHidden:YES];
//        }else{
//            //[myviewHederNavigation setFrame:CGRectMake(0, 0, 320, 0)];
//            [myviewHederNavigation setHidden:YES];
//        }
    }];
}

-(void)contract
{
    if(!hidden)
        return;
    
    hidden = NO;
    
    [self showTabBar:self.tabBarController];
    
    [UIView animateWithDuration:0.2 animations:^{
        if(!isMyProfile){
            [viewHederNavigation setFrame:CGRectMake(0, 20, 320,50)];
        }else{
            [myviewHederNavigation setFrame:CGRectMake(0, 20, 320,50)];
        }
        [tblview setContentInset:UIEdgeInsetsMake(70,0,0,0)];
    }completion:^(BOOL finished){
    }];
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)hideTabBar:(UITabBarController *) tabbarcontroller
{
    if(!isMyProfile){
        //[viewHederNavigation setFrame:CGRectMake(0, 0, 320,70)];
        [viewHederNavigation  setHidden:YES];
    }else{
        //[myviewHederNavigation setFrame:CGRectMake(0, 0, 320,70)];
        [myviewHederNavigation  setHidden:YES];
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x,[UIScreen mainScreen].bounds.size.height, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
        }
    }
    
    [UIView commitAnimations];
}

- (void)showTabBar:(UITabBarController *) tabbarcontroller
{
    if(!isMyProfile){
        //[viewHederNavigation setFrame:CGRectMake(0, 0, 320,70)];
        [viewHederNavigation  setHidden:NO];
    }else{
        //[myviewHederNavigation setFrame:CGRectMake(0, 0, 320,70)];
        [myviewHederNavigation  setHidden:NO];
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        NSLog(@"%@", view);
        
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, [UIScreen mainScreen].bounds.size.height-tabbarcontroller.tabBar.frame.size.height+3, view.frame.size.width, view.frame.size.height)];
            
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [UIScreen mainScreen].bounds.size.height-tabbarcontroller.tabBar.frame.size.height+3)];
        }
    }
    
    [UIView commitAnimations];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self HidePhotoView];
    startContentOffset = lastContentOffset = scrollView.contentOffset.y;
    //NSLog(@"scrollViewWillBeginDragging: %f", scrollView.contentOffset.y);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //[self HidePhotoView];
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat differenceFromStart = startContentOffset - currentOffset;
    CGFloat differenceFromLast = lastContentOffset - currentOffset;
    lastContentOffset = currentOffset;

    if((differenceFromStart) < 0)
    {
        // scroll up
        if(scrollView.isTracking && (abs(differenceFromLast)>1))
            [self expand];
    }
    else {
        if(scrollView.isTracking && (abs(differenceFromLast)>1))
            [self contract];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [self HidePhotoView];
    [self contract];
    return YES;
}

-(void)handleTapFrom:(UITapGestureRecognizer *)gesture{
    UIStoryboard *storyboard = self.navigationController.storyboard;
    PhotoDescriptionViewController *detailPage = [storyboard                                                instantiateViewControllerWithIdentifier:@"photoDescriptin"];
    detailPage.strImageid=[[mutArrayProfileImages objectAtIndex:gesture.view.tag] objectForKey:@"image_id"] ;
    detailPage.strUserid=self.userId;
    //set the product
    
    //Push to detail View
    [self.navigationController pushViewController:detailPage animated:YES];
    NSLog(@"%ld", (long)gesture.view.tag);
}

-(void)HidePhotoView
{
    TabbarControllerViewController *tab = (TabbarControllerViewController*)self.tabBarController;
    [tab hidePhotoView];
}

-(void)gotoProfilePage:(MyTapGestureRecognizer *)gesture
{
    
    UIStoryboard *storyboard = self.navigationController.storyboard;
    
    ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
    
    fllowerPrfile.userId=gesture.userid;
    
    //Push to detail View
    [self.navigationController pushViewController:fllowerPrfile animated:YES];
    [self showTabBar:self.tabBarController];
    [self HidePhotoView];
    hidden = NO;
}

- (IBAction)btnProfileScrollTop:(id)sender {
    [tblview scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (IBAction)btnWebSite:(id)sender {
    
    NSString *websiteStr = [[NSString alloc] initWithString:[[sender titleForState:UIControlStateNormal] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    if (websiteStr.length>0) {
        UIStoryboard *storyboard = self.navigationController.storyboard;
        WebsiteViewController *websiteVC = [storyboard instantiateViewControllerWithIdentifier:@"web"];
        websiteVC.webString = websiteStr;
        [self.navigationController pushViewController:websiteVC animated:YES];
    }
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@",websiteStr]]];
}

- (IBAction)btnFollowRequestClicked:(id)sender {
    
    UIButton *btnType = (UIButton *)sender;
    if (btnType.tag==0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self sendFollowRequestApiCall:@"1" completionBlock:^(BOOL result) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (result) {
                [self callFollowingApi];
            }
        }];
    }
    else if (btnType.tag==2) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self sendFollowRequestApiCall:@"0" completionBlock:^(BOOL result) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (result) {
                [self callFollowingApi];
            }
        }];
    }
}

#pragma mark - GKImagePicker delegate methods

- (void)imagePickerDidFinish:(GKImagePicker *)imagePicker withImage:(UIImage *)image {
    [self showTabBar:self.tabBarController];
//    coverpageImage.contentMode = UIViewContentModeCenter;
//    coverpageImage.image = image;
    UIImage* image1 = [image fixOrientation];
    NSData *img=UIImageJPEGRepresentation(image1, 0.3f);
    NSString *imagestring=[Base64 encode:img];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self updatecoverpicApi:imagestring completionBlock:^(BOOL result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(result){
        NSString *aStrDisplyCoverimage = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@",coverString];
        //[self downloadImageWithURL:[NSURL URLWithString:aStrDisplyCoverimage] completionBlock:^(BOOL succeeded, UIImage *image) {
        //    if (succeeded) {
                [coverpageImage setImage:image1];
        //    }
        //}];
        }
    }];
}

- (void)CommentLabelClicked:(MyTapGestureRecognizer *)gesture
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UILabel *lbl = gesture.eventLabel;
    CGPoint p = [gesture locationInView:lbl];
    NSAttributedString *attributedstr = [lbl attributedText];
    CGSize lblsize = lbl.frame.size;
    NSString *str = attributedstr.string;
    CGSize usernamesize = CGSizeMake(lblsize.width,999);
    NSString *preStr = @"";
    
    while(true){
        NSRange range = [str rangeOfString:@"#"];
        if(range.location == NSNotFound)
            break;
        preStr = [NSString stringWithFormat:@"%@%@", preStr, [str substringToIndex:range.location]];
        CGSize prevSize =[preStr boundingRectWithSize: usernamesize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:lbl.font} context: nil].size;
        NSString *temp = [str substringFromIndex:range.location];
        NSRange spacerange = [temp rangeOfString:@" "];
        NSRange alpharange = [temp rangeOfString:@"@"];
        NSRange sharprange = [[temp substringFromIndex:1] rangeOfString:@"#"];
        int index = temp.length;
        if(spacerange.location != NSNotFound && spacerange.location < index)
            index = spacerange.location;
        if(alpharange.location != NSNotFound && alpharange.location < index)
            index = alpharange.location;
        if(sharprange.location != NSNotFound && sharprange.location+1 < index)
            index = sharprange.location+1;
        NSString *hashword = [temp substringToIndex:index];
        str = [temp substringFromIndex:index];
        CGSize afterSize =[[NSString stringWithFormat:@"%@%@",preStr,hashword] boundingRectWithSize: usernamesize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:lbl.font} context: nil].size;
        
        float posx_prev = [preStr sizeWithFont:lbl.font
                                      forWidth:CGRectGetMaxX(lbl.frame)
                                 lineBreakMode:NSLineBreakByWordWrapping].width;
        float posx_next = [[NSString stringWithFormat:@"%@%@",preStr,hashword] sizeWithFont:lbl.font
                                                                                   forWidth:CGRectGetMaxX(lbl.frame)
                                                                              lineBreakMode:NSLineBreakByWordWrapping].width;
        
        float posy_hash = [hashword sizeWithFont:lbl.font forWidth:CGRectGetMaxX(lbl.frame) lineBreakMode:NSLineBreakByWordWrapping].height;
        preStr = [NSString stringWithFormat:@"%@%@", preStr, hashword];
        CGRect rt;
        if(prevSize.height == afterSize.height){
            rt.origin.x = posx_prev;
            rt.origin.y = afterSize.height-posy_hash+10;
            rt.size.width = posx_next-posx_prev;
            rt.size.height = posy_hash;
        }else{
            rt.origin.x = 0;
            rt.origin.y = afterSize.height-posy_hash+10;
            rt.size.width = posx_next;
            rt.size.height = posy_hash;
        }
        if( [self ptInRect:p withRect:rt]){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIStoryboard *storyboard = self.navigationController.storyboard;
            ExploreViewController *exploreController = [storyboard instantiateViewControllerWithIdentifier:@"ExploreView"];
            [exploreController InitializeHashtag:hashword];
            [self.navigationController pushViewController:exploreController animated:YES];
            return;
        }
    }
    
    str = attributedstr.string;
    preStr = @"";
    while(true){
        NSRange range = [str rangeOfString:@"@"];
        if(range.location == NSNotFound)
            break;
        preStr = [NSString stringWithFormat:@"%@%@", preStr, [str substringToIndex:range.location]];
        CGSize prevSize =[preStr boundingRectWithSize: usernamesize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:lbl.font} context: nil].size;
        NSString *temp = [str substringFromIndex:range.location];
        NSRange spacerange = [temp rangeOfString:@" "];
        NSRange alpharange = [[temp substringFromIndex:1] rangeOfString:@"@"];
        NSRange sharprange = [temp rangeOfString:@"#"];
        int index = temp.length;
        if(spacerange.location != NSNotFound && spacerange.location < index)
            index = spacerange.location;
        if(alpharange.location != NSNotFound && alpharange.location+1 < index)
            index = alpharange.location+1;
        if(sharprange.location != NSNotFound && sharprange.location < index)
            index = sharprange.location;
        NSString *hashword = [temp substringToIndex:index];
        str = [temp substringFromIndex:index];
        CGSize afterSize =[[NSString stringWithFormat:@"%@%@",preStr,hashword] boundingRectWithSize: usernamesize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:lbl.font} context: nil].size;
        
        float posx_prev = [preStr sizeWithFont:lbl.font
                                      forWidth:CGRectGetMaxX(lbl.frame)
                                 lineBreakMode:NSLineBreakByWordWrapping].width;
        float posx_next = [[NSString stringWithFormat:@"%@%@",preStr,hashword] sizeWithFont:lbl.font
                                                                                   forWidth:CGRectGetMaxX(lbl.frame)
                                                                              lineBreakMode:NSLineBreakByWordWrapping].width;
        
        float posy_hash = [hashword sizeWithFont:lbl.font forWidth:CGRectGetMaxX(lbl.frame) lineBreakMode:NSLineBreakByWordWrapping].height;
        preStr = [NSString stringWithFormat:@"%@%@", preStr, hashword];
        CGRect rt;
        if(prevSize.height == afterSize.height){
            rt.origin.x = posx_prev;
            rt.origin.y = afterSize.height-posy_hash+10;
            rt.size.width = posx_next-posx_prev;
            rt.size.height = posy_hash;
        }else{
            rt.origin.x = 0;
            rt.origin.y = afterSize.height-posy_hash+10;
            rt.size.width = posx_next;
            rt.size.height = posy_hash;
        }
        if( [self ptInRect:p withRect:rt]){
            hashword = [hashword substringFromIndex:1];
            ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_userid.php"]];
            __unsafe_unretained ASIFormDataRequest *request = _request;
            
            [request addRequestHeader:@"Content-Type" value:@"application/json"];
            [request setPostValue:hashword forKey:@"username"];
            
            [request startAsynchronous];
            [request setCompletionBlock:^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
                if(root){
                    NSString *uid = [root objectForKey:@"id"];
                    UIStoryboard *storyboard = self.navigationController.storyboard;
                    ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
                    fllowerPrfile.userId = uid;
                    [self.navigationController pushViewController:fllowerPrfile animated:YES];
                    return;
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
            return;
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (BOOL)ptInRect:(CGPoint)pt withRect:(CGRect)rt
{
    if(pt.x < rt.origin.x)
        return NO;
    if(pt.x > rt.origin.x+rt.size.width)
        return NO;
    if(pt.y < rt.origin.y)
        return NO;
    if(pt.y > rt.origin.y+rt.size.height)
        return NO;
    return YES;
}

- (NSMutableArray*)getHashUsernameRange:(NSString*)str
{
    NSString *preStr = @"";
    NSString *tempstr = [NSString stringWithFormat:@"%@",str];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    while(true){
        NSRange range = [tempstr rangeOfString:@"#"];
        if(range.location == NSNotFound)
            break;
        preStr = [NSString stringWithFormat:@"%@%@", preStr, [tempstr substringToIndex:range.location]];
        
        NSString *temp = [tempstr substringFromIndex:range.location];
        NSRange spacerange = [temp rangeOfString:@" "];
        NSRange alpharange = [temp rangeOfString:@"@"];
        NSRange sharprange = [[temp substringFromIndex:1] rangeOfString:@"#"];
        int index = temp.length;
        if(spacerange.location != NSNotFound && spacerange.location < index)
            index = spacerange.location;
        if(alpharange.location != NSNotFound && alpharange.location < index)
            index = alpharange.location;
        if(sharprange.location != NSNotFound && sharprange.location+1 < index)
            index = sharprange.location+1;
        NSRange newrange;
        newrange.location = preStr.length;
        newrange.length = index;
        [arr addObject:NSStringFromRange(newrange)];
        
        NSString *hashword = [temp substringToIndex:index];
        tempstr = [temp substringFromIndex:index];
        preStr = [NSString stringWithFormat:@"%@%@", preStr, hashword];
    }
    
    preStr = @"";
    tempstr = [NSString stringWithFormat:@"%@",str];
    while(true){
        NSRange range = [tempstr rangeOfString:@"@"];
        if(range.location == NSNotFound)
            break;
        preStr = [NSString stringWithFormat:@"%@%@", preStr, [tempstr substringToIndex:range.location]];
        
        NSString *temp = [tempstr substringFromIndex:range.location];
        NSRange spacerange = [temp rangeOfString:@" "];
        NSRange alpharange = [[temp substringFromIndex:1] rangeOfString:@"@"];
        NSRange sharprange = [temp rangeOfString:@"#"];
        int index = temp.length;
        if(spacerange.location != NSNotFound && spacerange.location < index)
            index = spacerange.location;
        if(alpharange.location != NSNotFound && alpharange.location+1 < index)
            index = alpharange.location+1;
        if(sharprange.location != NSNotFound && sharprange.location < index)
            index = sharprange.location;
        NSRange newrange;
        newrange.location = preStr.length;
        newrange.length = index;
        [arr addObject:NSStringFromRange(newrange)];
        
        NSString *hashword = [temp substringToIndex:index];
        tempstr = [temp substringFromIndex:index];
        preStr = [NSString stringWithFormat:@"%@%@", preStr, hashword];
    }
    return arr;
}

@end
