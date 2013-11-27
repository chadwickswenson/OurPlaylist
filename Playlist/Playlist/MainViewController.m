//
//  MainViewController.m
//  Playlist
//
//  Created by Chad Swenson on 6/19/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
//#import <FacebookSDK/FacebookSDK.h>
//#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import "FriendsPlayListsCell.h"
#import "ProjectConstants.h"
#import "GuestPlayListViewController.h"
#import "PLAppDelegate.h"
#import "AdminPlayListViewController.h"
#import "UIBarButtonItem+FlatUI.h"

@interface MainViewController (){
    NSString *playListTitleString;
    NSString *playListIDString;
    BOOL hideGoBackButton;
    BOOL hideCreateButton;
}

@end

@implementation MainViewController{

    IBOutlet CLLocationManager *locationManager;
    
    PFGeoPoint *myPoint;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    self.playListTablieView.backgroundView = nil;
    NSLog(@"mainview loaded");
    
    self.goBackButton.layer.cornerRadius = 4; // this value vary as per your desire
    self.goBackButton.clipsToBounds = YES;
    
    self.addPlayListButton.layer.cornerRadius = 4; // this value vary as per your desire
    self.addPlayListButton.clipsToBounds = YES;
    
    //self.addPlayListButton.buttonColor = [UIColor cloudsColor];
    /*
    
    
    
 
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor clearColor] forKey:UITextAttributeTextShadowColor],[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:UITextAttributeTextColor] ;
  self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:UITextAttributeTextColor];*/
    
   /* [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor colorWithRed:246 / 255.0 green:246 / 255.0 blue:246 / 255.0 alpha:1.0]];
    
       self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:UITextAttributeTextColor],[NSDictionary dictionaryWithObject:[UIColor clearColor] forKey:UITextAttributeTextShadowColor] ;
    
   */

    
    //self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:UITextAttributeTextColor];
  
    
   /* [_back setType:PBFlatIconBack];
    [_forward setType:PBFlatIconForward];
    [_menu setType:PBFlatIconMenu];
    [_search setType:PBFlatIconSearch];*/
  //  [UIBarButtonItem configureFlatButtonsWithColor:[UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:1.0]highlightedColor:[UIColor whiteColor]cornerRadius:3];
   // UINavigationBar* navBar = self.navigationController.navigationBar;
   // int borderSize = 1;
    //UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,navBar.frame.size.height-borderSize,navBar.frame.size.width, borderSize)];
   // UIColor *bg = [UIColor colorWithRed:238 / 255.0 green:38 / 255.0 blue:57 / 255.0 alpha:1.0];
    
   // [navBorder setBackgroundColor:bg];
  //  navBorder.alpha = 1;
    //[self.navigationController.navigationBar addSubview:navBorder];
   // UIImage *navBarImg = [UIImage imageNamed:@"nav-bg.png"];
    //[self.navigationController.navigationBar setBackgroundImage:navBarImg forBarMetrics:UIBarMetricsDefault];
    
}
-(void) resetCoreData{
    NSError *error;
    
    PLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    // retrieve the store URL
    NSURL * storeURL = [[context persistentStoreCoordinator] URLForPersistentStore:[[[context persistentStoreCoordinator] persistentStores] lastObject]];
    // lock the current context
    [context lock];
    [context reset];//to drop pending changes
    //delete the store from the current managedObjectContext
    if ([[context persistentStoreCoordinator] removePersistentStore:[[[context persistentStoreCoordinator] persistentStores] lastObject] error:&error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        //recreate the store like in the  appDelegate method
        [[context persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
    }
    [context unlock];
    ///////
    //Make new persistent store for future saves   (Taken From Above Answer)
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // do something with the error
    }
    
    NSLog(@"Data Reset");
}
- (void)viewWillAppear:(BOOL)animated {
    hideCreateButton = YES;
    hideGoBackButton = YES;
    [super viewWillAppear:animated];
    NSLog(@"main view appeared");
    [self.addPlayListButton setHidden:YES];
    [self.goBackButton setHidden:YES];
    
    self.playListTablieView.separatorColor = [UIColor colorWithRed:229 / 255.0 green:229 / 255.0 blue:229 / 255.0 alpha:1.0];
    
  
   
    ///////////
    [self resetCoreData];
    
    //PFUser *userObject = [PFUser currentUser];
    
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
         NSLog(@"anon");
    } else {
        //[self.facebookLoginButton setHidden:YES];
    }
   
    
    [self togglePlayListViewLoading: 1];
    
    if([self getAvailablePlaylistAndPopulate]){
        
    }
    else{
        //TODO HANDLE PLAYLIST FAILURE
    }

    // see if they have a playlist
    

    
}
-(void)togglePlayListViewLoading: (NSInteger)type{

    
    if(type == 1){
       
        self.loader.alpha = 1.0;
        self.loadingLabel.alpha = 1.0;
        [self.loader startAnimating];
        [self.addPlayListButton setHidden:(YES)];
        [self.goBackButton setHidden:YES];
        [self.noPlaylistsIndicator setHidden:YES];
    }
    else if(type == 2){
        [UIView animateWithDuration:1 animations:^() {

            self.loader.alpha = 0;
            self.loadingLabel.alpha = 0;
        }];
        [self.loader stopAnimating];
        [self.goBackButton setHidden:hideGoBackButton];
        [self.addPlayListButton setHidden:hideCreateButton];
        
    }
}
-(BOOL)getAvailablePlaylistAndPopulate{

    BOOL ret = YES;

    self.availablePlayLists = [[NSArray alloc] init];

    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {

        if (!error) {
            
            PFQuery *query = [PFQuery queryWithClassName:@"PlayList"];

            [query whereKey:@"location" nearGeoPoint:geoPoint withinMiles:3.0];
          
        
            myPoint = geoPoint;

            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
 
                if (!error) {

                    NSLog(@"Successfully retrieved %d scores.", objects.count);
                    
                    if ([objects count] == 0)
                    {
                        [self.noPlaylistsIndicator setHidden:NO];
                        hideCreateButton = NO;
                        [self.addPlayListButton setHidden:hideCreateButton];
                    }
                    else{
                        [self.noPlaylistsIndicator setHidden:YES];
                        self.availablePlayLists = objects;
                        [self.playListTablieView reloadData];
                        PFQuery *query = [PFQuery queryWithClassName:@"PlayList"];
                        
                        [query whereKey:@"user" equalTo:[PFUser currentUser]];
                        if ([self.noPlaylistsIndicator isHidden])
                        {

                            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                if (!error) {
                                    if(objects.count > 0){
                                        
                                        NSLog(@"count > 0");
                                        playListIDString = [objects[0] valueForKey:@"objectId"];
                                        NSLog(@"arr size %lu", (unsigned long)objects.count);
                                        playListTitleString = [objects[0] valueForKey:@"title"];
                                        //[self.addPlayListButton setHidden:YES];
                                        [self.goBackButton setHidden:NO];
                                        hideGoBackButton = NO;
                                        hideCreateButton = YES;
                                        NSLog(@"updating playlists");
                                    }
                                    else{
                                        NSLog(@"none");
                                        hideGoBackButton = YES;
                                        hideCreateButton = NO;
                                        [self.addPlayListButton setHidden:NO];
                                    }
                                    
                                }
                                else {
                                    
                                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                                    [self.addPlayListButton setHidden:NO];
                                    hideCreateButton = NO;
                                    
                                }
                                
                            }];
                        }                    }
                    
                    [self togglePlayListViewLoading: 2];
                   
                }
                else {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
                
            }];
            
        }
        else{
            NSLog(@"location failesd");
              [self togglePlayListViewLoading: 2];
            [self.noPlaylistsIndicator setHidden:NO]; //make u have no interwebs
            [self.addPlayListButton setHidden:NO];
           
            //TODO just get invites
            
        }
    }];
   
    
    return ret;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginFacebookTouched:(id)sender {
    
    /*PFUser *user = [PFUser currentUser];
    NSLog(@"pressed");
    [self.facebookLoginButton setHidden:YES];
     NSLog(@"2");
    if (![PFFacebookUtils isLinkedWithUser:user]) {
        [PFFacebookUtils linkUser:user permissions:nil block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Woohoo, user logged in with Facebook!");
            }
            else{
                [self.facebookLoginButton setHidden:NO];
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }*/
   /* NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //[_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            //[self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
        } else {
            NSLog(@"User with facebook logged in!");
            //[self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
        }
    }];*/
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"MainViewToPlayListView"]) {
        NSArray *cells = [self.playListTablieView visibleCells];
        
        for (FriendsPlayListsCell *cell in cells)
        {
            if(cell.selected){
               
               NSLog(@"playlist id: %@", cell.playListID);
                GuestPlayListViewController *destViewController = segue.destinationViewController;
                destViewController.playListID =  cell.playListID;
                //destViewController.playListHost = [[self.availablePlayLists objectAtIndex:indexPath.row] objectForKey:@"host"];
                destViewController.playListTitle =  cell.title.text;
                
                NSLog(@"changing");
                break;
            }
             
           
            
        }
      /*  NSIndexPath *indexPath = [self.playListTablieView indexPathForSelectedRow];
        GuestPlayListViewController *destViewController = segue.destinationViewController;
        FriendsPlayListsCell *cell2 =  [self.playListTablieView cellForRowAtIndexPath: indexPath];
        destViewController.playListID =  cell2.playListID;
        //destViewController.playListHost = [[self.availablePlayLists objectAtIndex:indexPath.row] objectForKey:@"host"];
        destViewController.playListTitle =  cell2.playListTitle.text;*/
        NSLog(@"changing");
    }
    else if([segue.identifier isEqualToString:@"GoBackToAdmin"]) {
       AdminPlayListViewController *destViewController = segue.destinationViewController;
        destViewController.playListID = playListIDString;
        destViewController.playListTitle = playListTitleString;
        
    }
    if ([self.availablePlayLists count] != 0)
    {
        [self.availablePlayLists removeAllObjects];
        [self.playListTablieView reloadData];
    }
}


- (IBAction)addPlayListTouched:(id)sender {
    
   

}

- (NSString *)deviceLocation {
    NSString *theLocation = [NSString stringWithFormat:@"latitude: %f longitude: %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
    return theLocation;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    return [self.availablePlayLists count];//[playLists count];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    // Return NO if you do not want the specified item to be editable.
    
    return NO;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"updating playlists id: %ld", (long)indexPath.row);
    PFObject *currentPlayList = [self.availablePlayLists objectAtIndex:indexPath.row];
    
    FriendsPlayListsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsPlayListCell"];
    
    
    if (!cell) {
        cell = [[ FriendsPlayListsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"friendsPlayListCell"];
    }
    
    cell.title.text = [[self.availablePlayLists objectAtIndex: indexPath.row] objectForKey:@"title"];
    //cell.playListHost.text = [NSString stringWithFormat:@"%f",[myPoint distanceInMilesTo:[[self.availablePlayLists objectAtIndex: indexPath.row] objectForKey:@"location"]]];
    
    //cell.playListHost.text = [[self.availablePlayLists objectAtIndex: indexPath.row] objectForKey:@"host"];
    cell.playListID = currentPlayList.objectId;
    //double x = [myPoint distanceInMilesTo:[[self.availablePlayLists objectAtIndex: indexPath.row] objectForKey:@"location"]];
   
   // cell.contentView.backgroundColor =[UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:0.7];
    //cell.accessoryView.backgroundColor =[UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:0.7];
    
   // cell.imageView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:0.7];
   // cell.backgroundView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:0.7];
   // cell.contentView.superview.backgroundColor = [UIColor greenColor];
   // cell.backgroundColor = [UIColor yellowColor];
    cell.accessoryView.contentMode = UIViewContentModeScaleAspectFit;
    //cell.myPoint = myPoint;
    //cell.playlistLocation = [[self.availablePlayLists objectAtIndex: indexPath.row] objectForKey:@"location"];
    //NSLog(@"updating playlists id: %@", cell.playListID);
    
    /*if(x < 0.025){
        cell.playListInfo.text = LOC1;
    }
    else if(x < 0.35){
        cell.playListInfo.text = LOC2;
    }
    else if(x < 0.5){
        cell.playListInfo.text = LOC3;
    }
    else if(x < 1){
        cell.playListInfo.text = LOC4;
    }
    else{
        cell.playListInfo.text = LOC5;
    }*/
    
    return cell;
}



@end
