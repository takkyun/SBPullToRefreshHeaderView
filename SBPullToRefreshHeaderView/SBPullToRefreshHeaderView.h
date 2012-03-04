//
//  SBPullToRefreshHeaderView.h
//  SBPullToRefreshHeaderView
//
//  Created by Takuya Otani on 24/02/12.
//  Copyright (c) 2012 SerendipityNZ Ltd.
//
//  Inspired by EGOTableViewPullRefresh 
//              Developed by Devin Doty on 10/14/09 (c) 2009 enormego.
//

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <UIKit/UIKit.h>

@class SBPullToRefreshHeaderView;

/// The delegate of a SBPullToRefreshHeaderView object must adopt the 
/// SBPullToRefreshHeaderViewDelegate protocol.
@protocol SBPullToRefreshHeaderViewDelegate <NSObject>

/// Notifies a user releases the scroll view to refresh.
/// @param headerView - associated SBPullToRefreshHeaderView instance.
- (void)didTriggerRefresh:(SBPullToRefreshHeaderView *)headerView;

/// Tells whether the target object is still under loading state or not.
/// @param headerView - associated SBPullToRefreshHeaderView instance.
/// @return YES if it's still under loading, NO otherwise.
- (BOOL)isRefreshStillProcessing:(SBPullToRefreshHeaderView *)headerView;

@end

#pragma mark -

typedef enum {
  kSBRefreshHeaderIsNormal = 0,
  kSBRefreshHeaderIsPulled,
  kSBRefreshHeaderIsLoading,
  kSBRefreshHeaderUnkownState // It must be always last
} SBPullToRefreshHeaderViewState;

/// A view which is placed on the top of associated scroll view to handle
/// pull-to-refresh interaction.
@interface SBPullToRefreshHeaderView : UIView

/// An activity indicator to be shown during loading.
/// SBPullToRefreshHeaderViewDelegate tells whether the target is still under
/// the loading state or not.
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

/// A status label to be shown to indicate the current status of the view.
/// The label text can be set via setMessage:forState: method.
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

/// An arrow image to be shown to indicate a direction to pull.
@property (nonatomic, strong) IBOutlet UIImageView *refreshArrow;

/// A reload image to be shown on the view.
@property (nonatomic, strong) IBOutlet UIImageView *reloadImage;

/// A delegate to handle SBPullToRefreshHeaderViewDelegate protocol.
@property (nonatomic, weak) NSObject<SBPullToRefreshHeaderViewDelegate> *delegate;

/// Initializes an instance of SBPullToRefreshHeaderView with a given scroll 
/// view.
/// @param scrollView - a scroll view to be associated with.
/// @param delegate - a delegate object to handle SBPullToRefreshHeaderViewDelegate
/// @return an initialized instance. If it's failed, it will return nil.
- (id)initOnScrollView:(UIScrollView *)scrollView
          withDelegate:(NSObject<SBPullToRefreshHeaderViewDelegate> *)delegate;

/// Sets a message for the given state. The SBPullToRefreshHeaderView can show 
/// message for each state.
/// @param message - to be shown at the given state.
/// @param state - a given state to be updated.
- (void)setMessage:(NSString *)message
          forState:(SBPullToRefreshHeaderViewState)state;

/// Resets the position of the view and hide activity indeicator.
/// It effectively reverts back to the initial state (kSBRefreshHeaderIsNormal).
/// @param animated - if it's YES, a view will be back to normal with animation.
- (void)resetView:(BOOL)animated;

@end
