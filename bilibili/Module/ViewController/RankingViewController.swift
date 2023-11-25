//
//  RankingViewController.swift
//  BilibiliLive
//
//  Created by yicheng on 2022/10/29.
//

import Foundation
import UIKit

struct RankCategoryInfo {
    let title: String
    let rid: Int
    var isSeason = false

    static let all = [RankCategoryInfo(title: "全站", rid: 0),
                      RankCategoryInfo(title: "动画", rid: 1),
                      RankCategoryInfo(title: "番剧", rid: 1, isSeason: true),
                      RankCategoryInfo(title: "国创", rid: 4, isSeason: true),
                      RankCategoryInfo(title: "音乐", rid: 3),
                      RankCategoryInfo(title: "舞蹈", rid: 129),
                      RankCategoryInfo(title: "游戏", rid: 4),
                      RankCategoryInfo(title: "知识", rid: 36),
                      RankCategoryInfo(title: "科技", rid: 188),
                      RankCategoryInfo(title: "运动", rid: 234),
                      RankCategoryInfo(title: "汽车", rid: 223),
                      RankCategoryInfo(title: "生活", rid: 160),
                      RankCategoryInfo(title: "美食", rid: 211),
                      RankCategoryInfo(title: "动物圈", rid: 217),
                      RankCategoryInfo(title: "鬼畜", rid: 119),
                      RankCategoryInfo(title: "时尚", rid: 155),
                      RankCategoryInfo(title: "娱乐", rid: 5),
                      RankCategoryInfo(title: "影视", rid: 181),
                      RankCategoryInfo(title: "纪录片", rid: 177),
                      RankCategoryInfo(title: "电影", rid: 23),
                      RankCategoryInfo(title: "电视剧", rid: 11)]
}

class RankingViewController: CategoryViewController {
    override func viewDidLoad() {
        categories = RankCategoryInfo.all
            .map {
                CategoryDisplayModel(title: $0.title, contentVC: RankingContentViewController(info: $0))
            }
        super.viewDidLoad()
    }
}

class RankingContentViewController: UIViewController, BLTabBarContentVCProtocol {
    let collectionVC = FeedCollectionViewController()
    let info: RankCategoryInfo

    init(info: RankCategoryInfo) {
        self.info = info
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionVC.styleOverride = .sideBar
        collectionVC.show(in: self)
        collectionVC.didSelect = {
            [weak self] in
            self?.goDetail(with: $0)
        }
        reloadData()
    }

    func reloadData() {
        Task {
            if info.isSeason {
                collectionVC.displayDatas = try await WebRequest.requestSeasonRank(for: info.rid)
            } else {
                collectionVC.displayDatas = try await WebRequest.requestRank(for: info.rid)
            }
        }
    }

    func goDetail(with record: any DisplayData) {
        if let record = record as? VideoDetail.Info {
            let detailVC = VideoDetailViewController.create(aid: record.aid, cid: record.cid)
            detailVC.present(from: self)
        } else if let record = record as? Season {
            let detailVC = VideoDetailViewController.create(seasonId: record.season_id)
            detailVC.present(from: self)
        }
    }
}

extension WebRequest.EndPoint {
    static let rank = "https://api.bilibili.com/x/web-interface/ranking/v2"
}

extension WebRequest {
    static func requestRank(for category: Int) async throws -> [VideoDetail.Info] {
        struct RankResp: Codable {
            let list: [VideoDetail.Info]
        }
        let resp: RankResp = try await request(url: EndPoint.rank, parameters: ["rid": category, "type": "all"])
        return resp.list
    }

    static func requestSeasonRank(for category: Int) async throws -> [Season] {
        struct Resp: Codable {
            let list: [Season]
        }
        let res: Resp = try await request(url: "https://api.bilibili.com/pgc/web/rank/list", parameters: ["day": 3, "season_type": category], dataObj: "result")
        return res.list
    }
}

struct Season: Codable, DisplayData {
    struct NewEP: Codable, Hashable {
        let cover: String
        let index_show: String
    }

    var ownerName: String { new_ep.index_show }
    var pic: URL? { cover }

    let title: String
    let cover: URL
    let season_id: Int
    let new_ep: NewEP
}
