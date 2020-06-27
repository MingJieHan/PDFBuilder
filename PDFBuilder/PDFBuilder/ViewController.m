//
//  ViewController.m
//  PDFBuilder
//
//  Created by Han Mingjie on 2020/6/27.
//  Copyright © 2020 MingJie Han. All rights reserved.
//

#import "ViewController.h"
#import "UIFolderTableView.h"

@interface ViewController (){
    UIFolderTableView *folder_table_view;
}
@end

@implementation ViewController
-(BOOL)create_folder:(NSString *)folder{
    NSString *root_folder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSError *error = nil;
    NSDictionary *dict = [NSDictionary dictionary];
    return [[NSFileManager defaultManager] createDirectoryAtPath:[root_folder stringByAppendingPathComponent:folder] withIntermediateDirectories:YES attributes:dict error:&error];
}

-(void)refresh{
    [folder_table_view reloadData];
}

-(void)new_folder{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Folder" message:@"Please input name for this new folder." preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Folder Name";
    }];
    UIAlertAction *create_action = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *folder_name = alert.textFields.firstObject.text;
        [self create_folder:folder_name];
        [self->folder_table_view reloadData];
        return;
    }];
    [alert addAction:create_action];
    UIAlertAction *cancel_action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel_action];
    [self presentViewController:alert animated:YES completion:nil];
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"PDF Builder";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(new_folder)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (nil == folder_table_view){
        folder_table_view = [[UIFolderTableView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        folder_table_view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        folder_table_view.folder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        [self.view addSubview:folder_table_view];
    }
}

@end
