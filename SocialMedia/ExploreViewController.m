//
//  ExploreViewController.m
//  SocialMedia
//
//  Created by kangZhe on 8/6/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "ExploreViewController.h"
#import "PhotoDescriptionViewController.h"
#import "AsyncImageView.h"
#import "TabbarControllerViewController.h"
#import "SVPullToRefresh.h"

@interface ExploreViewController ()

@end

@implementation ExploreViewController
@synthesize mutTimeline;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)InitializeHashtag:(NSString*)hash
{
    bHashTagPage = YES;
    hashtag = hash;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    if(bHashTagPage){
        [headerlabel setText:hashtag];
    }else{
        [headerlabel setText:@"Explore"];
    }
    [self getDataFromApi];
    
    [tblview addPullToRefreshWithActionHandler:^{
        ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_explore.php"]];
        __unsafe_unretained ASIFormDataRequest *request = _request;
        request.shouldAttemptPersistentConnection   = NO;
        [request setValidatesSecureCertificate:NO];
        
        
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
        if(bHashTagPage){
            [request setPostValue:hashtag forKey:@"hashtag"];
        }
        [request startAsynchronous];
        [request setCompletionBlock:^{
            NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
            //NSLog(@"News Root %@",root);
            if(root!=NULL)
            {
                mutTimeline=Nil;
                mutTimeline=[[NSMutableArray alloc]init];
                for (int i=0; i<[root count]; i++) {
                    [mutTimeline addObject:[root objectAtIndex:i]];
                }
                // mutTimeline = [root mutableCopy];
                NSLog(@"MUT%@",mutTimeline);
                [tblview reloadData];
            }
            [tblview.pullToRefreshView stopAnimating];
        }];
        
        [request setFailedBlock:^{
            NSError *error=[request error];
            [AJNotificationView showNoticeInView:[[UIApplication sharedApplication] delegate].window
                                            type:AJNotificationTypeRed
                                           title:error.localizedDescription
                                 linedBackground:AJLinedBackgroundTypeDisabled
                                       hideAfter:5.0];
        }];
    }];
    // Do any additional setup after loading the view.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//-(void)viewWillDisappear:(BOOL)animated
//{
//    hidden = NO;
//    
//    [self showTabBar:self.tabBarController];
//    //[hederview  setHidden:NO];
//    
//    [UIView animateWithDuration:0.2 animations:^{
//        [hederview setFrame:CGRectMake(0, 0, 320,70)];
//        [tblview setContentInset:UIEdgeInsetsMake(70,0,0,0)];
//    }completion:^(BOOL finished){
//    }];
//}

- (void)getDataFromApi {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ASIFormDataRequest *_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.99.7.25/~thesocialapp/social/iphone/get_explore.php"]];
    __unsafe_unretained ASIFormDataRequest *request = _request;
    request.shouldAttemptPersistentConnection   = NO;
    [request setValidatesSecureCertificate:NO];
    request.timeOutSeconds = 50;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] forKey:@"user_id"];
    if(bHashTagPage){
        [request setPostValue:hashtag forKey:@"hashtag"];
    }
    [request startAsynchronous];
    [request setCompletionBlock:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSMutableArray *root = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        //NSLog(@"News Root %@",root);
        if(root != nil)
        {
            mutTimeline=Nil;
            mutTimeline=[[NSMutableArray alloc]init];
            for (int i=0; i<[root count]; i++) {
                [mutTimeline addObject:[root objectAtIndex:i]];
            }
            // mutTimeline = [root mutableCopy];
            NSLog(@"MUT%@",mutTimeline);
            [tblview reloadData];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost==YES) {
        [self.tabBarController setSelectedIndex:0];
    }
    hidden = NO;
    [self showTabBar:self.tabBarController];
    [hederview setFrame:CGRectMake(0, 20, 320,50)];
    [tblview setContentInset:UIEdgeInsetsMake(70,0,0,0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int count = 0;
    float width = (self.view.frame.size.width-4*5)/3;
    float height = width*4/3;
    for(int i = 0 ; i < [mutTimeline count] ; i++){
        NSString *astrUserid=[[mutTimeline objectAtIndex:i] objectForKey:@"user_id"];
        //if(!bHashTagPage && [astrUserid intValue] == [[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] intValue])
        //    continue;
        count++;
    }
    int rows = count / 3;
    if(rows*3 < count)
        rows++;
    return 5 + rows*(height+5);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collectioncell"];
    int x = 5;
    int y = 5;
    float width = (self.view.frame.size.width-4*5)/3;
    float height = width*4/3;
    for(int i = 0 ; i < [mutTimeline count] ; i++){
        NSString *astrUserid=[[mutTimeline objectAtIndex:i] objectForKey:@"user_id"];
        //if(!bHashTagPage && [astrUserid intValue] == [[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] intValue])
        //    continue;
        NSString *astrImageid=[[mutTimeline objectAtIndex:i] objectForKey:@"image_id"];
        NSString *aStrDisplyimage=[NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@-%@.jpg",astrUserid, astrImageid];
        UIImageView *imageview = [[AsyncImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
       
        [imageview setBackgroundColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
        [cell.contentView addSubview:imageview];
        imageview.tag = i;
        //NSURL *imageURL = [NSURL URLWithString:aStrDisplyimage];
        //[imageview setImageURL:imageURL];
        //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSLog(aStrDisplyimage);
        [self downloadImageWithURL:[NSURL URLWithString:aStrDisplyimage] completionBlock:^(BOOL succeeded, UIImage *image) {
            //[MBProgressHUD hideHUDForView:self.view animated:YES];
            if (succeeded) {
                CGRect cropRect = CGRectMake(0, 0, 0, image.size.height);
                cropRect.size.width = image.size.height*150/200;
                
                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
                // or use the UIImage wherever you like
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                imageview.image = image;
            }
        }];
        
        x = x+imageview.frame.size.width+5;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        [imageview addGestureRecognizer:tapGestureRecognizer];
        imageview.userInteractionEnabled=YES;
        
        if(x >= (float)self.view.frame.size.width-10)
        {
            y = y+height+5;
            x = 5.0;
        }
    }
    return cell;
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:20];
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

-(void)handleTapFrom:(UITapGestureRecognizer *)gesture{
    [self HidePhotoView];
    [self contract];
    UIStoryboard *storyboard = self.navigationController.storyboard;
    PhotoDescriptionViewController *detailPage = [storyboard
                                                  instantiateViewControllerWithIdentifier:@"photoDescriptin"];
    detailPage.strImageid=[[mutTimeline objectAtIndex:gesture.view.tag] objectForKey:@"image_id"] ;
    detailPage.strUserid=[[mutTimeline objectAtIndex:gesture.view.tag] objectForKey:@"user_id"] ;
    //set the product
    
    //Push to detail View
    [self.navigationController pushViewController:detailPage animated:YES];
    NSLog(@"%ld", (long)gesture.view.tag);
}

- (IBAction)btnsearchclick:(id)sender
{
    [self HidePhotoView];
    SerchViewController *serchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"serch"];
    
    [self.navigationController pushViewController:serchVC animated:YES];
}

-(void)expand
{
    if(hidden)
        return;
    hidden = YES;
    
    [self hideTabBar:self.tabBarController];
    
    [UIView animateWithDuration:0.2 animations:^{
        [hederview setFrame:CGRectMake(0, -50, 320, 50)];
        [tblview setContentInset:UIEdgeInsetsMake(20,0,0,0)];
    }completion:^(BOOL finished){
        //[hederview setHidden:YES];
    }];
}

-(void)contract
{
    if(!hidden)
        return;
    
    hidden = NO;
    
    [self showTabBar:self.tabBarController];
    //[hederview  setHidden:NO];
    
    [UIView animateWithDuration:0.2 animations:^{
        [hederview setFrame:CGRectMake(0, 20, 320,50)];
        [tblview setContentInset:UIEdgeInsetsMake(70,0,0,0)];
    }completion:^(BOOL finished){
    }];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)hideTabBar:(UITabBarController *) tabbarcontroller
{
    [hederview setHidden:YES];
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
    [hederview setHidden:NO];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        NSLog(@"%@", view);
        
        if([view isKindOfClass:[UITabBar class]])
        {
            CGRect rt = view.frame;
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

-(void)HidePhotoView
{
    TabbarControllerViewController *tab = (TabbarControllerViewController*)self.tabBarController;
    [tab hidePhotoView];
}

@end
