//
//  FeedsCollectionViewController.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/30.
//

import UIKit

private let reuseIdentifier = "Cell"

class FeedsCollectionViewController: BaseCollectionViewController {
    var items = [ApiRequest.FeedResp.Items]()

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
            items = res
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
            items += res
            collectionView.reloadData()
            isLoading = false
        } catch let err {
            let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: .cancel))
            present(alert, animated: true)
        }
    }

    private func request(page: Int) async throws -> [ApiRequest.FeedResp.Items] {
        if page == 1 {
            return try await ApiRequest.getFeeds()
        } else if let last = (items.last)?.idx {
            return try await ApiRequest.getFeeds(lastIdx: last)
        } else {
            throw NSError(domain: "", code: -1)
        }
    }
}

extension FeedsCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        let item = items[indexPath.row]
        let detailVC = VideoDetailViewController.create(aid: item.aid, cid: item.cid)
        detailVC.present(from: self)
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
