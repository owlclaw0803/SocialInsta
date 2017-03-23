//
//  PhotoDescriptionViewController.m
//  SocialMedia
//
//  Created by PARMARTH MORI on 10/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "PhotoDescriptionViewController.h"
#import "HomeViewController.h"
#import "ExploreViewController.h"

@interface PhotoDescriptionViewController ()

@end

@implementation PhotoDescriptionViewController
@synthesize  strImageid,strUserid, profileName, profileImage,mutDict;

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
    
    landscapeView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 548)];
    [landscapeView setBackgroundColor:[UIColor blackColor]];
    
    profileImage.layer.masksToBounds=YES;
    profileImage.layer.cornerRadius = 15;
    [profileImage setContentMode: UIViewContentModeScaleAspectFill];
    _scrollViewObj.contentSize = CGSizeMake(320, 800);
    self.actionShare = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil];
    [self.view addSubview:self.actionShare];
    self.VideoImage=[[UIImageView alloc]initWithFrame:CGRectMake(150, 150, 80, 80)];
    self.VideoImage.image=[UIImage imageNamed:@"video@2x.png"];
    [self.postImage addSubview:self.VideoImage];
    [self.VideoImage setHidden:YES];
    backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    [self.tabBarController.tabBar setHidden:NO];
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost==YES) {
        [self.tabBarController setSelectedIndex:0];
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_image_info.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
    __unsafe_unretained ASIFormDataRequest *request = _request;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:strImageid forKey:@"image_id"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSMutableDictionary *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        NSLog(@"News Root %@",root);
        if(root!=NULL)
        {
            mutDict= [root mutableCopy];
            NSLog(@"MUT%@",mutDict);
            [self data];
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

-(void)data
{
    for (UIView *view in _scrollViewObj.subviews) {
        [view removeFromSuperview];
    }
    
    float Totalsize=0.0;
    int arraycount = 0;
    self.postImage = [[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 450)];
    NSString *astrUserid=[mutDict objectForKey:@"user_id"];
    NSString *astrImageid=[mutDict objectForKey:@"image_id"];
    NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, astrImageid ];
    NSString *aStrprofileimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-profile.jpg",astrUserid];
    NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
    NSURL *aProfileimage=[NSURL URLWithString:aStrprofileimage];
    
    [_scrollViewObj addSubview:_postImage];
//    NSData *imageData = [NSData dataWithContentsOfURL:aProfileimage];
//    if(imageData.length != 0){
//        self.profileImage.image = [UIImage imageWithData:imageData];
//    }
    //profileName.text = [mutDict objectForKey:@"display_name"];
    if ([[mutDict objectForKey:@"post_type"]isEqualToString:@"v"])
    {
        
        self.postImage.FeedType = 2;
        self.postImage.bNormalShow = YES;
        [self.postImage setImageURL:aimageurl];
        [self.postImage setHidden:YES];
        
        UITapGestureRecognizer *changeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videocall:)];
        [self.postImage addGestureRecognizer:changeTap];
        self.postImage.userInteractionEnabled=YES;
        
        NSString *astrUserid=[mutDict objectForKey:@"user_id"];
        NSString *astrImageid=[mutDict objectForKey:@"image_id"];
        NSString *astrExt=[mutDict objectForKey:@"ext"];
        NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/vids/user/%@-%@.%@",astrUserid, astrImageid ,astrExt];
        NSURL *avideourl=[NSURL URLWithString:aStrDisplyimage];
        
        self.player = [[MPMoviePlayerController alloc] initWithContentURL: avideourl];
        self.player.controlStyle=MPMovieControlStyleNone;
        [self.player setScalingMode:MPMovieScalingModeAspectFill];
        [self.player.view setFrame:CGRectMake(0, 0,320, 450)];
        [self.player play];
        self.player.movieSourceType = MPMovieSourceTypeStreaming;
        [self.scrollViewObj addSubview: [self.player view]];
        
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(playbackEnded:)
         name:MPMoviePlayerPlaybackDidFinishNotification
         object:self.player];
        
        Totalsize=Totalsize+450;
    }
    else if ([[mutDict  objectForKey:@"post_type"]isEqualToString:@"p"]) {
        
        AsyncImageView *pano=[[AsyncImageView alloc]init];
        [pano setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
        pano.FeedType = 1;
        pano.bNormalShow = YES;
        
        UIScrollView *scroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,320,450)];
        
        // Khalid Code Start
        
        UITapGestureRecognizer *panoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panoDescriptionGestureClicked:)];
        panoGesture.numberOfTapsRequired=1;
        [scroll addGestureRecognizer:panoGesture];
        
        [pano setFrame:CGRectMake(0, 0, pano.image.size.width, scroll.frame.size.height)];
        [self.scrollViewObj addSubview:scroll];
        [scroll setBounces:NO];
        [scroll addSubview:pano];
        [scroll setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
        pano.tempscroll = scroll;
        [pano setImageURL:aimageurl];
        Totalsize=Totalsize+scroll.frame.size.height+3;
        [self.postImage setHidden:YES];
    }
    else{
        self.postImage.FeedType = 3;
        self.postImage.bNormalShow = YES;
        [self.postImage setImageURL:aimageurl];
        
        Totalsize=_postImage.frame.size.height;
        
    }
    
    int backViewheight = 0;
    
    NSMutableArray *arrayLike = [[NSMutableArray alloc]init];
    NSMutableString *mutableStrLikes = [[NSMutableString alloc] init];
    arrayLike = [mutDict objectForKey:@"likes"];
    int k=0;
    for (int j=1; j<=[arrayLike count]; j++) {
        if (j == [arrayLike count]) {
            [mutableStrLikes appendString:[NSString stringWithFormat:@"%@",[[arrayLike objectAtIndex:k] objectForKey:@"display_name"]]];
        }
        else
        {
            [mutableStrLikes appendString:[NSString stringWithFormat:@"%@, ",[[arrayLike objectAtIndex:k] objectForKey:@"display_name"]]];
        }
        k++;
    }
    NSLog(@"%@",mutableStrLikes);
    [[self.scrollViewObj viewWithTag:25]removeFromSuperview];
    UILabel *likesNameLabel = [[UILabel alloc]init];
    [likesNameLabel setTag:25];
    
    [backView addSubview:likesNameLabel];
    [likesNameLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    likesNameLabel.text = mutableStrLikes;
    likesNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [likesNameLabel setNumberOfLines:0];
    [likesNameLabel setTextColor:[UIColor whiteColor]];
    CGSize Likesize = CGSizeMake(300,999);
    CGSize textRect = [likesNameLabel.text boundingRectWithSize: Likesize options: NSStringDrawingUsesLineFragmentOrigin
                                                     attributes: @{NSFontAttributeName:likesNameLabel.font} context: nil].size ;
    [likesNameLabel setFrame:CGRectMake(28, backViewheight+55, textRect.width, textRect.height)];
    
    backViewheight = backViewheight+likesNameLabel.frame.size.height+10;
    
    
    UIImageView *likeImage = [[UIImageView alloc]initWithFrame:CGRectMake(9, likesNameLabel.frame.origin.y+3, 12, 12)];
    [likeImage setTag:3];
    [backView addSubview:likeImage];
    [likeImage setImage:[UIImage imageNamed:@"likeicon.png"]];
    [[backView viewWithTag:320]removeFromSuperview];
    UILabel *lblUserCaptionName=[[UILabel alloc]init];
    lblUserCaptionName.textColor=[UIColor whiteColor];
    [backView addSubview:lblUserCaptionName];
    lblUserCaptionName.lineBreakMode=NSLineBreakByWordWrapping;
    [lblUserCaptionName setNumberOfLines:0];
    NSString *stringprofileName = [mutDict objectForKey:@"display_name"];
    int aprofileNametCount=[stringprofileName length];
    NSString *stringCaption = [mutDict objectForKey:@"caption"];
    int aCaptionCount=[stringCaption length];
    
    NSMutableString *aAllActivity = [NSMutableString stringWithFormat:@"%@ %@",stringprofileName,stringCaption];
    NSMutableAttributedString *aAtributedCaptionStr = [[NSMutableAttributedString alloc]initWithString:aAllActivity];
    [aAtributedCaptionStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:NSMakeRange(0, aprofileNametCount)];
    [aAtributedCaptionStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(aprofileNametCount+1, aCaptionCount)];
    //[aAtributedCaptionStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51.0/225.0f green:0/225.0f blue:102/225.0f alpha:1]range:NSMakeRange(0, aprofileNametCount)];
    // [aAtributedCaptionStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:33/225.0f alpha:1 ]range:NSMakeRange(aprofileNametCount+1, aCaptionCount)];
    [lblUserCaptionName setAttributedText:aAtributedCaptionStr];
    
    [lblUserCaptionName setTag:320];
    
    MyTapGestureRecognizer *tapGestureRecognizer1 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(CommentLabelClicked:)];
    lblUserCaptionName.userInteractionEnabled = YES;
    tapGestureRecognizer1.eventLabel = lblUserCaptionName;
    [lblUserCaptionName addGestureRecognizer:tapGestureRecognizer1];
    
    CGSize profilsize = CGSizeMake(290,999);
    CGSize profiletextRect =[lblUserCaptionName.text boundingRectWithSize: profilsize options: NSStringDrawingUsesLineFragmentOrigin
                                                               attributes: @{NSFontAttributeName:lblUserCaptionName.font} context: nil].size ;
    [lblUserCaptionName setFrame:CGRectMake(28, backViewheight+45, profiletextRect.width+10, profiletextRect.height+10)];
    
    
    backViewheight = backViewheight+profiletextRect.height+4;
    
#pragma mark -Add Buzz
    
    UIImageView *buzzImage = [[UIImageView alloc]initWithFrame:CGRectMake(9, lblUserCaptionName.frame.origin.y+10, 12, 12)];
    [buzzImage setTag:7];
    [backView addSubview:buzzImage];
    [buzzImage setImage:[UIImage imageNamed:@"commenticon.png"]];
    
#pragma mark -Add Buzz Users
    
    NSMutableArray *arrayBuzz = [[NSMutableArray alloc]init];
    arrayBuzz = [mutDict objectForKey:@"comments"];
    
    arraycount=arraycount+[arrayBuzz count];
    
    
    for (int j=0; j<[arrayBuzz count]; j++) {
        
        NSString *stringName = [[arrayBuzz objectAtIndex:j]objectForKey:@"display_name"];
        int aUserCount=[stringName length];
        NSString *stringComment = [[arrayBuzz objectAtIndex:j]objectForKey:@"comment"];
        int aActivity=[stringComment length];
        
        
        UILabel *labelCommentUserName = [[UILabel alloc]init];
        labelCommentUserName.tag=10+j;
        
        [backView addSubview:labelCommentUserName];
        
        NSMutableString *aAllActivity=[NSMutableString stringWithFormat:@"%@ %@",stringName,stringComment];
        if(aAllActivity.length > 94){
            aAllActivity=[NSMutableString stringWithFormat:@"%@...",[aAllActivity substringToIndex:90]];
            aActivity = aAllActivity.length-aUserCount-1;
        }
        
        NSMutableAttributedString *aAtributedStr=[[NSMutableAttributedString alloc]initWithString:aAllActivity];
        [aAtributedStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0] range:NSMakeRange(0, aUserCount)];
        [aAtributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(aUserCount+1, aActivity)];
        // [aAtributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51.0/225.0f green:0/225.0f blue:102/225.0f alpha:1]range:NSMakeRange(0, aUserCount)];
        // [aAtributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:33/225.0f alpha:1 ]range:NSMakeRange(aUserCount+1, aActivity)];
        
        //[labelCommentUserName setFont:[UIFont boldSystemFontOfSize:13.0f]];
        [labelCommentUserName setTextColor:[UIColor whiteColor]];
        [labelCommentUserName setAttributedText:aAtributedStr];
        labelCommentUserName.lineBreakMode=NSLineBreakByWordWrapping;
        [labelCommentUserName setNumberOfLines:0];
        
        MyTapGestureRecognizer *tapGestureRecognizer2 = [[MyTapGestureRecognizer alloc] initWithTarget:self action:@selector(CommentLabelClicked:)];
        labelCommentUserName.userInteractionEnabled = YES;
        tapGestureRecognizer2.eventLabel = labelCommentUserName;
        [labelCommentUserName addGestureRecognizer:tapGestureRecognizer2];
        
        float twolineheight = labelCommentUserName.font.lineHeight*2.2;
        CGSize commentUserNameSize = CGSizeMake(245,twolineheight);
        CGSize commentUserNameRect =[labelCommentUserName.text boundingRectWithSize: commentUserNameSize options: NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName:labelCommentUserName.font} context: nil].size ;
        [labelCommentUserName setFrame:CGRectMake(28, backViewheight+45, 245, commentUserNameRect.height+5)];
        backViewheight=backViewheight+commentUserNameRect.height+3;
    }
    
    [[backView viewWithTag:800] removeFromSuperview];
    UIButton *btnlike=[[UIButton alloc]initWithFrame:CGRectMake(10, backViewheight+65,55, 25)];
    btnlike.tag=800;
    [backView addSubview:btnlike];
    
    if ([btnlike isSelected]) {
        [btnlike setBackgroundImage:[UIImage imageNamed:@"likeinwhite.png"] forState:UIControlStateNormal];
        [btnlike setSelected:NO];
    }else{
        [btnlike setBackgroundImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        [btnlike setSelected:YES];
    }
    
    if ([[[mutDict objectForKey:@"user_liked"] description]isEqualToString:@"1"]) {
        [btnlike setBackgroundImage:[UIImage imageNamed:@"likeinwhite.png"] forState:UIControlStateNormal];
        [btnlike setSelected:NO];
    }
    
    [btnlike addTarget:self action:@selector(likebutton:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self.scrollViewObj viewWithTag:300]removeFromSuperview];
    UIButton *buzzButton = [[UIButton alloc]initWithFrame:CGRectMake(85, btnlike.frame.origin.y,87, 25)];
    [buzzButton setTag:300];
    [buzzButton setImage:[UIImage imageNamed:@"comment.png" ] forState:UIControlStateNormal];
    
    //[buzzButton addTarget:self action:@selector(buzzebtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [buzzButton addTarget:self action:@selector(buzzAction:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:buzzButton];
    [[self.scrollViewObj viewWithTag:600]removeFromSuperview];
    UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(250, btnlike.frame.origin.y, 50, 25)];
    [btnShare setTag:600];
    [btnShare setImage:[UIImage imageNamed:@"threedot.png"] forState:UIControlStateNormal];
    [btnShare addTarget:self action:@selector(shareImage:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:btnShare];
    backViewheight=backViewheight+btnlike.frame.size.height+28;
    
    [_scrollViewObj addSubview:backView];
    
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 450-backViewheight-36 , 180, 35)];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn addTarget:self action:@selector(gotoFollowersProfile:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(51, 450-backViewheight-35, 130, 33)];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    headerLabel.font = [UIFont boldSystemFontOfSize:13];
    headerLabel.textColor=[UIColor whiteColor];
    headerLabel.text=[mutDict objectForKey:@"display_name"];
    
    UIImageView *aImageViewInSectionView=[[UIImageView alloc] initWithFrame:CGRectMake(10,450-backViewheight-36, 35 , 35)];
    aImageViewInSectionView.layer.cornerRadius = aImageViewInSectionView.frame.size.width/2;
    aImageViewInSectionView.layer.masksToBounds = YES;
    [aImageViewInSectionView setImageWithURL:aProfileimage placeholderImage:NULL];
    
    UIImageView *aImageViewPhoto;
    if ([[mutDict objectForKey:@"post_type"]isEqualToString:@"p"]) {
        aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(260,450-backViewheight-24, 29 , 13)];
        aImageViewPhoto.image=[UIImage imageNamed:@"PanoramicIcon"];
    }
    else if ([[mutDict objectForKey:@"post_type"]isEqualToString:@"v"]) {
        aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(265,450-backViewheight-24, 21 , 13)];
        aImageViewPhoto.image=[UIImage imageNamed:@"VideoIcon"];
    }
    else {
        aImageViewPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(268,450-backViewheight-24, 14 , 13)];
        aImageViewPhoto.image=[UIImage imageNamed:@"PhotoIcon"];
    }
    
    [_scrollViewObj addSubview:aImageViewPhoto];
    [_scrollViewObj addSubview:btn];
    [_scrollViewObj addSubview:headerLabel];
    [_scrollViewObj addSubview:aImageViewInSectionView];
    _scrollViewObj.contentSize = CGSizeMake(320, Totalsize);
    
    backViewheight = backViewheight+45;
    
    backView.frame = CGRectMake(0,450-backViewheight,320,backViewheight);
    //[_scrollViewObj addSubview:titleView];
    //titleView.frame = CGRectMake(0, 450-backViewheight-42, 320, 42);
    //[titleView setHidden:NO];
}

- (void)playbackEnded:(NSNotification*)notification
{
    //    [[NSNotificationCenter defaultCenter]
    //     removeObserver:self name:@"MPMoviePlayerPlaybackDidFinishNotification"
    //     object:nil];
    
    [self.player stop];
    [self.player.view setHidden:YES];
    [self.postImage setHidden:NO];
    [self.VideoImage setHidden:NO];
}

-(void)videocall:(UITapGestureRecognizer *)gesture{
    [self.postImage setHidden:YES];
    [self.player.view setHidden:NO];
    [self.player play];
}

-(IBAction)likebutton:(id)sender{
    
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
    NSString *aStrLike=[mutDict objectForKey:@"image_id"];
    
    [self LikeApicall:(NSString *)aStrLike completionBlock:^(BOOL result) {
        [self viewWillAppear:YES];
    }];
}

-(IBAction)buzzAction:(id)sender{
    CommntViewController *buzz = [self.storyboard instantiateViewControllerWithIdentifier:@"comment"];
    buzz.strimageid=[mutDict objectForKey:@"image_id"];
    buzz.strUserid=[mutDict objectForKey:@"user_id"];

    [self.navigationController pushViewController:buzz animated:YES];
}

-(IBAction)shareImage:(id)sender{
    [_actionShare showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet==self.actionShare) {
        if (buttonIndex == 0) {
            NSString *astrUserid=[mutDict objectForKey:@"user_id"];
            NSString *imageid =[mutDict objectForKey:@"image_id"];
            NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, imageid ];
            NSURL *aimageurl=[NSURL URLWithString:aStrDisplyimage];
            UIImage  *shareimage=[UIImage imageWithData:[NSData dataWithContentsOfURL:aimageurl]];
            
            
            UIActivityViewController *aController= [[UIActivityViewController alloc]initWithActivityItems:@[shareimage]applicationActivities:nil];
            [self presentViewController:aController animated:YES completion:nil];
            
        }
    }
}

-(void)LikeApicall:(NSString *)imageID completionBlock:(void (^)(BOOL result)) return_block{
    
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/post_like.php"]];
    _request.shouldAttemptPersistentConnection   = NO;
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


- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)gotoFollowersProfile:(id)sender {
    
    UIStoryboard *storyboard = self.navigationController.storyboard;
    
    ProfileViewController *fllowerPrfile = [storyboard instantiateViewControllerWithIdentifier:@"followerProfile"];
    fllowerPrfile.userId=[[mutDict objectForKey:@"user_id"] mutableCopy];
    
    [self.navigationController pushViewController:fllowerPrfile animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)panoDescriptionGestureClicked:(UIGestureRecognizer*)sender {
    
    [self hideTabBar:self.tabBarController];
    
    NSString *astrUserid = [mutDict objectForKey:@"user_id"];
    NSString *astrImageid = [mutDict objectForKey:@"image_id"];
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
    
    UITapGestureRecognizer *panoDismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panoDismissDescriptionGestureClicked:)];
    panoDismissGesture.numberOfTapsRequired=1;
    [landscapeScroll addGestureRecognizer:panoDismissGesture];
    
    [landscapeView addSubview:landscapeScroll];
    [landscapeScroll setBounces:NO];
    [landscapeScroll setScrollEnabled:YES];
    [landscapeScroll setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
    [self.view addSubview:landscapeView];
    NSLog(@"Pano Clicked");
}

- (void)panoDismissDescriptionGestureClicked:(UIGestureRecognizer*)sender {
    [landscapeView removeFromSuperview];
    [self showTabBar:self.tabBarController];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)hideTabBar:(UITabBarController *) tabbarcontroller
{
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
        int index = temp.length;
        if(spacerange.location != NSNotFound && spacerange.location < index)
            index = spacerange.location;
        if(alpharange.location != NSNotFound && alpharange.location < index)
            index = alpharange.location;
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
        NSRange alpharange = [temp rangeOfString:@"#"];
        int index = temp.length;
        if(spacerange.location != NSNotFound && spacerange.location < index)
            index = spacerange.location;
        if(alpharange.location != NSNotFound && alpharange.location < index)
            index = alpharange.location;
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

- (void)showTabBar:(UITabBarController *) tabbarcontroller
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
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

@end
