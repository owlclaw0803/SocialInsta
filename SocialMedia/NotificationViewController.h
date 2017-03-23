//
//  NotificationViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 08/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoDescriptionViewController.h"
#import  "ProfileViewController.h"
#import "MyTapGestureRecognizer.h"
#import "NotificationCustomCell.h"
#import "UIImageView+AFNetworking.h"

@interface NotificationViewController : UIViewController<UITableViewDataSource,UITabBarDelegate, UITableViewDelegate>
{

   IBOutlet UITableView *tableViewObj;
    NSMutableDictionary *mutdict;
    NSMutableArray *fameArray;
    NSMutableArray *activityArray;
    IBOutlet UISegmentedControl *segmentedController;
//    IBOutlet UIView         *activityView;
//    IBOutlet UIButton       *btnAccept;
//    IBOutlet UIButton       *btnReject;
    
    NSMutableArray      *followersArray;
    NSMutableArray      *followersPendingArray;
    NSMutableArray      *followingArray;
    NSMutableArray      *followingPendingArray;
    
    BOOL                isFollowing;
}

-(IBAction)followingandnewsSegmentedSelect:(id)sender;
-(void)HidePhotoView;
- (void)gotoProfilePage:(MyTapGestureRecognizer *)gesture;

@end
