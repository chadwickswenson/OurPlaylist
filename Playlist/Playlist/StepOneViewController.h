//
//  StepOneViewController.h
//  Playlist
//
//  Created by Chad Swenson on 6/19/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StepOneViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *playListTitleTextField;
@property (strong, nonatomic) NSMutableArray *playListArray;
@property (strong, nonatomic) IBOutlet UITableView *localPlayListListView;
@property (weak, nonatomic) IBOutlet UISwitch *allMusicToggle;
@property (nonatomic, strong) NSMutableArray *localSongsArray;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *activityIndicatorYConstraint;
- (IBAction)startButtonTouched:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *invisButton;
@property (weak, nonatomic) NSString *playListID;
@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;

@property (strong, nonatomic) IBOutlet UIView *loadingIndicator;
@end
