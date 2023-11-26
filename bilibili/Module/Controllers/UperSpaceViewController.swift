//
//  UperSpaceViewController.swift
//  bilibili
//
//  Created by Zackary on 2023/11/26.
//

import UIKit

class UperSpaceViewController: BaseCollectionViewController {
    var items = [UpSpaceListData]()

    var uperData: UperData?

    var hasMore = true

    var isLoading = false

    private var mid = 0
    private var lastAid: Int?

    var page = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        Task {
            await loadData()
        }
        fetchUperInfo()
    }

    convenience init(mid: Int) {
        self.init()
        self.mid = mid
    }

    private func configUI() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.headerReferenceSize = CGSizeMake(view.frame.size.width, 300)
        }
        collectionView.register(UperSpaceSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(UperSpaceSectionHeader.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.snp.remakeConstraints { make in
            make.bottom.equalTo(view)
            make.centerX.equalTo(view)
            make.width.equalTo(VideoCell.videSize.width * 4 + 20 * 3)
            make.top.equalTo(view)
        }
    }

    private func fetchUperInfo() {
        Task {
            uperData = try await WebRequest.requestUserInfo(mid: mid)
            collectionView.reloadData()
        }
    }

    private func loadData() async {
        do {
            lastAid = nil
            page = 1
            let res = try await request()
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
            let res = try await request()
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

    private func request() async throws -> [UpSpaceListData] {
        let res = try await WebRequest.requestUpSpaceVideo(mid: mid, lastAid: lastAid, pageSize: 20)
        lastAid = res.last?.aid
        if res.count < 20 {
            hasMore = false
        }
        return res
    }
}

extension UperSpaceViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
//        let player = VideoPlayerViewController(playInfo: PlayInfo(aid: item.aid, cid: item.cid))
        let player = NewVideoDetailViewController(aid: item.aid, cid: item.cid)
        present(player, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard items.count > 0 else { return }
        guard indexPath.row == items.count - 1, !isLoading, hasMore else {
            return
        }
        isLoading = true
        Task {
            await loadMore()
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(UperSpaceSectionHeader.self), for: indexPath)
        if let sectionHeader = view as? UperSpaceSectionHeader,
           let data = uperData
        {
            sectionHeader.update(with: data)
        }
        return view
    }
}
