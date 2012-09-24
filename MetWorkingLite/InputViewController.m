//
//  InputViewController.m
//  MetWorkingLite
//
//  Created by Bobby Ren on 9/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InputViewController.h"

@interface InputViewController ()

@end

@implementation InputViewController

@synthesize inputView;
@synthesize delegate;
@synthesize initialText;
@synthesize labelText;
@synthesize label;
@synthesize inputTag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(didClickGoButton:)];
        [self.navigationItem setRightBarButtonItem:rightButton];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [inputView setText:initialText];
    [label setText:labelText];
    if (!labelText)
        [label setText:@"Enter some text!"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)didClickGoButton:(id)sender {
    [self.navigationController setNavigationBarHidden:YES];
    [delegate didGetInput:[inputView text] forTag:inputTag];
}

#pragma mark textviewdelegate
/*
-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    [self didClickGoButton:nil];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    [self didClickGoButton:nil];
}
 */
@end
