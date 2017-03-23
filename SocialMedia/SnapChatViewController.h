//
//  SnapChatViewController.h
//  SocialMedia
//
//  Created by kangZhe on 9/6/14.
//  Copyright (c) 2014 PARMARTH MORI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnapChatViewController : UIViewController<UIActionSheetDelegate, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UIActionSheet *actionSheet;
    UIPickerView *pickerView;
    NSArray *pickerContent;
    NSMutableArray *followings;
    int status;
    int timercount;
}

@property (weak, nonatomic) IBOutlet UIView *m_view1;
@property (weak, nonatomic) IBOutlet UIImageView *m_photoview;
@property (weak, nonatomic) IBOutlet UIButton *m_btntimer;
@property (retain, readwrite) UIImage* capturedimage;

@property (weak, nonatomic) IBOutlet UIView *m_view2;
@property (weak, nonatomic) IBOutlet UITableView *m_tblview;

@property (weak, nonatomic) IBOutlet UIButton *m_btnSend;
- (IBAction)onClickSend:(id)sender;

- (IBAction)onclickBtnTimer:(id)sender;
- (IBAction)onclickForwardBtn:(id)sender;
- (IBAction)onclickBackBtn:(id)sender;

-(void)openPickerView;
-(void)actionSheetDoneButtonClicked:(UIButton*)sender;
-(void)dismissActionSheet:(UIButton*)sender;
-(void)snapChatApiCall:(void (^)(BOOL result)) return_block;

@end
