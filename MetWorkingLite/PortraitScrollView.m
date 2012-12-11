//
//  PortraitScrollView.m
//  MetWorkingLite
//
//  Created by Bobby Ren on 10/27/12.
//
//

#import "PortraitScrollView.h"
#import "UserInfo.h"

@implementation PortraitScrollView

@synthesize pages, photo;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        pages = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addPhoto:(UIImage*)userPhoto {
    self.photo = userPhoto;
}

-(void)addUserInfo:(UserInfo *)userInfo {
    // create multiple pages
    CGSize size = self.bounds.size;
    int width = size.width;
    int height = size.height;
    int pageCt = 0;
    
    // background photo
    [self addPhoto:userInfo.photo];
    
    int fontSize = 20;
    int offset = 6;
    
    // page 1: username, headline
    pageCt++;
    UIView * page1 = [[UIView alloc] initWithFrame:self.frame];
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width-offset, height/2)];
    [nameLabel setText:userInfo.username];
    [nameLabel setNumberOfLines:3];
    [nameLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [nameLabel setCenter:CGPointMake((width+offset)/2, height/4*3)];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setTextColor:[UIColor whiteColor]];
    [page1 addSubview:nameLabel];
    
    pageCt++;
    UIView * page2 = [[UIView alloc] initWithFrame:self.frame];
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
    UIView * page3 = [[UIView alloc] initWithFrame:self.frame];
    UILabel * emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width-offset, height/2)];
    [emailLabel setText:userInfo.email];
    [emailLabel setNumberOfLines:3];
    [emailLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [emailLabel setCenter:CGPointMake((width+offset)/2, height/4*3)];
    [emailLabel setBackgroundColor:[UIColor clearColor]];
    [emailLabel setTextColor:[UIColor whiteColor]];
    [page3 addSubview:emailLabel];

    pageCt++;
    UIView * page4 = [[UIView alloc] initWithFrame:self.frame];
    UILabel * industryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width-offset, height/2)];
    [industryLabel setText:userInfo.industry];
    [industryLabel setNumberOfLines:3];
    [industryLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [industryLabel setCenter:CGPointMake((width+offset)/2, height/4*3)];
    [industryLabel setBackgroundColor:[UIColor clearColor]];
    [industryLabel setTextColor:[UIColor whiteColor]];
    [page4 addSubview:industryLabel];
    
    self.contentSize = CGSizeMake(width*pageCt, height);
    [page1 setCenter:CGPointMake(width/2+width*0, height/2)];
    [page2 setCenter:CGPointMake(width/2+width*1, height/2)];
    [page3 setCenter:CGPointMake(width/2+width*2, height/2)];
    [page4 setCenter:CGPointMake(width/2+width*3, height/2)];
//    [self addSubview:page1];
//    [self addSubview:page2];
//    [self addSubview:page3];
//    [self addSubview:page4];

    [self setPagingEnabled:YES];
    [self setPages:[NSMutableArray arrayWithObjects:page1,page2,page3,page4, nil]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
