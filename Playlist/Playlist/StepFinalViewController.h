//
//  StepFinalViewController.h
//  Playlist
//
//  Created by Chad Swenson on 6/19/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <FacebookSDK/FacebookSDK.h>

@interface StepFinalViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *startPlayListButton;

@property (nonatomic, strong) NSString *playListTitleString;
@property (nonatomic, strong) NSMutableArray *localPlayListsArray;
@property (nonatomic, strong) NSMutableArray *localSongsArray;
- (IBAction)selectFriendsTouched:(id)sender;
- (IBAction)startPlayListTouched:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addFriendsButton;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) NSArray* selectedFriends;

@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;
@end

