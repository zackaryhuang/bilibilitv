//
//  BaseCollectionViewController.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/30.
//

import Lottie
import UIKit

class BaseCollectionViewController: UIViewController {
    var type = CurrentFocusType.none

    var lottieView: LottieAnimationView!

    var emptyLabel: UILabel!

    var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.itemSize = CGSize(width: 420, height: 345)

        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: NSStringFromClass(VideoCell.self))
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        lottieView = LottieAnimationView(name: "lottie_empty", animationCache: nil)
        lottieView.isHidden = true
        lottieView.loopMode = .loop
        view.addSubview(lottieView)
        lottieView.snp.makeConstraints { make in
            make.center.equalTo(view)
        }

        emptyLabel = UILabel()
        emptyLabel.font = .systemFont(ofSize: 30)
        emptyLabel.textColor = UIColor(hex: 0xFAFAFA)
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        emptyLabel.text = "还没有内容哦～"
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(lottieView.snp.bottom)
            make.centerX.equalTo(lottieView)
        }
    }

    func showEmptyView() {
        lottieView.isHidden = false
        view.bringSubviewToFront(lottieView)
        view.bringSubviewToFront(emptyLabel)
        emptyLabel.isHidden = false
        lottieView.play()
    }

    func hideEmptyView() {
        lottieView.stop()
        lottieView.isHidden = true
        emptyLabel.isHidden = true
    }
}
