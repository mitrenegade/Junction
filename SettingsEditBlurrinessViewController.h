//
//  SettingsEditBlurrinessViewController.h
//  Junction
//
//  Created by Bobby Ren on 4/8/13.
//
//

#import <UIKit/UIKit.h>

@interface SettingsEditBlurrinessViewController : UIViewController <UINavigationControllerDelegate>
{
    IBOutlet UIImageView * photoView;
    IBOutlet UISlider * sliderBlur;
    int privacyLevel;
}

-(IBAction)sliderDidChangeValue:(id)sender;

@end
