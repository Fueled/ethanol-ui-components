//
//  ETHTextField.h
//  Ethanol
//
//  Created by Stephane Copin on 3/7/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETHExtendableTextField.h"

NS_ASSUME_NONNULL_BEGIN

@class ETHFormatter;
@class ETHValidator;
@class ETHTextField;

typedef NS_ENUM(NSUInteger, ETHTextFieldValidationReason) {
  ETHTextFieldValidationReasonLostFocus,
  ETHTextFieldValidationReasonReturnTapped,
  ETHTextFieldValidationReasonKeyTapped,
  ETHTextFieldValidationReasonProgramatically,
};

typedef BOOL (^ ETHValidationFailedBlock)(ETHTextFieldValidationReason validationReason, NSString * message);
typedef void (^ ETHValidationSuccessBlock)(ETHTextFieldValidationReason validationReason);

@protocol ETHTextFieldDelegate <ETHExtendableTextFieldDelegate>

@optional
- (BOOL)textField:(ETHTextField *)textField shouldFormat:(NSString *)text;
- (BOOL)textField:(ETHTextField *)textField shouldValidateText:(NSString *)text forReason:(ETHTextFieldValidationReason)reason;

- (void)textField:(ETHTextField *)textField didFormat:(NSString *)text;
- (BOOL)textField:(ETHTextField *)textField didValidateText:(NSString *)text withReason:(ETHTextFieldValidationReason)reason withSuccess:(BOOL)success error:(nullable NSError *)error;

@end

/**
 *  Provide a set of properties for limiting and validating the input of the user.
 *  Please see each individual property for more information.
 *  @note The following delegate methods should be called (Via super) when subclassing ETHTextField and overriding those methods
 *  (See ETHExtendableTextField documentation for more information):
 *  - (BOOL)textFieldTextShouldChange:(ETHExtendableTextField *)textField;
 *  - (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
 *  - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
 *  - (BOOL)textFieldShouldReturn:(UITextField *)textField;
 */
@interface ETHTextField : ETHExtendableTextField <ETHTextFieldDelegate>

/**
 *  Set/Get the formatter, used whenever text is entered in the text field.
 *  Text programatically set is not formatted.
 */
@property (nonatomic, strong, nullable) IBOutlet ETHFormatter * formatter;
/**
 * Set/Get the validator, called whenever the text field the user tap the return key if no delegate is set (By default).
 * If a delegate is set, this behavior can be changed by overriding the shouldValidateForReason: with
 * on lost focus or return tapped reasons.
 * In case validator is nil, the behavior is that of a normal UITextField.
 * Whenever this method is called, the `validateInput` method will be called.
 */
@property (nonatomic, strong, nullable) IBOutlet ETHValidator * validator;

/**
 * A property indicating whether the text field's text is validated or not.
 */
@property (nonatomic, assign, readonly, getter=isValidated) BOOL validated;

/**
 * Get what the ETHTextField's text will be set to if validation succeeds.
 * If no validation is in progress, then it is equivalent to using the `text` property.
 */
@property (nonatomic, copy, readonly, nullable) NSString * expectedText;

@property (nonatomic, weak, nullable) IBOutlet id<ETHTextFieldDelegate> delegate;

@property (nonatomic, strong, readonly) id<ETHTextFieldDelegate> proxyDelegate;

/**
 *  Get/Set the current allowed character set (i.e. characters that the user can type).
 *  Setting this property while there is a text will remove the characters that should not be displayed.
 *  @note A nil value means that all characters are allowed.
 */
@property (nonatomic, strong, nullable) NSCharacterSet * allowedCharacterSet;

/**
 *  Get/Set the maximum number of characters the user can type into this field.
 *  Setting this property while there is a text will truncate the text to the new limit, if needed.
 *  @note 0 means that there is no limit (Default behavior)
 */
@property (nonatomic, assign) NSUInteger maximumLength;

@property (nonatomic, assign) BOOL validateOnLostFocus; // Defaults to NO
@property (nonatomic, assign) BOOL validateOnReturn; // Defaults to YES
@property (nonatomic, assign) BOOL validateOnKeyTapped; // Defaults to NO

/**
 *  Validate the input of the text field. Doesn't call the related validation delegate with the programatically reason.
 *
 *  @return The validation result
 */
- (BOOL)validateInputSilently;

/**
 *  Validate the input of the text field.
 *
 *  @return The validation result
 */
- (BOOL)validateInput;

/**
 *  Can be overidden by subclasses. Only called when the value of `isValidated` changed.
 *
 *  @param reason The reason for which the validation state changed.
 */
- (void)validationStateDidChangeForReason:(ETHTextFieldValidationReason)reason;

@end
NS_ASSUME_NONNULL_END
