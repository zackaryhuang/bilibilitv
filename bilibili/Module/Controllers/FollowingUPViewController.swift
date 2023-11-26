//
//  FollowingUPViewController.swift
//  bilibili
//
//  Created by Zackary on 2023/11/25.
//

import UIKit

class FollowingUPViewController: UIViewController {
    static let CellWidth = 500.0
    static let CellHeight = 120.0
    static let Inset = 10.0
    static let InteritemSpacing = 40.0
    static let LineSpacing = 40.0
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
        let label = UILabel()
        label.text = "我的关注"
        label.font = .boldSystemFont(ofSize: 50)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(80)
            make.top.equalTo(view).offset(100)
        }

        let line = UIView()
        line.backgroundColor = .gray
        view.addSubview(line)
        line.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(80)
            make.trailing.equalTo(view).offset(-80)
            make.height.equalTo(2)
            make.top.equalTo(label.snp.bottom).offset(50)
        }

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Self.LineSpacing
        layout.minimumInteritemSpacing = Self.InteritemSpacing
        layout.itemSize = CGSizeMake(Self.CellWidth, Self.CellHeight)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: NSStringFromClass(FollowerCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.width.equalTo(Self.CellWidth * 3 + 2 * Self.InteritemSpacing)
            make.centerX.equalTo(view)
            make.top.equalTo(line.snp.bottom).offset(20)
            make.bottom.equalTo(view)
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

extension FollowingUPViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return follows.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(FollowerCell.self), for: indexPath)

        if let upCell = cell as? FollowerCell {
            let up = follows[indexPath.row]
            upCell.update(with: up)
        }
        return cell
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: Self.CellWidth, height: Self.CellHeight)
//    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard follows.count > 0 else { return }
        guard indexPath.row == follows.count - 1, !requesting, !finished else {
            return
        }
        loadMoreData()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = follows[indexPath.item]
        let upSpaceVC = UperSpaceViewController(mid: data.mid)
        present(upSpaceVC, animated: true)
    }
}
