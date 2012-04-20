//
//  AMVideoViewController.h
//  ianimeta
//
//  Created by 태호 김 on 12. 4. 20..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMVideoViewController : UIViewController <UIWebViewDelegate>

@property (copy, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
