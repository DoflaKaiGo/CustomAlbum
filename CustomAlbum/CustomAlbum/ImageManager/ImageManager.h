//
//  ImageManager.h
//  CustomAlbum
//
//  Created by 天狼 on 2019/7/8.
//  Copyright © 2019 shortmedia.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "AlbumAssetModel.h"
#import "ImageAssetModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,requestImageType){
    requestImageTypeImage,
    requestImageTypeVideo,
    requestImageTypeAll
};

@interface ImageManager : NSObject
@property (copy, nonatomic) NSArray * allAlbum;
@property (assign, nonatomic) requestImageType requesType;
@property (assign, nonatomic) CGFloat requestImageSize;
@property (assign, nonatomic) BOOL sortRequestImage;

+ (instancetype)shareManager;

- (BOOL)requestAuthority;
- (NSArray<AlbumAssetModel *> *)getSmartAlbums;
- (NSArray<AlbumAssetModel *> *)getAllAlbums;
- (void)getImageWithAsset:(ImageAssetModel*)asset handler:(void(^)(BOOL success ,UIImage * image))handler ;
- (void)getOringinPhototWithAssetModel:(ImageAssetModel*)model handler:(void(^)(BOOL success ,UIImage * image))handler ;
@end

NS_ASSUME_NONNULL_END
