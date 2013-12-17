//
//  SettingsEditPersonalViewController.h
//  Junction
//
//  Created by Bobby Ren on 4/7/13.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "UserInfo.h"

@interface SettingsEditPersonalViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate>
{
    IBOutlet UITextField * textFieldName;
    IBOutlet UITextField * textFieldEmail;
    IBOutlet UILabel * label1;
    IBOutlet UILabel * label2;
}
@end
