//
//  ExploreViewController.h
//  SocialMedia
//
//  Created by kangZhe on 8/6/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIScrollView+SVPullToRefresh.h"

@interface ExploreViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    BOOL hidden;
    IBOutlet UITableView *tblview;
    IBOutlet UIView *hederview;
    __weak IBOutlet UILabel *headerlabel;
    
    BOOL bHashTagPage;
    NSString *hashtag;
}
@property(strong,nonatomic)NSMutableArray *mutTimeline;

-(void)handleTapFrom:(UITapGestureRecognizer *)gesture;
- (IBAction)btnsearchclick:(id)sender;
-(void)HidePhotoView;
- (void)InitializeHashtag:(NSString*)hash;

@end
