//
//  UIFolderTableView.m
//  PDFBuilder
//
//  Created by Han Mingjie on 2020/6/27.
//  Copyright © 2020 MingJie Han. All rights reserved.
//

#import "UIFolderTableView.h"
#import <CoreGraphics/CoreGraphics.h>


@interface UIFolderTableView()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *folders_array;
}
@end


@implementation UIFolderTableView
@synthesize folder;

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self){
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}
-(void)setFolder:(NSString *)_folder{
    folder = _folder;
    NSError *error = nil;
    NSArray *files_array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:&error];
    folders_array = [[NSMutableArray alloc] initWithArray:files_array];
    [self reloadData];
    return;
}


-(void)createPDF:(NSString *)pdf_file with:(NSMutableArray *)image_files{
    [image_files sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *file1 = (NSString *)obj1;
        NSString *file2 = (NSString *)obj2;
        return [file1 compare:file2];
    }];
    
    
    UIAlertController *building_alert = [UIAlertController alertControllerWithTitle:@"Building" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:building_alert animated:YES completion:nil];

//    float dpi = 300.f;
    
    // A4
    // width 8.4
    // height 11.6
    // CGSize page_size = CGSizeMake(11.6 * dpi, 8.4 * dpi);
    
    CGSize page_size = CGSizeMake(1669, 942);
    
    CGRect mediaBox = CGRectMake (0, 0, page_size.width, page_size.height);
    
    const char *cfilePath = [pdf_file UTF8String];
    CFStringRef pathRef = CFStringCreateWithCString(NULL, cfilePath, kCFStringEncodingUTF8);
    
    // 3.设置当前pdf页面的属性
    CFStringRef myKeys[4];
    CFTypeRef myValues[4];
    myKeys[0] = kCGPDFContextMediaBox;
    myValues[0] = (CFTypeRef) CFDataCreate(NULL,(const UInt8 *)&mediaBox, sizeof (CGRect));
    myKeys[1] = kCGPDFContextTitle;
    myValues[1] = CFSTR("Hans CV");
    myKeys[2] = kCGPDFContextCreator;
    myValues[2] = CFSTR("PDF Builder");
    myKeys[3] = kCGPDFContextAuthor;
    myValues[3] = CFSTR("Mr Hans");
    CFDictionaryRef pageDictionary = CFDictionaryCreate(NULL, (const void **) myKeys, (const void **) myValues, 4,&kCFTypeDictionaryKeyCallBacks, & kCFTypeDictionaryValueCallBacks);
    
    CGContextRef myPDFContext = NULL;
    CFURLRef url;
    CGDataConsumerRef dataConsumer;
    url = CFURLCreateWithFileSystemPath (NULL, pathRef, kCFURLPOSIXPathStyle, false);
    if (url != NULL){
        dataConsumer = CGDataConsumerCreateWithURL(url);
        if (dataConsumer != NULL)
        {
            myPDFContext = CGPDFContextCreate (dataConsumer, &mediaBox, NULL);
            CGDataConsumerRelease (dataConsumer);
        }
        CFRelease(url);
    }
    
    for (NSString *image_file in image_files){
        //a page start
        CGPDFContextBeginPage(myPDFContext, pageDictionary);
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:image_file];
        
        UIImageView *rr = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, page_size.width, page_size.height)];
        rr.contentMode = UIViewContentModeScaleAspectFit;
        rr.image = image;
        
        //加载的image是上下翻转的，通过下面2行代码修复， 原因不明
        CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, rr.frame.size.height);
        CGContextConcatCTM(myPDFContext, flipVertical);
        //
        
        
        [rr.layer renderInContext:myPDFContext];
        CGContextEndPage (myPDFContext);
        //a page end
    }
    
    
    CFRelease(pageDictionary);
    CGContextRelease(myPDFContext);
    
    [building_alert dismissViewControllerAnimated:YES completion:nil];
    return;
}



#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSections{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return folders_array.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier_cell = @"FolderCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier_cell];
    if (nil == cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier_cell];
    }
    cell.textLabel.text = [folders_array objectAtIndex:indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *file = [folders_array objectAtIndex:indexPath.row];
    NSError *error = nil;
    NSDictionary *att_dict = [[NSFileManager defaultManager] attributesOfItemAtPath:[folder stringByAppendingPathComponent:file] error:&error];
    if ([NSFileTypeRegular isEqualToString:[att_dict valueForKey:NSFileType]]){
        //Selected is a file
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"File Edit" message:@"Please open \"File\" application to edit folder and files from iOS system." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok_action = [UIAlertAction actionWithTitle:@"I See" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok_action];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString *current_folder = [folder stringByAppendingPathComponent:file];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:current_folder error:&error];
    NSMutableArray *image_files = [[NSMutableArray alloc] init];
    NSUInteger images_num = 0;
    for (NSString *file in files){
        if ([[[file pathExtension] lowercaseString] isEqualToString:@"png"]
            || [[[file pathExtension] lowercaseString] isEqualToString:@"jpg"]){
            images_num ++;
            [image_files addObject:[current_folder stringByAppendingPathComponent:file]];
        }
    }
    if (0 == images_num){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No image" message:@"No image in your selected folder\n please goto \"File\" to add images in this folder." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok_action = [UIAlertAction actionWithTitle:@"I See" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok_action];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"Do you want to add %lu images into a new PDF file?",image_files.count];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *create_action = [UIAlertAction actionWithTitle:@"Create PDF" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self createPDF:[self->folder stringByAppendingPathComponent:[[current_folder lastPathComponent] stringByAppendingString:@".pdf"]] with:image_files];
        return;
    }];
    [alert addAction:create_action];
    UIAlertAction *cancel_action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel_action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    return;
}


@end
