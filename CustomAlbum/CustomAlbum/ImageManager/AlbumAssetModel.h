//
//  AlbumModel.h
//  CustomAlbum
//
//  Created by 天狼 on 2019/7/8.
//  Copyright © 2019 shortmedia.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "ImageAssetModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface AlbumAssetModel : NSObject
@property (strong, nonatomic) PHAssetCollection * albumAsset;
@property (copy, nonatomic)   NSArray<ImageAssetModel*>  * imageModels;
@property (strong, nonatomic) NSString * albumID;
@property (strong, nonatomic) NSString * albumName;
@property (strong, nonatomic) UIImage * albumImage;
@property (assign, nonatomic) NSInteger * count;
@property (assign, nonatomic, getter=isSelected) BOOL selected;
@end

NS_ASSUME_NONNULL_END
