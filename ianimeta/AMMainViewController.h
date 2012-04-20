//
//  AMMainViewController.h
//  ianimeta
//
//  Created by 태호 김 on 12. 4. 19..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMMainViewController : UIViewController <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *chartTableView;

- (void)loadChart;

@end
