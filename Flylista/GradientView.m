//
//  GradientView.m
//  ShadowedTableView
//
//  Created by Matt Gallagher on 2009/08/21.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//

#import "GradientView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GradientView

//
// layerClass
//
// returns a CAGradientLayer class as the default layer class for this view
//
+ (Class)layerClass
{
	return [CAGradientLayer class];
}

//
// setupGradientLayer
//
// Construct the gradient for either construction method
//
- (void)setupGradientLayer
{
	CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
	gradientLayer.colors =
		[NSArray arrayWithObjects:
			(id)[UIColor whiteColor].CGColor,
			(id)[UIColor colorWithWhite:0.902 alpha:1.000].CGColor,
		nil];
	self.backgroundColor = [UIColor clearColor];
}

//
// initWithFrame:
//
// Initialise the view.
//
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	if (self)
	{
		CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
		gradientLayer.colors =
			[NSArray arrayWithObjects:
				(id)[UIColor whiteColor].CGColor,
				(id)[UIColor colorWithWhite:0.902 alpha:1.000].CGColor,
			nil];
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
