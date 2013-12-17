//
//  IndustryFilterTableViewController.h
//  Junction
//
//  Created by Bobby Ren on 3/11/13.
//
//

#import <UIKit/UIKit.h>

#define INDUSTRY_ARRAY  @"BANKING", @"CONSUMER", @"ENTERTAINMENT", @"FASHION", @"FINANCE", @"GAMING", @"MARKETING", @"MEDIA", @"TECH", @"TRAVEL"

@protocol IndustryFilterDelegate <NSObject>

-(void)didSelectIndustryFilter:(NSString*)industry;

@end

@interface IndustryFilterTableViewController : UITableViewController

@property (nonatomic, weak) id delegate;
@end
