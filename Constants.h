//
//  Constants.h
//  Junction
//
//  Created by Bobby Ren on 12/22/12.
//
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#define TESTING 0
#define PARSE_HELPER_JUNCTION // parseHelper can use junction specific calls

#define PHOTO_BUCKET @"missionmade.junction.profile.photo"
#define PHOTO_BLUR_BUCKET @"missionmade.junction.profile.photoblur"

#define PROFILE_WIDTH 280
#define PROFILE_HEIGHT 280

#define USE_SIDEBAR 0
#define SIDEBAR_WIDTH 40

// whether slider to change blurriness exists in profile
#define USE_SLIDER_IN_PROFILE 0

#define COLOR_FAINTBLUE [UIColor colorWithRed:231.0/255.0 green:242.0/255.0 blue:249.0/255.0 alpha:1]
#define COLOR_LIGHTBLUE [UIColor colorWithRed:146.0/255.0 green:198.0/255.0 blue:226.0/255.0 alpha:1]
#define COLOR_BRIGHTBLUE [UIColor colorWithRed:0/255.0 green:139.0/255.0 blue:199.0/255.0 alpha:1]
#define COLOR_NAVYBLUE [UIColor colorWithRed:11.0/255.0 green:51.0/255.0 blue:91.0/255.0 alpha:1]
#define COLOR_ORANGE [UIColor colorWithRed:255.0/255.0 green:116.0/255.0 blue:82.0/255.0 alpha:1]
#define COLOR_GRAY [UIColor colorWithRed:87.0/255.0 green:87.0/255.0 blue:87.0/255.0 alpha:1]
#define COLOR_GREEN [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:102.0/255.0 alpha:1]
#define COLOR_[UIColor colorWithRed:67.0/255.0 green:99.0/255.0 blue:132.0/255.0 alpha:1]

@end
