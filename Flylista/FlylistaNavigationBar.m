//
//  FlylistaNavigationBar.m
//  Flylista
//
//  Created by Dmitry Shmidt on 11/7/12.
//
//

#import "FlylistaNavigationBar.h"

@implementation FlylistaNavigationBar

- (void) initialize{
    self.gradientStartColor = [UIColor colorWithWhite:0.298 alpha:1.000];
    self.gradientEndColor = [UIColor colorWithWhite:0.200 alpha:1.000];
    self.topLineColor = [UIColor colorWithWhite:0.200 alpha:1.000];
    self.bottomLineColor = [UIColor colorWithWhite:0.098 alpha:1.000];
    self.tintColor = [UIColor colorWithWhite:0.298 alpha:1.000];
    self.roundedCornerRadius = 8;
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
