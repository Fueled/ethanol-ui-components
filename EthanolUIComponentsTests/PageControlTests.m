//
//  PageControlTests.m
//  EthanolUIComponents
//
//  Created by Bastien Falcou on 8/20/15.
//  Copyright © 2015 Stephane Copin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ETHPageControl.h"

@interface ETHPageControl (PrivateTests)

@property (nonatomic, strong) NSMutableArray *dotsArray;

@end

@interface PageControlTests : XCTestCase

@property (nonatomic, strong) UIImage *inactiveLeftImage;
@property (nonatomic, strong) UIImage *inactiveMiddleImage;
@property (nonatomic, strong) UIImage *inactiveRightImage;

@property (nonatomic, strong) UIImage *activeLeftImage;
@property (nonatomic, strong) UIImage *activeMiddleImage;
@property (nonatomic, strong) UIImage *activeRightImage;

@end

@implementation PageControlTests

- (void)setUp {
  [super setUp];

  self.inactiveLeftImage = [UIImage imageNamed:@"Carousel-Middle-Active" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  self.inactiveMiddleImage = [UIImage imageNamed:@"Carousel-Middle-Active" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  self.inactiveRightImage = [UIImage imageNamed:@"Carousel-Middle-Active" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  
  self.activeLeftImage = [UIImage imageNamed:@"Carousel-Middle-Active" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  self.activeMiddleImage = [UIImage imageNamed:@"Carousel-Middle-Active" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  self.activeRightImage = [UIImage imageNamed:@"Carousel-Middle-Active" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

#pragma mark - Default Dots

- (void)testPageControlNumberOfPages {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  
  XCTAssertEqual(pageControl.dotsArray.count, 5);
}

- (void)testPageControlChangeNumberOfPages {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.numberOfPages = 10;
  pageControl.numberOfPages = 3;
  
  XCTAssertEqual(pageControl.dotsArray.count, 3);
}

- (void)testPageControlDefaultCurrentPage {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;

  XCTAssertEqual(pageControl.currentPage, 0);
}

- (void)testPageControlChangeCurrentPageColor {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 3;
  
  XCTAssertEqualObjects([(UIView *)pageControl.dotsArray[3] backgroundColor], pageControl.currentPageIndicatorTintColor);
}

- (void)testPageControlChangeOtherPagesColor {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  for (UIView *dot in pageControl.dotsArray) {
    if (dot != pageControl.dotsArray[0]) {
      XCTAssertEqualObjects(dot.backgroundColor, pageControl.pageIndicatorTintColor);
    }
  }
}

- (void)testPageControlChangeFrameDefaultDots {
  ETHPageControl *pageControl = [[ETHPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 100.0f)];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  CGFloat previousOriginX = [pageControl.dotsArray[0] frame].origin.x;
  pageControl.frame = CGRectMake(0.0f, 0.0f, 400.0f, 100.0f);
  
  XCTAssert([pageControl.dotsArray[0] frame].origin.x > previousOriginX);
}

#pragma mark - View Changes

- (void)testPageControlSizeToFit {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  [pageControl sizeToFit];
  
  for (UIView *dot in pageControl.dotsArray) {
    XCTAssertEqual(dot.frame.origin.y, 0.0f);
  }
}

- (void)testPageControlIntrinsicContentSize {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  pageControl.frame = CGRectMake(0.0f, 0.0f, [pageControl intrinsicContentSize].width, [pageControl intrinsicContentSize].height);
  
  for (UIView *dot in pageControl.dotsArray) {
    XCTAssertEqual(dot.frame.origin.y, 0.0f);
  }
}

- (void)testPageControlLayoutSubviews {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  CGFloat previousOriginX = [pageControl.dotsArray[0] frame].origin.x;
  pageControl.frame = CGRectMake(0.0f, 0.0f, 400.0f, 100.0f);
  
  [pageControl setNeedsLayout];
  [pageControl layoutIfNeeded];
  
  XCTAssert([pageControl.dotsArray[0] frame].origin.x > previousOriginX);
}

#pragma mark - Custom Dot Images

- (void)testPageControlCustomImagesInactiveAllTheSame {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  pageControl.leftDotImageInactive = self.activeMiddleImage;
  pageControl.middleDotImageInactive = self.activeMiddleImage;
  pageControl.rightDotImageInactive = self.activeMiddleImage;
  
  for (UIImageView *dot in pageControl.dotsArray) {
    if ([dot isKindOfClass:[UIImageView class]]) {
      XCTAssertEqualObjects(dot.image, self.activeMiddleImage);
    }
  }
}

- (void)testPageControlCustomImagesActiveAllTheSameCurrent {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  pageControl.leftDotImageActive = self.inactiveMiddleImage;
  pageControl.middleDotImageActive = self.inactiveMiddleImage;
  pageControl.rightDotImageActive = self.inactiveMiddleImage;
  
  XCTAssertEqualObjects([pageControl.dotsArray[0] image], self.inactiveMiddleImage);
}

- (void)testPageControlCustomImagesActiveAllTheSameOthers {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  pageControl.leftDotImageActive = self.activeMiddleImage;
  pageControl.middleDotImageActive = self.activeMiddleImage;
  pageControl.rightDotImageActive = self.activeMiddleImage;
  
  for (UIImageView *dot in pageControl.dotsArray) {
    if ([dot isKindOfClass:[UIImageView class]] && dot != pageControl.dotsArray[0]) {
      XCTAssertNotEqualObjects(dot.image, self.activeMiddleImage);
    }
  }
}

- (void)testPageControlCustomImagesInactiveLeft {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 0;
  
  pageControl.leftDotImageActive = self.inactiveLeftImage;
  pageControl.middleDotImageActive = self.inactiveMiddleImage;
  pageControl.rightDotImageActive = self.inactiveRightImage;
  
  XCTAssertEqualObjects([pageControl.dotsArray[0] image], self.inactiveLeftImage);
}

- (void)testPageControlCustomImagesInactiveLeftOthersDifferent {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 4;
  
  pageControl.leftDotImageActive = self.inactiveLeftImage;
  pageControl.middleDotImageActive = self.inactiveMiddleImage;
  pageControl.rightDotImageActive = self.inactiveRightImage;
  
  for (UIImageView *dot in pageControl.dotsArray) {
    if ([dot isKindOfClass:[UIImageView class]] && dot != pageControl.dotsArray[4]) {
      XCTAssertNotEqualObjects(dot.image, self.inactiveLeftImage);
    }
  }
}

- (void)testPageControlCustomImagesInactiveMiddle {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  
  pageControl.leftDotImageActive = self.inactiveLeftImage;
  pageControl.middleDotImageActive = self.inactiveMiddleImage;
  pageControl.rightDotImageActive = self.inactiveRightImage;
  
  pageControl.leftDotImageInactive = self.inactiveLeftImage;
  pageControl.middleDotImageInactive = self.inactiveMiddleImage;
  pageControl.rightDotImageInactive = self.inactiveRightImage;
  
  for (UIImageView *dot in pageControl.dotsArray) {
    if (dot != [pageControl.dotsArray firstObject] && dot != [pageControl.dotsArray lastObject]) {
      XCTAssertEqualObjects(dot.image, self.inactiveMiddleImage);
    }
  }
}

- (void)testPageControlCustomImagesInactiveMiddleOthersDifferent {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 5;
  
  pageControl.leftDotImageActive = self.inactiveLeftImage;
  pageControl.middleDotImageActive = self.inactiveMiddleImage;
  pageControl.rightDotImageActive = self.inactiveRightImage;
  
  pageControl.leftDotImageInactive = self.inactiveLeftImage;
  pageControl.middleDotImageInactive = self.inactiveMiddleImage;
  pageControl.rightDotImageInactive = self.inactiveRightImage;
  
  XCTAssertNotEqualObjects([[pageControl.dotsArray firstObject] image], self.inactiveMiddleImage);
  XCTAssertNotEqualObjects([[pageControl.dotsArray lastObject] image], self.inactiveMiddleImage);
}

#pragma mark - Properties

- (void)testPageControlHidesForSinglePageFirst {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.hidesForSinglePage = YES;
  pageControl.numberOfPages = 1;
  
  XCTAssertEqual(pageControl.dotsArray.count, 0);
}

- (void)testPageControlHidesForSinglePageAfterward {
  ETHPageControl *pageControl = [[ETHPageControl alloc] init];
  pageControl.numberOfPages = 1;
  pageControl.hidesForSinglePage = YES;
  
  XCTAssertEqual(pageControl.dotsArray.count, 0);
}

@end
