//
//  EditPhotoViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 07/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapView.h"
#import "Place.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AFPhotoEditorController.h"
#import "Base64.h"
#import "TPKeyboardAvoidingScrollView.h"
#import <CFNetwork/CFNetwork.h>
#import "Reachability.h"
#import <Social/Social.h>

@interface EditPhotoViewController : UIViewController<AFPhotoEditorControllerDelegate,CLLocationManagerDelegate,UITextViewDelegate,UIAlertViewDelegate>
{
    IBOutlet UIImageView *imageview;
    IBOutlet UITextView *txtfield;
    IBOutlet UIView     *sharingView;
    IBOutlet UILabel    *editLabel;
    __weak IBOutlet UIScrollView *scroll;
    
    __weak IBOutlet UIButton *btnfacebook;
    __weak IBOutlet UIButton *btntwitter;
    __weak IBOutlet UIButton *btnEditPhoto;
    __weak IBOutlet UIButton *btnSaveCameraroll;
    MPMoviePlayerController *videoController;
    CLLocationManager *locationManager;
    MapView* mapView;
    Place *userLoc;
    UIImageView *pano;
}
- (IBAction)back:(id)sender;

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (strong, nonatomic) UIImage *imageObj;
@property BOOL *aBoolpano;
@property UIImage *videoImage;
@property NSURL *videoURL;
@property NSString *videoStr;
@property NSString *latitude;
@property NSString *longitude;
@property(strong,nonatomic) UITabBarController *tabbar;

- (IBAction)editPhoto:(id)sender;
- (IBAction)SavePhotoOnClick:(id)sender;
- (IBAction)AddLocation:(id)sender;
- (IBAction)Post:(id)sender;
- (IBAction)btnshareFacebook:(id)sender;
- (IBAction)btnshareTwitter:(id)sender;
- (IBAction)btnshareInstagram:(id)sender;

@end
