//
//  AMMainViewController.m
//  ianimeta
//
//  Created by 태호 김 on 12. 4. 19..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "AMMainViewController.h"
#import "AMWorkViewController.h"
#import "AMWorkRankCell.h"

@interface AMSuggestionItem : NSObject

@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) NSUInteger rank;

@end

@implementation AMSuggestionItem

@synthesize title, rank;

@end

@interface AMWorkChartItem : NSObject

@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) NSUInteger rank;
@property (assign, nonatomic) NSInteger rankDiff;

@end

@implementation AMWorkChartItem

@synthesize title, rank, rankDiff;

@end

@interface AMMainViewController () {
    NSMutableArray *suggests;
    NSMutableArray *chart;
}
@end

@implementation AMMainViewController
@synthesize chartTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    suggests = [[NSMutableArray alloc] init];
    chart = [[NSMutableArray alloc] init];
    [self loadChart];
}

- (void)loadChart
{
    [[AMClient sharedClient] getPath:@"v1/charts/work?period=week&count=20" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [chart removeAllObjects];
        for (NSDictionary *item in [responseObject objectForKey:@"items"]) {
            AMWorkChartItem *chartItem = [[AMWorkChartItem alloc] init];
            chartItem.title = [item objectForKey:@"work"];
            chartItem.rank = [[item objectForKey:@"rank"] unsignedIntegerValue];
            if ([item objectForKey:@"diff"])
                chartItem.rankDiff = [[item objectForKey:@"diff"] integerValue];
            else
                chartItem.rankDiff = 0;
            [chart addObject:chartItem];
        }
        [chartTableView reloadData];
    } failure:nil];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if ([searchString isEqualToString:@""]) {
        [suggests removeAllObjects];
        return YES;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            searchString, @"keyword",
                            nil];
    [[AMClient sharedClient] getPath:@"works" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [suggests removeAllObjects];
        for (NSDictionary *item in responseObject) {
            AMSuggestionItem *suggestion = [[AMSuggestionItem alloc] init];
            suggestion.title = [item objectForKey:@"title"];
            suggestion.rank = [[item objectForKey:@"rank"] unsignedIntegerValue];
            [suggests addObject:suggestion];
        }
        [controller.searchResultsTableView reloadData];
    } failure:nil];
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == chartTableView)
        return chart.count;
    else
        return suggests.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == chartTableView)
        return @"주간 인기 작품";
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == chartTableView) {
        AMWorkRankCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkRankCell"];
        AMWorkChartItem *item = [chart objectAtIndex:indexPath.row];
        cell.titleLabel.text = item.title;
        cell.rankLabel.text = [NSString stringWithFormat:@"%d위", item.rank];
        if (item.rankDiff == 0) {
            cell.rankDiffLabel.text = @"";
            cell.rankDiffLabel.textColor = [UIColor blackColor];
        } else {
            cell.rankDiffLabel.text = [NSString stringWithFormat:@"%+d", item.rankDiff];
            cell.rankDiffLabel.textColor = item.rankDiff < 0 ? [UIColor blueColor] : [UIColor redColor];
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        }
        AMSuggestionItem *item = [suggests objectAtIndex:indexPath.row];
        cell.textLabel.text = item.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d위", item.rank];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"WorkDetailSegue" sender:[[suggests objectAtIndex:indexPath.row] title]];
        self.searchDisplayController.active = NO;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"WorkDetailSegue"]) {
        AMWorkViewController *vc = segue.destinationViewController;
        if ([sender isKindOfClass:[NSString class]]) {
            vc.workTitle = sender;
        } else {
            AMWorkChartItem *item = [chart objectAtIndex:[chartTableView indexPathForCell:sender].row];
            vc.workTitle = item.title;
        }
    }
}

- (void)viewDidUnload
{
    [self setChartTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
