//
//  ChangePasswordCustomCell.m
//  SocialMedia
//
//  Created by Khalid  on 18/10/2014.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import "ChangePasswordCustomCell.h"

@implementation ChangePasswordCustomCell

@synthesize leftImage;
@synthesize pswrdField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
