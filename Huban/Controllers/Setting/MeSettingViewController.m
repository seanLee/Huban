//
//  SettingMeViewController.m
//  Huban
//
//  Created by sean on 15/8/5.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "MeSettingViewController.h"
#import "TitleValueMoreCell.h"
#import "TitleRImageMoreCell.h"
#import "SettingTextViewController.h"
#import "BaseNavigationController.h"
#import "CityChosenViewController.h"

@interface MeSettingViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *titleArr;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) User *loginUser;
@end

@implementation MeSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"个人信息";
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValueMore];
        [tableView registerClass:[TitleRImageMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleRImageMore];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    _loginUser = [Login curLoginUser];
    
    [self setupTitles];
}

- (void)setupTitles {
    _titleArr = [NSMutableArray new];
    [_titleArr addObject:@[@"头像",@"昵称",@"呼伴账号"]];
    [_titleArr addObject:@[@"性别",@"地区",@"个人签名"]];
}

- (NSString *)titleForIndexpath:(NSIndexPath *)indexPath {
    NSArray *titles = _titleArr[indexPath.section];
    return titles[indexPath.row];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titleArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *titles = _titleArr[section];
    return titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return [TitleRImageMoreCell cellHeight];
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        return [TitleValueMoreCell cellHeightWithStr:_loginUser.usersign];
    }
    return [TitleValueMoreCell cellHeightWithStr:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kScaleFrom_iPhone5_Desgin(10);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView getHeaderViewWithStr:nil andHeight:kScaleFrom_iPhone5_Desgin(10) andBlock:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        TitleRImageMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleRImageMore forIndexPath:indexPath];
        cell.curUser = _loginUser;
        [cell setTitleStr:[self titleForIndexpath:indexPath]];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
    TitleValueMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValueMore forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 1:
                    [cell setTitleStr:[self titleForIndexpath:indexPath] valueStr:_loginUser.username];
                    break;
                default:
                    [cell setTitleStr:[self titleForIndexpath:indexPath] valueStr:_loginUser.useruid.length == 0?@"未设置":_loginUser.useruid];
                    break;
            }
        }
            break;
        default: {
            switch (indexPath.row) {
                case 0:
                    [cell setTitleStr:[self titleForIndexpath:indexPath] valueStr:_loginUser.usersex.integerValue == 1?@"男":@"女"];
                    break;
                case 1:
                    [cell setTitleStr:[self titleForIndexpath:indexPath] valueStr:_loginUser.cityname];
                    break;
                default:
                    [cell setTitleStr:[self titleForIndexpath:indexPath] valueStr:_loginUser.usersign];
                    break;
            }
        };
            break;
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 2) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak typeof(self) weakSelf = self;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    [[UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"拍照",@"从手机相册选择"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                        if (index == 2) {
                            return ;
                        }
                        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                        picker.delegate = self;
                        picker.allowsEditing = YES;//设置可编辑
                        if (index == 0) {
                            //        拍照
                            if (![Helper checkCameraAuthorizationStatus]) {
                                return;
                            }
                            
                            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                            
                        }else if (index == 1){
                            //        相册
                            if (![Helper checkPhotoLibraryAuthorizationStatus]) {
                                return;
                            }
                            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        }
                        [self presentViewController:picker animated:YES completion:nil];//进入照相界面
                    }] showInView:self.view];
                }
                    break;
                case 1: {
                    SettingTextViewController *vc = [[SettingTextViewController alloc] init];
                    vc.title = @"设置昵称";
                    vc.textValue = _loginUser.username;
                    vc.doneBlock = ^(NSString *textValue) {
                        weakSelf.loginUser.username = textValue;
                        [[NetAPIManager shareManager] request_updateUserInfo:weakSelf.loginUser andBlock:^(id data, NSError *error) {
                            if (data) {
                                if ([data[@"state"] integerValue] == 1) {
                                    [weakSelf.myTableView reloadData];
                                }
                                if (weakSelf.refreshBlock) {
                                    weakSelf.refreshBlock();
                                }
                            }
                        }];
                    };
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default: {
            switch (indexPath.row) {
                case 0: {
                    [[UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"男",@"女"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                        weakSelf.loginUser.usersex = @(index+1);
                        [[NetAPIManager shareManager] request_updateUserInfo:weakSelf.loginUser andBlock:^(id data, NSError *error) {
                            if (data) {
                                if ([data[@"state"] integerValue] == 1) {
                                    [weakSelf.myTableView reloadData];
                                }
                                if (weakSelf.refreshBlock) {
                                    weakSelf.refreshBlock();
                                }
                            }
                        }];
                    }] showInView:self.view];
                }
                    break;
                case 1: {
                    CityChosenViewController *vc = [[CityChosenViewController alloc] init];
                    vc.type = RegionType_PersionalInfo;
                    vc.selectedRegionBlock = ^(Region *curRegion) {
                        weakSelf.loginUser.provcode = curRegion.provcode;
                        weakSelf.loginUser.citycode = curRegion.citycode;
                        weakSelf.loginUser.cityname = curRegion.cityname;
                        [[NetAPIManager shareManager] request_updateRegionInfo:weakSelf.loginUser andBlock:^(id data, NSError *error) {
                            if (data) {
                                if ([data[@"state"] integerValue] == 1) {
                                    [weakSelf.myTableView reloadData];
                                }
                            }
                        }];
                    };
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                default: {
                    SettingTextViewController *vc = [[SettingTextViewController alloc] init];
                    vc.canSubmibNil = YES;
                    vc.limited = YES;
                    vc.limitedCount = 30;
                    vc.title = @"设置个性签名";
                    vc.textValue = _loginUser.usersign;
                    vc.doneBlock = ^(NSString *textValue) {
                        weakSelf.loginUser.usersign = textValue;
                        [[NetAPIManager shareManager] request_updateUserInfo:weakSelf.loginUser andBlock:^(id data, NSError *error) {
                            if (data) {
                                if ([data[@"state"] integerValue] == 1) {
                                    [weakSelf.myTableView reloadData];
                                }
                            }
                        }];
                    };
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
            }
        };
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *editedImage, *originalImage;
        editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        
        {
            _hud = [[MBProgressHUD alloc] initWithView:self.view];
            _hud.removeFromSuperViewOnHide = YES;
            _hud.labelText = @"正在上传头像";
            _hud.delegate = self;
            [_hud show:YES];
            [self.view addSubview:_hud];
        }
        @weakify(self);
        double fileSize = [UIImageJPEGRepresentation(editedImage, 1.f) length];
        NSString *base64Str = [NSObject encodeBase64WithImage:editedImage];
        NSString *fileData = [NSString stringWithFormat:@"%@@%@",@"png",base64Str];
        NSDictionary *params = @{@"filedata":fileData};
        [[NetAPIManager shareManager] request_updateSingleImage:params withSize:fileSize andBlock:^(id data, NSError *error) {
            @strongify(self);
            [self.hud hide:YES];
            if (data) {
                self.loginUser.userlogourl = data[@"filepath"];
                [[NetAPIManager shareManager] request_updateUserInfo:self.loginUser andBlock:^(id updateData, NSError *error) {
                    if (updateData) {
                        if ([updateData[@"state"] integerValue] == 1) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.myTableView reloadData];
                            });
                            if (self.refreshBlock) {
                                self.refreshBlock();
                            }
                        }
                    }
                }];
            }
        }];
        
        // 保存原图片到相册中
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, NULL);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
    [hud removeFromSuperview];
    hud = nil;
}
@end
