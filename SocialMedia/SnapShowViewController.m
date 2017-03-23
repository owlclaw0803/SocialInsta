//
//  SnapShowViewController.m
//  SocialMedia
//
//  Created by kangZhe on 9/15/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "SnapShowViewController.h"

@interface SnapShowViewController ()

@end

@implementation SnapShowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    NSString *strPath = [NSString stringWithFormat:@"http://192.99.7.25/~thesocialapp/social/imgs/user/%@",self.imagePath];
    strPath = [strPath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *imageurl = [NSURL URLWithString:strPath];

    self.m_imgsnap.FeedType = 2;
    self.m_imgsnap.bNormalShow = YES;

    [self.m_imgsnap setImageURL:imageurl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
