//
//  AMClient.m
//  ianimeta
//
//  Created by 태호 김 on 12. 4. 20..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "AMClient.h"

@implementation AMClient

+ (AMClient *)sharedClient
{
    static AMClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[AMClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://animeta.net/api/v1/"]];
    });
    return client;
}

- (id)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL:url]) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }
    return self;
}

@end
