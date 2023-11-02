//
//  LivesCollectionViewController.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/30.
//

import UIKit

class LivesCollectionViewController: BaseCollectionViewController {
    var currentLiveCategory: LiveCategory? {
        didSet {
            Task {
                await loadData()
            }
        }
    }

    var dataArray = [AnyDispplayData]()

    var isLoading = false
    var page = 1
    var hasMore = true

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        Task {
            await loadData()
        }
    }

    func loadData() async {
        if currentLiveCategory?.type == .followed {
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
        } else {
            hideEmptyView()
        }
    }

    func loadMore() async {
        if currentLiveCategory?.type == .followed {
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
        guard let liveAreaID = currentLiveCategory?.areaID else {
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
}
