//
//  PhotoBrowserViewController.m
//  Huban
//
//  Created by sean on 15/9/23.
//  Copyright © 2015年 sean. All rights reserved.
//

#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

#define kPhotoBrowserPading

#import "PhotoBrowserViewController.h"
#import "SDWebImageManager+MJ.h"
#import "MJPhotoView.h"
#import "MJPhotoBrowser.h"

@interface PhotoBrowserViewController () <UIScrollViewDelegate, MJPhotoViewDelegate>
@property (strong, nonatomic) UIScrollView *photoScrollView;
@property (strong, nonatomic) NSMutableSet *visiblePhotoViews, *reusablePhotoViews;

@property (strong, nonatomic) NSMutableArray *assetsUrl;

@property (assign, nonatomic) BOOL taped;
@end

@implementation PhotoBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_deletePhoto"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteItem:)];
    self.navigationItem.rightBarButtonItem = deleteItem;
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    //photo Scroll View
    [self.view addSubview:self.photoScrollView];
    
    //初始化数据
    {
        if (!_visiblePhotoViews) {
            _visiblePhotoViews = [NSMutableSet set];
        }
        if (!_reusablePhotoViews) {
            _reusablePhotoViews = [NSMutableSet set];
        }
        
        [self setupScrollView];
    }
}

- (void)setupScrollView {
    CGRect frame = self.view.bounds;
    frame.origin.x -= kPaddingLeftWidth;
    frame.size.width += (2 * kPaddingLeftWidth);
    self.photoScrollView.contentSize = CGSizeMake(frame.size.width * self.photos.count, 0);
    self.photoScrollView.contentOffset = CGPointMake(self.currentIndex * frame.size.width, 0);
    
    [self refreshTitle];
    [self showPhotos];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.automaticallyAdjustsScrollViewInsets = YES;
}

#pragma mark - Show Photo
- (void)showPhotos{
    CGRect visibleBounds = _photoScrollView.bounds;
    int firstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+kPaddingLeftWidth*2) / CGRectGetWidth(visibleBounds));
    int lastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-kPaddingLeftWidth*2-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex = (int)_photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = (int)_photos.count - 1;
    
    // 回收不再显示的ImageView
    NSInteger photoViewIndex;
    for (MJPhotoView *photoView in _visiblePhotoViews) {
        photoViewIndex = kPhotoViewIndex(photoView);
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            [_reusablePhotoViews addObject:photoView];
            [photoView removeFromSuperview];
        }
    }
    
    [_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
    
    for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showPhotoViewAtIndex:(int)index];
        }
    }
}

//显示一个图片view
- (void)showPhotoViewAtIndex:(int)index {
    MJPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) {
        photoView = [[MJPhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }
    //调整当前页的Frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPaddingLeftWidth);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPaddingLeftWidth;
    photoView.tag = kPhotoViewTagOffset + index;
    
    MJPhoto *photo = _photos[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    
    [_visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
    
    [self loadImageNearIndex:index];
}

//加载index周围的图片
- (void)loadImageNearIndex:(int)index {
    if (index > 0) {
        MJPhoto *photo = _photos[index - 1];
        [SDWebImageManager downloadWithURL:photo.url];
    }
    
    if (index < _photos.count - 1) {
        MJPhoto *photo = _photos[index + 1];
        [SDWebImageManager downloadWithURL:photo.url];
    }
}

//index这页是否在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    for (MJPhotoView *photoView in _visiblePhotoViews) {
        if (kPhotoViewIndex(photoView) == index) {
            return YES;
        }
    }
    return NO;
}

//重用页面
- (MJPhotoView *)dequeueReusablePhotoView {
    MJPhotoView *photoView = [_reusablePhotoViews anyObject];
    if (photoView) {
        [_reusablePhotoViews removeObject:photoView];
    }
    return photoView;
}

#pragma mark - Getter and Setter
- (void)setPhotos:(NSMutableArray *)photos {
    _photos = photos;
    if (_photos.count <= 0) {
        return;
    }
    for (int i = 0; i < _photos.count; i++) {
        MJPhoto *photo = _photos[i];
        photo.index = i;
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    if (_photoScrollView) {
        _photoScrollView.contentOffset = CGPointMake(_currentIndex * _photoScrollView.frame.size.width, 0);
        // 显示所有的相片
        [self showPhotos];
    }
}

- (UIScrollView *)photoScrollView {
    if (!_photoScrollView) {
        CGRect frame = self.view.bounds;
        frame.origin.x -= kPaddingLeftWidth;
        frame.size.width += (2 * kPaddingLeftWidth);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.delegate = self;
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.backgroundColor = [UIColor clearColor];
    }
    return _photoScrollView;
}

#pragma mark - Refresh
- (void)refreshTitle {
    _currentIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    self.title = [NSString stringWithFormat:@"%@/%@",@(_currentIndex + 1),@(_photos.count)];
}

#pragma mark - MJPhotoViewDelegate
- (void)photoViewSingleTap:(MJPhotoView *)photoView {
    _taped = !_taped;
    //隐藏navigationController之后会造成整体界面滑动,暂无解决方案
    [self.navigationController setNavigationBarHidden:_taped animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:_taped withAnimation:UIStatusBarAnimationSlide];
}

- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView {
    [self refreshTitle];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showPhotos];
    [self refreshTitle];
}

#pragma mark - Action
- (void)deleteItem:(id)sender {
    @weakify(self);
    [[UIActionSheet bk_actionSheetCustomWithTitle:@"要删除这张照片吗" buttonTitles:nil destructiveTitle:@"删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            @strongify(self);
            //删除本地路径
            [self.assetsUrl removeObjectAtIndex:self.currentIndex];
            //block回调
            if (self.deleteImageBlock) {
                self.deleteImageBlock(self.assetsUrl);
            }
            //删除图片浏览器中的对象
            [self.photos removeObjectAtIndex:self.currentIndex];
            if (self.photos.count == 0) { //如果删除数组的最后一个
                [self.navigationController popViewControllerAnimated:YES];
                return ;
            }
            if (self.currentIndex >= self.photos.count) { //如果删除数组的最后一个
                self.currentIndex = self.photos.count - 1;
            }
            [self showPhotoViewAtIndex:(int)self.currentIndex];
            [self setupScrollView];
        }
    }] showInView:self.view];
}

#pragma mark - Getter
- (NSMutableArray *)assetsUrl {
    if (!_assetsUrl) {
        _assetsUrl = [[NSMutableArray alloc] initWithCapacity:self.photos.count];
        for (MJPhoto *photoAsset in self.photos) {
            [_assetsUrl addObject:photoAsset.assetsUrl];
        }
    }
    return _assetsUrl;
}
@end
