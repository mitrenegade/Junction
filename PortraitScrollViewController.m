//
//  PortraitScrollViewController.m
//  MetWorkingLite
//
//  Created by Bobby Ren on 10/30/12.
//
//

#import "PortraitScrollViewController.h"

@interface PortraitScrollViewController ()

@end

@implementation PortraitScrollViewController

@synthesize pages, photo;
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //pages = [[NSMutableArray alloc] init];
	pageControlBeingUsed = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addPhoto:(UIImage*)userPhoto {
    self.photo = userPhoto;
    int border = 2;
    int size = self.view.bounds.size.width;
    CGRect portraitframe = CGRectMake(border,border,size-border,size-border);

    UIImageView * photoBG = [[UIImageView alloc] initWithImage:self.photo];
    [photoBG setFrame:portraitframe];
    [self.view addSubview:photoBG];
}

-(void)addUserInfo:(UserInfo *)userInfo {
    // create multiple pages
    int width = self.view.bounds.size.width;
    int height = self.view.bounds.size.height;
    int pageCt = 0;
    
    // background photo
    [self addPhoto:userInfo.photo];
    
    int fontSizeName = 20;
    int fontSize = 15;
    int offset = 6;
    int border = 2;
    int size = self.view.bounds.size.width;
    CGRect portraitframe = CGRectMake(border,border,size-border,size-border);
    
    // page 1: username, headline
    pageCt++;
    UIView * page1 = [[UIView alloc] initWithFrame:portraitframe];
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width-offset, height/2)];
    [nameLabel setText:userInfo.username];
    [nameLabel setNumberOfLines:3];
    [nameLabel setFont:[UIFont boldSystemFontOfSize:fontSizeName]];
    [nameLabel setCenter:CGPointMake((width+offset)/2, height/4*3)];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setTextColor:[UIColor whiteColor]];
    [page1 addSubview:nameLabel];
    
    pageCt++;
    UIView * page2 = [[UIView alloc] initWithFrame:portraitframe];
    UILabel * headlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width-offset, height/2)];
    [headlineLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [headlineLabel setText:userInfo.headline];
    [headlineLabel setNumberOfLines:3];
    [headlineLabel setCenter:CGPointMake((width+offset)/2, height/4*3)];
    [headlineLabel setBackgroundColor:[UIColor clearColor]];
    [headlineLabel setTextColor:[UIColor whiteColor]];
    [page2 addSubview:headlineLabel];
    
    // page 2: username, headline
    pageCt++;
    UIView * page3 = [[UIView alloc] initWithFrame:portraitframe];
    UILabel * emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width-offset, height/2)];
    [emailLabel setText:userInfo.email];
    [emailLabel setNumberOfLines:3];
    [emailLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [emailLabel setCenter:CGPointMake((width+offset)/2, height/4*3)];
    [emailLabel setBackgroundColor:[UIColor clearColor]];
    [emailLabel setTextColor:[UIColor whiteColor]];
    [page3 addSubview:emailLabel];
    
    pageCt++;
    UIView * page4 = [[UIView alloc] initWithFrame:portraitframe];
    UILabel * industryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width-offset, height/2)];
    [industryLabel setText:userInfo.industry];
    [industryLabel setNumberOfLines:3];
    [industryLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [industryLabel setCenter:CGPointMake((width+offset)/2, height/4*3)];
    [industryLabel setBackgroundColor:[UIColor clearColor]];
    [industryLabel setTextColor:[UIColor whiteColor]];
    [page4 addSubview:industryLabel];
    
    scrollView = [[UIScrollView alloc] initWithFrame:portraitframe];
    [scrollView setDelegate:self];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setDirectionalLockEnabled:YES];
    [scrollView setBounces:NO];
    self.scrollView.contentSize = CGSizeMake(width*pageCt, height);
    [page1 setCenter:CGPointMake(width/2+width*0, height/2)];
    [page2 setCenter:CGPointMake(width/2+width*1, height/2)];
    [page3 setCenter:CGPointMake(width/2+width*2, height/2)];
    [page4 setCenter:CGPointMake(width/2+width*3, height/2)];
    [self.scrollView addSubview:page1];
    [self.scrollView addSubview:page2];
    [self.scrollView addSubview:page3];
    [self.scrollView addSubview:page4];
    [self.scrollView setPagingEnabled:YES];
    [self.view addSubview:scrollView];
    
//    [self setPages:[NSMutableArray arrayWithObjects:page1,page2,page3,page4, nil]];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (!pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
		CGFloat pageWidth = self.scrollView.frame.size.width;
		int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		//self.pageControl.currentPage = page;
        currentPage = page;
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
	frame.origin.x = self.scrollView.frame.size.width * currentPage; //self.pageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.scrollView.frame.size;
	[self.scrollView scrollRectToVisible:frame animated:YES];
	
	// Keep track of when scrolls happen in response to the page control
	// value changing. If we don't do this, a noticeable "flashing" occurs
	// as the the scroll delegate will temporarily switch back the page
	// number.
	pageControlBeingUsed = YES;
}


@end
