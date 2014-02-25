//
//  SPWKDetailViewController.h
//  StoryboardLintTest
//
//  Created by Johannes Fahrenkrug on 24.02.14.
//  Copyright (c) 2014 Johannes Fahrenkrug. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPWKDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
