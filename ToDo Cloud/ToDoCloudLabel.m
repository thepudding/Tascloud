//
//  ToDoCloudLabel.m
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/9/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import "ToDoCloudLabel.h"

NSString* NSStringFromDirection(Direction d) {
    if(d.x == 0 && d.y == 0) {
        return @".";
    }
    
    if(d.x == 0) {
        if(d.y > 0) {
            return @"v";
        } else {
            return @"^";
        }
    } else if(d.y == 0) {
        if(d.x > 0) {
            return @">";
        } else {
            return @"<";
        }
    } else {
        return @"?";
    }
}

BOOL directionIsZero(Direction d) {
    return d.x == 0 && d.y == 0;
}

Direction inverseDirection(Direction d) {
    return (Direction){-1*d.x, -1*d.y};
}

@implementation ToDoCloudLabel

@synthesize visualCenter, lastPushedDirection, anchor, completed;
////////
// NSCoder implementation
////////
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.text forKey:@"textKey"];
    [aCoder encodeCGPoint:self.center forKey:@"centerKey"];
}
-(id)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithText: [aDecoder decodeObjectForKey:@"textKey"] center:[aDecoder decodeCGPointForKey:@"centerKey"]];
}

////////
// Initializers
////////
- (id)initAtCenterWithText:(NSString *)text withVisualCenter:(CGPoint)vc {
    self.visualCenter = vc;
    return [self initWithText:text center:vc];
}
- (id)initWithText:(NSString *)text center:(CGPoint)center {
    if (self = [super init]) {
        self.completed = false;
        self.text = text;
        self.center = center;
        self.anchor = [self frameAtPosition:center];
        self.userInteractionEnabled = true;
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor colorWithWhite: 0.13 alpha:1];
    }
    return self;
}

////////
// Accessors
////////
- (void)setVisualCenter:(CGPoint)vc {
    visualCenter = vc;
    [self updateFontSize];
}

////////
// Touch Events
////////
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	// When a touch starts, get the current location in the view
	currentPoint = [[touches anyObject] locationInView:self];
}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	// Get active location upon move
	CGPoint activePoint = [[touches anyObject] locationInView:self];
    
	// Determine new point based on where the touch is now located
	CGPoint newPoint = CGPointMake(self.center.x + (activePoint.x - currentPoint.x),
                                   self.center.y + (activePoint.y - currentPoint.y));
    [self boundedMoveToNewCenter:newPoint];
    self.anchor = self.frame;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Task Moved" object:self];
    
    //[self.superview updateIntersenctingLabelsOf:self];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // The point in taskField when the touch ended
    CGPoint endPoint = [[touches anyObject] locationInView:self.superview];
    
    // Check for delete
    if(CGRectContainsPoint([self.superview viewWithTag:1].frame, endPoint)) {
        [self showDeleteActionSheet];
    // Check for Complete
    } else if(CGRectContainsPoint([self.superview viewWithTag:2].frame, endPoint) && !self.completed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Task Completed" object: self];
        self.completed = true;
    // Check for bounce
    } else if(completed) {
        [self removeFromSuperview];
    } else if([self isInBounceZone]) {
        //bounce up!
        [self bounceAwayFromBottom];
    }
}

// returns the direction that pushedView should be pushed in to remove overlap
- (Direction)pushDirectionFor:(ToDoCloudLabel *)pushedLabel {
    Direction d = {0,0};
    
    float xVelocity = self.center.x - CGRectGetMidX(previousPosition);
    float yVelocity = self.center.y - CGRectGetMidY(previousPosition);
    if(CGRectIntersectsRect(previousPosition, pushedLabel.frame)) {
        if(directionIsZero(pushedLabel.lastPushedDirection)) {
            if(xVelocity == 0 && yVelocity == 0) {
                CGSize s = CGRectIntersection(previousPosition, pushedLabel.frame).size;
                if(s.width > s.height) {
                    if(CGRectGetMidX(previousPosition) > CGRectGetMidX(pushedLabel.frame)) {
                        d.x = -1;
                    } else {
                        d.x = 1;
                    }
                } else {
                    if(CGRectGetMidY(previousPosition) > CGRectGetMidY(pushedLabel.frame)) {
                        d.y = -1;
                    } else {
                        d.y = 1;
                    }
                }
            } else if(fabs(xVelocity) > fabs(yVelocity)) {
                d.x = signumF(xVelocity);
            } else {
                d.y = signumF(yVelocity);
            }
        } else {
            return pushedLabel.lastPushedDirection;
        }
    } else {
        // differences in centers of two views
        float xDiff = pushedLabel.center.x - CGRectGetMidX(previousPosition);
        float yDiff = pushedLabel.center.y - CGRectGetMidY(previousPosition);
        // A rectangle equal to the prevPos but aligned with pushedView.center on x and y axis respectively
        CGRect xAlign = CGRectOffset(previousPosition, xDiff, 0);
        CGRect yAlign = CGRectOffset(previousPosition, 0, yDiff);
        
        // Push along X if
        if(CGRectIntersectsRect(pushedLabel.frame, xAlign)) {
            d.x = signumF(xDiff);
            // otherwise push along y if
        } else if(CGRectIntersectsRect(pushedLabel.frame, yAlign)) {
            d.y = signumF(yDiff);
            // if they don't overlap at all, just use the direction with more force
        } else {
            if(xVelocity > yVelocity) {
                d.x = signumF(xDiff);
            } else {
                d.y = signumF(yDiff);
            }
        }
    }
    if(directionIsZero(d)) {
        NSException *exception = [NSException exceptionWithName: @"DirectionUndetermined"
                                                         reason: @"pushDirectionFor should never return {0,0}"
                                                       userInfo: nil];
        @throw exception;
    }
    pushedLabel.lastPushedDirection = d;
    return d;
}

- (CGPoint)getShift {
    return CGPointMake(self.center.x - CGRectGetMidX(previousPosition),
                       self.center.y - CGRectGetMidY(previousPosition));
}

////////
// Movement Methods
////////
- (BOOL)moveToCenter {
    return [self boundedMoveToNewCenter:visualCenter];
}
- (BOOL)boundedShiftBy:(CGPoint)shiftFactor {
    return [self boundedMoveToNewCenter:CGPointMake(self.center.x + shiftFactor.x, self.center.y + shiftFactor.y)];
}
- (BOOL)isInBounceZone {
    CGFloat tops = [self.superview viewWithTag:1].frame.origin.y - 8.0;
    return self.frame.origin.y + self.frame.size.height > tops;
}
- (void)bounceAwayFromBottom {
    CGFloat tops = [self.superview viewWithTag:1].frame.origin.y - 8.0;
    CGPoint newCenter = CGPointMake(self.center.x, tops - (self.frame.size.height/2.0));
    //CGFloat duration = 1.0 - (self.center.y - newCenter.y)/55.0;
    previousPosition = self.frame;
    [UIView animateWithDuration:0.25
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.center = newCenter;
                         [self updateFontSize];
                     }
                     completion:^(BOOL finished){
                         [self updateFontSize];
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"Task Moved" object:self];
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"Task Move Finished" object:self];
                     }];
}
// Returns the offset from the desired point
- (BOOL)boundedMoveToNewCenter:(CGPoint)newPoint {
    BOOL hitBounds = false;
    previousPosition = self.frame;
    //--------------------------------------------------------
	// Make sure we stay within the bounds of the parent view
	//--------------------------------------------------------
    float midPointX = CGRectGetMidX(self.bounds);
	// If too far right...
    if (newPoint.x > self.superview.bounds.size.width  - midPointX) {
        hitBounds = true;
        newPoint.x = self.superview.bounds.size.width - midPointX;
    } else if (newPoint.x < midPointX) {
        hitBounds = true;
        // If too far left...
        newPoint.x = midPointX;
    }
    
	float midPointY = CGRectGetMidY(self.bounds);
    // If too far down...
	if (newPoint.y > self.superview.bounds.size.height  - midPointY) {
        hitBounds = true;
        newPoint.y = self.superview.bounds.size.height - midPointY;
    } else if (newPoint.y < midPointY) {
        hitBounds = true;
        // If too far up...
        newPoint.y = midPointY;
    }
    
	// Set new center location
	self.center = newPoint;
    // update the font size
    [self updateFontSize];
    return hitBounds;
}
- (void)snapToAnchor {
    self.bounds = (CGRect){CGPointZero, self.anchor.size};
    [UIView animateWithDuration:0.25
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.frame = anchor;
                         [self updateFontSize];
                     }
                     completion:^(BOOL finished){
                         [self updateFontSize];
                     }];
}
////////
// Resize
////////
- (UIFont *)fontForPosition:(CGPoint)pos {
    CGFloat xDist = (self.visualCenter.x - self.center.x);
    CGFloat yDist = (self.visualCenter.y - self.center.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    
    CGFloat fontSize = MAXIMUM_FONT_SIZE - distance/FONT_RESIZE_FACTOR;
    if(fontSize < MINIMUM_FONT_SIZE){
        fontSize = MINIMUM_FONT_SIZE;
    }
    
    return [UIFont fontWithName:@"GillSans-Light" size:fontSize];
}
- (CGRect)frameAtPosition:(CGPoint)pos {
    UIFont *newFont = [self fontForPosition:self.center];
    CGSize newSize = [self.text sizeWithFont:newFont];
    return CGRectMake(self.center.x - newSize.width/2,
                      self.center.y - newSize.height/2,
                      newSize.width,
                      newSize.height);
}
- (void)updateFontSize {
    UIFont *newFont = [self fontForPosition:self.center];
    CGSize newSize = [self.text sizeWithFont:newFont];
    self.frame = CGRectMake(self.center.x - newSize.width/2,
                            self.center.y - newSize.height/2,
                            newSize.width,
                            newSize.height);
    self.font = newFont;
}
////////
// Delete Dialogue
////////
-(void)showDeleteActionSheet{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"confirm" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.superview];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self removeFromSuperview];
            break;
        case 1:
            [self bounceAwayFromBottom];
            break;
    }
}
@end
