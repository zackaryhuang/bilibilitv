//
//  SubSidePanel.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/26.
//

import UIKit

protocol SideSubPanelDelegate: NSObjectProtocol {
    func sideSubPanelDidFocus(on category: LiveCategory)
    func sideSubPanelDidBecomeUnFocused(sideSubPanel: SubSidePanel)
}

class SettingItem {
    let title: String
    let settingKey: String
    init(title: String, settingKey: String) {
        self.title = title
        self.settingKey = settingKey
    }
}

enum LiveCategoryType: Int {
    case followed
    case recommend
    case hot
    case entertainment
    case virtual
    case netGame
    case mobileGame
    case singleGame
    case life
    case radio
    case knowledge
    case competition
}

struct LiveCategory {
    let title: String
    let type: LiveCategoryType

    var areaID: Int? {
        switch type {
        case .followed:
            return nil
        case .recommend:
            return -1
        case .hot:
            return 0
        case .entertainment:
            return 1
        case .virtual:
            return 9
        case .netGame:
            return 2
        case .mobileGame:
            return 3
        case .singleGame:
            return 6
        case .life:
            return 10
        case .radio:
            return 5
        case .knowledge:
            return 11
        case .competition:
            return 13
        }
    }
}

class SubSidePanel: UIView {
    weak var delegate: SideSubPanelDelegate?

    var currentFocusType: CurrentFocusType {
        didSet {
            switch currentFocusType {
            case .none:
                titleLabel.text = "未知"
            case .userInfo:
                titleLabel.text = "用户"
            case .live:
                titleLabel.text = "直播"
            case .recommend:
                titleLabel.text = "推荐"
            case .hot:
                titleLabel.text = "热门"
            case .rank:
                titleLabel.text = "排行"
            case .follow:
                titleLabel.text = "关注"
            case .setting:
                titleLabel.text = "设置"
            }
            tableView.reloadData()
        }
    }

    weak var parentViewController: UIViewController?
    let settingItems = [SettingItem(title: "直接进入视频", settingKey: "Settings.playVideoDirectly"),
                        SettingItem(title: "弹幕显示区域", settingKey: "Settings.danmuArea"),
                        SettingItem(title: "时间线显示模式", settingKey: "Settings.displayStyle"),
                        SettingItem(title: "视频相关推荐加载", settingKey: "Settings.showRelatedVideoInCurrentVC"),
                        SettingItem(title: "继续播放", settingKey: "Settings.continuePlay"),
                        SettingItem(title: "自动跳过片头片尾", settingKey: "Settings.play.autoSkip"),
                        SettingItem(title: "最高画质", settingKey: "Settings.mediaQuality"),
                        SettingItem(title: "无损音频和杜比全景声", settingKey: "Settings.losslessAudio"),
                        SettingItem(title: "HEVC优先", settingKey: "Settings.preferHevc"),
                        SettingItem(title: "连续播放", settingKey: "Settings.continouslyPlay"),
                        SettingItem(title: "弹幕大小", settingKey: "Settings.danmuSize"),
                        SettingItem(title: "智能防档弹幕", settingKey: "Settings.danmuMask"),
                        SettingItem(title: "本地智能防档弹幕", settingKey: "Settings.vnMask"),
                        SettingItem(title: "匹配视频内容", settingKey: "Settings.contentMatch")]

    let liveItems = [LiveCategory(title: "关注", type: .followed),
                     LiveCategory(title: "推荐", type: .recommend),
                     LiveCategory(title: "热门", type: .hot),
                     LiveCategory(title: "娱乐", type: .entertainment),
                     LiveCategory(title: "虚拟主播", type: .virtual),
                     LiveCategory(title: "网游", type: .netGame),
                     LiveCategory(title: "手游", type: .mobileGame),
                     LiveCategory(title: "单机", type: .singleGame),
                     LiveCategory(title: "生活", type: .life),
                     LiveCategory(title: "电台", type: .radio),
                     LiveCategory(title: "知识", type: .knowledge),
                     LiveCategory(title: "赛事", type: .competition)]

    var tableView: UITableView!
    var titleLabel: UILabel!

    override init(frame: CGRect) {
        currentFocusType = .none
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        titleLabel = UILabel()
        titleLabel.text = "设置"
        titleLabel.font = .boldSystemFont(ofSize: 40)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(10)
            make.top.equalTo(self).offset(70)
        }

        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(self)
            make.top.equalTo(titleLabel.snp.bottom).offset(60)
        }
    }
}

extension SubSidePanel: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentFocusType {
        case .setting:
            return settingItems.count
        case .live:
            return liveItems.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentFocusType {
        case .setting:
            var cell = tableView.dequeueReusableCell(withIdentifier: "SubPanelCell")
            if cell == nil {
                cell = SettingCell(style: .default, reuseIdentifier: "SettingCell")
            }
            if let settingCell = cell as? SettingCell {
                let settingItem = settingItems[indexPath.row]
                settingCell.update(with: settingItem)
            }
            return cell!
        case .live:
            var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LiveCategoryCell.self))
            if cell == nil {
                cell = LiveCategoryCell(style: .default, reuseIdentifier: NSStringFromClass(LiveCategoryCell.self))
            }
            if let liveItemCell = cell as? LiveCategoryCell {
                liveItemCell.delegate = self
                let liveItem = liveItems[indexPath.row]
                liveItemCell.update(with: liveItem)
            }
            return cell!
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentFocusType {
        case .setting:
            let item = settingItems[indexPath.row]
            let cancelAction = UIAlertAction(title: nil, style: .cancel)
            if item.settingKey == "Settings.playVideoDirectly" {
                Settings.playVideoDirectly = !Settings.playVideoDirectly
            } else if item.settingKey == "Settings.mediaQuality" {
                let alert = UIAlertController(title: "最高画质", message: "4k以上需要大会员", preferredStyle: .actionSheet)
                for quality in MediaQualityEnum.allCases {
                    let action = UIAlertAction(title: quality.desp, style: .default) { _ in
                        Settings.mediaQuality = quality
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                    alert.addAction(action)
                }
                alert.addAction(cancelAction)
                parentViewController?.present(alert, animated: true)
            } else if item.settingKey == "Settings.danmuArea" {
                let alert = UIAlertController(title: "弹幕显示区域", message: "设置弹幕显示区域", preferredStyle: .actionSheet)
                for style in DanmuArea.allCases {
                    let action = UIAlertAction(title: style.title, style: .default) { _ in
                        Settings.danmuArea = style
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                    alert.addAction(action)
                }
                alert.addAction(cancelAction)
                parentViewController?.present(alert, animated: true)
            } else if item.settingKey == "Settings.displayStyle" {
                let alert = UIAlertController(title: "显示模式", message: "重启app生效", preferredStyle: .actionSheet)
                for style in FeedDisplayStyle.allCases.filter({ !$0.hideInSetting }) {
                    let action = UIAlertAction(title: style.desp, style: .default) { _ in
                        Settings.displayStyle = style
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                    alert.addAction(action)
                }
                alert.addAction(cancelAction)
                parentViewController?.present(alert, animated: true)
            } else if item.settingKey == "Settings.showRelatedVideoInCurrentVC" {
                Settings.showRelatedVideoInCurrentVC = !Settings.showRelatedVideoInCurrentVC
            } else if item.settingKey == "Settings.continuePlay" {
                Settings.continuePlay = !Settings.continuePlay
            } else if item.settingKey == "Settings.continouslyPlay" {
                Settings.continouslyPlay = !Settings.continouslyPlay
            } else if item.settingKey == "Settings.losslessAudio" {
                Settings.losslessAudio = !Settings.losslessAudio
            } else if item.settingKey == "Settings.preferHevc" {
                Settings.preferHevc = !Settings.preferHevc
            } else if item.settingKey == "Settings.danmuSize" {
                let alert = UIAlertController(title: "弹幕大小", message: "默认为36", preferredStyle: .actionSheet)
                for style in DanmuSize.allCases {
                    let action = UIAlertAction(title: style.title, style: .default) { _ in
                        Settings.danmuSize = style
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                    alert.addAction(action)
                }
                alert.addAction(cancelAction)
                parentViewController?.present(alert, animated: true)
            } else if item.settingKey == "Settings.danmuMask" {
                Settings.danmuMask = !Settings.danmuMask
            } else if item.settingKey == "Settings.vnMask" {
                Settings.vnMask = !Settings.vnMask
            } else if item.settingKey == "Settings.contentMatch" {
                Settings.contentMatch = !Settings.contentMatch
            } else if item.settingKey == "Settings.play.autoSkip" {
                Settings.autoSkip = !Settings.autoSkip
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .live:
            let liveItem = liveItems[indexPath.row]
            debugPrint(liveItem.title)
        default:
            debugPrint("unknown")
        }
    }

    override var preferredFocusedView: UIView? {
        return tableView
    }

    override var canBecomeFocused: Bool {
        return true
    }

    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        if context.nextFocusedView is SettingCell || context.nextFocusedView is LiveCategoryCell ||
            context.nextFocusedView is SidePanel ||
            context.nextFocusedView is SidePanelItemView
        {
        } else {
            delegate?.sideSubPanelDidBecomeUnFocused(sideSubPanel: self)
        }
        return true
    }
}

extension SubSidePanel: LiveCategoryCellDelegate {
    func liveCategoryCellDidBecomeFocused(category: LiveCategory) {
        delegate?.sideSubPanelDidFocus(on: category)
    }
}
