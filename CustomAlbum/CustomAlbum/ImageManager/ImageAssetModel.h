//
//  ImageAssetModel.h
//  CustomAlbum
//
//  Created by 天狼 on 2019/7/8.
//  Copyright © 2019 shortmedia.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ImageAssetModelType){
    ImageAssetModelTypePhoto,
    ImageAssetModelTypeVideo,
    ImageAssetModelTypLivePhoto,
    ImageAssetModelTypePhotoGIf
};

@interface ImageAssetModel : NSObject
@property (strong, nonatomic) UIImage * smallmage;
@property (strong, nonatomic) UIImage * hightImage;
@property (strong, nonatomic) UIImage * originImage;
@property (strong, nonatomic) PHAsset * imageAsset;
@property (strong, nonatomic) NSString * imageID;
@property (assign, nonatomic) CGSize  imageSize;
@property (assign, nonatomic, getter=isSelected) BOOL selected;
@property (assign, nonatomic) ImageAssetModelType assetTypel;

@end

NS_ASSUME_NONNULL_END
