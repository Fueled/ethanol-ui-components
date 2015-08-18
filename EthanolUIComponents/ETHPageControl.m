//
//  ETHPageControl.m
//  Ethanol
//
//  Created by Bastien Falcou on 1/9/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

#import "ETHPageControl.h"

#define kDefaultPageControlSize CGSizeMake(7.0f, 7.0f)
#define kPageControlDotsOriginalWidth 7.0f
#define kPageControlDotsOriginalHeight 7.0f
#define kPageControlDotsOriginalSpace 6.0f
#define kUndefinedFloatValue INFINITY
#define kDefaultCurrentPageTintColor [UIColor whiteColor]
#define kDefaultPageTintColor [[UIColor whiteColor] colorWithAlphaComponent:0.5f]

@interface ETHPageControl ()

/**
 *  Size for dots section (from the first to the last one)
 */
@property (nonatomic, assign) CGSize sizeForDotSection;

@end

@implementation ETHPageControl

- (void)awakeFromNib {
  self.dotsSpace = kPageControlDotsOriginalSpace;
  self.pageIndicatorTintColor = kDefaultPageTintColor;
  self.currentPageIndicatorTintColor = kDefaultCurrentPageTintColor;
  self.defersCurrentPageDisplay = NO;
  self.hidesForSinglePage = NO;
  [self updateDots];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self updateDots];
}

- (void)updateDots {
  [self forceUpdateDots:NO];
}

- (void)forceUpdateDots:(BOOL)forced {
  if (self.defersCurrentPageDisplay && forced == NO) {
    return;
  }
  
  // Remove previous subviews.
  for (UIView *subView in self.subviews) {
    [subView removeFromSuperview];
  }
  
  [self updateSizeForDotSection];
  for (NSInteger i = 0; i < [self numberOfDotsToDisplay]; i++) {
    CGSize dotSize = CGSizeMake(kUndefinedFloatValue, kUndefinedFloatValue);
    
    // Update dot size.
    if (self.numberOfPages == 1 && self.middleDotImageActive) {
      dotSize = self.middleDotImageActive.size;
    } else {
      if (i == self.currentPage) {
        if (i == 0 && self.leftDotImageActive) {
          dotSize = self.leftDotImageActive.size;
        } else if (i == self.numberOfPages - 1 && self.rightDotImageActive) {
          dotSize = self.rightDotImageActive.size;
        } else if (self.middleDotImageActive) {
          dotSize = self.middleDotImageActive.size;
        }
      } else {
        if (i == 0 && self.leftDotImageInactive) {
          dotSize = self.leftDotImageInactive.size;
        } else if (i == self.numberOfPages - 1 && self.rightDotImageInactive) {
          dotSize = self.rightDotImageInactive.size;
        } else if (self.middleDotImageInactive) {
          dotSize = self.middleDotImageInactive.size;
        }
      }
    }
    
    // Update dot if needed (if custom size has been set).
    if (dotSize.width != kUndefinedFloatValue) {
      UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake([self xOriginForDotAtIndex:i], (self.frame.size.height - dotSize.height) / 2.0f, dotSize.width, dotSize.height)];
      view.backgroundColor = [UIColor clearColor];
      
      // Assign new image.
      if (self.numberOfPages == 1) {
        view.image = self.middleDotImageActive;
      } else {
        if (i == self.currentPage) {
          if (i == 0) {
            view.image = self.leftDotImageActive;
          } else if (i == self.numberOfPages - 1) {
            view.image = self.rightDotImageActive;
          } else {
            view.image = self.middleDotImageActive;
          }
        } else {
          if (i == 0) {
            view.image = self.leftDotImageInactive;
          } else if (i == self.numberOfPages - 1) {
            view.image = self.rightDotImageInactive;
          } else {
            view.image = self.middleDotImageInactive;
          }
        }
      }
      [self addSubview:view];
    } else {
      UIView *view = [[UIView alloc] initWithFrame:CGRectMake([self xOriginForDotAtIndex:i], (self.frame.size.height - kDefaultPageControlSize.height) / 2.0f, kPageControlDotsOriginalWidth, kPageControlDotsOriginalHeight)];
      view.backgroundColor = i == self.currentPage ? self.currentPageIndicatorTintColor : self.pageIndicatorTintColor;
      view.layer.cornerRadius = MIN(view.bounds.size.width, view.bounds.size.height) / 2.0f;
      view.layer.masksToBounds = YES;

      [self addSubview:view];
    }
  }
  [self invalidateIntrinsicContentSize];
}

- (void)updateSizeForDotSection {
  self.sizeForDotSection = CGSizeMake([self totalWidthForNumberOfPages:self.numberOfPages], [self maxHeightForNumberOfPages:self.numberOfPages]);
}

- (void)updateCurrentPageDisplay {
  [self forceUpdateDots:YES];
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount {
  return CGSizeMake([self totalWidthForNumberOfPages:pageCount], [self maxHeightForNumberOfPages:pageCount]);
}

#pragma mark - Helper Methods

- (NSInteger)numberOfDotsToDisplay {
  if (self.numberOfPages == 1) {
    return self.hidesForSinglePage ? 0 : 1;
  }
  
  return self.numberOfPages;
}

#pragma mark - Calculate Sizes

- (CGSize)leftDotSize {
  if (self.currentPage == 0) {
    if (self.leftDotImageActive) {
      return self.leftDotImageActive.size;
    } else {
      return kDefaultPageControlSize;
    }
  } else {
    if (self.leftDotImageInactive) {
      return self.leftDotImageInactive.size;
    } else {
      return kDefaultPageControlSize;
    }
  }
}

- (CGSize)rightDotSize {
  if (self.currentPage == self.numberOfPages - 1) {
    if (self.rightDotImageActive) {
      return self.rightDotImageActive.size;
    } else {
      return kDefaultPageControlSize;
    }
  } else {
    if (self.rightDotImageInactive) {
      return self.rightDotImageInactive.size;
    } else {
      return kDefaultPageControlSize;
    }
  }
}

- (CGSize)middleDotSizeSelected:(BOOL)selected {
  if (selected) {
    if (self.middleDotImageActive) {
      return self.middleDotImageActive.size;
    } else {
      return kDefaultPageControlSize;
    }
  } else {
    if (self.middleDotImageInactive) {
      return self.middleDotImageInactive.size;
    } else {
      return kDefaultPageControlSize;
    }
  }
}

- (CGFloat)middleDotsSectionWidth {
  return [self middleDotsSectionWidthForNumberOfPages:self.numberOfPages];
}

- (CGFloat)middleDotsSectionWidthForNumberOfPages:(NSInteger)numberOfPages {
  CGFloat sectionWidth = 0.0f;
  
  if (self.currentPage != 0 && self.currentPage < numberOfPages - 1) {
    sectionWidth += [self middleDotSizeSelected:YES].width;
    sectionWidth += (numberOfPages - 3) * [self middleDotSizeSelected:NO].width;
  } else {
    sectionWidth += (numberOfPages - 2) * [self middleDotSizeSelected:NO].width;
  }
  
  sectionWidth += self.dotsSpace * (numberOfPages - 3);
  return sectionWidth;
}

- (CGFloat)totalWidthForNumberOfPages:(NSInteger)numberOfPages {
  if (numberOfPages == 0) {
    return 0.0f;
  } else if (numberOfPages == 1) {
    return self.hidesForSinglePage ? 0.0f : [self middleDotSizeSelected:YES].width;
  } else if (numberOfPages == 2) {
    return [self leftDotSize].width + self.dotsSpace + [self rightDotSize].width;
  } else {
    return [self leftDotSize].width + self.dotsSpace + [self middleDotsSectionWidthForNumberOfPages:numberOfPages] + self.dotsSpace + [self rightDotSize].width;
  }
}
                    
- (CGFloat)maxHeight {
  return [self maxHeightForNumberOfPages:self.numberOfPages];
}

- (CGFloat)maxHeightForNumberOfPages:(NSInteger)numberOfPages {
  CGFloat maxHeight = 0.0f;
  
  if (numberOfPages == 0) {
    maxHeight = 0.0f;
  } else if (numberOfPages == 1) {
    maxHeight = self.hidesForSinglePage ? 0.0f : [self middleDotSizeSelected:YES].height;
  } else if (numberOfPages == 2) {
    maxHeight = fmax([self rightDotSize].height, [self leftDotSize].height);
  } else {
    maxHeight = fmax(fmax([self rightDotSize].height, [self leftDotSize].height),fmax([self middleDotSizeSelected:YES].height, [self middleDotSizeSelected:NO].height));
  }
  return maxHeight;
}

#pragma mark - Calculate x origin for dots

- (CGFloat)xOriginFirstDot {
  return (self.frame.size.width - self.sizeForDotSection.width) / 2.0f;
}

- (CGFloat)xOriginForDotAtIndex:(NSInteger)dotIndex {
  if (dotIndex < 0 || dotIndex > self.numberOfPages - 1) {
    return kUndefinedFloatValue;
  }
  
  CGFloat sectionWidth = [self xOriginFirstDot];
  
  if (self.currentPage != 0 && self.currentPage < dotIndex) {
    sectionWidth += [self middleDotSizeSelected:YES].width;
    sectionWidth += (dotIndex - 1) * [self middleDotSizeSelected:NO].width;
  } else {
    sectionWidth += dotIndex * [self middleDotSizeSelected:NO].width;
  }
  
  sectionWidth += self.dotsSpace * dotIndex;
  return sectionWidth;
}

#pragma mark - UIView overriden methods

- (void)sizeToFit {
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [self sizeForNumberOfPages:self.numberOfPages].width, [self sizeForNumberOfPages:self.numberOfPages].height);
}

- (CGSize)intrinsicContentSize {
  return [self sizeForNumberOfPages:self.numberOfPages];
}

#pragma mark - Custom setters

- (void)setNumberOfPages:(NSInteger)numberOfPages {
  if (numberOfPages < 0) {
    _numberOfPages = 0;
  }
  
  _numberOfPages = numberOfPages;
  if (numberOfPages <= self.currentPage && self.currentPage > 0) {
    self.currentPage = numberOfPages - 1;
  }
  
  [self updateDots];
}

- (void)setCurrentPage:(NSInteger)page {
  if (page < 0) {
    _currentPage = 0;
  }
  
  if (self.numberOfPages - 1 < page) {
    _currentPage = self.numberOfPages - 1;
  } else {
    _currentPage = page;
  }
  
  [self updateDots];
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
  _pageIndicatorTintColor = pageIndicatorTintColor ? pageIndicatorTintColor : kDefaultPageTintColor;
  [self updateDots];
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
  _currentPageIndicatorTintColor = currentPageIndicatorTintColor ? currentPageIndicatorTintColor : kDefaultCurrentPageTintColor;
  [self updateDots];
}

- (void)setDotsSpace:(CGFloat)dotsGauge {
  _dotsSpace = dotsGauge;
  [self updateDots];
}

- (void)setLeftDotImageActive:(UIImage *)leftDotImageActive {
  _leftDotImageActive = leftDotImageActive;
  [self updateDots];
}

- (void)setMiddleDotImageActive:(UIImage *)middleDotImageActive {
  _middleDotImageActive = middleDotImageActive;
  [self updateDots];
}

- (void)setRightDotImageActive:(UIImage *)rightDotImageActive {
  _rightDotImageActive = rightDotImageActive;
  [self updateDots];
}

- (void)setLeftDotImageInactive:(UIImage *)leftDotImageInactive {
  _leftDotImageInactive = leftDotImageInactive;
  [self updateDots];
}

- (void)setMiddleDotImageInactive:(UIImage *)middleDotImageInactive {
  _middleDotImageInactive = middleDotImageInactive;
  [self updateDots];
}

- (void)setRightDotImageInactive:(UIImage *)rightDotImageInactive {
  _rightDotImageInactive = rightDotImageInactive;
  [self updateDots];
}

@end