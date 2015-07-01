//
//  ETHRefreshControlSubclass.m
//  Ethanol
//
//  Created by Stephane Copin on 5/20/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import "ETHRefreshControlSubclass.h"

@implementation ETHRefreshControl (ForSubclass)

#pragma mark - Method to be overriden in subclasses

- (void)updateRefreshControlProgress:(CGFloat)progress pulling:(BOOL)pulling {
  
}

- (void)updateRefreshControlLayoutForEvent:(ETHRefreshControlEvent)event {
  
}

@end
