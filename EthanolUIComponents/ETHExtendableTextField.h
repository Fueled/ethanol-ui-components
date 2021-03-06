//
//  ETHExtendableTextField.h
//  Ethanol
//
//  Created by Stephane Copin on 1/6/15.
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ETHExtendableTextField;

@protocol ETHExtendableTextFieldDelegate <UITextFieldDelegate>

@optional
- (BOOL)textFieldTextShouldChange:(ETHExtendableTextField *)textField toText:(NSString *)text;
- (void)textFieldTextDidChange:(ETHExtendableTextField *)textField;

@end

/**
 *  This is a subclass of UITextField intended for given easy access to its delegate in its subclass and allow to extend its behavior easily.
 *  If you do override its any of its delegate method, you can call self.delegate to call the 'real' delegate method.
 *  If you don't call it manually, it will be called automatically /after/ your method has run, but its return value (if any) will be discarded.
 *  This class can work with any delegates.

 *  When subclassing a subclass of this class, it is required that you indicate which delegate methods you implemented,
 *  so that people can know if they have to call super or not (This class implement one delegate method, see the note below)
 *  Please also see the documentation of the property `proxyDelegate` in ETHExtendableTextField+Subclass for information on how
 *  to create your own delegate methods.
 *
 *  @note This class already implement the following delegate method, and subclasses should call it:
 *  - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
 *    The default implementation of that method call the -[textFieldTextShouldChange:toText:] delegate method.
 *
 *  @warning Due to how the class work behind the scene, anything you assign to the delegate property will be replaced by
 *  another object, though it should not impact your code.
 *  Specifically, this is the only case worth noting:
 *       id delegateObject = ...;
 *       ETHExtendableTextField * textField = [[ETHExtendableTextField alloc] init];
 *       textField.delegate = delegateObject;
 *       if(textField.delegate == delegateObject) {
 *         // This test will NOT work. Use -[NSObject isEqual:] to test for equality instead, if available
 *       }
 */
@interface ETHExtendableTextField : UITextField <ETHExtendableTextFieldDelegate>

@property (nonatomic, weak, nullable) id<ETHExtendableTextFieldDelegate> delegate;

/**
 *  The proxyDelegate property should be used to call *custom* delegate. For example,
 *  `ETHExtendableTextField` uses `self.proxyDelegate` to call its custom textFieldTextShouldChange: and
 *  textFieldTextDidChange: delegate method, but uses `self.delegate` to call existing UITextField delegate methods.
 */
@property (nonatomic, strong, readonly) id<ETHExtendableTextFieldDelegate> proxyDelegate;

/**
 *  This method will set the text field text directly, using the standard iOS setter `setText`.
 *  This method should not be overriden by subclasses.
 *
 *  @param text The new text to set the text field.
 */
- (void)setTextFieldText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
