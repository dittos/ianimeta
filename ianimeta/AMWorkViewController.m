//
//  AMWorkViewController.m
//  ianimeta
//
//  Created by 태호 김 on 12. 4. 20..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "AMWorkViewController.h"
#import "AMVideoViewController.h"
#import "UIView+Layout.h"

NSString * const AMDaumTVPotAPIKey = @"657857ec3568fa992941ecbac875cc8261024953";

enum {
    ReviewSection,
    VideoSection
};

@interface AMReview : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *comment;

@end

@implementation AMReview

@synthesize userName, status, comment;

@end

@interface AMWorkViewController ()
{
    NSMutableArray *reviews;
    NSMutableArray *videos;
    NSUInteger currentVideoPage;
    BOOL hasNextPage;
}
@end

@implementation AMWorkViewController

@synthesize workTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = workTitle;
    
    reviews = [[NSMutableArray alloc] init];
    videos = [[NSMutableArray alloc] init];
    currentVideoPage = 0;
    
    [self loadReviews];
    [self loadVideos];
}

- (void)loadReviews
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            workTitle, @"work",
                            @"true", @"only_commented",
                            @"4", @"count",
                            nil];
    [[AMClient sharedClient] getPath:@"records" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [reviews removeAllObjects];
        for (NSDictionary *item in responseObject) {
            AMReview *review = [[AMReview alloc] init];
            review.userName = [item objectForKey:@"user"];
            review.comment = [item objectForKey:@"comment"];
            review.status = [item valueForKeyPath:@"status.text"];
            [reviews addObject:review];
        }
        [self.tableView reloadData];
    } failure:nil];
}

- (void)loadVideos
{
    const int perPage = 10;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            AMDaumTVPotAPIKey, @"apikey",
                            @"json", @"output",
                            [NSString stringWithFormat:@"%d", perPage], @"result",
                            workTitle, @"q",
                            [NSString stringWithFormat:@"%d", ++currentVideoPage], @"pageno",
                            nil];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://apis.daum.net/"]];
    [client getPath:@"search/vclip" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        hasNextPage = currentVideoPage < ([[data valueForKeyPath:@"channel.totalCount"] intValue] / perPage);
        [videos addObjectsFromArray:[data valueForKeyPath:@"channel.item"]];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == ReviewSection)
        return @"감상평";
    else if (section == VideoSection)
        return @"관련 동영상";
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == ReviewSection)
        return reviews.count;
    else if (section == VideoSection)
        return videos.count + (hasNextPage ? 1 : 0);
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == ReviewSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];
        AMReview *review = [reviews objectAtIndex:indexPath.row];
        UILabel *comment = (UILabel *)[cell viewWithTag:200];
        comment.text = review.comment;
        [comment sizeToFit];
        
        UILabel *detail = (UILabel *)[cell viewWithTag:300];
        detail.text = [NSString stringWithFormat:@"%@ / %@", review.status, review.userName];
        [detail putBelow:comment withTopMargin:0];
    } else if (indexPath.section == VideoSection) {
        if (indexPath.row == videos.count)
            return [tableView dequeueReusableCellWithIdentifier:@"LoadMoreCell"];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"VideoCell"];
        NSDictionary *video = [videos objectAtIndex:indexPath.row];
        [(UIImageView *)[cell viewWithTag:100] setImageWithURL:[NSURL URLWithString:[video objectForKey:@"thumbnail"]]];
        NSString *title = [video objectForKey:@"title"];
        // TODO: decode entity (fucking tvpot!)
        title = [title stringByReplacingOccurrencesOfString:@"&lt;b&gt;" withString:@""];
        title = [title stringByReplacingOccurrencesOfString:@"&lt;/b&gt;" withString:@""];
        [(UILabel *)[cell viewWithTag:200] setText:title];
        int duration = [[video objectForKey:@"playtime"] intValue];
        NSString *metadata = [video objectForKey:@"cpname"];
        if (duration != 0)
            metadata = [NSString stringWithFormat:@"%d분 %d초 / %@", duration / 60, duration % 60, metadata];
        [(UILabel *)[cell viewWithTag:300] setText:metadata];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != ReviewSection)
        return tableView.rowHeight;
    
    AMReview *review = [reviews objectAtIndex:indexPath.row];
    CGSize size = [review.comment sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(300, MAXFLOAT) lineBreakMode:UILineBreakModeCharacterWrap];
    return 5 + size.height + 24;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == VideoSection) {
        if (indexPath.row == videos.count) {
            [self loadVideos];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"WatchVideoSegue"]) {
        NSDictionary *video = [videos objectAtIndex:[self.tableView indexPathForCell:sender].row];
        AMVideoViewController *vc = segue.destinationViewController;
        vc.videoURL = [NSURL URLWithString:[video objectForKey:@"link"]];
    }
}

@end
