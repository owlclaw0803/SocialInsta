//
//  SnapShowViewController.h
//  SocialMedia
//
//  Created by kangZhe on 9/15/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import <AVFoundation/AVFoundation.h>

@interface SnapShowViewController : UIViewController

@property (weak, nonatomic) IBOutlet AsyncImageView *m_imgsnap;
@property (readwrite) NSString *imagePath;
- (IBAction)btnClickBack:(id)sender;

@end
