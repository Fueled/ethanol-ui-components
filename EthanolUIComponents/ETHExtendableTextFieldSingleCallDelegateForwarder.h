//
//  ETHExtendedTextFieldSingleCallDelegateForwarder.h
//  Ethanol
//
//  Created by Stephane Copin on 1/7/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETHExtendableTextFieldDelegateProxy.h"

@interface ETHExtendableTextFieldSingleCallDelegateForwarder : NSObject <UITextFieldDelegate>

@property (nonatomic, weak) ETHExtendableTextField * textField;
@property (nonatomic, weak) id<UITextFieldDelegate> delegate;

@end
