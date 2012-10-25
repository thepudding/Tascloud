//
//  ToDoCloudLabel.m
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/9/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import "ToDoCloudLabel.h"

@implementation ToDoCloudLabel

@synthesize visualCenter, velocity;

-(void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.text forKey:@"textKey"];
    [aCoder encodeCGPoint:self.center forKey:@"centerKey"];
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.text = [aDecoder decodeObjectForKey:@"textKey"];
        self.center = [aDecoder decodeCGPointForKey:@"centerKey"];
        self.velocity = CGPointMake(0, 0);
        self.userInteractionEnabled = true;
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor colorWithWhite: 0.13 alpha:1];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame visualCenter:(CGPoint)visualCenter {
    self = [self initWithFrame:frame];
    self.visualCenter = visualCenter;
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        velocity = CGPointMake(0.0, 0.0);
    }
    return self;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	// When a touch starts, get the current location in the view
	currentPoint = [[touches anyObject] locationInView:self];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	// Get active location upon move
	CGPoint activePoint = [[touches anyObject] locationInView:self];
    
	// Determine new point based on where the touch is now located
	CGPoint newPoint = CGPointMake(self.center.x + (activePoint.x - currentPoint.x),
                                   self.center.y + (activePoint.y - currentPoint.y));
    [self boundedMoveToNewCenter:newPoint];
    
    [self checkAndUpdateOverlappingLabels];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    int length = [self.superview.subviews count];
    int count=0;
    while(count < length) {
        UIView *element = [self.superview.subviews objectAtIndex:count];
        count += 1;
        if([element isKindOfClass: ToDoCloudLabel.class]) {
            ToDoCloudLabel *checkLabel = (ToDoCloudLabel *)element;
            checkLabel.velocity = CGPointZero;
        }
    }
    
    CGPoint endPoint = [[touches anyObject] locationInView:self.superview];
    CGFloat tops = [self.superview viewWithTag:1].frame.origin.y - 8.0;
    if(CGRectContainsPoint([self.superview viewWithTag:1].frame, endPoint)) {
        [self removeFromSuperview];
        NSLog(@"Deleted: %@", self.text);
    } else if(CGRectContainsPoint([self.superview viewWithTag:2].frame, endPoint)) {
        [self removeFromSuperview];
        //TODO: store the completed ones somewhere. WHERE? who knows!
        NSLog(@"Completed: %@", self.text);
    } else if(self.frame.origin.y + self.frame.size.height > tops) {
        //bounce up!
        CGPoint newCenter = CGPointMake(self.center.x, tops - (self.frame.size.height/2.0));
        CGFloat duration = 1.0 - (self.center.y - newCenter.y)/55.0;
        [UIView animateWithDuration:0.25 + 0.25*duration
                              delay:0
                            options: UIViewAnimationCurveEaseIn
                         animations:^{
                             self.center = newCenter;
                         } 
                         completion:^(BOOL finished){
                             NSLog(@"Bounce Done!");
                         }];
    }
}

- (void)moveToCenter {
    [self boundedMoveToNewCenter:visualCenter];
    [self checkAndUpdateOverlappingLabels];
}

- (void)checkAndUpdateOverlappingLabels {
    //Ok you shouldn't have to do that ...
    [self checkAndUpdateOverlappingLabelsExcluding:[[NSMutableArray alloc] init]];
}

- (void)checkAndUpdateOverlappingLabelsExcluding:(NSMutableArray *)exclude {
    int length = [self.superview.subviews count];
    int count=0;
    while(count < length) {
        UIView *element = [self.superview.subviews objectAtIndex:count];
        count += 1;
        if([element isKindOfClass: ToDoCloudLabel.class]) {
            ToDoCloudLabel *checkLabel = (ToDoCloudLabel *)element;
            // Don't compare to itself delete or complete views.
            if(checkLabel != self && checkLabel.tag != 1 && checkLabel.tag != 2 &&
               ([exclude count] == 0 || ![exclude containsObject:checkLabel]) &&
               CGRectIntersectsRect(self.frame, checkLabel.frame)) {
                // Push the overlapping label out
                CGSize overlap = CGRectIntersection(self.frame, checkLabel.frame).size;
                CGPoint shift;
                // Push along the X axis
                /*
                 If:
                    the bottom of self falls within the y range of check
                    or the top '' ''
                 */
                CGFloat minXPos = CGRectGetMinX(self.frame)-velocity.x;
                CGFloat maxXPos = CGRectGetMaxX(self.frame)-velocity.x;
                NSString *s;
                if(//!(velocity.x > CGRectGetMidX(checkLabel.bounds)) &&
                   ((minXPos > CGRectGetMinX(checkLabel.frame)&&
                     minXPos < CGRectGetMaxX(checkLabel.frame)) ||
                    (maxXPos > CGRectGetMinX(checkLabel.frame)&&
                     maxXPos < CGRectGetMaxX(checkLabel.frame))))
                {
                    shift = CGPointMake(0,overlap.height*signumF(velocity.y));
                    if(signumF(velocity.y) > 0) {
                        s = @"v";
                    } else if(signumF(velocity.y) < 0) {
                        s = @"^";
                    } else {
                        s = [NSString stringWithFormat:@"...y: %f", velocity.y];
                    }
                // otherwise push along the x axis
                } else {
                    shift = CGPointMake(overlap.width*signumF(velocity.x),0);
                    if(signumF(velocity.x) > 0) {
                        s = @">";
                    } else if(signumF(velocity.x) < 0) {
                        s = @"<";
                    } else {
                        s = [NSString stringWithFormat:@"...x: %f", velocity.x];
                    }
                }
                NSLog(@"%@", s);
                // If moving the label hit a wall
                CGPoint difference = [checkLabel boundedShiftBy:shift];
                if(difference.x != 0 || difference.y != 0) {
                    [self boundedMoveToNewCenter:CGPointMake(self.center.x - difference.x, self.center.y - difference.y)];
                }
                
                /*else if(CGRectIntersectsRect(self.frame, checkLabel.frame)) {
                    CGSize overlap = CGRectIntersection(self.frame, checkLabel.frame).size;
                    CGPoint shift = CGPointMake(overlap.width/2, overlap.height/2);
                    
                    //[self boundedShiftBy:CGMakePoint(overlap.)];
                }*/
                
                // add checklabel to the array and call it again.
                [exclude addObject:checkLabel];
                [checkLabel checkAndUpdateOverlappingLabelsExcluding:exclude];
            }
        }
    }
}

- (CGPoint)boundedShiftBy:(CGPoint)shiftFactor {
    return [self boundedMoveToNewCenter:CGPointMake(self.center.x + shiftFactor.x, self.center.y + shiftFactor.y)];
}
// Returns the offset from the desired point
- (CGPoint)boundedMoveToNewCenter:(CGPoint)newPoint {
    CGPoint compare = newPoint;
    //--------------------------------------------------------
	// Make sure we stay within the bounds of the parent view
	//--------------------------------------------------------
    float midPointX = CGRectGetMidX(self.bounds);
	// If too far right...
    if (newPoint.x > self.superview.bounds.size.width  - midPointX) {
        newPoint.x = self.superview.bounds.size.width - midPointX;
    } else if (newPoint.x < midPointX) {
        // If too far left...
        newPoint.x = midPointX;
    }
    
	float midPointY = CGRectGetMidY(self.bounds);
    // If too far down...
	if (newPoint.y > self.superview.bounds.size.height  - midPointY) {
        newPoint.y = self.superview.bounds.size.height - midPointY;
    } else if (newPoint.y < midPointY) {
        // If too far up...
        newPoint.y = midPointY;
    }
    velocity = CGPointMake(newPoint.x - self.center.x,newPoint.y - self.center.y);
    
	// Set new center location
	self.center = newPoint;
    // update the font size
    [self updateFontSize];
    return CGPointMake(compare.x - newPoint.x, compare.y - newPoint.y);
}

- (void)updateFontSize {
    CGFloat xDist = (self.visualCenter.x - self.center.x);
    CGFloat yDist = (self.visualCenter.y - self.center.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    
    CGFloat fontSize = MAXIMUM_FONT_SIZE - distance/FONT_RESIZE_FACTOR;
    if(fontSize < MINIMUM_FONT_SIZE){
        fontSize = MINIMUM_FONT_SIZE;
    }
    
    UIFont *newFont = [UIFont fontWithName:@"GillSans-Light" size:fontSize];
    CGSize newSize = [self.text sizeWithFont:newFont];
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            newSize.width,
                            newSize.height);
    self.font = newFont;
}
@end
