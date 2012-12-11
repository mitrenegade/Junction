//
//  MapGestureRecognizer.h
//  GettingStuffWorking
//
//  Created by Geoff Oberhofer on 8/15/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^TouchesEventBlock)(NSSet * touches, UIEvent * event);

@interface MapGestureRecognizer : UIGestureRecognizer {
    TouchesEventBlock touchesBeganCallback;
}

@property(copy) TouchesEventBlock touchesBeganCallback;

@end
