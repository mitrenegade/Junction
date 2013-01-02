//
//  Chat.h
//  Junction
//
//  Created by Bobby Ren on 1/1/13.
//
//

#import <Foundation/Foundation.h>
#import "PFObjectFactory.h"
//#import "UserInfo.h"

@interface Chat : NSObject <PFObjectFactory>
@property (strong, nonatomic) NSString * className;
@property (strong, nonatomic) NSString * sender;
@property (strong, nonatomic) NSString * message;
@property (nonatomic, strong) PFObject *pfObject;
@property (nonatomic, strong) NSString * chatChannel;

-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
+(NSString*)getClassName;

@end
