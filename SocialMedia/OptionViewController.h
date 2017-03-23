//
//  OptionViewController.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 15/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "EditPhotoViewController.h"
#import "CRVPanoramaImagePicker.h"

@interface OptionViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

{
    IBOutlet UIButton *panaroma;
    IBOutlet UIButton *video;
    IBOutlet UIButton *Photos;
    
    EditPhotoViewController *editPhotview;
    CRVPanoramaImagePicker *panoramaImagePicker;
}

- (IBAction)panaroma:(id)sender;
- (IBAction)video:(id)sender;
- (IBAction)photos:(id)sender;

@property (strong, nonatomic)    UIActionSheet *photoOptions;
@property (strong, nonatomic)    UIActionSheet *panoramaOptions;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property(strong,nonatomic)NSString *strExtension;

@end
