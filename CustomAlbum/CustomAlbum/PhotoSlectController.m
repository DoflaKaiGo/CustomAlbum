//
//  PhotoSlectController.m
//  CustomAlbum
//
//  Created by 天狼 on 2019/7/8.
//  Copyright © 2019 shortmedia.com. All rights reserved.
//

#import "PhotoSlectController.h"
#import "PreviewViewController.h"
#import "ImageManager.h"
#import "AlbumAssetModel.h"

@interface PhotoSlectController()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource>
@property (copy, nonatomic) NSArray * assets;
@property (strong, nonatomic) NSArray * albums;
@property (strong, nonatomic) UICollectionView * collectionview;
@property (strong, nonatomic) UITableView * albumTableView;
@property (strong, nonatomic) UIView * bottomView;
@property (assign, nonatomic) BOOL isShowAlbum;


@end

@implementation PhotoSlectController
 static float iteamWith;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightIteambutton:)];
    self.isShowAlbum = NO;
    iteamWith = ([UIScreen mainScreen].bounds.size.width - 25)/4;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    [self getAllImages];
    [self requestAlbum];
}

- (void)requestAlbum {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.albums = [[ImageManager shareManager] getSmartAlbums];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.albumTableView reloadData];
        });
    });
}

- (void)setupUI {
    [self.view addSubview:self.collectionview];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.albumTableView];
}

- (void)clickRightIteambutton:(UIButton*) sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)getAllImages {
    PHFetchOptions * options = [[PHFetchOptions alloc]init];
    NSMutableArray * imageModels = [NSMutableArray array];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchResult * result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (PHAsset * imageAsset in result) {
                ImageAssetModel * model = [[ImageAssetModel alloc]init];
                model.imageAsset = imageAsset;
                [imageModels addObject:model];
            }
            self.assets = [imageModels mutableCopy];
            [self.collectionview reloadData];
        });
    });
}

- (UICollectionView *)collectionview {
    if (!_collectionview) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(iteamWith,iteamWith);
        layout.sectionInset  = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        _collectionview = [[UICollectionView alloc]initWithFrame:CGRectMake(5, 20, self.view.bounds.size.width - 10, self.view.bounds.size.height) collectionViewLayout:layout];
        _collectionview.backgroundColor = [UIColor whiteColor];
        _collectionview.delegate = self;
        _collectionview.dataSource = self;
        [_collectionview registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"collectionCell"];
    }
    return _collectionview;
}

- (UITableView *)albumTableView {
    if (!_albumTableView) {
        _albumTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 360, [UIScreen mainScreen].bounds.size.width, 600) style:UITableViewStylePlain];
        _albumTableView.delegate = self;
        _albumTableView.dataSource = self;
        _albumTableView.backgroundColor = [UIColor colorWithRed:60/ 255.0 green:61/ 255.0 blue:73 / 255.0 alpha:1];
        _albumTableView.layer.anchorPoint = CGPointMake(0.5, 1);
        _albumTableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 0.001);
        _albumTableView.rowHeight = UITableViewAutomaticDimension;
        _albumTableView.estimatedRowHeight = 44;
        _albumTableView.hidden = true;
        [_albumTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"albumCell"];
    }
    return _albumTableView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 60, [UIScreen mainScreen].bounds.size.width, 60)];
        _bottomView.backgroundColor = [UIColor colorWithRed:60/ 255.0 green:61/ 255.0 blue:73 / 255.0 alpha:1];
        UIButton * albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [albumButton setTitle:@"选择相册" forState:UIControlStateNormal];
        [albumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        albumButton.titleLabel.font = [UIFont systemFontOfSize:12];
        albumButton.frame = CGRectMake(30, 10, 60, 40);
        [albumButton addTarget:self action:@selector(clickAlbumButton:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:albumButton];
    }
    return _bottomView;
}

- (void)clickAlbumButton:(UIButton *)sender {
    self.isShowAlbum = !self.isShowAlbum;
    if (self.isShowAlbum) {
        self.albumTableView.hidden = NO;
        [self.albumTableView reloadData];
        [UIView animateWithDuration:0.3 animations:^{
            self.albumTableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            self.albumTableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.001);
        }completion:^(BOOL finished) {
            self.albumTableView.hidden = true;
        }];
    }
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
    imageV.frame = cell.contentView.bounds;
    [cell.contentView addSubview:imageV];
    ImageAssetModel * model = self.assets[indexPath.row];
    [[ImageManager shareManager] getImageWithAsset:model handler:^(BOOL success, UIImage * _Nonnull image) {
        if (success) {
            imageV.image = image;
        }
    }];
    imageV.contentMode = UIViewContentModeScaleAspectFill;
    imageV.clipsToBounds = true;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray * images = @[self.assets[indexPath.row]];
    PreviewViewController * preVC = [[PreviewViewController alloc]initWithModels:images];
    [self.navigationController pushViewController:preVC animated:true];
    
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell" forIndexPath:indexPath];
    AlbumAssetModel * model = self.albums[indexPath.row];
    cell.imageView.image = model.albumImage;
    CGRect rect =  cell.imageView.frame;
    rect.size.width = 44;
    cell.imageView.frame = rect;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    cell.textLabel.text = [NSString stringWithFormat:@"%@----------%lu",model.albumName,(unsigned long)model.count];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumAssetModel * album = self.albums[indexPath.row];
    self.assets = album.imageModels;
    [self.albumTableView setHidden:true];
    [self.collectionview reloadData];
}

@end
