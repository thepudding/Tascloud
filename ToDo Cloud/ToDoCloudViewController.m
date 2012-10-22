//
//  ToDoCloudViewController.m
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/8/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import "ToDoCloudViewController.h"

@interface ToDoCloudViewController ()

@end

@implementation ToDoCloudViewController
@synthesize taskInput, taskField, visualCenter, deleteArea, completeArea;

- (void)saveStateWith:(NSKeyedArchiver *)archiver {
    NSMutableArray *save = [[NSMutableArray alloc] init];
    for(UIView *element in taskField.subviews) {
        if([element isKindOfClass: ToDoCloudLabel.class]) {
            ToDoCloudLabel *label = (ToDoCloudLabel *)element;
            [save addObject:label];
        }
    }
    [archiver encodeObject:save forKey:@"tasks"];
}


- (void)restoreStateWith:(NSKeyedUnarchiver *)unarchiver {
    for(ToDoCloudLabel *label in [[NSUserDefaults standardUserDefaults] objectForKey:@"tasks"]) {
        [taskField addSubview:label];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.visualCenter = CGPointMake(CGRectGetMidX(taskField.bounds),
                                    CGRectGetMidY(taskField.bounds)- BUTTONS_HEIGHT);
    // Kids, NEVER do what I'm about to do...
    deleteArea.tag = 1;
    completeArea.tag = 2;
    taskField.tag = 9001;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addTask:(id)sender
{
    // Only add a task if there is one to add
    if([taskInput.text length] > 0) {
        ToDoCloudLabel *label = [[ToDoCloudLabel alloc] initWithFrame:CGRectMake(0,0,50,50) visualCenter:self.visualCenter];
        [label setText:taskInput.text];
        label.userInteractionEnabled = YES;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithWhite: 0.13 alpha:1];
        [taskField addSubview:label];
        [label moveToCenter];
    }
    
    // Clear the contents of the text box
    taskInput.text = @"";
    
    // If you hit the add with the keyboard open, close the keyboard
    if([taskInput isFirstResponder]) {
        [taskInput resignFirstResponder];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    // TODO enter adds?
    if (taskInput == self.taskInput) {
        [theTextField resignFirstResponder];
        [self addTask:self];
    }
    return YES;
}
@end
