//
//  DropdownListView.m
//  BPMS
//
//  Created by lianditech on 2017/10/13.
//  Copyright © 2017年 啾三万. All rights reserved.
//

#import "DropdownListView.h"
#import "Marco.h"

@interface DropdownListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UIImageView *dropImageView;
@property (nonatomic, strong) UIButton *dropButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat tableViewHeight;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, assign) BOOL isDrop;

@end

@implementation DropdownListView

static CGFloat const imageWidth = 16;
static CGFloat const imageHeight = 16;
static CGFloat const tableViewMaxHeight = 150;
static CGFloat const animationDuration = 0.1;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _tableViewHeight = tableViewMaxHeight;
        self.layer.borderWidth = 1;
        self.itemFont = [UIFont systemFontOfSize:13];
        self.itemTextColor = [UIColor blackColor];
        self.itemBorderColor = [UIColor lightGrayColor];
        [self addSubview:self.resultLabel];
        [self addSubview:self.dropImageView];
        [self addSubview:self.dropButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.resultLabel.frame = CGRectMake(15, 0, self.frame.size.width - imageWidth, self.frame.size.height);
    self.dropImageView.frame = CGRectMake(self.resultLabel.frame.size.width, (self.frame.size.height - imageHeight) / 2, imageWidth, imageHeight);
    self.dropButton.frame = self.bounds;
}

- (void)dealloc {
    [_cancelButton removeFromSuperview];
    [_tableView removeFromSuperview];
}

- (void)dropOrUpEvent {
    self.isDrop = !self.isDrop;
    if (self.clickDropBlock) self.clickDropBlock(self.isDrop);
    CGRect rect = [self convertRect:self.bounds toView:nil];
    CGFloat bottomSpace = kScreenH - kStatusH - 44 - rect.origin.y - self.frame.size.height;
    if (self.isDrop) {
        // 如果出现时父视图太靠下(下面空间不足tableView的高度)则从上面出现，如果不太靠下，则从上面出现
        if (bottomSpace >= self.tableViewHeight) {
            self.tableView.frame = CGRectMake(rect.origin.x, rect.origin.y + self.frame.size.height, self.frame.size.width, 0);
            [[UIApplication sharedApplication].keyWindow addSubview:self.cancelButton];
            [[UIApplication sharedApplication].keyWindow addSubview:self.tableView];
            [UIView animateWithDuration:animationDuration animations:^{
                CGRect frame = self.tableView.frame;
                frame.size.height += self.tableViewHeight;
                self.tableView.frame = frame;
            }];
        } else {
            self.tableView.frame = CGRectMake(rect.origin.x, rect.origin.y, self.frame.size.width, 0);
            [[UIApplication sharedApplication].keyWindow addSubview:self.cancelButton];
            [[UIApplication sharedApplication].keyWindow addSubview:self.tableView];
            [UIView animateWithDuration:animationDuration animations:^{
                CGRect frame = self.tableView.frame;
                frame.origin.y -= self.tableViewHeight;
                frame.size.height += self.tableViewHeight;
                self.tableView.frame = frame;
            }];
        }
    } else {
        if (bottomSpace >= self.tableViewHeight) {
            [UIView animateWithDuration:animationDuration animations:^{
                CGRect frame = self.tableView.frame;
                frame.size.height -= self.tableViewHeight;
                self.tableView.frame = frame;
            } completion:^(BOOL finished) {
                [self.tableView removeFromSuperview];
                [self.cancelButton removeFromSuperview];
            }];
        } else {
            [UIView animateWithDuration:animationDuration animations:^{
                CGRect frame = self.tableView.frame;
                frame.origin.y += self.tableViewHeight;
                frame.size.height -= self.tableViewHeight;
                self.tableView.frame = frame;
            } completion:^(BOOL finished) {
                [self.tableView removeFromSuperview];
                [self.cancelButton removeFromSuperview];
            }];
        }
    }
}

#pragma mark - set
- (void)setDataArray:(NSArray<NSString *> *)dataArray {
    _dataArray = dataArray;
    CGFloat height = _dataArray.count * self.frame.size.height;
    self.tableViewHeight = height;
    if (height >= tableViewMaxHeight) self.tableViewHeight = tableViewMaxHeight;
    [self.tableView reloadData];
    self.selectIndex = 0;
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex;
    self.resultLabel.text = self.dataArray[_selectIndex];
    [self.tableView reloadData];
}

- (void)setItemFont:(UIFont *)itemFont {
    _itemFont = itemFont;
    self.resultLabel.font = _itemFont;
    [self.tableView reloadData];
}

- (void)setItemTextColor:(UIColor *)itemTextColor {
    _itemTextColor = itemTextColor;
    self.resultLabel.textColor = _itemTextColor;
    [self.tableView reloadData];
}

- (void)setItemBorderColor:(UIColor *)itemBorderColor {
    _itemBorderColor = itemBorderColor;
    self.layer.borderColor = _itemBorderColor.CGColor;
    self.tableView.layer.borderColor = _itemBorderColor.CGColor;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdf = @"cellIdf";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdf];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdf];
    }
    cell.textLabel.font = self.itemFont;
    cell.textLabel.textColor = self.itemTextColor;
    cell.textLabel.text = self.dataArray[indexPath.row];
    if (indexPath.row == self.selectIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dropOrUpEvent];
    if (indexPath.row == self.selectIndex) return;
    self.selectIndex = indexPath.row;
    if (self.selectBlock) self.selectBlock(indexPath.row);
}

#pragma mark - lazy
- (UILabel *)resultLabel {
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.frame.size.width - imageWidth, self.frame.size.height)];
    }
    return _resultLabel;
}

- (UIImageView *)dropImageView {
    if (!_dropImageView) {
        _dropImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.resultLabel.frame.size.width, (self.frame.size.height - imageHeight) / 2, imageWidth, imageHeight)];
        _dropImageView.image = [UIImage imageNamed:@"icon_drop"];
    }
    return _dropImageView;
}

- (UIButton *)dropButton {
    if (!_dropButton) {
        _dropButton = [[UIButton alloc] initWithFrame:self.bounds];
        _dropButton.titleLabel.text = @"";
        [_dropButton addTarget:self action:@selector(dropOrUpEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dropButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.layer.borderWidth = 1;
        _tableView.rowHeight = self.frame.size.height;
    }
    return _tableView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kStatusH + 44, kScreenW, kScreenH - kStatusH - 44)];
        [_cancelButton setTitle:@"" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(dropOrUpEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
