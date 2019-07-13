//
//  PreviewViewController.m
//  CustomAlbum
//
//  Created by 天狼 on 2019/7/13.
//  Copyright © 2019 shortmedia.com. All rights reserved.
//

#import "PreviewViewController.h"
#import "ImageManager/ImageAssetModel.h"
#import "ImageManager/ImageManager.h"
@interface PreviewViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (copy, nonatomic) NSArray * assets;
@property (strong, nonatomic) UICollectionView * previewCollectionView;
@end

@implementation PreviewViewController
static float iteamWidth;
static float iteamHeight;

- (instancetype)initWithModels:(NSArray *)models {
    self = [super init];
    if (self) {
        self.assets = models;
        [self config];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.previewCollectionView];
}

- (void)config {
    iteamWidth = [UIScreen mainScreen].bounds.size.width;
    iteamHeight = [UIScreen mainScreen].bounds.size.height;
}

- (UICollectionView *)previewCollectionView {
    if (!_previewCollectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        _previewCollectionView.backgroundColor = [UIColor whiteColor];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(iteamWidth,iteamHeight);
        layout.sectionInset  = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        _previewCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(5, 20, self.view.bounds.size.width - 10, self.view.bounds.size.height) collectionViewLayout:layout];
        _previewCollectionView.backgroundColor = [UIColor whiteColor];
        _previewCollectionView.delegate = self;
        _previewCollectionView.dataSource = self;
        [_previewCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"collectionCell"];
    }
    return _previewCollectionView;
}


#pragma mark - UICollectionViewDelegate UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc]initWithFrame:CGRectZero];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    NSArray * subViews = cell.contentView.subviews;
    for (UIView * view in subViews) {
        [view removeFromSuperview];
    }
    UIImageView * imageV = [[UIImageView alloc]init];
    imageV.backgroundColor = [UIColor redColor];
    imageV.frame = CGRectMake(0, 0, iteamWidth, iteamHeight / 3 * 2);
    imageV.center = cell.contentView.center;
    imageV.contentMode = UIViewContentModeScaleAspectFill;
    imageV.clipsToBounds = true;
    [cell.contentView addSubview:imageV];
    ImageAssetModel * model = self.assets[indexPath.row];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[ImageManager shareManager] getOringinPhototWithAssetModel:model handler:^(BOOL success, UIImage * _Nonnull image) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageV.image = image;
                });
            }
        }];
    });
    return cell;
}


@end
