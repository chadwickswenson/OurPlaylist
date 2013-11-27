//
//  PLMasterViewController.h
//  Playlist
//
//  Created by Chad Swenson on 6/17/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>

@class PLDetailViewController;

#import <CoreData/CoreData.h>

@interface PLMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) PLDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
