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

class SidePanel: UIView {
    var userItemView: SidePanelItemView!

    var lastFocusedView: UIView?

    weak var delegate: SidePanelDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()

        WebRequest.requestLoginInfo { [weak self] response in
            switch response {
            case let .success(json):
                self?.userItemView.imageView.kf.setImage(with: URL(string: json["face"].stringValue))
                let labelUrl = json["vip_label"]["img_label_uri_hans_static"]
                self?.userItemView.label.text = json["uname"].stringValue
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
        userItemView = SidePanelItemView()
        userItemView.type = .userInfo
        userItemView.imageView.layer.cornerRadius = 25
        userItemView.imageView.clipsToBounds = true
        addSubview(userItemView)
        userItemView.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(20)
            make.width.equalTo(360)
            make.top.equalTo(self).offset(60)
        }

        let recommend = SidePanelItemView()
        recommend.type = .recommend
        recommend.title = "推荐"
        recommend.image = "icon_recommend"
        addSubview(recommend)
        recommend.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(20)
            make.width.equalTo(360)
            make.top.equalTo(userItemView.snp.bottom).offset(60)
        }

        let hot = SidePanelItemView()
        hot.type = .hot
        hot.title = "热门"
        hot.image = "icon_hot"
        addSubview(hot)
        hot.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(20)
            make.width.equalTo(360)
            make.top.equalTo(recommend.snp.bottom).offset(10)
        }

        let live = SidePanelItemView()
        live.type = .live
        live.title = "直播"
        live.image = "icon_live"
        addSubview(live)
        live.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(20)
            make.width.equalTo(360)
            make.top.equalTo(hot.snp.bottom).offset(10)
        }

        let rank = SidePanelItemView()
        rank.type = .rank
        rank.title = "排行榜"
        rank.image = "icon_rank"
        addSubview(rank)
        rank.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(20)
            make.width.equalTo(360)
            make.top.equalTo(live.snp.bottom).offset(10)
        }

        let follow = SidePanelItemView()
        follow.type = .follow
        follow.title = "关注"
        follow.image = "icon_follow"
        addSubview(follow)
        follow.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(20)
            make.width.equalTo(360)
            make.top.equalTo(rank.snp.bottom).offset(10)
        }

        let setting = SidePanelItemView()
        setting.type = .setting
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onSetting))
        setting.addGestureRecognizer(tapGesture)
        setting.title = "设置"
        setting.image = "icon_setting"
        addSubview(setting)
        setting.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(20)
            make.width.equalTo(360)
            make.bottom.equalTo(self).offset(-60)
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

//    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
//        if context.nextFocusedView == self {
//            showTitle()
//        } else {
//            hideTitle()
//        }
//    }

    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        if let nextFocusedView = context.nextFocusedView {
            if subviews.contains(nextFocusedView) {
                debugPrint("进入")
                showTitle()
                delegate?.sidePanelDidBecomeFocused(sidePanel: self)
                if let sideItem = nextFocusedView as? SidePanelItemView {
                    delegate?.sidePanelDidFocus(sidePanel: self, focusType: sideItem.type)
                }
            } else {
                debugPrint("出去")
                lastFocusedView = context.previouslyFocusedView
                hideTitle()
                delegate?.sidePanelDidBecomeUnFocused(sidePanel: self)
            }
        }
        return true
    }

    @objc func onSetting() {
        delegate?.sidePanelDidClickSetting(sidePanel: self)
    }
}
