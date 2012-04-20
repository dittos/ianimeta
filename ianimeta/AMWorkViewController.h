//
//  AMWorkViewController.h
//  ianimeta
//
//  Created by 태호 김 on 12. 4. 20..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMWorkViewController : UITableViewController

@property (strong, nonatomic) NSString *workTitle;

- (void)loadReviews;
- (void)loadVideos;

@end
