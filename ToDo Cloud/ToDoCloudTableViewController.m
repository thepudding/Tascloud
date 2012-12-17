//
//  ToDoCloudTableViewController.m
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 11/6/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import "ToDoCloudTableViewController.h"

@implementation ToDoCloudTableViewController
@synthesize editing, completedTasks;

NSDateFormatter *formatter;

- (void)viewDidLoad {
    formatter = [ToDoCloudViewController formatter];
    self.completedTasks = ((ToDoCloudViewController *)([self presentingViewController])).completedTasks;
    self.completionDates = ((ToDoCloudViewController *)([self presentingViewController])).completionDates;
    NSLog(@"TABLE restored tasks: %@, dates: %@", self.completedTasks, self.completionDates);
}

- (IBAction)dismissTable:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)editTasks:(id)sender {
    if(self.editing) {
        self.editing = false;
        [self showDoneButton];
        self.editButton.style = UIBarButtonItemStyleBordered;
        self.editButton.title = NSLocalizedString(@"Edit", @"Edit");
        self.toolbarTitle.title = @"Completed Tasks";
        [self.taskTable setEditing:false animated:YES];

    } else {
        self.editing = true;
        [self hideDoneButton];
        self.editButton.style = UIBarButtonItemStyleDone;
        self.editButton.title = NSLocalizedString(@"Done", @"Done");
        self.toolbarTitle.title = @"Edit Completed Tasks";
        [self.taskTable setEditing:editing animated:YES];

    }
}

-(void)showDoneButton {
    [self.toolbar setItems:[self.toolbar.items arrayByAddingObject:self.doneButton]];
}
-(void)hideDoneButton {
    [self.toolbar setItems:
     [self.toolbar.items filteredArrayUsingPredicate:
      [NSPredicate predicateWithBlock:^BOOL (id evaluatedObject, NSDictionary *bindings) {
         return [evaluatedObject tag] != 777;
     }]]];
}

// TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.completedTasks count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 1. get the Date associated with the section
    // 2. get the string format of the date (which is the key for the dictionary
    // 3. use the string to get the array of tasks for that date
    // 4. get the length of the array of tasks
    return [[completedTasks objectForKey:
             [self.completionDates objectAtIndex:section]]
            count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    return [formatter stringFromDate:[self.completionDates objectAtIndex:section]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    cell.textLabel.text = [[self.completedTasks objectForKey:
                            [self.completionDates objectAtIndex:
                             [indexPath indexAtPosition:0]]]
                           objectAtIndex:[indexPath indexAtPosition:1]];
    return cell;
}

// Editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionDate = [self.completionDates objectAtIndex:
                                   [indexPath indexAtPosition:0]];
    NSMutableArray *sectionTasks = [self.completedTasks objectForKey:sectionDate];
    
    [sectionTasks removeObjectAtIndex:[indexPath indexAtPosition:1]];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    // If We are deleting the last task in a section, delete the section
    if([sectionTasks count] == 0) {
        
        [self.completedTasks removeObjectForKey:sectionDate];
        [tableView
         deleteSections: [[NSIndexSet alloc] initWithIndex: [indexPath indexAtPosition:0]]
         withRowAnimation: UITableViewRowAnimationAutomatic];
    }
}
@end
