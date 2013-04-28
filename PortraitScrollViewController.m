//
//  PortraitScrollViewController.m
//  MetWorkingLite
//
//  Created by Bobby Ren on 10/30/12.
//
//

#import "PortraitScrollViewController.h"
#import "AppDelegate.h"
#import "AsyncImageView.h"
#import "OutlineLabel.h"

@implementation PortraitScrollViewController

static AppDelegate * appDelegate;

@synthesize pages, photo;
@synthesize scrollView;
@synthesize pageControl;
@synthesize delegate;
@synthesize lastLoadedPortrait;
@synthesize photoBG;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    pages = [[NSMutableArray alloc] init];
	pageControlBeingUsed = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    // on dealloc, there may still be pending async calls, which will eventually call on a deallocated delegate unless set to nil
    [self.photoBG setDelegate:nil];
}

-(void)addPhoto:(UIImage*)userPhoto withURL:(NSString*)urlString {
    self.photo = userPhoto;
    int border = 0;
    int size = self.view.frame.size.width;
    CGRect portraitframe = CGRectMake(border,border,size-border,size-border);

#if 0
    UIImageView * photoBG = [[UIImageView alloc] initWithImage:self.photo];
    [photoBG setFrame:portraitframe];
    [self.view addSubview:photoBG];
#else
    self.photoBG = [[AsyncImageView alloc] init]; //WithImage:self.photo];
    [photoBG setDelegate:self];
    NSLog(@"PortraitScroll for %@: adding photo at url %@", self.userInfo.username, urlString);
    if (urlString == nil)
        NSLog(@"Here!");
    [photoBG setImageURL:[NSURL URLWithString:urlString]];
    [photoBG setFrame:portraitframe];
    
    if (userPhoto) {
        [photoBG setImage:userPhoto];
    }
    else {
        [photoBG setImage:self.lastLoadedPortrait];
    }
    
    [self.view addSubview:photoBG];
#endif
}

-(void)addUserInfo:(UserInfo *)userInfo {
    NSLog(@"Added userInfo %@ to portrait!", userInfo.username);
    if (!userInfo)
        NSLog(@"Added nil userinfo!");
    self.userInfo = userInfo;
    
    // create multiple pages
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height;
    
    // background photo
    if ([appDelegate isConnectedWithUser:userInfo]) {
        [self addPhoto:userInfo.photoThumb withURL:userInfo.photoThumbURL];
    }
    else if ([appDelegate isConnectRequestReceivedFromUser:userInfo]) {
        [self addPhoto:userInfo.photoThumb withURL:userInfo.photoThumbURL];
    }
    else {
        [self addPhoto:userInfo.photoBlurThumb withURL:userInfo.photoBlurThumbURL];
    }
    int fontSize = 12;
    int offset = 6;
    int size = self.view.frame.size.width;
    UIColor * bgColor = [UIColor clearColor];
    CGRect portraitframe = CGRectMake(0,0,size,size);
    
    [pages removeAllObjects];
    
    // page 1: professional information
    UIView * page1 = [[UIView alloc] initWithFrame:portraitframe];
    [page1 setBackgroundColor:[UIColor clearColor]];
    
    CGRect labelFrame = CGRectMake(offset, height/2-20, width-offset*2, height/2);
    OutlineLabel * roleLabel = [[OutlineLabel alloc] initWithFrame:labelFrame];
    [roleLabel setText:userInfo.position];
    [roleLabel setNumberOfLines:0];
    [roleLabel setFontSize:fontSize+3];
    [roleLabel setBackgroundColor:bgColor];
    [roleLabel setTextColor:[UIColor whiteColor]];
    [roleLabel setOutlineColor:[UIColor blackColor]];
    [roleLabel setTextAlignment:NSTextAlignmentCenter];
    [roleLabel sizeToFit];
    CGRect sublabelFrame = roleLabel.frame;
    sublabelFrame.origin.y += sublabelFrame.size.height;
    sublabelFrame.origin.x = offset;
    sublabelFrame.size.width = width - offset*2;
    OutlineLabel * companyLabel = [[OutlineLabel alloc] initWithFrame:sublabelFrame];
    if (userInfo.isVisible) {
        [companyLabel setText:[NSString stringWithFormat:@"at %@", userInfo.company]];
        [companyLabel setNumberOfLines:0];
        [companyLabel setFontSize:fontSize-1];
        [companyLabel setBackgroundColor:bgColor];
        [companyLabel setTextColor:[UIColor whiteColor]];
        [companyLabel setOutlineColor:[UIColor blackColor]];
        [companyLabel setTextAlignment:NSTextAlignmentCenter];
        [companyLabel sizeToFit];
        sublabelFrame = companyLabel.frame;
        sublabelFrame.origin.y += sublabelFrame.size.height;
        sublabelFrame.origin.x = offset;
        sublabelFrame.size.width = width - offset*2;
    }
    OutlineLabel * industryLabel = [[OutlineLabel alloc] initWithFrame:sublabelFrame];
    [industryLabel setText:[NSString stringWithFormat:@"in %@", userInfo.industry]];
    [industryLabel setNumberOfLines:0];
    [industryLabel setFontSize:fontSize-1];
    [industryLabel setBackgroundColor:bgColor];
    [industryLabel setTextColor:[UIColor whiteColor]];
    [industryLabel setOutlineColor:[UIColor blackColor]];
    [industryLabel setTextAlignment:NSTextAlignmentCenter];
    [industryLabel sizeToFit];
    
    [page1 addSubview:roleLabel];
    [roleLabel setCenter:CGPointMake(width/2, roleLabel.center.y)];
    if (appDelegate.myUserInfo.isVisible) {
        [page1 addSubview:companyLabel];
        [companyLabel setCenter:CGPointMake(width/2, companyLabel.center.y)];
    }
    [page1 addSubview:industryLabel];
    [industryLabel setCenter:CGPointMake(width/2, industryLabel.center.y)];
    [pages addObject:page1];

    // page 2: i'm looking for
    UIView * page2 = [[UIView alloc] initWithFrame:portraitframe];
    [page2 setBackgroundColor:[UIColor clearColor]];
    
    OutlineLabel * lookingForTitle = [[OutlineLabel alloc] initWithFrame:labelFrame];
    [lookingForTitle setText:@"I'm looking for:"];
    [lookingForTitle setNumberOfLines:0];
    [lookingForTitle setFontSize:fontSize+2];
    [lookingForTitle setBackgroundColor:bgColor];
    [lookingForTitle setTextColor:[UIColor whiteColor]];
    [lookingForTitle setOutlineColor:[UIColor blackColor]];
    [lookingForTitle setTextAlignment:NSTextAlignmentCenter];
    [lookingForTitle sizeToFit];
    sublabelFrame = lookingForTitle.frame;
    sublabelFrame.origin.y += sublabelFrame.size.height;
    sublabelFrame.origin.x = offset;
    sublabelFrame.size.width = width - offset*2;
    OutlineLabel * lookingForLabel = [[OutlineLabel alloc] initWithFrame:sublabelFrame];
    [lookingForLabel setFontSize:fontSize];
    [lookingForLabel setText:userInfo.lookingFor];
    [lookingForLabel setNumberOfLines:0];
    [lookingForLabel setBackgroundColor:bgColor];
    [lookingForLabel setTextColor:[UIColor whiteColor]];
    [lookingForLabel setOutlineColor:[UIColor blackColor]];
    [lookingForLabel setTextAlignment:NSTextAlignmentCenter];
    [lookingForLabel sizeToFit];
    [page2 addSubview:lookingForTitle];
    [page2 addSubview:lookingForLabel];
    [lookingForTitle setCenter:CGPointMake(width/2, lookingForTitle.center.y)];
    [lookingForLabel setCenter:CGPointMake(width/2, lookingForLabel.center.y)];
    [pages addObject:page2];

    // page 3: talk to me about
    UIView * page3 = [[UIView alloc] initWithFrame:portraitframe];
    [page3 setBackgroundColor:[UIColor clearColor]];
    
    OutlineLabel * talkAboutTitle = [[OutlineLabel alloc] initWithFrame:labelFrame];
    [talkAboutTitle setText:@"Talk to me about:"];
    [talkAboutTitle setNumberOfLines:0];
    [talkAboutTitle setFontSize:fontSize+2];
    [talkAboutTitle setBackgroundColor:bgColor];
    [talkAboutTitle setTextColor:[UIColor whiteColor]];
    [talkAboutTitle setOutlineColor:[UIColor blackColor]];
    [talkAboutTitle setTextAlignment:NSTextAlignmentCenter];
    [talkAboutTitle sizeToFit];
    sublabelFrame = lookingForTitle.frame;
    sublabelFrame.origin.y += sublabelFrame.size.height;
    sublabelFrame.origin.x = offset;
    sublabelFrame.size.width = width - offset*2;
    OutlineLabel * talkAboutLabel = [[OutlineLabel alloc] initWithFrame:sublabelFrame];
    [talkAboutLabel setText:userInfo.talkAbout];
    [talkAboutLabel setNumberOfLines:0];
    [talkAboutLabel setFontSize:fontSize];
    [talkAboutLabel setBackgroundColor:bgColor];
    [talkAboutLabel setTextColor:[UIColor whiteColor]];
    [talkAboutLabel setOutlineColor:[UIColor blackColor]];
    [talkAboutLabel setTextAlignment:NSTextAlignmentCenter];
    [talkAboutLabel sizeToFit];
    [page3 addSubview:talkAboutTitle];
    [page3 addSubview:talkAboutLabel];
    [talkAboutTitle setCenter:CGPointMake(width/2, talkAboutTitle.center.y)];
    [talkAboutLabel setCenter:CGPointMake(width/2, talkAboutLabel.center.y)];
    [pages addObject:page3];

    scrollView = [[UIScrollView alloc] initWithFrame:portraitframe];
    [scrollView setDelegate:self];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setDirectionalLockEnabled:YES];
    [scrollView setBounces:NO];
    self.scrollView.contentSize = CGSizeMake(width*[pages count], height);
    for (int i=0; i<[pages count]; i++) {
        [[pages objectAtIndex:i] setCenter:CGPointMake(width/2+width*i, height/2)];
        [self.scrollView addSubview:[pages objectAtIndex:i]];
    }
    [self.scrollView setPagingEnabled:YES];
    //[self.scrollView setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:scrollView];

    pageControl = [[UIPageControl alloc] init];
    int pageCt = [pages count];
    [pageControl setNumberOfPages:pageCt];
    [pageControl setHidesForSinglePage:NO];
    [pageControl setFrame:portraitframe];
    
    CGSize pcsize = [pageControl sizeForNumberOfPages:pageCt]; //[pages count]];
    [pageControl setFrame:CGRectMake(0, 0, pcsize.width, pcsize.height)];
    CGPoint center = CGPointMake(width/2, height-10);//self.view.center;
    [pageControl setCenter:center];
    
    [self.view addSubview:pageControl];

    // connection request and chat notifications
    chatIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-new-chat"]];
    connectIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-connected"]];
    [self updateIcons];
    
    // add gesture recognizer
    UITapGestureRecognizer * myTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [myTapRecognizer setNumberOfTapsRequired:1];
    [myTapRecognizer setNumberOfTouchesRequired:1];
    [myTapRecognizer setDelegate:self];
    [self.view addGestureRecognizer:myTapRecognizer];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (!pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
		CGFloat pageWidth = self.scrollView.frame.size.width;
		int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		self.pageControl.currentPage = page;
        //currentPage = page;
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (IBAction)changePage {
	// Update the scroll view to the appropriate page
	CGRect frame;
	frame.origin.x = self.pageControl.currentPage;
    frame.origin.y = 0;
    //self.scrollView.frame.size.width * currentPage; //	frame.origin.y = 0;
	frame.size = self.scrollView.frame.size;
	[self.scrollView scrollRectToVisible:frame animated:YES];
	
	// Keep track of when scrolls happen in response to the page control
	// value changing. If we don't do this, a noticeable "flashing" occurs
	// as the the scroll delegate will temporarily switch back the page
	// number.
	pageControlBeingUsed = YES;
}

#pragma mark gesture recognizer
-(void)tapGestureHandler:(UITapGestureRecognizer*) sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        // so tap is not continuously sent
        NSLog(@"Tap gesture!");
        [delegate didTapPortraitWithUserInfo:self.userInfo];
    }
}

#pragma mark AsyncImageDelegate {

-(void)didFinishLoadingImage:(UIImage *)result {
    self.lastLoadedPortrait = result;
}

-(void)reloadWithUserInfo:(UserInfo*)userInfo {
    [photoBG setImageURL:nil];
    [self addUserInfo:userInfo];
}

-(void)updateIcons {
    BOOL hasConnectionRequest = [appDelegate isConnectRequestReceivedFromUser:self.userInfo];
    BOOL hasNewChat = [appDelegate hasNewChatFromUserInfo:self.userInfo];
    CGRect firstFrame = CGRectMake(self.view.frame.size.width - 60/2, 5, 55/2, 59/2);
    CGRect secondFrame = CGRectMake(self.view.frame.size.width - 115/2, 5, 55/2, 59/2);

    if (!hasConnectionRequest)
        [connectIcon removeFromSuperview];
    if (!hasNewChat)
        [chatIcon removeFromSuperview];
    if (hasConnectionRequest) {
        [connectIcon setFrame:firstFrame];
        [self.view addSubview:connectIcon];
    }
    if (hasNewChat) {
        [chatIcon setFrame:firstFrame];
        [self.view addSubview:chatIcon];
        if (hasConnectionRequest) {
            [chatIcon setFrame:secondFrame];
        }
    }
}
@end
