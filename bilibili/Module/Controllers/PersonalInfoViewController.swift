//
//  PersonalInfoViewController.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/11/8.
//

import UIKit

class PersonalInfoViewController: UIViewController {
    var type = CurrentFocusType.userInfo

    let infoCard = PersonalInfoCard()

    let scrollView = UIScrollView()

    var histories = [HistoryData]()

    var watchLaterList = [ToViewData]()

    var historyCollectionView: UICollectionView!

    var watchLaterCollectionView: UICollectionView!

    override func viewDidLoad() {
        configUI()
        Task {
            do {
                let resp = try await WebRequest.requestUserInfo()
                infoCard.update(with: resp)
            } catch let err {
                debugPrint(err)
            }
        }

        WebRequest.requestTopHistory { histories in
            self.histories = histories
            self.historyCollectionView.reloadData()
        }

        Task {
            do {
                let resp = try await WebRequest.requestToView()
                watchLaterList = resp
                watchLaterCollectionView.reloadData()
            } catch let err {
                debugPrint(err)
            }
        }
    }

    func configUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        scrollView.addSubview(infoCard)
        infoCard.snp.makeConstraints { make in
            make.leading.equalTo(scrollView).offset(60)
            make.top.equalTo(scrollView).offset(30)
        }

        let followerButton = LargeButton(title: "我的关注", image: "icon_follow_2")
        scrollView.addSubview(followerButton)
        followerButton.snp.makeConstraints { make in
            make.leading.equalTo(infoCard.snp.trailing).offset(30)
            make.top.equalTo(infoCard).offset(30)
            make.bottom.equalTo(infoCard)
            make.width.equalTo(220)
        }

        let tapForFollow = UITapGestureRecognizer(target: self, action: #selector(onFollowClick))
        followerButton.addGestureRecognizer(tapForFollow)

        let settingButton = LargeButton(title: "设置", image: "icon_setting_2")
        scrollView.addSubview(settingButton)
        settingButton.snp.makeConstraints { make in
            make.leading.equalTo(followerButton.snp.trailing).offset(30)
            make.top.equalTo(followerButton)
            make.bottom.equalTo(followerButton)
            make.width.equalTo(followerButton)
        }

        let tapForSetting = UITapGestureRecognizer(target: self, action: #selector(onSettingClick))
        settingButton.addGestureRecognizer(tapForSetting)

        let aboutButton = LargeButton(title: "关于", image: "icon_about")
        scrollView.addSubview(aboutButton)
        aboutButton.snp.makeConstraints { make in
            make.leading.equalTo(settingButton.snp.trailing).offset(30)
            make.top.equalTo(settingButton)
            make.bottom.equalTo(settingButton)
            make.width.equalTo(settingButton)
        }

        let tapForAbout = UITapGestureRecognizer(target: self, action: #selector(onAboutClick))
        aboutButton.addGestureRecognizer(tapForAbout)

        let logoutButton = LargeButton(title: "退出登录", image: "icon_exit")
        scrollView.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.leading.equalTo(aboutButton.snp.trailing).offset(30)
            make.top.equalTo(aboutButton)
            make.bottom.equalTo(aboutButton)
            make.width.equalTo(aboutButton)
        }

        let tapForExit = UITapGestureRecognizer(target: self, action: #selector(onExitClick))
        logoutButton.addGestureRecognizer(tapForExit)

        let recentLabel = UILabel()
        recentLabel.text = "最近播放"
        scrollView.addSubview(recentLabel)
        recentLabel.snp.makeConstraints { make in
            make.leading.equalTo(infoCard)
            make.top.equalTo(infoCard.snp.bottom).offset(30)
        }

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.itemSize = CGSize(width: VideoCell.CellSize.width, height: VideoCell.CellSize.height)

        historyCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        historyCollectionView.register(VideoCell.self, forCellWithReuseIdentifier: NSStringFromClass(VideoCell.self))
        historyCollectionView.delegate = self
        historyCollectionView.dataSource = self
        scrollView.addSubview(historyCollectionView)
        historyCollectionView.snp.makeConstraints { make in
            make.top.equalTo(recentLabel.snp.bottom).offset(20)
            make.leading.equalTo(recentLabel)
            make.height.equalTo(VideoCell.CellSize.height)
            make.width.equalTo(VideoCell.CellSize.width * 4 + 20 * 3)
        }

        let watchLaterLabel = UILabel()
        watchLaterLabel.text = "稍后播放"
        scrollView.addSubview(watchLaterLabel)
        watchLaterLabel.snp.makeConstraints { make in
            make.leading.equalTo(infoCard)
            make.top.equalTo(historyCollectionView.snp.bottom).offset(30)
        }

        let watchFlowLayout = UICollectionViewFlowLayout()
        watchFlowLayout.scrollDirection = .horizontal
        watchFlowLayout.minimumLineSpacing = 20
        watchFlowLayout.minimumInteritemSpacing = 20
        watchFlowLayout.itemSize = CGSize(width: VideoCell.CellSize.width, height: VideoCell.CellSize.height)

        watchLaterCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: watchFlowLayout)
        watchLaterCollectionView.register(VideoCell.self, forCellWithReuseIdentifier: NSStringFromClass(VideoCell.self))
        watchLaterCollectionView.delegate = self
        watchLaterCollectionView.dataSource = self
        scrollView.addSubview(watchLaterCollectionView)
        watchLaterCollectionView.snp.makeConstraints { make in
            make.top.equalTo(watchLaterLabel.snp.bottom).offset(20)
            make.leading.equalTo(recentLabel)
            make.height.equalTo(VideoCell.CellSize.height)
            make.width.equalTo(VideoCell.CellSize.width * 4 + 20 * 3)
            make.bottom.equalTo(scrollView)
        }
    }

    @objc func onSettingClick() {
        let setting = SettingViewController()
        present(setting, animated: true)
    }

    @objc func onFollowClick() {
        let follow = FollowingUPViewController()
        present(follow, animated: true)
    }

    @objc func onAboutClick() {}

    @objc func onExitClick() {}
}

extension PersonalInfoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == historyCollectionView {
            return histories.count
        }
        return watchLaterList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(VideoCell.self), for: indexPath)

        if let videoCell = cell as? VideoCell {
            if collectionView == historyCollectionView {
                let item = histories[indexPath.row]
                videoCell.update(with: item)
            } else if collectionView == watchLaterCollectionView {
                let item = watchLaterList[indexPath.row]
                videoCell.update(with: item)
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == historyCollectionView {
            let item = histories[indexPath.row]
            if Settings.playVideoDirectly {
                let player = VideoPlayerViewController(playInfo: PlayInfo(aid: item.aid, cid: item.cid))
                present(player, animated: true)
            } else {
                let detailVC = NewVideoDetailViewController(aid: item.aid, cid: item.cid ?? 0)
                present(detailVC, animated: true)
            }

        } else if collectionView == watchLaterCollectionView {
            let item = watchLaterList[indexPath.row]
            if Settings.playVideoDirectly {
                let player = VideoPlayerViewController(playInfo: PlayInfo(aid: item.aid, cid: item.cid))
                present(player, animated: true)
            } else {
                let detailVC = NewVideoDetailViewController(aid: item.aid, cid: item.cid)
                present(detailVC, animated: true)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
