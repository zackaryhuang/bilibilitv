//
//  SidePanel.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/24.
//

import Kingfisher
import SnapKit
import UIKit

protocol SidePanelDelegate: NSObjectProtocol {
    func sidePanelDidBecomeFocused(sidePanel: SidePanel)
    func sidePanelDidBecomeUnFocused(sidePanel: SidePanel)
    func sidePanelDidClickSetting(sidePanel: SidePanel)
    func sidePanelDidFocus(sidePanel: SidePanel, focusType: CurrentFocusType)
}

enum CurrentFocusType: Int {
    case none
    case userInfo
    case live
    case recommend
    case hot
    case rank
    case follow
    case setting
}

class SidePanelItem {
    let icon: String
    var avatar: String?
    let title: String
    let type: CurrentFocusType
    init(icon: String, avatar: String? = nil, title: String, type: CurrentFocusType) {
        self.icon = icon
        self.avatar = avatar
        self.title = title
        self.type = type
    }
}

class SidePanel: UIView {
    var userItemView: SidePanelItemView!

    var lastFocusedView: UIView?
    var hotItem: SidePanelItemView!
    var tableView: UITableView!
    var sidePanelItems = [SidePanelItem(icon: "icon_recommend", title: "推荐", type: .recommend),
                          SidePanelItem(icon: "icon_hot", title: "热门", type: .hot),
                          SidePanelItem(icon: "icon_live", title: "直播", type: .live),
                          SidePanelItem(icon: "icon_rank", title: "排行榜", type: .rank),
                          SidePanelItem(icon: "icon_follow", title: "关注", type: .follow),
                          SidePanelItem(icon: "icon_setting", title: "设置", type: .setting)]
    weak var delegate: SidePanelDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()

        WebRequest.requestLoginInfo { [weak self] response in
            switch response {
            case let .success(json):
                let userItem = SidePanelItem(icon: "", avatar: json["face"].stringValue, title: json["uname"].stringValue, type: .userInfo)
                self?.sidePanelItems.insert(userItem, at: 0)
                self?.tableView.reloadData()
            case .failure:
                break
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.insetsContentViewsToSafeArea = false
        tableView.insetsLayoutMarginsFromSafeArea = false
        tableView.preservesSuperviewLayoutMargins = false
        tableView.contentInset = .zero
        tableView.remembersLastFocusedIndexPath = true
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 60, left: 10, bottom: 0, right: 0))
        }
    }

    private func showTitle() {
        for view in subviews {
            if let itemView = view as? SidePanelItemView {
                itemView.label.isHidden = false
            }
        }
    }

    private func hideTitle() {
        for view in subviews {
            if let itemView = view as? SidePanelItemView {
                itemView.label.isHidden = true
            }
        }
    }

    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        if let nextFocusedView = context.nextFocusedView {
            if nextFocusedView is SidePanelItemView {
                debugPrint("进入")
                showTitle()
                delegate?.sidePanelDidBecomeFocused(sidePanel: self)
                if let sideItem = nextFocusedView as? SidePanelItemView {
                    delegate?.sidePanelDidFocus(sidePanel: self, focusType: sideItem.type)
                }
                subviews.forEach { view in
                    if let item = view as? SidePanelItemView {
                        item.canBeF = true
                    }
                }
            } else {
                debugPrint("出去")
                lastFocusedView = context.previouslyFocusedView
                hideTitle()
                delegate?.sidePanelDidBecomeUnFocused(sidePanel: self)

                subviews.forEach { view in
                    if let item = view as? SidePanelItemView {
                        item.canBeF = item == lastFocusedView
                    }
                }
            }
        }
        return true
    }

    @objc func onSetting() {
        delegate?.sidePanelDidClickSetting(sidePanel: self)
    }
}

extension SidePanel: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sidePanelItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SidePanelItemView.self))
        if cell == nil {
            cell = SidePanelItemView(style: .default, reuseIdentifier: NSStringFromClass(SidePanelItemView.self))
        }

        if let itemCell = cell as? SidePanelItemView {
            itemCell.updateCell(with: sidePanelItems[indexPath.row])
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        if let cell = tableView.cellForRow(at: indexPath) as? SidePanelItemView {
            return cell.canBeF
        }
        return false
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
