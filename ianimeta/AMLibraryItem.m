//
//  AMLibraryItem.m
//  ianimeta
//
//  Created by 태호 김 on 12. 4. 21..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "AMLibraryItem.h"

AMStatusType AMStatusTypeFromString(NSString *string)
{
    if ([string isEqualToString:@"finished"])
        return AMStatusTypeFinished;
    else if ([string isEqualToString:@"suspended"])
        return AMStatusTypeSuspended;
    else if ([string isEqualToString:@"interested"])
        return AMStatusTypeInterested;
    return AMStatusTypeWatching;
}

NSString *AMStatusTypeString(AMStatusType statusType)
{
    switch (statusType) {
        case AMStatusTypeWatching: return @"보는 중";
        case AMStatusTypeFinished: return @"완료";
        case AMStatusTypeSuspended: return @"중단";
        case AMStatusTypeInterested: return @"볼 예정";
    }
}

NSString *AMStatusTextWithSuffix(NSString *statusText)
{
    if (statusText.length > 0 && isdigit([statusText characterAtIndex:statusText.length - 1]))
        return [statusText stringByAppendingString:@"화"];
    
    return statusText;
}

@implementation AMLibraryItem

@synthesize id, title, statusText, statusType, updatedAt;

@end
