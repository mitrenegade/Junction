//
//  InputViewController.h
//  MetWorkingLite
//
//  Created by Bobby Ren on 9/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputViewDelegate <NSObject>

-(void)didGetInput:(NSString*)text forTag:(int)tag;

@end
@interface InputViewController : UIViewController <UINavigationControllerDelegate, UITextViewDelegate>

@property (nonatomic) IBOutlet UITextView * inputView;
@property (nonatomic) IBOutlet UILabel * label;
@property (nonatomic, assign) id delegate;
@property (nonatomic) NSString * initialText;
@property (nonatomic) NSString * labelText;
@property (nonatomic, assign) int inputTag;
@end
