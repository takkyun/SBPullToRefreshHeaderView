//
//  SBViewController.m
//  SBPullToRefreshHeaderView
//
//  Created by Takuya Otani on 24/02/12.
//  Copyright (c) 2012 SerendipityNZ Ltd. All rights reserved.
//

#import "SBViewController.h"

@interface SBViewController ()

@end

@implementation SBViewController
{
@private
  SBPullToRefreshHeaderView *mRefreshHeaderView;
  BOOL mIsReloading;
}


#pragma mark -
#pragma mark === UIViewController overridden

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  if (mRefreshHeaderView == nil)
  {
    mRefreshHeaderView = [[SBPullToRefreshHeaderView alloc] initOnScrollView:self.tableView
                                                                withDelegate:self];
    
    // setup messages ...
    [mRefreshHeaderView setMessage:NSLocalizedString(@"Pull down to refresh ...",@"")
                          forState:kSBRefreshHeaderIsNormal];
    [mRefreshHeaderView setMessage:NSLocalizedString(@"Release to refresh ...",@"")
                          forState:kSBRefreshHeaderIsPulled];
    [mRefreshHeaderView setMessage:NSLocalizedString(@"Loading ...",@"")
                          forState:kSBRefreshHeaderIsLoading];
  }
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark -
#pragma mark === private methods 

- (void)reloadTableViewDataSource
{
	// should be calling your tableviews data source model to reload put here just
  // for demo
	mIsReloading = YES;
}

- (void)doneLoadingTableViewData
{
	// model should call this when its done loading
	mIsReloading = NO;
  [mRefreshHeaderView resetView:YES];
}

#pragma mark -
#pragma mark === SBPullToRefreshHeaderViewDelegate

- (void)didTriggerRefresh:(SBPullToRefreshHeaderView *)headerView
{
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData)
             withObject:nil
             afterDelay:3.0];
}

- (BOOL)isRefreshStillProcessing:(SBPullToRefreshHeaderView *)headerView
{
  return mIsReloading;
}

#pragma mark -
#pragma mark === UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 10;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  if (cell == nil)
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"Cell"];
  }
  cell.textLabel.text = [NSString stringWithFormat:@"Row %i", indexPath.row];
  return cell;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
	return [NSString stringWithFormat:@"Section %i", section];
}

#pragma mark -
#pragma mark === UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath
                           animated:YES];
}

@end
