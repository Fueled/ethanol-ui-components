//
//  ETHRefreshControl.m
//  Ethanol
//
//  Created by Stephane Copin on 4/24/14.
//  Copyright (c) 2015 Fueled Digital Media, LLC.
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
//

#import "ETHRefreshControl.h"
#import "ETHRefreshControl+Subclass.h"
#import <EthanolUtilities/CADisplayLink+EthanolBlocks.h>

#define kETHRefreshControlContentOffsetAnimationDuration 0.35f

@interface ETHRefreshControl () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIScrollView * scrollView;
@property (nonatomic, assign, getter = isRefreshing) BOOL refreshing;
@property (nonatomic, assign, getter = isDoingEndRefreshAnimation) BOOL doingEndRefreshAnimation;
@property (nonatomic, strong) UIPanGestureRecognizer * panGestureRecognizer;
@property (nonatomic, assign, getter = isUserPanning) BOOL userPanning;
@property (nonatomic, strong, readonly) UIRefreshControl * internalRefreshControl;

@end

@implementation ETHRefreshControl
@synthesize internalRefreshControl = _internalRefreshControl;

#pragma mark - Initialization methods

- (instancetype)init {
  return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    [self refreshControlInit];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if(self != nil) {
    [self refreshControlInit];
  }
  return self;
}

- (void)refreshControlInit {
  [self setupPanGestureRecognizer];
  
}

- (void)setupPanGestureRecognizer {
  _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandled:)];
  _panGestureRecognizer.delegate = self;
}

#pragma mark - Gesture recognizer action

- (void)panGestureHandled:(UIPanGestureRecognizer *)gestureRecognizer {
  switch(gestureRecognizer.state) {
    case UIGestureRecognizerStateBegan:
      self.userPanning = YES;
      break;
    case UIGestureRecognizerStateChanged:
      break;
    default:
      self.userPanning = NO;
      break;
  }
}

#pragma mark - UIGestureRecognizer delegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}

#pragma mark - Inherited methods

- (void)didMoveToSuperview {
  [super didMoveToSuperview];
  
  if([self.superview isKindOfClass:[UIScrollView class]]) {
    self.scrollView = (UIScrollView *)self.superview;
    
    [self updateRefreshControlLayoutForEvent:kETHRefreshControlEventStandingBy];
    
    [self.superview sendSubviewToBack:self];
  }
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  CGFloat oldContentOffset = [self contentOffsetYFromNSValue:change[NSKeyValueChangeOldKey]];
  CGFloat newContentOffset = [self contentOffsetYFromNSValue:change[NSKeyValueChangeNewKey]];
  newContentOffset += self.scrollView.contentInset.top;
  if(fabs(newContentOffset - oldContentOffset) >= DBL_EPSILON && !self.isRefreshing) {
    newContentOffset = -newContentOffset;
    if(newContentOffset >= self.pullToRefreshHeight && self.isUserPanning) {
      [self beginRefreshing];
    } else {
      CGFloat max = self.isDoingEndRefreshAnimation ? self.actualHeight : self.pullToRefreshHeight;
      CGFloat progress = fmin(1.0f, fmax(newContentOffset / max, 0.0f));
      if(progress == -0.0) {
        progress = 0.0f;
      }
      
      if(!self.doingEndRefreshAnimation) {
        [self updateRefreshControlProgress:progress pulling:!self.doingEndRefreshAnimation];
      }
    }
  }
  
  [self updateFrame];
  [self updateRefreshControlLayoutForEvent:self.refreshing ? kETHRefreshControlEventRefreshing : kETHRefreshControlEventPulling];
}

#pragma mark - Public methods

- (void)beginRefreshing {
  if(![NSThread isMainThread]) {
    [self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:YES];
    return;
  }
  
  self.refreshing = YES;
  
  UIEdgeInsets insets = self.scrollView.contentInset;
  insets.top += self.actualHeight;
  self.scrollView.contentInset = insets;
  CGPoint contentOffset = self.scrollView.contentOffset;
  contentOffset.y -= self.actualHeight;
  self.scrollView.contentOffset = contentOffset;
  
  [self sendActionsForControlEvents:UIControlEventValueChanged];
  
  if(self.refreshing) {
    // In case sending the value changed event stopped the refreshing
    [self updateRefreshControlLayoutForEvent:kETHRefreshControlEventPullingToRefreshing];
  }
}

- (void)cancelRefreshing {
  if(![NSThread isMainThread]) {
    [self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:YES];
    return;
  }
  
  [self sendActionsForControlEvents:UIControlEventTouchUpInside];
  
  [self updateRefreshControlLayoutForEvent:kETHRefreshControlEventRefreshingCancelled];
  
  [self endRefreshing];
}

- (void)endRefreshing {
  if(![NSThread isMainThread]) {
    [self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:YES];
    return;
  }
  
  [self updateRefreshControlProgress:0.0f pulling:NO];
  
  [self moveToTopOfScrollView];
  
  UIEdgeInsets insets = self.scrollView.contentInset;
  insets.top -= self.actualHeight;
  self.scrollView.contentInset = insets;
  
  self.refreshing = NO;
  
  [self updateFrame];
  [self updateRefreshControlLayoutForEvent:kETHRefreshControlEventResetting];
}

#pragma mark - Custom setters/getters

- (void)setActualHeight:(CGFloat)actualHeight {
  _actualHeight = actualHeight;
  
  [self updateFrame];
}

- (void)setScrollView:(UIScrollView *)scrollView {
  [_scrollView removeGestureRecognizer:self.panGestureRecognizer];
  _scrollView = scrollView;
  [_scrollView addGestureRecognizer:self.panGestureRecognizer];
  
  [self updateFrame];
}

#pragma mark - Helper methods

- (void)moveToTopOfScrollView {
  CGFloat contentOffset = self.scrollView.contentOffset.y;
  contentOffset += self.scrollView.contentInset.top;
  contentOffset = -contentOffset;
  if(contentOffset >= 0.0f) {
    __block BOOL isInvalidated = NO;
    self.doingEndRefreshAnimation = YES;
    CADisplayLink * displayLink = [CADisplayLink eth_displayLinkWithBlock:^(CADisplayLink * displayLink) {
      CGFloat newContentOffset = [[self.scrollView.layer presentationLayer] bounds].origin.y;
      newContentOffset += self.scrollView.contentInset.top;
      newContentOffset = -newContentOffset;
      CGFloat progress = fmin(1.0f, fmax(newContentOffset / self.actualHeight, 0.0f));
      if(progress == -0.0) {
        progress = 0.0f;
      }
      
      if(!isInvalidated) {
        [self updateRefreshControlProgress:1.0f - progress pulling:NO];
      }
    }];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [displayLink addToRunLoop:runner forMode:NSRunLoopCommonModes];
    
    [self updateRefreshControlProgress:0.0f pulling:NO];
    [UIView animateWithDuration:kETHRefreshControlContentOffsetAnimationDuration animations:^{
      self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x,
                                                  self.actualHeight - self.scrollView.contentInset.top);
    } completion:^(BOOL finished) {
      [self updateRefreshControlProgress:1.0f pulling:NO];
      self.doingEndRefreshAnimation = NO;
      
      isInvalidated = YES;
      [displayLink invalidate];
      
      [self updateRefreshControlLayoutForEvent:kETHRefreshControlEventResetted];
    }];
  }
}

- (CGFloat)contentOffsetYFromNSValue:(NSValue *)value {
  CGPoint contentOffset;
  [value getValue:&contentOffset];
  return contentOffset.y;
}

- (void)updateFrame {
  CGFloat contentOffset = self.scrollView.contentOffset.y + self.scrollView.contentInset.top - (self.isRefreshing ? self.actualHeight : 0.0f);
  CGRect newFrame = CGRectMake(0.0f, contentOffset, self.scrollView.frame.size.width, self.actualHeight);
  if(!CGRectEqualToRect(self.frame, newFrame)) {
    self.frame = newFrame;
  }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
  [self.superview removeObserver:self forKeyPath:@"contentOffset"];
  
  [newSuperview addObserver:self forKeyPath:@"contentOffset"
                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                    context:nil];
  
  [super willMoveToSuperview:newSuperview];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
  if([super respondsToSelector:aSelector]) {
    return YES;
  }
  
  return [self.internalRefreshControl respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
  NSMethodSignature * signature = [super methodSignatureForSelector:aSelector];
  if(signature != nil) {
    return signature;
  }
  
  return [self.internalRefreshControl methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
  if([self.internalRefreshControl respondsToSelector:anInvocation.selector]) {
    [anInvocation invokeWithTarget:self.internalRefreshControl];
  } else {
    [super forwardInvocation:anInvocation];
  }
}

- (UIRefreshControl *)internalRefreshControl {
  if(_internalRefreshControl == nil) {
    _internalRefreshControl = [[UIRefreshControl alloc] init];
  }
  return _internalRefreshControl;
}

@end
