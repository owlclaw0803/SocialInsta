//
//  PhotoDescriptionViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 10/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import <MediaPlayer/MediaPlayer.h>
#import<MobileCoreServices/MobileCoreServices.h>
#import "CommntViewController.h"
#import "ProfileViewController.h"

@interface PhotoDescriptionViewController : UIViewController<UIActionSheetDelegate>
{
    UIView *backView;
    UIView  *landscapeView;
    __weak IBOutlet UIView *titleView;
}

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;

@property (strong, nonatomic) IBOutlet UIView * bkView;

@property(strong,nonatomic) AsyncImageView *postImage;
@property(strong,nonatomic) UIImageView *VideoImage;
@property(nonatomic,strong)MPMoviePlayerController *player;
@property (strong, nonatomic) IBOutlet UILabel *profileName;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewObj;
- (IBAction)backButtonAction:(id)sender;
- (IBAction)gotoFollowersProfile:(id)sender;
@property (strong, nonatomic) UIActionSheet *actionShare;
//@property (strong, nonatomic) IBOutlet UIImageView *postImage;
@property(strong,nonatomic) NSString *strImageid;
@property(strong,nonatomic)NSString *strUserid;
@property(strong,nonatomic)NSMutableDictionary *mutDict;

- (BOOL)ptInRect:(CGPoint)pt withRect:(CGRect)rt;

@end
