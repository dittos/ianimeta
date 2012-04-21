//
//  AMLoginViewController.m
//  ianimeta
//
//  Created by 태호 김 on 12. 4. 21..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "AMLoginViewController.h"

@interface AMLoginViewController ()

@end

@implementation AMLoginViewController
@synthesize usernameField;
@synthesize passwordField;

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
    [usernameField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setUsernameField:nil];
    [self setPasswordField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancel:(id)sender {
    [(UITabBarController *)self.presentingViewController setSelectedIndex:0];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doLogin:(id)sender {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            usernameField.text, @"username",
                            passwordField.text, @"password",
                            @"ios-app", @"app_token", // XXX
                            nil];
    [[AMClient sharedClient] postPath:@"auth/sessions/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        [[AMClient sharedClient] loginWithToken:[responseObject objectForKey:@"token"]];
        [self dismissModalViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        id responseObject = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:nil];
        [SVProgressHUD dismissWithError:[responseObject objectForKey:@"error"]];
        NSLog(@"%@", error);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == usernameField)
        [passwordField becomeFirstResponder];
    else if (textField == passwordField)
        [self doLogin:textField];
    return NO;
}

@end
