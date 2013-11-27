//
//  AdminPlayListViewController.h
//  Playlist
//
//  Created by Chad Swenson on 6/19/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "REMenu.h"

@interface AdminPlayListViewController : UIViewController <UIActionSheetDelegate,MFMessageComposeViewControllerDelegate>
@property (strong, nonatomic) NSString *playListID;
@property (weak, nonatomic) NSString *playListTitle;
@property (weak, nonatomic) NSString *playListHost;
@property (weak, nonatomic) IBOutlet UITableView *songTableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *titleNavItem;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *nextSongButton;
@property (strong, nonatomic) IBOutlet UIButton *menuStart;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loader;
@property (strong, nonatomic) IBOutlet UINavigationItem *titleNavBar;
@property (strong, nonatomic) IBOutlet UIButton *navBarMenuButton;

@property (strong, nonatomic) IBOutlet UILabel *songNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *artistLabel;
- (IBAction)inviteFriendsTouched:(id)sender;
- (IBAction)volumeChanged:(id)sender;
- (IBAction)playPause:(id)sender;
- (IBAction)nextSong:(id)sender;
- (IBAction)menuButtonTouched:(UIBarButtonItem *)sender;
- (IBAction)menuTouched:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *deletingPlaylistIndicator;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (nonatomic, retain) NSManagedObjectContext        *   managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator  *   persistentStoreCoordinator;
@property (strong, nonatomic) NSArray *songsArray;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *listViewLoader;
@property (nonatomic, strong) SLComposeViewController *mySLComposerSheet;
@property (strong, nonatomic) MPMediaItem *nextSong;
@property (strong, nonatomic) NSTimer *chooseSongTimer;

@property (strong, readonly, nonatomic) REMenu *menu;
@end
