//
//  UIFolderTableView.h
//  PDFBuilder
//
//  Created by Han Mingjie on 2020/6/27.
//  Copyright © 2020 MingJie Han. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFolderTableView : UITableView{
    NSString *folder;
}
@property (nonatomic) NSString *folder;
@end

NS_ASSUME_NONNULL_END
