//
//  MONestedScrollViewController.swift
//  MODemoSwift
//
//  Created by mikimo on 2022/8/17.
//

import UIKit

class MONestedScrollViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - Initail Methods
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(self.mainScrollView)
        self.mainScrollView.addSubview(self.tabsContainerCtl.view)
        self.view.addSubview(self.headerView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.mainScrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let viewSize = self.view.bounds.size
        let safeInset = self.view.safeAreaInsets
        let containerWidth = viewSize.width - safeInset.left - safeInset.right
        let containerHeight = viewSize.height - safeInset.top - safeInset.bottom

        let mainScrollView = self.mainScrollView
        let headerView = self.headerView
        let tabsContainerView = self.tabsContainerCtl.view
        
        /// 铺满
        mainScrollView.frame = CGRect(x: safeInset.left,
                                      y: safeInset.top,
                                      width: containerWidth,
                                      height: containerHeight)
        mainScrollView.contentSize = CGSize(width: containerWidth,
                                            height: containerHeight)
        /// 内边距为可滑动值
        let scrollTopInset = headerViewMaxHeight - headerViewMinHeight
        mainScrollView.contentInset = UIEdgeInsets(top: scrollTopInset,
                                                   left: 0.0,
                                                   bottom: 0.0,
                                                   right: 0.0)
        /// 高度根据偏移
        let headerHeight = headerViewMinHeight + abs(mainScrollView.contentOffset.y)
        headerView.frame = CGRect(x: safeInset.left,
                                  y: safeInset.top,
                                  width: containerWidth,
                                  height: headerHeight)
        /// 高度等于剩下的范围
        tabsContainerView?.frame = CGRect(x: 0.0,
                                          y: headerViewMinHeight,
                                          width: containerWidth,
                                          height: containerHeight - headerHeight)
    }
    
    // MARK: - Private Methods - 主 ScrollView 的回调事件

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollExecutor.mainScrollViewWillBeginDragging(scrollView)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollExecutor.mainScrollViewDidScroll(scrollView)
    }
    
    // MARK: - Private Properties
    
    private var headerViewMinHeight: CGFloat = 100.0
    private var headerViewMaxHeight: CGFloat = 200.0

    // MARK: - Getter Methods
    
    private lazy var mainScrollView: MOMultiResponseScrollView = {
        let scroll = MOMultiResponseScrollView(frame: .zero)
        scroll.delegate = self
        scroll.bounces = false
        scroll.backgroundColor = .blue
        return scroll
    }()

    private lazy var headerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .red
        return view
    }()

    private lazy var tabsContainerCtl: MOMultiTabContainerViewController = {
        let ctl = MOMultiTabContainerViewController(nibName: nil, bundle: nil)
        /// 内部 ScrollView 的回调事件
        ctl.willBeginDragging = { [weak self] (scrollView: UIScrollView) in
            self?.scrollExecutor.subScrollWillBeginDragging(scrollView)
        }
        ctl.didScroll = { [weak self] (scrollView: UIScrollView) in
            self?.scrollExecutor.subScrollDidScroll(scrollView)
        }
        ctl.view.backgroundColor = .cyan
        return ctl
    }()
    
    private lazy var scrollExecutor: MOSubScrollExecutor = {
        let exector = MOSubScrollExecutor()
        exector.mainScrollSuperView = self.view
        return exector
    }()
}
