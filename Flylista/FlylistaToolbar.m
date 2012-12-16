//
//  FlylistaToolbar.m
//  Flylista
//
//  Created by Dmitry Shmidt on 11/7/12.
//
//

#import "FlylistaToolbar.h"

@implementation FlylistaToolbar

- (void) initialize{
//    self.gradientStartColor =  [UIColor colorWithRed:1.000 green:0.772 blue:0.000 alpha:1.000];
//    self.gradientEndColor = [UIColor colorWithRed:0.619 green:0.480 blue:0.000 alpha:1.000];
//    self.topLineColor = [UIColor colorWithWhite:0.800 alpha:1.000];
//    self.bottomLineColor = [UIColor colorWithWhite:0.098 alpha:1.000];
//    self.tintColor = [UIColor colorWithWhite:0.298 alpha:1.000];
//    self.roundedCornerRadius = 8;
    //init your ivars here
}

- (id) initWithCoder:(NSCoder *)aCoder{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if(self = [super initWithCoder:aCoder]){
        [self initialize];
    }
    return self;
}


@end
