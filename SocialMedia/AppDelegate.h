//
//  AppDelegate.h
//  SocialMedia
//
//  Created by PARMARTH MORI on 01/07/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK.h"

#import "ASIFormDataRequest.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSString *strID;
}

@property (strong, nonatomic) UIWindow *window;


- (void)openSessionWithAllowLoginUI:(BOOL)allowLoginUI completionBlock:(void(^)(BOOL result))return_back;

@property (strong,nonatomic) FBSession *session;
@property (strong,nonatomic) NSMutableArray *AlbumData;
@property (nonatomic) BOOL boolCenterMap;
@property (nonatomic) double trackLat;
@property (nonatomic) double trackLong;
@property (nonatomic) NSString *storyboardname;
@property(nonatomic,strong) UITabBarController *tabBarController;
@property(nonatomic, readwrite) UINavigationController *navigationController;

-(void)Initialize;

@end
