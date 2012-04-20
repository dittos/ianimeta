//
//  AMClient.h
//  ianimeta
//
//  Created by 태호 김 on 12. 4. 20..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "AFNetworking.h"

@interface AMClient : AFHTTPClient

+ (AMClient *)sharedClient;

@end
