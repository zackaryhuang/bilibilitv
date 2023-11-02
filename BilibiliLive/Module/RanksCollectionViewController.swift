//
//  RanksCollectionViewController.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/30.
//

import UIKit

private let reuseIdentifier = "Cell"

class RanksCollectionViewController: BaseCollectionViewController {
    var dataArray = [AnyDispplayData]()
    var currentRankCategory: RankCategoryInfo? {
        didSet {
            dataArray = []
            collectionView.reloadData()
            Task {
                await loadData()
            }
        }
    }

    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        Task {
            await loadData()
        }
    }

    func loadData() async {
        guard let category = currentRankCategory else {
            return
        }
        if category.isSeason == true {
            do {
                isLoading = true
                let res = try await WebRequest.requestSeasonRank(for: category.rid)
                var temp = [AnyDispplayData]()
                res.forEach { liveRoom in
                    temp.append(AnyDispplayData(data: liveRoom))
                }
                dataArray = temp
                isLoading = false
                collectionView.reloadData()
            } catch let err {
                isLoading = false
                let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .cancel))
                present(alert, animated: true)
            }
        } else {
            do {
                isLoading = true
                let res = try await WebRequest.requestRank(for: category.rid)
                var temp = [AnyDispplayData]()
                res.forEach { info in
                    temp.append(AnyDispplayData(data: info))
                }
                dataArray = temp
                isLoading = false
                collectionView.reloadData()
            } catch let err {
                isLoading = false
                let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .cancel))
                present(alert, animated: true)
            }
        }

        if dataArray.count == 0 {
            showEmptyView()
        } else {
            hideEmptyView()
        }
    }
}

extension RanksCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(VideoCell.self), for: indexPath)

        if let videoCell = cell as? VideoCell {
            let data = dataArray[indexPath.row]
            videoCell.update(with: data)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataArray[indexPath.row]
        if let record = item.data as? VideoDetail.Info {
            let detailVC = VideoDetailViewController.create(aid: record.aid, cid: record.cid)
            detailVC.present(from: self)
        } else if let record = item.data as? Season {
            let detailVC = VideoDetailViewController.create(seasonId: record.season_id)
            detailVC.present(from: self)
        }
    }

    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
