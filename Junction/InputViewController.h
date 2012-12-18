//
//  InputViewController.h
//  Junction
//
//  Created by Bobby Ren on 9/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputViewDelegate <NSObject>

-(void)didGetInput:(NSString*)text forTag:(int)tag;

@end
@interface InputViewController : UIViewController <UINavigationControllerDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView * inputView;
@property (strong, nonatomic) IBOutlet UILabel * label;
@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) NSString * initialText;
@property (strong, nonatomic) NSString * labelText;
@property (assign, nonatomic) int inputTag;
@end
