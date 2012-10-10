//
//  ToDoCloudViewController.m
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/8/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import "ToDoCloudViewController.h"
#import "ToDoCloudLabel.h"

@interface ToDoCloudViewController ()

@end

@implementation ToDoCloudViewController
@synthesize taskInput, taskField, visualCenter;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.visualCenter = CGPointMake(CGRectGetMidX(taskField.bounds),
                                    CGRectGetMidY(taskField.bounds)- BUTTONS_HEIGHT);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addTask:(id)sender
{
    ToDoCloudLabel *label = [[ToDoCloudLabel alloc] initWithFrame:CGRectMake(0,0,50,50) visualCenter:self.visualCenter];
    [label setText:taskInput.text];
    [label setFont:[UIFont systemFontOfSize:20.0]];
    [label sizeToFit];
    [label moveToCenter];
    label.userInteractionEnabled = YES;
    [taskField addSubview:label];
}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (taskInput == self.taskInput) {
        [theTextField resignFirstResponder];
    }
    return YES;
}
@end
