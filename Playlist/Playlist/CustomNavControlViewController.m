//
//  CustomNavControlViewController.m
//  Playlist
//
//  Created by Chad Swenson on 6/21/13.
//  Copyright (c) 2013 Chad Swenson. All rights reserved.
//

#import "CustomNavControlViewController.h"
#import "UIColor+FlatUI.h"

@interface CustomNavControlViewController ()

@end

@implementation CustomNavControlViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
   // [self.navigationBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
