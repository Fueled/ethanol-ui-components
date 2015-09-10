//
//  ETHNibView.h
//
//  Created by Stéphane Copin on 12/7/12.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Subclass this class to use
 *  @note
 *  Instructions:
 *  - Subclass this class
 *  - Associate it with a nib via File's Owner (Whose name is defined by [-nibName])
 *  - Bind contentView to the root view of the nib
 *  - Then you can insert it either in code or in a xib/storyboard, your choice
 */
@interface ETHNibView : UIView

@property (strong, nonatomic, readonly) IBOutlet UIView *contentView;

/**
 *  Is called when the nib name associated with the class is going to be loaded.
 *
 *  @return The nib name (Default implementation returns class name: `NSStringFromClass([self class])`)
 *  You will want to override this method in swift as the class name is prefixed with the module in that case
 */
- (NSString *)nibName;

/**
 *  Called when first loading the nib.
 *  Defaults to `[NSBundle bundleForClass:[self class]]`
 *
 *  @return The bundle in which to find the nib.
 */
- (nullable NSBundle *)nibBundle;

/**
 *  Use the 2 methods above to instanciate the correct instance of UINib for the view.
 *  You can override this if you need more customization.
 *
 *  @return An instance of UINib
 */
- (nonnull UINib *)nib;

@end

NS_ASSUME_NONNULL_END
