//
//  MainViewController.h
//  Playlist
//
//  Created by Chad Swenson on 6/19/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FUIButton.h"


@interface MainViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *playListTablieView;
@property (strong, nonatomic) IBOutlet FUIButton *addPlayListButton;

@property (strong, nonatomic) NSMutableArray *availablePlayLists;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loader;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;
@property (strong, nonatomic) IBOutlet UINavigationItem *test;
@property (strong, nonatomic) NSManagedObjectContext        *   managedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator  *   persistentStoreCoordinator;
@property (strong, nonatomic) IBOutlet FUIButton *goBackButton;
@property (strong, nonatomic) IBOutlet UIView *noPlaylistsIndicator;


- (IBAction)addPlayListTouched:(id)sender;

@end
