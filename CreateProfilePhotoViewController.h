//
//  CreateProfilePhotoViewController.h
//  Junction
//
//  Created by Bobby Ren on 1/27/13.
//
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@protocol CreateProfilePhotoDelegate <NSObject>

-(void)didSaveProfilePhoto;

@end

@interface CreateProfilePhotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView * photoView;
@property (nonatomic, weak) IBOutlet UIButton * buttonChangePhoto;
@property (nonatomic, weak) IBOutlet UISlider * slider;
@property (nonatomic, weak) UserInfo * userInfo;
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) IBOutlet UIButton * stepButton;

-(IBAction)sliderDidChangeValue:(id)sender;
-(void)populateWithUserInfo:(UserInfo*)newUserInfo;
@end
