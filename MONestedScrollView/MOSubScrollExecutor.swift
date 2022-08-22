//
//  MOSubScrollExecutor.swift
//  MODemoSwift
//
//  Created by mikimo on 2022/8/20.
//

import UIKit

class MOSubScrollExecutor: NSObject {
    
    // MARK: - Public

    public var mainScrollSuperView: UIView?

    // MARK: - 主 ScrollView 的滑动回调
    
    public func mainScrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.mainScrollView = scrollView
        /// 记录拖拽前的偏移
        self.mainScrollOffsetBeforeDragging = scrollView.contentOffset
    }

    public func mainScrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.mainScrollEnable {
            /// 需要重新布局，重新计算 headerView 和 containerView 的高度
            /// 触发 MONestedScrollViewController 的 viewDidLayoutSubviews 方法
            self.mainScrollSuperView?.setNeedsLayout()
            return
        }
        /// 不可滑动时，重置偏移
        self.updateScrollView(scrollView, self.mainScrollOffsetBeforeDragging)
    }
    
    // MARK: - 内部 ScrollView 的滑动回调

    public func subScrollWillBeginDragging(_ scrollView: UIScrollView) {
        /// 切换tab时重置标记位
        if self.currentSubScrollView != nil &&
            !self.currentSubScrollView!.isEqual(scrollView) {
            print("subScrollDidChange")
            self.mainScrollEnable = true
        }
        self.currentSubScrollView = scrollView
        self.subScrollViewPreOffset = scrollView.contentOffset
    }

    public func subScrollDidScroll(_ scrollView: UIScrollView) {
        /// 丢弃其他 scrollView 的回调(case: 刚拖拽完 tabView，立马切换到 webView，此时还会收到 tabView 的滑动回调)
        if !scrollView.isEqual(self.currentSubScrollView) {
            return
        }
        if scrollView.contentOffset.y.isEqual(to: self.subScrollViewPreOffset.y) {
            return
        }
        let pullDown: Bool = scrollView.contentOffset.y < self.subScrollViewPreOffset.y
        if pullDown {
            self.handlePullDown(scrollView) /// 处理下拉
        } else {
            self.handlePullUp(scrollView)   /// 处理上拉
        }
    }
    
    // MARK: - Private Methods
    
    /// 下拉: list 先拉到顶，再放大 headerView
    func handlePullDown(_ scrollView: UIScrollView) {
        print("下拉 subScrollDidScroll: \(scrollView.contentOffset.y)")
        
        /// 还没拉到顶 或 headerView 已是最大状态，允许 subScrollView 滑动，不做处理
        if scrollView.contentOffset.y > 0 ||
            self.headerIsMaxState() {
            self.mainScrollEnable = false
            self.subScrollViewPreOffset = scrollView.contentOffset
        } else {
            /// 拉到顶部了 且 headerView 需要放大
            print("拉到顶部了 & headerView 需要放大")
            self.mainScrollEnable = true
            
            /// 重置偏移(放大 headerView 时，不需要下拉刷新效果)
            self.updateScrollView(scrollView, .zero)
            self.subScrollViewPreOffset = .zero
        }
    }
    
    /// pullUp 上拉: 先缩小 headerView，再拉 list
    func handlePullUp(_ scrollView: UIScrollView) {
        print("上拉 subScrollDidScroll: \(scrollView.contentOffset.y)")
        
        /// headerView 已是最小状态，允许subScrollView滑动，不做处理
        if self.headerIsMinState() {
            self.mainScrollEnable = false
            self.subScrollViewPreOffset = scrollView.contentOffset
            return
        }
        self.mainScrollEnable = true
        if scrollView.contentOffset.y <= 0 { /// 忽略下拉刷新的回弹(否则死循环)
            return
        }
        print("heanderView 缩小时，重置 subScrollView 偏移")
        self.updateScrollView(scrollView, self.subScrollViewPreOffset)
    }

    func headerIsMinState() -> Bool {
        guard let mainScrollView = self.mainScrollView else {
            return true
        }
        return mainScrollView.contentOffset.y.isEqual(to: 0.0)
    }

    func headerIsMaxState() -> Bool {
        guard let mainScrollView = self.mainScrollView else {
            return true
        }
        return mainScrollView.contentInset.top.isEqual(to: abs(mainScrollView.contentOffset.y))
    }
    
    // MARK: - Helper Methods
    
    /// 更新 scrollView 的 offset, 相同时跳过，防止极限情况死循环
    private func updateScrollView(_ scrollView: UIScrollView, _ offset: CGPoint) {
        if scrollView.contentOffset.equalTo(offset) {
            return
        }
        scrollView.contentOffset = offset;
    }
    
    // MARK: - Private Properties
    
    /// 用于判断其最大最小状态
    private var mainScrollView: UIScrollView?
    /// 记录拖拽前的偏移，用于不可滑动状态时，重置偏移
    private var mainScrollOffsetBeforeDragging: CGPoint = .zero
    /// 是否处于可滑动状态
    private var mainScrollEnable: Bool = true

    /// 用于防重入
    private var currentSubScrollView: UIScrollView?
    /// 记录拖拽前的偏移，用于不可滑动状态时，重置偏移
    private var subScrollViewPreOffset: CGPoint = .zero

}
