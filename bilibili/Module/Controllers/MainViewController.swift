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
    static let SidePanelMaxWidth = 260
    static let SidePanelMinWidth = 110
    var sidePanel: SidePanel!
    var currentPageType = CurrentFocusType.recommend
//    var subPanel: SubSidePanel!
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
        view.backgroundColor = UIColor(hex: 0x17181A, alpha: 1)
        sidePanel = SidePanel()
        sidePanel.backgroundColor = UIColor(hex: 0x1E2022)
        sidePanel.clipsToBounds = true
        sidePanel.delegate = self
        view.addSubview(sidePanel)
        sidePanel.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.top.bottom.equalTo(view)
            make.width.equalTo(Self.SidePanelMinWidth)
        }

        let rightContainerView = UIView()
        view.addSubview(rightContainerView)
        rightContainerView.snp.makeConstraints { make in
            make.leading.equalTo(sidePanel.snp.trailing)
            make.top.bottom.trailing.equalTo(view)
        }

        for collectionVC in subViewControllers {
            rightContainerView.addSubview(collectionVC.view)
            if collectionVC is BaseCollectionViewController {
                collectionVC.view.snp.makeConstraints { make in
                    make.top.bottom.equalTo(rightContainerView)
                    make.width.equalTo(4 * 420 + 3 * 20)
                    make.leading.equalTo(rightContainerView).offset(40)
                }
            } else {
                collectionVC.view.snp.makeConstraints { make in
                    make.edges.equalTo(rightContainerView)
                }
            }
            if let infoVC = collectionVC as? PersonalInfoViewController {
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
                make.width.equalTo(Self.SidePanelMaxWidth)
            }
            self.view.layoutIfNeeded()
        }
    }

    func sidePanelDidBecomeUnFocused(sidePanel: SidePanel) {
        UIView.animate(withDuration: 0.3) {
            sidePanel.snp.updateConstraints { make in
                make.width.equalTo(Self.SidePanelMinWidth)
            }
            self.view.layoutIfNeeded()
        }
    }

    func sidePanelDidFocus(sidePanel: SidePanel, focusType: CurrentFocusType) {
        subViewControllers.forEach { VC in
//            VC.view.isHidden = focusType != VC.type
            if let infoVC = VC as? PersonalInfoViewController {
                infoVC.view.isHidden = infoVC.type != focusType
            }

            if let viewController = VC as? BaseCollectionViewController {
                viewController.view.isHidden = viewController.type != focusType
            }
        }
    }
}
