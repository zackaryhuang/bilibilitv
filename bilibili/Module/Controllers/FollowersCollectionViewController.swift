//
//  FollowersCollectionViewController.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/30.
//

import UIKit

class FollowersCollectionViewController: BaseCollectionViewController {
    var items = [DynamicFeedData]()

    var isLoading = false

    var page = 1
    var lastOffset = ""

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
            lastOffset = ""
            let res = try await WebRequest.requestFollowsFeed(offset: lastOffset, page: page)
            items = res.videoFeeds
            collectionView.reloadData()
        } catch let err {
            let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .cancel))
            present(alert, animated: true)
        }
    }

    private func loadMore() async {
        do {
            let res = try await WebRequest.requestFollowsFeed(offset: lastOffset, page: page + 1)
            page = page + 1
            lastOffset = res.offset
            items += res.videoFeeds
            collectionView.reloadData()
            isLoading = false
        } catch let err {
            let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .cancel))
            present(alert, animated: true)
        }
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
            videoCell.install(with: item)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feed = items[indexPath.row]
        if let episodeID = feed.modules.module_dynamic.major?.pgc?.epid {
            let detailVC = NewVideoDetailViewController(episodeID: episodeID)
            present(detailVC, animated: true)
        } else if let aid = feed.modules.module_dynamic.major?.archive?.aid, let aid = Int(aid) {
            let detailVC = NewVideoDetailViewController(playInfo: PlayInfo(aid: aid))
            present(detailVC, animated: true)
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
