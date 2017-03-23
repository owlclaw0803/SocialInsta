//
//  WebsiteViewController.h
//  SocialMedia
//
//  Created by Khalid  on 27/10/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface WebsiteViewController : UIViewController <UIWebViewDelegate>

{
    IBOutlet UIWebView      *websiteView;
}

@property (nonatomic,retain) NSString *webString;

@end
