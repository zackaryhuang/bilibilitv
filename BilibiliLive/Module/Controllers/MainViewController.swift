//
//  MainViewController.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/24.
//

import SnapKit
import UIKit

enum CurrentPageType: Int {
    case none
    case feeds
    case lives
    case hots
    case ranks
    case followers
}

class MainViewController: UIViewController {
    var sidePanel: SidePanel!
    var currentPageType = CurrentFocusType.recommend
    var subPanel: SubSidePanel!
    var subViewControllers = [UIViewController]()

    var liveVC: LivesCollectionViewController!
    var rankVC: RanksCollectionViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        configSubViewControllers()
        configUI()
    }

    private func configSubViewControllers() {
        let personal = PersonalInfoViewController()
        personal.type = .userInfo
        let feeds = FeedsCollectionViewController()
        feeds.type = .recommend
        liveVC = LivesCollectionViewController()
        liveVC.type = .live
        let hots = HotsCollectionViewController()
        hots.type = .hot
        rankVC = RanksCollectionViewController()
        rankVC.type = .rank
        let followers = FollowersCollectionViewController()
        followers.type = .follow
        subViewControllers = [personal, feeds, liveVC, hots, rankVC, followers]
        subViewControllers.forEach { subVC in
            addChild(subVC)
        }
    }

    private func configUI() {
        sidePanel = SidePanel()
        sidePanel.clipsToBounds = true
        sidePanel.delegate = self
        view.addSubview(sidePanel)
        sidePanel.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.top.bottom.equalTo(view)
            make.width.equalTo(100)
        }

        subPanel = SubSidePanel()
        subPanel.delegate = self
        subPanel.parentViewController = self
        subPanel.clipsToBounds = true
        subPanel.isHidden = true
        view.addSubview(subPanel)
        subPanel.snp.makeConstraints { make in
            make.leading.equalTo(sidePanel.snp.trailing)
            make.top.bottom.equalTo(view)
            make.width.equalTo(CGFLOAT_MIN)
        }

        let rightContainerView = UIView()
        view.addSubview(rightContainerView)
        rightContainerView.snp.makeConstraints { make in
            make.leading.equalTo(subPanel.snp.trailing)
            make.top.bottom.trailing.equalTo(view)
        }

        for collectionVC in subViewControllers {
            rightContainerView.addSubview(collectionVC.view)
            collectionVC.view.snp.makeConstraints { make in
                make.leading.top.bottom.equalTo(rightContainerView)
                make.width.equalTo(4 * 420 + 3 * 20)
            }
            if let infoVC = collectionVC as? PersonalViewController {
                infoVC.view.isHidden = infoVC.type != currentPageType
            }

            if let vc = collectionVC as? BaseCollectionViewController {
                vc.view.isHidden = vc.type != currentPageType
            }
        }
    }
}

extension MainViewController: SidePanelDelegate {
    func sidePanelDidBecomeFocused(sidePanel: SidePanel) {
        UIView.animate(withDuration: 0.3) {
            sidePanel.snp.updateConstraints { make in
                make.width.equalTo(400)
            }
            self.view.layoutIfNeeded()
        }
    }

    func sidePanelDidBecomeUnFocused(sidePanel: SidePanel) {
        UIView.animate(withDuration: 0.3) {
            sidePanel.snp.updateConstraints { make in
                make.width.equalTo(100)
            }
            self.view.layoutIfNeeded()
        }
    }

    func sidePanelDidClickSetting(sidePanel: SidePanel) {
        let vc = SettingsViewController.create()
        present(vc, animated: true)
    }

    func sidePanelDidFocus(sidePanel: SidePanel, focusType: CurrentFocusType) {
        if focusType == .setting || focusType == .live || focusType == .rank {
            subPanel.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.subPanel.snp.updateConstraints { make in
                    if focusType == .live {
                        make.width.equalTo(300)
                    } else if focusType == .rank {
                        make.width.equalTo(200)
                    } else {
                        make.width.equalTo(400)
                    }
                }
                self.view.layoutIfNeeded()
            }
        } else {
            subPanel.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.subPanel.snp.updateConstraints { make in
                    make.width.equalTo(CGFLOAT_MIN)
                }
                self.view.layoutIfNeeded()
            }
        }

        subViewControllers.forEach { VC in
//            VC.view.isHidden = focusType != VC.type
            if let infoVC = VC as? PersonalInfoViewController {
                infoVC.view.isHidden = infoVC.type != focusType
            }

            if let viewController = VC as? BaseCollectionViewController {
                viewController.view.isHidden = viewController.type != focusType
            }
        }

        subPanel.currentFocusType = focusType
    }
}

extension MainViewController: SideSubPanelDelegate {
    func sideSubPanelDidFocus(on category: LiveCategory) {
        liveVC.currentLiveCategory = category
    }

    func sideSubPanelDidBecomeUnFocused(sideSubPanel: SubSidePanel) {
        subPanel.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.subPanel.snp.updateConstraints { make in
                make.width.equalTo(CGFLOAT_MIN)
            }
            self.view.layoutIfNeeded()
        }
    }

    func sideSubPanelDidFocus(on category: RankCategoryInfo) {
        rankVC.currentRankCategory = category
    }
}
