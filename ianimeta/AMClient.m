//
//  AMClient.m
//  ianimeta
//
//  Created by 태호 김 on 12. 4. 20..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "AMClient.h"

NSString * const AMClientSessionTokenUserDefaultsKey = @"AnimetaSessionToken";

@implementation AMClient

+ (AMClient *)sharedClient
{
    static AMClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[AMClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://animeta.net/api/"]];
    });
    return client;
}

- (id)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL:url]) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setToken:[[NSUserDefaults standardUserDefaults] stringForKey:AMClientSessionTokenUserDefaultsKey]];
    }
    return self;
}

- (NSString *)token
{
    return [self defaultValueForHeader:@"X-Animeta-Token"];
}

- (void)setToken:(NSString *)token
{
    if (token)
        [self setDefaultHeader:@"X-Animeta-Token" value:token];
}

- (void)loginWithToken:(NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:AMClientSessionTokenUserDefaultsKey];
    [defaults synchronize];
    
    [self setToken:token];
}

@end
