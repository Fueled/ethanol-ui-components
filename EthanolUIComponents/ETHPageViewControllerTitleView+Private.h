//
//  ETHPageViewControllerTitleView+Private.h
//  EthanolUIComponents
//
//  Created by Stephane Copin on 8/12/15.
//  Copyright © 2015 Stephane Copin. All rights reserved.
//

#import <EthanolUIComponents/ETHPageViewControllerTitleView.h>

@interface ETHPageViewControllerTitleView ()

@property (nonatomic, assign) CGFloat currentPosition;

- (void)animateTitleToRegularHorizontalSizeClass:(BOOL)regular usingCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

@end
