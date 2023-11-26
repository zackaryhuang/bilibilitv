//
//  FollowersCollectionViewController.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/30.
//

import UIKit

class FollowersCollectionViewController: BaseCollectionViewController {
    var items = [AnyDispplayData]()

    var isLoading = false

    var page = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        Task {
            await loadData()
        }
    }

    private func loadData() async {
        do {
            page = 1
            let res = try await request(page: page)
            page += 1
            var temp = [AnyDispplayData]()
            res.forEach { feed in
                temp.append(AnyDispplayData(data: feed))
            }
            items = temp
            collectionView.reloadData()
        } catch let err {
            let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .cancel))
            present(alert, animated: true)
        }
    }

    private func loadMore() async {
        do {
            let res = try await request(page: page)
            page += 1
            var temp = [AnyDispplayData]()
            res.forEach { feed in
                temp.append(AnyDispplayData(data: feed))
            }
            items += temp
            collectionView.reloadData()
            isLoading = false
        } catch let err {
            let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .cancel))
            present(alert, animated: true)
        }
    }

    func request(page: Int) async throws -> [FeedData] {
        let json = try await WebRequest.requestJSON(url: "https://api.bilibili.com/x/web-feed/feed?ps=40&pn=\(page)")

        let datas = json.arrayValue.map { data -> FeedData in
            let timestamp = data["pubdate"].int
            let date = DateFormatter.stringFor(timestamp: timestamp)
            let bangumi = data["bangumi"]
            if !bangumi.isEmpty {
                let season = bangumi["season_id"].intValue
                let owner = bangumi["title"].stringValue
                let pic = bangumi["cover"].url!
                let ep = bangumi["new_ep"]
                let title = "第" + ep["index"].stringValue + "集 - " + ep["index_title"].stringValue
                let episode = ep["episode_id"].intValue
                return FeedData(title: title, cid: 0, aid: 0, isSession: true, season: season, episode: episode, ownerName: owner, duration: nil, pic: pic, avatar: nil, date: date, stat: nil)
            }
            let avid = data["id"].intValue
            let archive = data["archive"]
            let title = archive["title"].stringValue
            let cid = archive["cid"].intValue
            let owner = archive["owner"]["name"].stringValue
            let avatar = archive["owner"]["face"].url
            let pic = archive["pic"].url!

            let duration = archive["duration"].intValue
            let danmaku = archive["stat"]["danmaku"].intValue
            let view = archive["stat"]["view"].intValue
            let favorite = archive["stat"]["favorite"].intValue
            let coin = archive["stat"]["coin"].intValue
            let like = archive["stat"]["like"].intValue
            let share = archive["stat"]["share"].intValue
            let dislike = archive["stat"]["dislike"].intValue
            let stat = Stat(favorite: favorite, coin: coin, like: like, share: share, danmaku: danmaku, view: view, dislike: dislike)

            return FeedData(title: title, cid: cid, aid: avid, isSession: false, season: nil, episode: nil, ownerName: owner, duration: duration, pic: pic, avatar: avatar, date: date, stat: stat)
        }
        return datas
    }
}

extension FollowersCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(VideoCell.self), for: indexPath)

        if let videoCell = cell as? VideoCell {
            let item = items[indexPath.row]
            videoCell.update(with: item)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = items[indexPath.row].data as? FeedData else {
            return
        }

        if !item.isSession {
            if Settings.playVideoDirectly {
                let player = VideoPlayerViewController(playInfo: PlayInfo(aid: item.aid, cid: item.cid))
                present(player, animated: true)
            } else {
                let videoDetailVC = NewVideoDetailViewController(aid: item.aid, cid: item.cid)
                present(videoDetailVC, animated: true)
            }
        } else {
            if let epid = item.episode {
                let detailVC = NewVideoDetailViewController(episodeID: epid)
                present(detailVC, animated: true)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard items.count > 0 else { return }
        guard indexPath.row == items.count - 1, !isLoading else {
            return
        }
        isLoading = true
        Task {
            await loadMore()
        }
    }
}
