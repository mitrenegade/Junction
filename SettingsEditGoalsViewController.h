//
//  SettingsEditGoalsViewController.h
//  Junction
//
//  Created by Bobby Ren on 4/7/13.
//
//

#import <UIKit/UIKit.h>

@interface SettingsEditGoalsViewController : UIViewController <UITextViewDelegate, UINavigationControllerDelegate>
{
    IBOutlet UITextView * textViewLookingFor;
    IBOutlet UITextView * textViewTalkAbout;
    IBOutlet UILabel * labelLookingFor;
    IBOutlet UILabel * labelTalkAbout;
    IBOutlet UIScrollView * scrollView;
    
    BOOL keyboardIsShown;
    UITextView * currentTextView;
}
@end
