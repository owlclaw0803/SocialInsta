//
//  MyTapGestureRecognizer.h
//  SocialMedia
//
//  Created by kangZhe on 9/1/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTapGestureRecognizer : UITapGestureRecognizer

@property (nonatomic) NSString *userid;
@property (nonatomic) UILabel *eventLabel;

@property (nonatomic) NSString *imageurl;
@property (nonatomic) int mediatype;
@property (nonatomic) int videoid;
@property (nonatomic) UIImage *attachimage;

@property (nonatomic) UIImageView *hideimageview;
@property (nonatomic) UIView *hideview;
@property (nonatomic) UIScrollView *hidescroll;
@property (nonatomic) UIView *tempclickview;
@end
