//
//  SPWKMasterViewController.h
//  StoryboardLintTest
//
//  Created by Johannes Fahrenkrug on 24.02.14.
//  Copyright (c) 2014 Johannes Fahrenkrug. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPWKDetailViewController;

@interface SPWKMasterViewController : UITableViewController

@property (strong, nonatomic) SPWKDetailViewController *detailViewController;

@end
