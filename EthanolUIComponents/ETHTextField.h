//
//  ETHTextField.h
//  Ethanol
//
//  Created by Stephane Copin on 3/7/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EthanolUIComponents/ETHExtendableTextField.h>

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
- (BOOL)textField:(ETHTextField *)textField shouldValidateOnLostFocus:(NSString *)text;
- (BOOL)textField:(ETHTextField *)textField shouldValidateOnReturn:(NSString *)text;
- (BOOL)textField:(ETHTextField *)textField shouldValidateOnKeyTapped:(NSString *)text;

- (void)textField:(ETHTextField *)textField didFormat:(NSString *)text;

// The below methods takes precedence over the validationFailedBlock/validationSucceededBlock, if they are defined.
- (BOOL)textField:(ETHTextField *)textField didValidateOnLostFocus:(NSString *)text withSuccess:(BOOL)success;
- (BOOL)textField:(ETHTextField *)textField didValidateOnReturn:(NSString *)text withSuccess:(BOOL)success;
- (void)textField:(ETHTextField *)textField didValidateOnKeyTapped:(NSString *)text withSuccess:(BOOL)success;
- (void)textField:(ETHTextField *)textField didValidateProgrammatically:(NSString *)text withSuccess:(BOOL)success;

@end

/**
 *  Provide a set of properties for limiting and validating the input of the user.
 *  Please see each individual property for more information.
 *  @note The following delegate methods should be called (Via super) when subclassing ETHTextField and overriding those methods
 *  (See ETHExtendableTextField documentation for more information):
 *  - (void)textFieldTextDidChange:(UITextField *)textField;
 *  - (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
 *  - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
 *  - (BOOL)textFieldShouldReturn:(UITextField *)textField;
 */
@interface ETHTextField : ETHExtendableTextField

/**
 *  Set/Get the formatter, used whenever text is entered in the text field.
 *  Text programatically set is not formatted.
 */
@property (nonatomic, strong) IBOutlet ETHFormatter * formatter;
/**
 * Set/Get the validator, called whenever the text field the user tap the return key if no delegate is set.
 * If a delegate is set, this behavior can be changed by overriding the textFieldShouldValidateOnLostFocus: and
 * textFieldShouldValidateOnReturn: methods.
 * In case validator is nil, the behavior is that of a normal UITextField.
 */
@property (nonatomic, strong) IBOutlet ETHValidator * validator;
@property (nonatomic, weak) IBOutlet id<ETHTextFieldDelegate> delegate;

/**
 *  Get/Set the current allowed character set (i.e. characters that the user can type).
 *  Setting this property while there is a text will remove the characters that should not be displayed.
 *  @note A nil value means that all characters are allowed.
 */
@property (nonatomic, strong) NSCharacterSet * allowedCharacterSet;

/**
 *  Get/Set the maximum number of characters the user can type into this field.
 *  Setting this property while there is a text will truncate the text to the new limit, if needed.
 *  @note 0 means that there is no limit (Default behavior)
 */
@property (nonatomic, assign) NSUInteger maximumLength;

@property (nonatomic, assign) BOOL validateOnLostFocus;
@property (nonatomic, assign) BOOL validateOnReturn;
@property (nonatomic, assign) BOOL validateOnKeyTapped;

/**
 *  Validate the input of the text field.
 *
 *  @return The validation result
 */
- (BOOL)validateInputSilently;

/**
 *  Validate the input of the text field, and calls the validation failed block in case of validation failure
 *
 *  @return The validation result
 */
- (BOOL)validateInput;

@end
