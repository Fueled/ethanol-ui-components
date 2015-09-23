//
//  ETHPageViewControllerTitleView.m
//  EthanolUIComponents
//
//  Created by Stephane Copin on 8/12/15.
//  Copyright © 2015 Stephane Copin. All rights reserved.
//

#import "ETHPageViewControllerTitleView.h"
#import "ETHPageViewControllerTitleView+Private.h"
#import <EthanolUtilities/EthanolUtilities.h>
#import <EthanolTools/EthanolTools.h>

@interface ETHPageViewControllerTitleView ()

@property (nonatomic, strong) IBOutlet UIView *titleView;
@property (nonatomic, strong) IBOutlet UIScrollView *compactTitlesScrollView;
@property (nonatomic, strong) IBOutlet UIView *regularTitlesContainer;
@property (nonatomic, strong) IBOutlet UIImageView *placeholderImageView;
@property (nonatomic, strong) IBOutlet UIView *regularPageControlContainer;
@property (nonatomic, strong) IBOutlet UIView *compactTitleView;
@property (nonatomic, strong) IBOutlet UIView *regularTitleView;
@property (nonatomic, strong) CADisplayLink * displayLink;
@property (nonatomic, weak) UIView * regularMaxWidthTitleView;
@property (nonatomic, weak) NSLayoutConstraint *regularPageControlContainerCenterXConstraint;
@property (nonatomic, assign) UIUserInterfaceSizeClass currentTitleViewSizeClass;
@property (nonatomic, assign) UIUserInterfaceSizeClass currentEffectiveSizeClass;

@end

@implementation ETHPageViewControllerTitleView

- (void)awakeFromNib {
  [super awakeFromNib];
  
  self.regularTitleViewSpacing = 20.0;
  
  self.currentTitleViewSizeClass = UIUserInterfaceSizeClassUnspecified;
  [self generateTitleViewForSizeClass:self.traitCollection.horizontalSizeClass];
  [self updateTitleViewSizeClassAnimated:NO];
}

- (void)layoutSubviews {
  if(self.currentEffectiveSizeClass == UIUserInterfaceSizeClassUnspecified) {
    self.currentEffectiveSizeClass = self.traitCollection.horizontalSizeClass;
  }
  
  [self generateTitleViewForSizeClass:self.currentEffectiveSizeClass];
  [self updateTitleViewSizeClassAnimated:NO];
}

- (void)generateTitleViewForSizeClass:(UIUserInterfaceSizeClass)sizeClass {
  return [self generateTitleViewForSizeClass:sizeClass force:YES];
}

- (void)generateTitleViewForSizeClass:(UIUserInterfaceSizeClass)sizeClass force:(BOOL)force {
  if(sizeClass == UIUserInterfaceSizeClassUnspecified) {
    return;
  }
  
  if(sizeClass == UIUserInterfaceSizeClassRegular && [self isRegularTitleViewTooLarge]) {
    sizeClass = UIUserInterfaceSizeClassCompact;
  }
  
  if(force || self.currentTitleViewSizeClass != sizeClass) {
    self.currentEffectiveSizeClass = sizeClass;
    self.currentTitleViewSizeClass = sizeClass;
    if(sizeClass == UIUserInterfaceSizeClassRegular) {
      [self generateRegularTitleViews];
    } else {
      [self generateCompactTitleViews];
    }
  }
}

- (void)setTitleViews:(NSArray<UIView *> *)titleViews {
  _titleViews = [titleViews copy];
  
  [self generateTitleViewForSizeClass:self.traitCollection.horizontalSizeClass force:YES];
  [self updateTitleViewSizeClassAnimated:YES];
}

- (void)replaceTitleViewsAtIndexes:(NSIndexSet *)indexes withTitleViews:(NSArray *)array {
  NSMutableArray * titleViews = [self.titleViews mutableCopy];
  [titleViews replaceObjectsAtIndexes:indexes withObjects:array];
  self.titleViews = titleViews;
}

- (void)replaceTitleViewsAtIndexes:(NSIndexSet *)indexes withTitleViews:(NSArray<UIView *> *)array animated:(BOOL)animated {
  if(!animated) {
    [self replaceTitleViewsAtIndexes:indexes withTitleViews:array];
    return;
  }
  
  NSAssert(indexes.count == array.count, @"-[ETHPageViewControllerTitleView replaceTitleViewsAtIndexes:withTitleViews:animated: doesn't support remove/inserting title views while replacing existing title views. Please provide the same number of items on both sides.");
  NSMutableArray<UIView *> * previousTitleViews = [NSMutableArray arrayWithCapacity:indexes.count];
  [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
    [previousTitleViews addObject:self.titleViews[idx]];
  }];
  
  for(UIView * newTitleView in array) {
    newTitleView.alpha = 0.0;
  }
  
  [UIView animateWithDuration:0.35 animations:^{
    [array enumerateObjectsUsingBlock:^(UIView *  _Nonnull newTitleView, NSUInteger idx, BOOL * _Nonnull stop) {
      UIView * previousTitleView = previousTitleViews[idx];
      newTitleView.alpha = previousTitleView.alpha;
      previousTitleView.alpha = 0.0;
    }];
    [self replaceTitleViewsAtIndexes:indexes withTitleViews:array];
  }];
}

- (void)updateTitleViewPosition {
  CGFloat position = self.currentPosition;
  self.compactTitlesScrollView.contentOffset = [self compactTitleScrollViewContentOffsetFromPagePosition:position];
  self.regularPageControlContainerCenterXConstraint.constant = (self.regularMaxWidthTitleView.bounds.size.width + self.regularTitleViewSpacing) * position + self.regularMaxWidthTitleView.bounds.size.width / 2.0;
  [self.regularPageControlContainer layoutIfNeeded];
  
  [self updateTitleViewAlphaWithPosition:position];
}

- (CGPoint)compactTitleScrollViewContentOffsetFromPagePosition:(CGFloat)pagePosition {
  return CGPointMake(pagePosition * self.frame.size.width, 0.0f);
}

- (void)updateTitleViewAlphaWithPosition:(CGFloat)position {
  CGFloat minimumTitleAlpha = self.currentEffectiveSizeClass == UIUserInterfaceSizeClassRegular ? self.regularMinimumTitleAlpha : self.compactMinimumTitleAlpha;
  CGFloat (^ calculateProgress)(CGFloat, CGFloat) = ^CGFloat(CGFloat origin, CGFloat offset) {
    offset -= origin;
    offset  = (CGFloat)fabs(offset);
    // Linear function
    CGFloat a = (1.0f - minimumTitleAlpha) / (0.0f - 0.5f);
    CGFloat b = 1.0f - a * 0.0f;
    offset = a * offset + b;
    if(offset < minimumTitleAlpha) {
      return minimumTitleAlpha;
    } else if(offset > 1.0f) {
      return 1.0f;
    }
    return offset;
  };
  
  NSUInteger count = self.titleViews.count;
  for(NSUInteger i = 0;i < count;++i) {
    self.titleViews[i].alpha = calculateProgress(i * 1.0f, position);
  }
}

- (void)setCurrentPosition:(CGFloat)currentPosition {
  _currentPosition = currentPosition;
  
  [self updateTitleViewPosition];
}

- (void)animateTitleToHorizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass usingCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  if(self.currentEffectiveSizeClass == horizontalSizeClass) {
    return;
  }
  
  self.placeholderImageView.image = [self snapshotOfView:self.titleView];
  self.titleView.alpha = 0.0;
  
  [self generateTitleViewForSizeClass:horizontalSizeClass];
  
  CGFloat compactTargetAlpha = self.currentEffectiveSizeClass == UIUserInterfaceSizeClassCompact ? 1.0 : 0.0;
  CGFloat regularTargetAlpha = 1.0 - compactTargetAlpha;
  [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    self.titleView.alpha = 1.0;
    self.placeholderImageView.alpha = 0.0;
    self.compactTitleView.alpha = compactTargetAlpha;
    self.regularTitleView.alpha = regularTargetAlpha;
  } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    self.placeholderImageView.image = nil;
    self.placeholderImageView.alpha = 1.0;
  }];
}

- (void)updateTitleViewSizeClassAnimated:(BOOL)animated {
  CGFloat compactTargetAlpha = self.currentEffectiveSizeClass == UIUserInterfaceSizeClassCompact ? 1.0 : 0.0;
  CGFloat regularTargetAlpha = 1.0 - compactTargetAlpha;
  
  void (^ animationBlock)(void) = ^{
    self.compactTitleView.alpha = compactTargetAlpha;
    self.regularTitleView.alpha = regularTargetAlpha;
  };
  
  if(animated) {
    [UIView animateWithDuration:0.35 animations:animationBlock];
  } else {
    animationBlock();
  }
}

- (void)animateTitleToSize:(CGSize)size usingCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  self.compactTitlesScrollView.contentOffset = CGPointMake(0.0f, 0.0f);
}

- (void)generateCompactTitleViews {
  for(UIView * subview in self.compactTitlesScrollView.subviews) {
    [subview removeFromSuperview];
  }
  for(UIView * subview in self.regularTitlesContainer.subviews) {
    [subview removeFromSuperview];
  }
  
  UIView * previousContainerView = nil;
  for(NSInteger i = 0;i < self.titleViews.count;++i) {
    UIView * titleView = self.titleViews[i];
    
    UIView * containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.clipsToBounds = false;
    
    [containerView addSubview:titleView];
    
    NSLayoutConstraint * centerXConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint * centerYConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    
    [containerView addConstraints:@[centerXConstraint, centerYConstraint]];
    
    [self.compactTitlesScrollView addSubview:containerView];
    
    NSMutableArray * constraints = [NSMutableArray array];
    if(previousContainerView == nil) {
      [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.compactTitlesScrollView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    } else {
      [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:previousContainerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    }
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.compactTitlesScrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.compactTitlesScrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    if(i == self.titleViews.count - 1) {
      [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.compactTitlesScrollView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    }
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.compactTitlesScrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.compactTitlesScrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    
    [self.compactTitlesScrollView addConstraints:constraints];
    
    previousContainerView = containerView;
  }
}

- (void)maxWidthView:(UIView **)maxWidthView andMaxHeightViewForRegularTitleView:(UIView **)maxHeightView {
  *maxWidthView = nil;
  *maxHeightView = nil;
  for(UIView * titleView in self.titleViews) {
    [titleView sizeToFit];
    
    if(titleView.bounds.size.width > (*maxWidthView).bounds.size.width) {
      *maxWidthView = titleView;
    }
    if(titleView.bounds.size.height > (*maxHeightView).bounds.size.height) {
      *maxHeightView = titleView;
    }
  }
}

- (BOOL)isRegularTitleViewTooLarge {
  UIView * maxWidthView = nil;
  UIView * maxHeightView = nil;
  [self maxWidthView:&maxWidthView andMaxHeightViewForRegularTitleView:&maxHeightView];
  
  CGFloat totalWidth = maxWidthView.bounds.size.width * self.titleViews.count + self.regularTitleViewSpacing * (self.titleViews.count - 1);
  return totalWidth > self.bounds.size.width;
}

- (void)generateRegularTitleViews {
  UIView * maxWidthView = nil;
  UIView * maxHeightView = nil;
  [self maxWidthView:&maxWidthView andMaxHeightViewForRegularTitleView:&maxHeightView];
  
  for(UIView * subview in self.compactTitlesScrollView.subviews) {
    [subview removeFromSuperview];
  }
  for(UIView * subview in self.regularTitlesContainer.subviews) {
    [subview removeFromSuperview];
  }
  
  UIView * allTitlesView = [[UIView alloc] init];
  allTitlesView.translatesAutoresizingMaskIntoConstraints = NO;
  
  NSMutableArray * constraints = [NSMutableArray array];
  UIView * previousContainerView = nil;
  for(UIView * titleView in self.titleViews) {
    UIView * containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.clipsToBounds = false;
    
    [containerView addSubview:titleView];
    
    NSLayoutConstraint * centerXConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint * centerYConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    
    [containerView addConstraints:@[centerXConstraint, centerYConstraint]];
    
    [allTitlesView addSubview:containerView];
    
    if(previousContainerView == nil) {
      [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:allTitlesView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    } else {
      [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:previousContainerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:self.regularTitleViewSpacing]];
    }
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:allTitlesView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:allTitlesView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:maxWidthView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:maxHeightView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    
    [allTitlesView addSubview:containerView];
    
    previousContainerView = containerView;
  }
  
  [allTitlesView addConstraints:constraints];
  
  [constraints addObject:[NSLayoutConstraint constraintWithItem:allTitlesView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:maxWidthView attribute:NSLayoutAttributeWidth multiplier:(CGFloat)self.titleViews.count constant:self.regularTitleViewSpacing * (self.titleViews.count - 1)]];
  [constraints addObject:[NSLayoutConstraint constraintWithItem:allTitlesView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:maxHeightView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
  
  [allTitlesView addConstraints:constraints];
  
  [self.regularTitlesContainer addSubview:allTitlesView];
  
  NSLayoutConstraint * centerXConstraint = [NSLayoutConstraint constraintWithItem:allTitlesView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.regularTitlesContainer attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
  NSLayoutConstraint * centerYConstraint = [NSLayoutConstraint constraintWithItem:allTitlesView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.regularTitlesContainer attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
  
  [self.regularTitlesContainer addConstraints:@[centerXConstraint, centerYConstraint]];
  
  self.regularMaxWidthTitleView = maxWidthView;
  self.regularPageControlContainerCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.regularPageControlContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:allTitlesView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
  [self.regularTitleView addConstraint:self.regularPageControlContainerCenterXConstraint];
}

- (UIImage *)snapshotOfView:(UIView *)view {
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  
  UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  return image;
}

@end
