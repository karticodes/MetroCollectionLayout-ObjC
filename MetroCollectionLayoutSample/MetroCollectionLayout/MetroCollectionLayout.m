//
//  MetroFlowLayout.m
//  MetroCollectionLayoutSample
//
//  Created by Karthik on 3/19/15.
//  Copyright (c) 2015 Karthik. All rights reserved.
//

#import "MetroCollectionLayout.h"

static NSString *const MetroCollectionViewCell = @"MetroCollectionViewCell";
NSString *const MetroCollectionViewHeader = @"UICollectionElementKindSectionHeader";
NSString *const MetroCollectionViewFooter = @"UICollectionElementKindSectionFooter";

#define isIPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

@interface MetroCollectionLayout()

@property (nonatomic, strong) NSDictionary *layoutInfoDict;
@property (nonatomic, strong) NSMutableDictionary *sectionHeaderSizes;
@property (nonatomic, strong) NSMutableDictionary *sectionFooterSizes;

@property (nonatomic, assign) CGFloat wideCellWidth;
@property (nonatomic, assign) CGFloat wideCellHeight;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, readonly) NSInteger numberOfSections;
@property (nonatomic, readonly) NSInteger itemsPerSubRow;

@property (nonatomic, assign) MetroCollectionLayoutDirection wideCellDirection;
@property (nonatomic, assign) BOOL shouldAutoAlign;
@property (nonatomic, assign) NSInteger numberOfItems;

@end

@implementation MetroCollectionLayout

- (instancetype)initWithDelegate:(id<MetroCollectionLayoutDelegate>)delegate{
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

#pragma mark - Init

- (void)calculateValues{
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfItemsPerGroupForCollectionView:andLayout:)]) {
        _numberOfItems = [_delegate numberOfItemsPerGroupForCollectionView:self.collectionView andLayout:self];
    }else{
        _numberOfItems = (isIPhone)? 3: 5;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wideCellWidthForCollectionView:andLayout:)]) {
        _wideCellWidth = [_delegate wideCellWidthForCollectionView:self.collectionView andLayout:self];
    }else{
        _wideCellWidth = (isIPhone)? (2 * CGRectGetWidth(self.collectionView.bounds)/3): ( CGRectGetWidth(self.collectionView.bounds)/2);
    }
    if (_delegate && [_delegate respondsToSelector:@selector(shouldAutoAlignCollectionView:)]) {
        _shouldAutoAlign = [_delegate shouldAutoAlignCollectionView:self.collectionView];
    }else{
        _shouldAutoAlign = NO;
    }
}

- (CGFloat)cellWidth{
    return (CGRectGetWidth([self.collectionView bounds]) - self.wideCellWidth)/self.itemsPerSubRow;
}

- (NSInteger)itemsPerSubRow{
    return (self.numberOfItems-1)/2;
}

- (NSInteger)numberOfSections{
    return [self.collectionView numberOfSections];
}

- (CGFloat)wideCellHeight{
    return self.wideCellWidth;
}

- (CGFloat)cellHeight{
    return self.wideCellHeight/2;
}

#pragma mark - Layout
-(void)prepareLayout{
    [self calculateValues];
    NSMutableDictionary *tempLayoutDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *headerLayoutDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *footerLayoutDictionary = [NSMutableDictionary dictionary];
    
    self.sectionHeaderSizes = [NSMutableDictionary dictionary];
    self.sectionFooterSizes = [NSMutableDictionary dictionary];
    
    for (NSInteger section = 0; section < self.numberOfSections; section++) {
        NSInteger itemsCount = [self itemsInSection:section];
        
        for (NSInteger item = 0; item < itemsCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            if (indexPath.item == 0) {
                CGSize size = [self estimatedSizeForHeaderInSection:section];
                
                if (!CGSizeEqualToSize(size, CGSizeZero)) {
                    self.sectionHeaderSizes[indexPath] = [NSValue valueWithCGSize:size];
                    
                    UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes
                                                                          layoutAttributesForSupplementaryViewOfKind:MetroCollectionViewHeader
                                                                          withIndexPath:indexPath];
                    headerAttributes.frame = [self frameForHeaderAtIndexPath:indexPath withSize:size];
                    
                    headerLayoutDictionary[indexPath] = headerAttributes;
                }
                if (itemsCount == 1) {
                    CGSize size = [self estimatedSizeForFooterInSection:section];
                    
                    if (!CGSizeEqualToSize(size, CGSizeZero)) {
                        self.sectionFooterSizes[indexPath] = [NSValue valueWithCGSize:size];
                        
                        UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes       layoutAttributesForSupplementaryViewOfKind:MetroCollectionViewFooter
                                                                            withIndexPath:indexPath];
                        footerAttributes.frame = [self frameForFooterAtIndexPath:indexPath withSize:size];
                        
                        footerLayoutDictionary[indexPath] = footerAttributes;
                    }
                }
            } else if([self isTheLastItemAtIndexPath:indexPath]) {
                CGSize size = [self estimatedSizeForFooterInSection:section];
                
                if (!CGSizeEqualToSize(size, CGSizeZero)) {
                    self.sectionFooterSizes[indexPath] = [NSValue valueWithCGSize:size];
                    
                    UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MetroCollectionViewFooter withIndexPath:indexPath];
                    footerAttributes.frame = [self frameForFooterAtIndexPath:indexPath withSize:size];
                    
                    footerLayoutDictionary[indexPath] = footerAttributes;
                }
            }
            
            UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            layoutAttributes.frame = [self frameForItemAtIndexPath:indexPath];
            cellLayoutDictionary[indexPath] = layoutAttributes;
        }
    }
    
    tempLayoutDictionary[MetroCollectionViewCell] = cellLayoutDictionary;
    tempLayoutDictionary[MetroCollectionViewHeader] = headerLayoutDictionary;
    tempLayoutDictionary[MetroCollectionViewFooter] = footerLayoutDictionary;
    
    self.layoutInfoDict = tempLayoutDictionary;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfoDict.count];
    
    [self.layoutInfoDict enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfoDict[MetroCollectionViewCell][indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfoDict[kind][indexPath];
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.collectionView.bounds.size.width, ([self totalContentHeight] + [self sectionSuplementaryElementsHeight:self.numberOfSections]));
}

#pragma mark - Common Calculations
- (CGFloat)totalContentHeight{
    CGFloat height = 0;
    if (self.shouldAutoAlign) {
        height = [self totalSectionHeightTillSection:self.numberOfSections]- [self sectionSuplementaryElementsHeight:self.numberOfSections];
    } else {
        height = (self.wideCellHeight * [self totalGroupsInCollectionView]);
    }
    return height;
}

- (CGFloat)totalSectionHeightTillSection:(NSInteger)section{
    CGFloat height = 0;
    if (self.shouldAutoAlign) {
        for (int i = 0; i < section; i++) {
            height += [self sectionContentHeight:i];
        }
        height += [self sectionSuplementaryElementsHeight:section];
    } else {
        height = (self.wideCellHeight * [self totalGroupsTillSection:section])+[self sectionSuplementaryElementsHeight:section];;
    }
    return height;
}

- (CGFloat)sectionContentHeight:(NSInteger)section{
    NSInteger itemsCount = [self itemsInSection:section];
    
    CGFloat sectionHeight = (itemsCount / self.numberOfItems) * self.wideCellHeight;
    NSUInteger mod = itemsCount % self.numberOfItems;
    if (mod > 0) {
        sectionHeight += self.cellHeight;
    }
    
    return sectionHeight;
}

- (CGFloat)sectionSuplementaryElementsHeight:(NSInteger)sectionValue{
    CGFloat totalHeight = 0.f;
    for (NSInteger section = 0; section < sectionValue; section++) {
        CGSize sizeHeader = [self estimatedSizeForHeaderInSection:section];
        CGSize sizeFooter = [self estimatedSizeForFooterInSection:section];
        
        totalHeight += sizeHeader.height + sizeFooter.height;
    }
    return totalHeight;
}

#pragma mark - Groups
- (NSInteger)totalGroupsInCollectionView
{
    return [self totalGroupsTillSection:self.numberOfSections];
}

- (CGFloat)totalGroupsTillSection:(NSInteger)sectionValue{
    NSInteger totalGroups = 0;
    for (NSInteger section = 0; section < sectionValue; section++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        totalGroups += [self totalGroupsAtIndexPath:indexPath];
    }
    return totalGroups;
}

- (NSInteger)totalGroupsAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger itemsCount = [self itemsInSection:indexPath.section];
    
    NSInteger resultValue = itemsCount / self.numberOfItems;
    
    NSUInteger mod = itemsCount % self.numberOfItems;
    if (mod > 0) {
        resultValue += 1;
    }
    
    return resultValue;
}

#pragma mark - Header and Footer
- (CGSize)estimatedSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = CGSizeZero;
    
    if ([self.delegate conformsToProtocol:@protocol(MetroCollectionLayoutDelegate)] && [self.delegate respondsToSelector:@selector(collectionView:layout:estimatedSizeForHeaderInSection:)]) {
        size = [self.delegate collectionView:self.collectionView layout:self estimatedSizeForHeaderInSection:section];
    }
    
    return size;
}

- (CGFloat)heightForHeaderAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [self.sectionHeaderSizes[indexPath] CGSizeValue];
    return size.height;
}

- (CGSize)estimatedSizeForFooterInSection:(NSInteger)section
{
    CGSize size = CGSizeZero;
    
    if ([self.delegate conformsToProtocol:@protocol(MetroCollectionLayoutDelegate)] && [self.delegate respondsToSelector:@selector(collectionView:layout:estimatedSizeForFooterInSection:)]) {
        size = [self.delegate collectionView:self.collectionView layout:self estimatedSizeForFooterInSection:section];
    }
    
    return size;
}

- (CGRect)frameForHeaderAtIndexPath:(NSIndexPath *)indexPath withSize:(CGSize)size
{
    CGRect frame = CGRectZero;
    if (indexPath.section == 0) {
        frame.origin.y = 0;
    } else {
        frame.origin.y = [self getYForFooter:NO atIndexPath:indexPath] - size.height;
    }
    frame.size = size;
    
    return frame;
}

- (CGRect)frameForFooterAtIndexPath:(NSIndexPath *)indexPath withSize:(CGSize)size
{
    CGRect frame = CGRectZero;
    frame.origin.y =  [self getYForFooter:YES atIndexPath:indexPath] + [self getHeightForItemAtIndexPath:indexPath];
    frame.size = size;
    
    return frame;
}

- (CGFloat)getHeightForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger itemsCount = [self itemsInSection:indexPath.section];
    NSUInteger mod = itemsCount % self.numberOfItems;
    if (mod > 0) {
        return self.cellHeight;
    }else{
        return 0;
    }
}

#pragma mark - Frame Calculations
- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self frameForCellAtIndexPath:indexPath];
}

- (CGRect)frameForCellAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = CGRectZero;
    
    if ([self isWideCellAtIndexPath:indexPath]) {
        self.wideCellDirection = [self getDirectionForGroup:[self currentGroupAtIndexPath:indexPath] inSection:indexPath.section];
        CGFloat xValue;
        
        if (self.wideCellDirection == MetroCollectionLayoutDirectionLeft) {
            xValue = 0;
        } else {
            xValue = (CGRectGetWidth([self.collectionView bounds]) - self.wideCellWidth);
        }
        
        NSInteger currentGroup = [self currentGroupAtIndexPath:indexPath];
        NSIndexPath *indexPathFirstElementCurrentSection = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
        CGFloat yValue = currentGroup * self.wideCellHeight + [self heightForHeaderAtIndexPath:indexPathFirstElementCurrentSection];
        yValue += [self totalSectionHeightTillSection:indexPath.section];
        
        frame = CGRectMake(xValue, yValue, self.wideCellWidth, self.wideCellHeight);
    } else {
        frame = CGRectMake([self getXAtIndexPath:indexPath], [self getYForFooter:NO atIndexPath:indexPath], self.cellWidth, self.cellHeight);
    }
    
    return frame;
}

- (MetroCollectionLayoutDirection)getDirectionForGroup:(NSInteger)group inSection:(NSInteger)section{
    if ([self.delegate conformsToProtocol:@protocol(MetroCollectionLayoutDelegate)] && [self.delegate respondsToSelector:@selector(collectionView:layout:directionForGroup:inSection:)]) {
        return [self.delegate collectionView:self.collectionView layout:self directionForGroup:group-1 inSection:section];
    }else{
        if ((group-1) % 2 != 0) {
            return MetroCollectionLayoutDirectionLeft;
        } else {
            return MetroCollectionLayoutDirectionRight;
        }
    }
}

- (CGFloat)getXAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat coordinateX = 0;
    NSInteger multiplyValue;
    NSInteger position = indexPath.row % self.numberOfItems;
    if ([self isFlatGroupAtIndexPath:indexPath]) {
        multiplyValue = indexPath.row % self.numberOfItems;
    } else {
        if ([self getDirectionForGroup:[self currentGroupAtIndexPath:indexPath] inSection:indexPath.section] == MetroCollectionLayoutDirectionLeft) {
            coordinateX = self.wideCellWidth;
            multiplyValue = (position -1) % self.itemsPerSubRow;
        } else {
            multiplyValue = position % self.itemsPerSubRow;
        }
    }
    
    coordinateX = coordinateX + (self.cellWidth * multiplyValue);
    return coordinateX;
}

- (CGFloat)getYForFooter:(BOOL)footer atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger currentGroup = [self currentGroupAtIndexPath:indexPath];
    CGFloat yValue = 0.0f;
    NSIndexPath *indexPathFirstElementCurrentSection = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];

    NSInteger multiplyValue;
    NSInteger maxElement = self.numberOfItems * (currentGroup+1);
    NSInteger position = indexPath.row - (maxElement - self.numberOfItems);
    if ([self isFlatGroupAtIndexPath:indexPath]) {
        multiplyValue = 0;
    } else {
        if ([self getDirectionForGroup:currentGroup inSection:indexPath.section] == MetroCollectionLayoutDirectionLeft) {
            multiplyValue = (position <= self.itemsPerSubRow)? 0 : 1;
            if (footer) multiplyValue++;
        } else {
            multiplyValue = (position / self.itemsPerSubRow);
        }
    }
    
    yValue = (currentGroup * self.wideCellHeight) + (self.cellHeight * multiplyValue) + [self heightForHeaderAtIndexPath:indexPathFirstElementCurrentSection];
    
    yValue += [self totalSectionHeightTillSection:indexPath.section];
    
    return yValue;
}

#pragma mark - utils
- (BOOL)isTheLastItemAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.row + 1) == [self itemsInSection:indexPath.section]) {
        return YES;
    }
    return NO;
}

-(NSInteger)itemsInSection:(NSInteger)section{
    return [self.collectionView numberOfItemsInSection:section];
}

- (NSInteger)currentGroupAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger item = indexPath.row + 1;
    NSInteger resultValue = (item / self.numberOfItems)-1;
    NSUInteger mod = item % self.numberOfItems;
    if (mod > 0) {
        resultValue += 1;
    }
    return resultValue;
}

- (BOOL)isWideCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.shouldAutoAlign) {
        if ([self isFlatGroupAtIndexPath:indexPath]) {
            return NO;
        } else {
            return [self isWideCellWithAlignmentAtIndexPath:indexPath];
        }
    } else {
        return [self isWideCellWithAlignmentAtIndexPath:indexPath];
    }
    return NO;
}

- (BOOL)isWideCellWithAlignmentAtIndexPath:(NSIndexPath *)indexPath{
    if ([self getDirectionForGroup:[self currentGroupAtIndexPath:indexPath] inSection:indexPath.section] == MetroCollectionLayoutDirectionLeft) {
        if (indexPath.row % (2 * self.numberOfItems) == 0 || indexPath.row % self.numberOfItems==0) {
            return YES;
        }
    } else {
        if ((indexPath.row+1) % (2 * self.numberOfItems) == 0 || (indexPath.row+1) % self.numberOfItems == 0) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isFlatGroupAtIndexPath:(NSIndexPath *)indexPath{
    if (self.shouldAutoAlign) {
        NSInteger currentGroup = [self currentGroupAtIndexPath:indexPath]+1;
        NSInteger sectionCount = [self itemsInSection:indexPath.section];
        NSInteger result = sectionCount / self.numberOfItems;
        if (result >= currentGroup) {
            return NO;
        }
        NSInteger reminder = sectionCount % self.numberOfItems;
        return (reminder > 0 && reminder < self.numberOfItems);
    } else {
        return NO;
    }
}

@end
