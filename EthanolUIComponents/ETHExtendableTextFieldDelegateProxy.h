//
//  ETHTextFieldProxyDelegate.h
//  Ethanol
//
//  Created by Stephane Copin on 3/25/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETHExtendableTextField.h"

@class ETHExtendableTextField;

@interface ETHExtendableTextFieldDelegateProxy : NSObject <ETHExtendableTextFieldDelegate>

@property (nonatomic, weak) ETHExtendableTextField * textField;
@property (nonatomic, weak) id<UITextFieldDelegate> delegate;

@end
