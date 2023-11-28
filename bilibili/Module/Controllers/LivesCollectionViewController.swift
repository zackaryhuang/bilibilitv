//
//  LivesCollectionViewController.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/30.
//

import UIKit

class LivesCollectionViewController: BaseCollectionViewController {
    var currentLiveCategory: LiveCategory = LiveCategory.all.first! {
        didSet {
            dataArray = []
            collectionView.reloadData()
            Task {
                await loadData()
            }
        }
    }

    var dataArray = [AnyDispplayData]()
    var categoryCollectionView: UICollectionView!
    var isLoading = false
    var page = 1
    var hasMore = true
    let focusGuide = UIFocusGuide()

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

        // 将Focus Guide的preferredFocusedView属性设置为需要获得焦点的视图

        collectionView.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalTo(view)
            make.top.equalTo(categoryCollectionView.snp.bottom).offset(20)
            make.bottom.equalTo(view)
        }
        collectionView.delegate = self
        collectionView.dataSource = self

        // 将Focus Guide添加到当前视图上
        view.addLayoutGuide(focusGuide)

        // 设置Focus Guide的frame，使其位于右上角
        focusGuide.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 0).isActive = true
        focusGuide.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: 0).isActive = true
        focusGuide.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 0).isActive = true
        focusGuide.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 0).isActive = true
        focusGuide.preferredFocusEnvironments = [categoryCollectionView]
        focusGuide.isEnabled = false
        Task {
            await loadData()
        }
    }

    func loadData() async {
        if currentLiveCategory.areaID == nil {
            do {
                hasMore = true
                page = 1
                isLoading = true
                let res = try await WebRequest.requestLiveRoom(page: page)
                var temp = [AnyDispplayData]()
                res.forEach { liveRoom in
                    temp.append(AnyDispplayData(data: liveRoom))
                }
                dataArray = temp
                isLoading = false
                page += 1
                collectionView.reloadData()
            } catch let err {
                hasMore = true
                isLoading = false
                let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .cancel))
                present(alert, animated: true)
            }
        } else {
            do {
                hasMore = true
                page = 1
                isLoading = true
                let res = try await request(page: page)
                var temp = [AnyDispplayData]()
                res.forEach { areaLiveRoom in
                    temp.append(AnyDispplayData(data: areaLiveRoom))
                }
                dataArray = temp
                isLoading = false
                page += 1
                collectionView.reloadData()
            } catch let err {
                hasMore = true
                isLoading = false
                let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .cancel))
                present(alert, animated: true)
            }
        }

        if dataArray.count == 0 {
            showEmptyView()
            focusGuide.isEnabled = true
        } else {
            hideEmptyView()
            focusGuide.isEnabled = false
        }
    }

    func loadMore() async {
        if currentLiveCategory.areaID == nil {
            do {
                isLoading = true
                let res = try await WebRequest.requestLiveRoom(page: page)
                res.forEach { liveRoom in
                    dataArray.append(AnyDispplayData(data: liveRoom))
                }
                page += 1
                isLoading = false
                hasMore = res.count > 0
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
                let res = try await request(page: page)
                res.forEach { areaLiveRoom in
                    dataArray.append(AnyDispplayData(data: areaLiveRoom))
                }
                page += 1
                hasMore = res.count > 0
                isLoading = false
                collectionView.reloadData()
            } catch let err {
                isLoading = false
                let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                alert.addAction(.init(title: "Ok", style: .cancel))
                present(alert, animated: true)
            }
        }
    }

    func request(page: Int) async throws -> [AreaLiveRoom] {
        guard let liveAreaID = currentLiveCategory.areaID else {
            return []
        }
        if liveAreaID == 0 {
            return try await WebRequest.requestHotLiveRoom(page: page)
        } else if liveAreaID == -1 {
            return try await WebRequest.requestRecommandLiveRoom(page: page)
        }
        return try await WebRequest.requestAreaLiveRoom(area: liveAreaID, page: page)
    }
}

extension LivesCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return LiveCategory.all.count
        }
        return dataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CategoryCell.self), for: indexPath)

            if let categoryCell = cell as? CategoryCell {
                let data = LiveCategory.all[indexPath.row]
                categoryCell.update(with: data, isSelected: data == currentLiveCategory)
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
            let data = LiveCategory.all[indexPath.row]
            currentLiveCategory = data
            collectionView.reloadData()
            return
        }
        let item = dataArray[indexPath.row]
        if let areaLiveRoom = item.data as? AreaLiveRoom {
            let playerVC = LivePlayerViewController()
            playerVC.room = areaLiveRoom.toLiveRoom()
            present(playerVC, animated: true, completion: nil)
            return
        }

        if let liveRoom = item.data as? LiveRoom {
            let playerVC = LivePlayerViewController()
            playerVC.room = liveRoom
            present(playerVC, animated: true, completion: nil)
            return
        }
    }

    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard dataArray.count > 0 else { return }
        guard indexPath.row == dataArray.count - 1, !isLoading, hasMore else {
            return
        }
        Task {
            await loadMore()
        }
    }

    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        if collectionView == categoryCollectionView {
            if let index = LiveCategory.all.firstIndex(of: currentLiveCategory) {
                return IndexPath(row: index, section: 0)
            }
        }
        return nil
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [categoryCollectionView]
    }
}
