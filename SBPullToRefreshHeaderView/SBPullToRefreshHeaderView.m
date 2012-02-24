//
//  SBPullToRefreshHeaderView.m
//  SBPullToRefreshHeaderView
//
//  Created by Takuya Otani on 24/02/12.
//  Copyright (c) 2012 SerendipityNZ Ltd. All rights reserved.
//
//  Inspired by EGOTableViewPullRefresh 
//              Developed by Devin Doty on 10/14/09 (c) 2009 enormego
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

#import <QuartzCore/QuartzCore.h>
#import "SBPullToRefreshHeaderView.h"

#define kSBPullToRefreshHeaderViewAnimationOption \
  UIViewAnimationOptionTransitionNone | \
  UIViewAnimationOptionCurveEaseInOut | \
  UIViewAnimationOptionAllowUserInteraction

@interface SBPullToRefreshHeaderView ()

- (void)setState:(SBPullToRefreshHeaderViewState)state;

@end

#pragma mark -

@implementation SBPullToRefreshHeaderView
{
@private
  __strong UIActivityIndicatorView *mActivityIndicator;
  __strong UILabel *mStatusLabel;
  __strong UIImageView *mRefreshArrow;
  __strong UIImageView *mReloadImage;
  __strong NSMutableDictionary *mMessages;
  __weak NSObject<SBPullToRefreshHeaderViewDelegate> *mDelegate;
  __weak UIScrollView *mScrollView;
  SBPullToRefreshHeaderViewState mState;
  BOOL mIsDragging;
  CGFloat mViewHeight;
}

@synthesize activityIndicator = mActivityIndicator;
@synthesize statusLabel       = mStatusLabel;
@synthesize refreshArrow      = mRefreshArrow;
@synthesize reloadImage       = mReloadImage;
@synthesize delegate          = mDelegate;

#pragma mark -
#pragma mark === initialization

- (id)initOnScrollView:(UIScrollView *)scrollView
          withDelegate:(NSObject<SBPullToRefreshHeaderViewDelegate> *)delegate
{
  self = (SBPullToRefreshHeaderView *)[[[NSBundle mainBundle] loadNibNamed:@"SBPullToRefreshHeaderView"
                                                                     owner:nil
                                                                   options:nil] objectAtIndex:0];
  if (self)
  {
    mDelegate   = delegate;
    mScrollView = scrollView;
    mViewHeight = CGRectGetHeight(self.refreshArrow.bounds);
    mMessages   = [NSMutableDictionary dictionaryWithCapacity:kSBRefreshHeaderUnkownState];
    mIsDragging = mScrollView.isDragging;
    
    CGRect frame = self.bounds;
    frame.origin.y    = - CGRectGetHeight(scrollView.bounds);
    frame.size.width  = CGRectGetWidth(scrollView.bounds);
    frame.size.height = CGRectGetHeight(scrollView.bounds);
    [self setFrame:frame];
    
    // setup default messages ...
    [self setMessage:@"Pull down to refresh ..."
            forState:kSBRefreshHeaderIsNormal];
    [self setMessage:@"Release to refresh ..."
            forState:kSBRefreshHeaderIsPulled];
    [self setMessage:@"Loading ..."
            forState:kSBRefreshHeaderIsLoading];
    
    // Initializes a state as normal
    [self setState:kSBRefreshHeaderIsNormal];

    [mScrollView addSubview:self];
  }
  return self;
}

#pragma mark -
#pragma mark === finalization

- (void)dealloc
{
}

#pragma mark -
#pragma mark === private methods

- (void)setState:(SBPullToRefreshHeaderViewState)state
{
  void (^changeState)() = ^()
  {
    switch (state)
    {
      case kSBRefreshHeaderIsNormal:
      {
        self.refreshArrow.alpha = 1.f;
        self.activityIndicator.alpha = 0.f;
        self.reloadImage.alpha = 0.f;
        self.refreshArrow.layer.transform = CATransform3DIdentity;
        break;
      }
      case kSBRefreshHeaderIsPulled:
      {
        self.refreshArrow.alpha = 0.f;
        self.activityIndicator.alpha = 0.f;
        self.reloadImage.alpha = 1.f;
        self.refreshArrow.layer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 175.0f,
                                                                      0.0f,
                                                                      0.0f,
                                                                      1.0f);
        break;
      }
      case kSBRefreshHeaderIsLoading:
      {
        self.refreshArrow.alpha = 0.f;
        self.activityIndicator.alpha = 1.f;
        self.reloadImage.alpha = 0.f;
        break;
      }
      case kSBRefreshHeaderUnkownState:
        break;
    } // end of switch (state)
  };
  
  [UIView animateWithDuration:0.2
                        delay:0.f
                      options:kSBPullToRefreshHeaderViewAnimationOption
                   animations:changeState
                   completion:nil];
  
  mState = state;
  if (self.activityIndicator.alpha > 0)
  {
    [self.activityIndicator startAnimating];
  }
  else
  {
    [self.activityIndicator stopAnimating];
  }
  self.statusLabel.text = [mMessages objectForKey:[NSString stringWithFormat:@"msg%d",
                                                   mState]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if (mState == kSBRefreshHeaderIsLoading)
  {
    CGFloat offset = 0.f;
    offset = MAX(scrollView.contentOffset.y * -1, offset);
    offset = MIN(offset, mViewHeight);
    scrollView.contentInset = UIEdgeInsetsMake(offset, 0.f, 0.f, 0.f);
  }
  else if (scrollView.isDragging)
  {
    BOOL isLoading = [self.delegate isRefreshStillProcessing:self];
    if (!isLoading)
    {
      if (mState == kSBRefreshHeaderIsPulled &&
          scrollView.contentOffset.y > - mViewHeight &&
          scrollView.contentOffset.y < 0.f)
      {
        [self setState:kSBRefreshHeaderIsNormal];
      }
      else if (mState == kSBRefreshHeaderIsNormal &&
               scrollView.contentOffset.y < - mViewHeight)
      {
        [self setState:kSBRefreshHeaderIsPulled];
      }
    }
    if (mScrollView.contentInset.top != 0)
    {
      mScrollView.contentInset = UIEdgeInsetsZero;
    }
  }
}

- (void)stopDragging
{
  BOOL isLoading = [self.delegate isRefreshStillProcessing:self];
  if (!isLoading &&
      mScrollView.contentOffset.y <= - mViewHeight)
  {
    [self.delegate didTriggerRefresh:self];
    [self setState:kSBRefreshHeaderIsLoading];
    [UIView animateWithDuration:0.2
                          delay:0.f
                        options:kSBPullToRefreshHeaderViewAnimationOption
                     animations:^()
     {
       mScrollView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.bounds),
                                                   0.f,
                                                   0.f,
                                                   0.f);
     }
                     completion:nil];
  }
}

#pragma mark -
#pragma mark === NSObject(NSKeyValueObserving)

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if (object == mScrollView &&
      [keyPath isEqual:@"contentOffset"])
  {
    [self scrollViewDidScroll:mScrollView];
    if (mIsDragging != mScrollView.isDragging)
    {
      if (!mScrollView.isDragging)
      {
        [self stopDragging];
      }
      mIsDragging = mScrollView.isDragging;
    }
  }
}

#pragma mark -
#pragma mark === UIView overridden

- (void)didMoveToSuperview
{
  if (self.superview == mScrollView)
  { // The view has been added into the target scroll view so it starts 
    // observing contentOffset changes.
    [mScrollView addObserver:self 
                  forKeyPath:@"contentOffset" 
                     options:NSKeyValueObservingOptionNew 
                     context:nil];
  }
  else
  { // The view has been removed from the target scroll view so it stops 
    // observing contentOffset changes.
    [mScrollView removeObserver:self
                     forKeyPath:@"contentOffset"];
  }
}

#pragma mark -
#pragma mark === instance methods

- (void)setMessage:(NSString *)message
          forState:(SBPullToRefreshHeaderViewState)state;
{
  if (state == kSBRefreshHeaderUnkownState)
  {
    return;
  }
  [mMessages setObject:[message copy]
                forKey:[NSString stringWithFormat:@"msg%d",
                        state]];
  if (mState == state)
  { // The view sits at a given state now, it needs to applied immediately.
    self.statusLabel.text = message;
  }
}

- (void)resetView:(BOOL)animated
{
  void (^reset)() = ^()
  {
    mScrollView.contentInset = UIEdgeInsetsZero;
  };
  if (animated)
  {
    [UIView animateWithDuration:0.3
                          delay:0.f
                        options:kSBPullToRefreshHeaderViewAnimationOption
                     animations:reset
                     completion:nil];
  }
  else
  {
    reset();
  }
  [self setState:kSBRefreshHeaderIsNormal];
}
@end
