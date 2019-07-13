//
//  ImageManager.m
//  CustomAlbum
//
//  Created by 天狼 on 2019/7/8.
//  Copyright © 2019 shortmedia.com. All rights reserved.
//

#import "ImageManager.h"
@interface ImageManager ()
@property (assign, nonatomic)  BOOL requestAuthority;
@property (nonatomic, assign) CGFloat photoWidth;
@end
@implementation ImageManager
CGFloat screenScale;
CGFloat screenWidth;
static ImageManager * manager;
static dispatch_once_t onceToken;

+(instancetype)shareManager {
    dispatch_once(&onceToken, ^{
        manager = [[ImageManager alloc]init];
        manager.requestAuthority = [manager requestAuthority];
        [manager configer];
    });
    return manager;
}

- (void)configer{
    //NO,最新的照片会显示在最前面
    self.sortRequestImage = NO;
    [self configScreenWidth];
}

- (void)configScreenWidth {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.requestImageSize = ([UIScreen mainScreen].bounds.size.width - 25.f)/4.0;
    screenScale = 2.0;
    if (screenWidth > 700) {
        screenScale = 1.5;
    }
}

+ (void)deallocManager {
    onceToken = 0;
    manager = nil;
}

- (void)setPhotoWidth:(CGFloat)photoWidth {
    _photoWidth = photoWidth;
    screenWidth = photoWidth / 2;
}

- (BOOL)requestAuthority {
   __block BOOL isGetRequestAlbumauthority = NO;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if(status== PHAuthorizationStatusRestricted) {
            NSLog(@"未权限");
            isGetRequestAlbumauthority =  NO;
        }
        else if (status==PHAuthorizationStatusDenied) {
            NSLog(@"用户拒绝访问相册");
            isGetRequestAlbumauthority =  NO;
        }
        else if ( status == PHAuthorizationStatusAuthorized ){
            NSLog(@"获得权限");
            isGetRequestAlbumauthority =  true;
        }
    }];
    return isGetRequestAlbumauthority;
}

//获取职能相册
-(NSArray *)getSmartAlbums {
    NSMutableArray * albumArray = [NSMutableArray array];
    PHFetchResult * albumRestle = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil ];
        for (PHAssetCollection * collection in albumRestle) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            //过滤空相册
            if (collection.estimatedAssetCount <= 0) continue;
            AlbumAssetModel * model = [self modelWithCollection:collection];
            if(model.imageModels.count > 0){
                [albumArray addObject:model];
            }
        }
    return albumArray;
}

//获取所有相册
-(NSArray<AlbumAssetModel *> *)getAllAlbums {
    NSMutableArray * albumArray = [NSMutableArray array];
    // 我的照片流 1.6.10重新加入..
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            //过滤空相册
            if (collection.estimatedAssetCount <= 0) continue;
            AlbumAssetModel * model = [self modelWithCollection:collection];
            if(model.imageModels.count > 0){
                [albumArray addObject:model];
            }
        }
    
    }
    return albumArray;
}

//获取相册封面
- (void)getAlbumImageWithAssetModel:(ImageAssetModel*)model handler:(void(^)(BOOL success ,UIImage * image))handler{
    [self getImageWithAsset:model photoWidth: 80.0 handler:^(BOOL success, UIImage *image) {
        if (success) {
            handler(true,image);
        }
    }];
   
}

//请求配置
- (PHFetchOptions *)configRequestOptions {
    PHFetchOptions  * options = [[PHFetchOptions alloc]init];
    if(self.requesType != requestImageTypeImage) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    }else   if(self.requesType != requestImageTypeAll){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    }
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortRequestImage]];
    return options;
}

//获取图片
- (UIImage *)getImageWithAsset:(ImageAssetModel *)model photoWidth:(CGFloat)width  handler:(void(^)(BOOL success ,UIImage * image))handler {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    //options.resizeMode = PHImageRequestOptionsResizeModeFast; //fast 会导致稍微模糊
    options.networkAccessAllowed = YES;
    options.synchronous = NO;
    if (model.assetTypel == ImageAssetModelTypePhotoGIf) {
        options.version = PHImageRequestOptionsVersionOriginal;
    }
    
    PHAsset * phAsset = model.imageAsset;
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat pixeWidth = width * screenScale;
    
    //超宽图片
    if (aspectRatio > 1.8) {
        pixeWidth = pixeWidth * aspectRatio;
    }
    //超高图片
    if(aspectRatio < 0.2){
        pixeWidth = pixeWidth * 0.5;
    }
    
    CGFloat pixeHeight = pixeWidth / aspectRatio;
    CGSize imageSize = CGSizeMake(pixeWidth, pixeHeight);
    
    __block UIImage * image;
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:imageSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            handler(true,result);
        }
    }];
    return image;
}

///获取图片数据
- (void)getImageWithAsset:(ImageAssetModel *)model handler:(void(^)(BOOL success ,UIImage * image))handler {
    [self getImageWithAsset:model photoWidth:self.requestImageSize handler:^(BOOL success, UIImage *image) {
        if (success) {
            handler(true,image);
        }
    }];
}

//获取原图
- (void)getOringinPhototWithAssetModel:(ImageAssetModel*)model handler:(nonnull void (^)(BOOL, UIImage * _Nonnull))handler{
    __block UIImage * image;
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.synchronous = YES;
    PHAsset * phAsset = model.imageAsset;
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        image = [self fixOrientation:result];
        if (image) {
            handler(true,image);
        }
    }];
}
// 获取原图图片数据

//获取图片大小
- (NSInteger)getOriginImageSizeWithAsset:(ImageAssetModel *)model {
   __block NSInteger imageSize = 0;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.networkAccessAllowed = YES;
    if (model.assetTypel == ImageAssetModelTypePhotoGIf) {
        options.version = PHImageRequestOptionsVersionOriginal;
    }
    [[PHImageManager defaultManager] requestImageDataForAsset:model.imageAsset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        imageSize = imageData.length;
    }];
    return imageSize;
}

//返回相册模型
- (AlbumAssetModel *)modelWithCollection:(PHAssetCollection *)collection{
    PHFetchOptions  * options = [self configRequestOptions];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    AlbumAssetModel *model  = [[AlbumAssetModel alloc]init];
    model.albumName = collection.localizedTitle;
    model.albumID = collection.localIdentifier;
    model.albumAsset = collection;
    model.count =  (NSInteger *)fetchResult.count;
    model.imageModels = [self getAssetsFromFetchResult:fetchResult];
    [self getAlbumImageWithAssetModel:model.imageModels.firstObject handler:^(BOOL success, UIImage *image) {
        if (success) {
            model.albumImage = image;
        }
    }];
    return model;
}

//获取图片数据
- (NSArray*)getAssetsFromFetchResult:(PHFetchResult *)result{
    NSMutableArray * photoArr = [NSMutableArray array];
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self fetchSizeWithAsset:asset]) {
            ImageAssetModel *model = [[ImageAssetModel alloc]init];
            model.imageAsset = asset;
            model.imageID = asset.localIdentifier;
            model.imageSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
            [photoArr addObject:model];
        }
    }];
    return photoArr;
}

//检查图片尺寸是否满足规范
- (BOOL)fetchSizeWithAsset:(PHAsset*)asset {
    CGSize photoSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    if (photoSize.width < self.requestImageSize || photoSize.height < self.requestImageSize ) {
        return NO;
    }
    return true;
}

/// 缩放图片至新尺寸
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}

/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage {
   // if (!self.shouldFixOrientation) return aImage;
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
