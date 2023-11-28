//
//  SubSidePanel.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/26.
//

import UIKit

// protocol SideSubPanelDelegate: NSObjectProtocol {
//    func sideSubPanelDidFocus(on category: LiveCategory)
//    func sideSubPanelDidFocus(on category: RankCategoryInfo)
//    func sideSubPanelDidBecomeUnFocused(sideSubPanel: SubSidePanel)
//    func sideSubPanelDidFocus(on category: PersonalInfoCategory)
// }

// extension SideSubPanelDelegate {
//    func sideSubPanelDidFocus(on category: PersonalInfoCategory) {
//        debugPrint("Implemented in extension")
//    }
//
//    func sideSubPanelDidFocus(on category: LiveCategory) {
//        debugPrint("Implemented in extension")
//    }
//
//    func sideSubPanelDidFocus(on category: RankCategoryInfo) {
//        debugPrint("Implemented in extension")
//    }
//
//    func sideSubPanelDidBecomeUnFocused(sideSubPanel: SubSidePanel) {
//        debugPrint("Implemented in extension")
//    }
// }

class SettingItem {
    let title: String
    let settingKey: String
    init(title: String, settingKey: String) {
        self.title = title
        self.settingKey = settingKey
    }
}

struct LiveCategory: Equatable {
    let title: String
    let areaID: Int?

    static let all = [LiveCategory(title: "关注", areaID: nil),
                      LiveCategory(title: "推荐", areaID: 0),
                      LiveCategory(title: "娱乐", areaID: 1),
                      LiveCategory(title: "网游", areaID: 2),
                      LiveCategory(title: "手游", areaID: 3),
                      LiveCategory(title: "电台", areaID: 5),
                      LiveCategory(title: "单机", areaID: 6),
                      LiveCategory(title: "虚拟", areaID: 9),
                      LiveCategory(title: "生活", areaID: 10),
                      LiveCategory(title: "知识", areaID: 11),
                      LiveCategory(title: "竞技", areaID: 13)]
}

enum PersonalInfoCategoryType: Int {
    case followedUp
    case watchLater
    case history
    case logout
}

struct PersonalInfoCategory {
    let title: String
    let type: PersonalInfoCategoryType
}
