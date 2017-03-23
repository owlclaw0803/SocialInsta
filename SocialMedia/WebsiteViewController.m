//
//  WebsiteViewController.m
//  SocialMedia
//
//  Created by Khalid  on 27/10/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "WebsiteViewController.h"

@interface WebsiteViewController ()

@end

@implementation WebsiteViewController
@synthesize webString;

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
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    BOOL isPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"Post"];
    if (isPost==YES) {
        [self.tabBarController setSelectedIndex:0];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *myURL;
    if ([self.webString hasPrefix:@"http://"]) {
        myURL = [NSURL URLWithString:self.webString];
    } else {
        myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",self.webString]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
    [websiteView setScalesPageToFit:YES];
    [websiteView loadRequest:request];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
 
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    NSLog(@"Error : %@",error);
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
