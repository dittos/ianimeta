//
//  AMLibraryViewController.m
//  ianimeta
//
//  Created by 태호 김 on 12. 4. 21..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "AMLibraryViewController.h"
#import "AMLibraryItem.h"
#import "ISO8601DateFormatter.h"

@interface AMLibraryViewController ()
{
    NSMutableArray *items;
}
@end

@implementation AMLibraryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    items = [[NSMutableArray alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[AMClient sharedClient] token])
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    else {
        [SVProgressHUD show];
        [[AMClient sharedClient] getPath:@"v1/me" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [items removeAllObjects];
            ISO8601DateFormatter *fmt = [[ISO8601DateFormatter alloc] init];
            for (NSDictionary *dict in [responseObject objectForKey:@"library_items"]) {
                AMLibraryItem *item = [[AMLibraryItem alloc] init];
                item.id = [[dict objectForKey:@"id"] unsignedIntegerValue];
                item.title = [dict objectForKey:@"title"];
                item.statusText = [dict valueForKeyPath:@"status.raw_text"];
                item.statusType = AMStatusTypeFromString([dict valueForKeyPath:@"status.type"]);
                item.updatedAt = [fmt dateFromString:[dict objectForKey:@"updated_at"]];
                [items addObject:item];
            }
            NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO];
            [items sortUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (operation.response.statusCode == 403) {
                [self performSegueWithIdentifier:@"LoginSegue" sender:self];
                [SVProgressHUD dismiss];
            } else {
                [SVProgressHUD dismissWithError:@"Error"];
            }
        }];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    AMLibraryItem *item = [items objectAtIndex:indexPath.row];
    
    cell.textLabel.text = item.title;
    NSString *status = AMStatusTextWithSuffix(item.statusText);
    if (item.statusType != AMStatusTypeWatching)
        status = [NSString stringWithFormat:@"%@ (%@)", status, AMStatusTypeString(item.statusType)];
    cell.detailTextLabel.text = status;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ItemDetailSegue"]) {
        AMLibraryItem *item = [items objectAtIndex:[self.tableView indexPathForCell:sender].row];
        NSLog(@"%d", item.id);
    }
}

@end
