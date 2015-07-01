//
//  ETHPageControl.h
//  Ethanol
//
//  Created by Bastien Falcou on 1/9/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETHPageControl : UIView

/**
 *  Number of pages of the carousel, will define the number of dots.
 */
@property (nonatomic, assign) NSInteger numberOfPages;

/**
 *  Carousel page currently displayed. The corresponding dot will be displayed as active (all the other dots will be inactive).
 */
@property (nonatomic, assign) NSInteger currentPage;

/**
 *  Distance between two dots (whether they are custom images or build-in ones).
 */
@property (nonatomic, assign) CGFloat dotsSpace;

/**
 *  Hide the the indicator if there is only one page. Default is NO.
 */
@property (nonatomic, assign) BOOL hidesForSinglePage;

/**
 *  TintColor for inactive page indicators (dots). You can specify your alpha for the provided custom color if needed.
 */
@property (nonatomic, strong) UIColor *pageIndicatorTintColor UI_APPEARANCE_SELECTOR;

/**
 *  TintColor for active page indicator. You can specify your alpha for the provided custom color if needed.
 */
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor UI_APPEARANCE_SELECTOR;

/**
 *  Set the value of this property to true so that, when the user taps the control to go to a new page, the class defers updating the page control until it calls updateCurrentPageDisplay. 
 *  Set the value to false (the default) to have the page control updated immediately.
 */
@property (nonatomic, assign) BOOL defersCurrentPageDisplay;

/**
 *  Image for the top left dot (corresponding to the first page of the carousel).
 *  This image will be displayed when the state is active (current page is the first page).
 *  Default circle dot will be set if this property is set to nil.
 */
@property (nonatomic, strong) UIImage *leftDotImageInactive;

/**
 *  Image for all the dots in the middle, that are neither the top left dot nor the top right dot, this whatever the number of middle dots is.
 *  This image will be displayed when the state is active (for the dot corresponding to the current page).
 *  Default circle dot will be set if this property is set to nil.
 */
@property (nonatomic, strong) UIImage *middleDotImageInactive;

/**
 *  Image for the top left left (corresponding to the last page of the carousel).
 *  This image will be displayed when the state is active (current page is the last page).
 *  Default circle dot will be set if this property is set to nil.
 */
@property (nonatomic, strong) UIImage *rightDotImageInactive;

/**
 *  Same for top left dot when its state its inactive (current page is not the first page).
 */
@property (nonatomic, strong) UIImage *leftDotImageActive;

/**
 *  Same for dots in the middle when they are in they state inactive.
 */
@property (nonatomic, strong) UIImage *middleDotImageActive;

/**
 *  Same for top right dot when its state its inactive (current page is not the last page).
 */
@property (nonatomic, strong) UIImage *rightDotImageActive;

/**
 *  Returns minimum size required to display dots for given page count. Can be used to size control if page count could change.
 *
 *  @param pageCount Given page count.
 *
 *  @return Size for given number of pages.
 */
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;

/**
 *  This method updates the page indicator so that the current page (the white dot) matches the value returned from currentPage. 
 *  The class ignores this method if the value of defersCurrentPageDisplay is false. Setting the currentPage value directly updates the indicator immediately.
 */
- (void)updateCurrentPageDisplay;

@end