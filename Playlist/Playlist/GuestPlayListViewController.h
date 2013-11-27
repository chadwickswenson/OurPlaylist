//
//  GuestPlayListViewController.h
//  Playlist
//
//  Created by Chad Swenson on 6/19/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>
@interface GuestPlayListViewController : UIViewController <UIActionSheetDelegate, MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) NSString *playListID;
@property (weak, nonatomic) NSString *playListTitle;
@property (weak, nonatomic) NSString *playListHost;
@property (weak, nonatomic) IBOutlet UITableView *songTableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *titleNavItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIButton *refreshBut;
- (IBAction)refreshTouched:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *pinchTutView;
@property (strong, nonatomic) IBOutlet UIView *swipeRightTut;
@property (strong, nonatomic) IBOutlet UIView *swipeLeftTut;
- (IBAction)back:(id)sender;




- (IBAction)inviteFriendsTouched:(id)sender;

- (IBAction)refreshButtonTouched:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext        *   managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator  *   persistentStoreCoordinator;
@property (strong, nonatomic) NSArray *songsArray;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *listViewLoader;
@property (nonatomic, strong) SLComposeViewController *mySLComposerSheet;
@property (weak, nonatomic) NSString *searchText;

- (IBAction)tablePinched:(id)sender;

@end
