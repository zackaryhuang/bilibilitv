//
//  Model.swift
//  bilibili
//
//  Created by Zackary on 2024/8/15.
//

import Foundation

struct CommonDataResponse<T: Codable>: Codable {
    let code: Int?
    let message: String
    let ttl: Int
    var data: T? = nil
}

struct RecommendationResponse: Codable {
    let mid: Int
    let items: [VideoInfo]
    enum CodingKeys: String, CodingKey {
        case mid
        case items = "item"
    }
}

struct VideoInfo: Codable, DisplayableData {
    var cover: String { return pic }
    var ownerName: String { return owner.name }
    var ownerFace: String { return owner.face }
    var viewCount: String { return stat.viewCount.numberString() }
    var danmakuCount: String { return stat.danmakuCount.numberString() }

    let id: Int
    let bvid: String
    let cid: Int
    let goto: String
    let uri: String
    let pic: String
    let title: String
    let duration: Int
    let pubDate: Int
    let isFollowed: Int
    let showInfo: Int
    let stat: VideoStateInfo
    let owner: VideoOwnerInfo
    enum CodingKeys: String, CodingKey {
        case id
        case bvid
        case cid
        case goto
        case uri
        case pic
        case title
        case duration
        case pubDate = "pubdate"
        case isFollowed = "is_followed"
        case showInfo = "show_info"
        case stat
        case owner
    }
}

struct VideoStateInfo: Codable {
    let viewCount: Int
    let likeCount: Int
    let danmakuCount: Int
    enum CodingKeys: String, CodingKey {
        case viewCount = "view"
        case likeCount = "like"
        case danmakuCount = "danmaku"
    }
}

struct VideoOwnerInfo: Codable {
    let mid: Int
    let name: String
    let face: String
}

struct DynamicFeedInfo: Codable {
    let items: [DynamicFeedData]
    let offset: String
    let update_num: Int
    let update_baseline: String
    let has_more: Bool
    var videoFeeds: [DynamicFeedData] {
        return items
            .filter({ $0.aid != 0 || $0.modules.module_dynamic.major?.pgc != nil })
    }
}

struct DynamicFeedData: Codable, PlayableData, DisplayData {
    var aid: Int {
        if let str = modules.module_dynamic.major?.archive?.aid {
            return Int(str) ?? 0
        }
        return 0
    }

    var cid: Int { return 0 }

    var title: String {
        return modules.module_dynamic.major?.archive?.title ?? modules.module_dynamic.major?.pgc?.title ?? ""
    }

    var ownerName: String {
        return modules.module_author.name
    }

    var pic: URL? {
        return URL(string: modules.module_dynamic.major?.archive?.cover ?? "") ?? modules.module_dynamic.major?.pgc?.cover
    }

    var avatar: URL? {
        return URL(string: modules.module_author.face)
    }

    var date: String? {
        return modules.module_author.pub_time
    }

    let type: String
    let basic: Basic
    let modules: Modules
    let id_str: String

    struct Basic: Codable, Hashable {
        let comment_id_str: String
        let comment_type: Int
    }

    struct Modules: Codable, Hashable {
        let module_author: ModuleAuthor
        let module_dynamic: ModuleDynamic

        struct ModuleAuthor: Codable, Hashable {
            let face: String
            let mid: Int
            let name: String
            let pub_time: String
        }

        struct ModuleDynamic: Codable, Hashable {
            let major: Major?

            struct Major: Codable, Hashable {
                let archive: Archive?
                let pgc: Pgc?

                struct Archive: Codable, Hashable {
                    let aid: String?
                    let cover: String?
                    let desc: String?
                    let title: String?

                    let stat: State?

                    struct State: Codable, Hashable {
                        let play: String?
                        let danmaku: String?
                    }
                }

                struct Pgc: Codable, Hashable {
                    let epid: Int
                    let title: String?
                    let cover: URL?
                    let jump_url: URL?
                }
            }
        }
    }
}
