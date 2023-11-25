//
//  PersonalInfoViewController.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/11/8.
//

import UIKit

class PersonalInfoViewController: UIViewController {
    static let CellWidth = 500.0
    static let CellHeight = 120.0
    static let Inset = 10.0
    static let InteritemSpacing = 20.0
    static let LineSpacing = 20.0

    var sidePanel: SubSidePanel!

    var type: CurrentFocusType = .userInfo
    var currentCategory: PersonalInfoCategory?

    var collectionView: UICollectionView!
    var requesting = false
    var finished = false
    var page = 0

    var follows = [WebRequest.FollowingUser]() {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadData()
    }

    func configUI() {
        sidePanel = SubSidePanel()
        sidePanel.delegate = self
        sidePanel.currentFocusType = .userInfo
        view.addSubview(sidePanel)
        sidePanel.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(view)
            make.width.equalTo(170)
        }

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: NSStringFromClass(FollowerCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: Self.Inset, left: Self.Inset, bottom: Self.Inset, right: Self.Inset)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.equalTo(sidePanel.snp.trailing)
            make.top.bottom.equalTo(view)
            make.width.equalTo(Self.CellWidth * 3 + 2 * Self.Inset + 2 * Self.InteritemSpacing)
        }
    }

    func loadData() {
        Task {
            requesting = true
            do {
                follows = try await WebRequest.requestFollowing(page: 1)
            } catch {}
            requesting = false
        }
    }

    func loadMoreData() {
        requesting = true
        Task {
            do {
                page += 1
                let next = try await WebRequest.requestFollowing(page: page)
                finished = next.count < 40
                follows.append(contentsOf: next)
            } catch {
                finished = true
            }
            requesting = false
        }
    }
}

extension PersonalInfoViewController: SideSubPanelDelegate {
    func sideSubPanelDidFocus(on category: PersonalInfoCategory) {
        currentCategory = category
        collectionView.reloadData()
    }
}

extension PersonalInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentCategory?.type == .followedUp {
            return follows.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(FollowerCell.self), for: indexPath)

        if let upCell = cell as? FollowerCell {
            let up = follows[indexPath.row]
            upCell.update(with: up)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if currentCategory?.type == .followedUp {
            return CGSize(width: Self.CellWidth, height: Self.CellHeight)
        }
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard follows.count > 0 else { return }
        guard indexPath.row == follows.count - 1, !requesting, !finished else {
            return
        }
        loadMoreData()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = follows[indexPath.item]
        let upSpaceVC = UpSpaceViewController()
        upSpaceVC.mid = data.mid
        present(upSpaceVC, animated: true)
    }
}
