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
        fetchUperInfo()
        Task {
            await loadData()
        }
    }

    convenience init(mid: Int) {
        self.init()
        self.mid = mid
    }

    private func configUI() {
        view.backgroundColor = .black
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.headerReferenceSize = CGSizeMake(view.frame.size.width, 300)
        }
        collectionView.register(UperSpaceSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(UperSpaceSectionHeader.self))
        collectionView.insetsLayoutMarginsFromSafeArea = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.preservesSuperviewLayoutMargins = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.snp.remakeConstraints { make in
            make.edges.equalTo(view)
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

extension UperSpaceViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
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
        if indexPath.section == 0 {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(UperSpaceSectionHeader.self), for: indexPath)
            if let sectionHeader = view as? UperSpaceSectionHeader,
               let data = uperData
            {
                sectionHeader.update(with: data)
            }
            return view
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: view.frame.size.width, height: 300)
        }
        return CGSize(width: view.frame.size.width, height: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            let inset = (view.frame.size.width - 4 * VideoCell.CellSize.width - 3 * 20) / 2.0
            return UIEdgeInsets(top: 20, left: inset, bottom: 0, right: inset)
        }
        return .zero
    }
}
