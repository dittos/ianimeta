//
//  AMLibraryItem.h
//  ianimeta
//
//  Created by 태호 김 on 12. 4. 21..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AMStatusTypeWatching,
    AMStatusTypeFinished,
    AMStatusTypeSuspended,
    AMStatusTypeInterested,
} AMStatusType;

AMStatusType AMStatusTypeFromString(NSString *string);
NSString *AMStatusTypeString(AMStatusType statusType);
NSString *AMStatusTextWithSuffix(NSString *statusText);

@interface AMLibraryItem : NSObject

@property (assign, nonatomic) NSUInteger id;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *statusText;
@property (assign, nonatomic) AMStatusType statusType;
@property (copy, nonatomic) NSDate *updatedAt;

@end
