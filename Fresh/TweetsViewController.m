//
//  TweetsViewController.m
//  Fresh
//
//  Created by James Cryer on 17/03/2013.
//  Copyright (c) 2013 James Cryer. All rights reserved.
//

#import "TweetsViewController.h"

@interface TweetsViewController ()

- (NSURL *)url;
- (void)refresh:(id)sender;

@end

@implementation TweetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];

    [self setRefreshControl:refreshControl];
    [self refresh:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tweets ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tweets count] ? [self.tweets count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *tweet = [self.tweets objectAtIndex:[indexPath row]];
    
    [cell.textLabel setText:[tweet objectForKey:@"text"]];
    [cell.detailTextLabel setText:[tweet objectForKey:@"from_user"]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    NSURL *url = [NSURL URLWithString:[tweet objectForKey:@"profile_image_url"]];
    [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    return cell;
}

#pragma mark - Refresh

- (void)refresh:(id)sender
{
    NSURL *url = [self url];

    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray *results = [(NSDictionary *)JSON objectForKey:@"results"];
        if ([results count]) {
            self.tweets = results;

            [self.tableView reloadData];
            [(UIRefreshControl *)sender endRefreshing];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {

        [(UIRefreshControl *)sender endRefreshing];
    }];

    [operation start];
}

- (NSURL *)url
{
    return [NSURL URLWithString:@"http://search.twitter.com/search.json?q=ios%20development&rpp=100&include_entities=true&result_type=mixed/"];
}

@end
