//
//  ToDoCloudViewController.m
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/8/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import "ToDoCloudViewController.h"

@implementation ToDoCloudViewController
@synthesize taskInput, taskField, visualCenter, deleteArea, completeArea, completedTasks, completionDates;

UIActionSheet *deleteConfirmation;

NSDateFormatter *theFormatter;
NSCalendar *calendar;
NSInteger comps;
+ (void)initialize {
    theFormatter = [[NSDateFormatter alloc] init];
    [theFormatter setDateFormat:@"MMM dd yyyy"];
}

+ (NSDateFormatter *) formatter { return theFormatter; }

/*
 * Data persistence
 */
// Holds reloaded task objects till they can be placed in the taskField
NSArray *loggedTasks;
// Saves tasks to the archiver
- (IBAction)tapTest:(id)sender {
    NSLog(@"tap!");
}

- (void)saveStateWith:(NSKeyedArchiver *)archiver {
    NSMutableArray *saveTask = [[NSMutableArray alloc] init];
    for(UIView *element in taskField.subviews) {
        if([element isKindOfClass: ToDoCloudLabel.class]) {
            ToDoCloudLabel *label = (ToDoCloudLabel *)element;
            [saveTask addObject:label];
        }
    }
    [archiver encodeObject:saveTask forKey:@"tasks"];
    [archiver encodeObject:completedTasks forKey:@"completedTasks"];
    [archiver encodeObject:completionDates forKey:@"completionDates"];
}
// Loads tasks from the archiver
- (void)restoreStateWith:(NSKeyedUnarchiver *)unarchiver {
    loggedTasks = [unarchiver decodeObjectForKey:@"tasks"];
    completedTasks = [[NSMutableDictionary alloc] init];
    completionDates  = [[NSMutableArray alloc] init];
    self.completedTasks = [unarchiver decodeObjectForKey:@"completedTasks"];
    self.completionDates = [unarchiver decodeObjectForKey:@"completionDates"];
    NSLog(@"restored tasks: %@, dates: %@", completedTasks, completionDates);
}
- (void)viewDidLoad {
    if(self.completedTasks == nil) {
        self.completedTasks = [[NSMutableDictionary alloc] init];
        self.completionDates =[[NSMutableArray alloc] init];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    calendar = [NSCalendar currentCalendar];
    comps = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    
    
    self.visualCenter = CGPointMake(CGRectGetMidX(taskField.bounds),
                                    CGRectGetMidY(taskField.bounds)-BUTTONS_HEIGHT);
    
    self.deleteArea.tag = 1;
    self.completeArea.tag = 2;
    
    // Add restored tasks to taskField
    if(loggedTasks) {
        for(ToDoCloudLabel *label in loggedTasks) {
            [label setVisualCenter:self.visualCenter];
            [taskField addSubview:label];
        }
    }
    
    
    // respond to a task being dragged
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskMoved:)
                                                 name:@"Task Moved"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskMoveFinished:)
                                                 name:@"Task Move Finished"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskCompleted:)
                                                 name:@"Task Completed"
                                               object:nil];
}

- (IBAction)addTask:(id)sender {
    // Only add a task if there is one to add
    if([taskInput.text length] > 0) {
        ToDoCloudLabel *label = [[ToDoCloudLabel alloc] initAtCenterWithText:taskInput.text
                                                            withVisualCenter: visualCenter];
        [taskField addSubview:label];
        [label moveToCenter];
        [self pushTasksWith:label];
        [self anchorTasks];
    }
    
    // Clear the contents of the text box
    taskInput.text = @"";
    
    // If you hit the add with the keyboard open, close the keyboard
    if([taskInput isFirstResponder]) {
        [taskInput resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (taskInput == self.taskInput) {
        [theTextField resignFirstResponder];
        [self addTask:self];
    }
    return YES;
}

- (void)taskMoved:(NSNotification *)notification {
	ToDoCloudLabel *task = [notification object];
    [self pushTasksWith:task];
}
- (void)pushTasksWith:(ToDoCloudLabel *)task {
    // Iterate over labels intersecting task
    for(UIView *element in taskField.subviews) {
        // Don't bother unless they are intersecting
        if([element isKindOfClass:ToDoCloudLabel.class] &&
           element != task &&
           CGRectIntersectsRect(task.frame, element.frame)) {
            ToDoCloudLabel *pushedTask = (ToDoCloudLabel *)element;
            // snap back!
            if(!CGRectIntersectsRect(pushedTask.anchor, task.frame)) {
                [pushedTask snapToAnchor];
            } else {
                Direction pushDirection = [task pushDirectionFor: pushedTask];
                
                CGSize size = CGRectIntersection(task.frame, element.frame).size;
                CGPoint shift = { size.width+1, size.height+1 };
                shift.x *= pushDirection.x;
                shift.y *= pushDirection.y;
                // If pushedTask didn't get shifted all the way...
                if([pushedTask boundedShiftBy:shift]) {
                    pushDirection = inverseDirection(pushDirection);
                    size = CGRectIntersection(task.frame, pushedTask.frame).size;
                    shift = (CGPoint){ size.width+1, size.height+1 };
                    shift.x *= pushDirection.x;
                    shift.y *= pushDirection.y;
                    [task boundedShiftBy:shift];
                }
                [self pushTasksWith:pushedTask];
            }
        }
    }
}
- (void)taskMoveFinished:(NSNotification *)notification {
    [self anchorTasks];
}
- (void)anchorTasks {
    for(UIView *element in taskField.subviews) {
        // Don't bother unless they are intersecting
        if([element isKindOfClass:ToDoCloudLabel.class]) {
            ToDoCloudLabel *task = (ToDoCloudLabel *)element;
            if([task isInBounceZone]) {
                [task bounceAwayFromBottom];
                return;
            } else {
                task.anchor = task.frame;
            }
        }
    }
}

/*
 * Task Completion Logging
 */
- (void)taskCompleted:(NSNotification *)notification {
    NSString *task = [[notification object] text];
    [[notification object] performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    
    NSDate *today = [calendar dateFromComponents: [calendar components:comps
                                                                        fromDate: [NSDate date]]];
    
    if([notification object] && [[notification object] completed]) { return; }
    
    NSLog(@"'%@' Completed", task);
    
    NSMutableArray *todaysCompletedTasks = [completedTasks objectForKey:today];
    if([todaysCompletedTasks count] > 0) {
        [todaysCompletedTasks addObject:task];
    } else {
        [self addCompletionDate:today];
        [completedTasks
         setObject: [[NSMutableArray alloc] initWithObjects:task, nil]
         forKey:today];
    
    }
    NSLog(@"%@ %@", completionDates, completedTasks);
}
- (void)addCompletionDate:(NSDate *)date {
    
    
    NSUInteger i = [self.completionDates indexOfObjectPassingTest: ^BOOL(id obj, NSUInteger idx, BOOL *stop){
        return [date compare: obj] == NSOrderedAscending;
    }];
    if(i < [self.completionDates count]) {
        [self.completionDates insertObject:date atIndex:i];
    } else {
        [self.completionDates addObject:date];
    }

}

@end
