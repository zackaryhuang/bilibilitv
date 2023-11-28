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

    var categoryCollectionView: UICollectionView!
    var currentRankCategory: RankCategoryInfo = RankCategoryInfo.all.first! {
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

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 150, height: 60)

        categoryCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        categoryCollectionView.remembersLastFocusedIndexPath = true
        categoryCollectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        categoryCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: NSStringFromClass(CategoryCell.self))
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        view.addSubview(categoryCollectionView)
        categoryCollectionView.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.top.equalTo(view).offset(60)
            make.height.equalTo(60 + 40)
        }

        collectionView.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalTo(view)
            make.top.equalTo(categoryCollectionView.snp.bottom).offset(20)
        }

        collectionView.delegate = self
        collectionView.dataSource = self
        Task {
            await loadData()
        }
    }

    func loadData() async {
        if currentRankCategory.isSeason == true {
            do {
                isLoading = true
                let res = try await WebRequest.requestSeasonRank(for: currentRankCategory.rid)
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
                let res = try await WebRequest.requestRank(for: currentRankCategory.rid)
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
        if collectionView == categoryCollectionView {
            return RankCategoryInfo.all.count
        }
        return dataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CategoryCell.self), for: indexPath)

            if let videoCell = cell as? CategoryCell {
                let data = RankCategoryInfo.all[indexPath.row]
                videoCell.update(with: data, isSelected: data == currentRankCategory)
            }
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(VideoCell.self), for: indexPath)

        if let videoCell = cell as? VideoCell {
            let data = dataArray[indexPath.row]
            videoCell.update(with: data)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            let data = RankCategoryInfo.all[indexPath.row]
            currentRankCategory = data
            collectionView.reloadData()
            return
        }
        let item = dataArray[indexPath.row]
        if let record = item.data as? VideoDetail.Info {
            if Settings.playVideoDirectly {
                let player = VideoPlayerViewController(playInfo: PlayInfo(aid: record.aid, cid: record.cid))
                present(player, animated: true)
            } else {
                let detail = NewVideoDetailViewController(aid: record.aid, cid: record.cid)
                present(detail, animated: true)
            }
        } else if let record = item.data as? Season {
            let detail = NewVideoDetailViewController(seasonID: record.season_id)
            present(detail, animated: true)
        }
    }

    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        if collectionView == categoryCollectionView {
            if let index = RankCategoryInfo.all.firstIndex(of: currentRankCategory) {
                return IndexPath(row: index, section: 0)
            }
        }
        return nil
    }

    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
