//
//  NewVideoDetailViewController.swift
//  bilibili
//
//  Created by Zackary on 2023/11/26.
//

import Lottie
import UIKit

class NewVideoDetailViewController: UIViewController {
    static var CollectionViewInset = 20.0
    private var playInfo: PlayInfo
    private var data: VideoDetail?
    private var isSession = false
    private var pages = [VideoPage]()
    private var episodes = [Episode]()
    var episodesCollectionView: UICollectionView!

    let coverImageView = UIImageView()
    let contentScrollView = UIScrollView()
//    let uperAvatarView = UIImageView()
//    let uperNameLabel = UILabel()
    let uperProfileView = LeftImageRightTextView()
    let titleLabel = UILabel()
    let playButton = ProgressPlayButton()
    let tagLabel = UILabel()
    let descLabel = UILabel()
    var collectionButton: NormalButton!
    var thumbUpButton: NormalButton!
    var coinButton: NormalButton!
    var dislikeButton: NormalButton!
    var episodesLabel = UILabel()
    var lottieView = LottieAnimationView(name: "All")
    var isTripleCanceled = false
    var hasTripled = false
    var tripleStartTime = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let aid = data?.View.aid, let cid = data?.View.cid {
            Task {
                let playInfo = try? await WebRequest.requestPlayerInfo(aid: aid, cid: cid)
                update(with: data, info: playInfo)
            }
        }
    }

    convenience init(aid: Int = 0, cid: Int = 0) {
        self.init(playInfo: PlayInfo(aid: aid, cid: cid))
    }

    init(playInfo: PlayInfo) {
        self.playInfo = playInfo
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(seasonID: Int) {
        self.init(playInfo: PlayInfo(seasonID: seasonID))
    }

    convenience init(episodeID: Int) {
        self.init(playInfo: PlayInfo(episodeID: episodeID))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        view.backgroundColor = .black
        contentScrollView.insetsLayoutMarginsFromSafeArea = false
        contentScrollView.contentInsetAdjustmentBehavior = .never
        contentScrollView.preservesSuperviewLayoutMargins = false
        view.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.isUserInteractionEnabled = true
        contentScrollView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.leading.top.equalTo(contentScrollView)
            make.trailing.equalTo(view)
            make.height.equalTo(view)
            make.bottom.equalTo(contentScrollView)
        }

        let imageView = UIImageView(image: UIImage(named: "cover_mask"))
        coverImageView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(coverImageView)
        }

        uperProfileView.imageView.layer.cornerRadius = 40
        uperProfileView.imageView.layer.masksToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goUperSpace))
        uperProfileView.addGestureRecognizer(tapGesture)
        coverImageView.addSubview(uperProfileView)
        uperProfileView.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView).offset(80)
            make.bottom.equalTo(coverImageView).offset(-380)
        }

        coverImageView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(uperProfileView.snp.bottom).offset(30)
            make.leading.equalTo(coverImageView).offset(80)
        }

        collectionButton = NormalButton(image: "icon_collect_gray", title: "0")
        addTapAndLongPress(for: collectionButton)
        coverImageView.addSubview(collectionButton)
        collectionButton.snp.makeConstraints { make in
            make.leading.equalTo(uperProfileView)
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
        }

        thumbUpButton = NormalButton(image: "icon_thumb_up_gray", title: "0")
        addTapAndLongPress(for: thumbUpButton)
        coverImageView.addSubview(thumbUpButton)
        thumbUpButton.snp.makeConstraints { make in
            make.leading.equalTo(collectionButton.snp.trailing).offset(20)
            make.centerY.equalTo(collectionButton)
        }

        coinButton = NormalButton(image: "icon_coin_gray", title: "0")
        addTapAndLongPress(for: coinButton)
        coverImageView.addSubview(coinButton)
        coinButton.snp.makeConstraints { make in
            make.leading.equalTo(thumbUpButton.snp.trailing).offset(20)
            make.centerY.equalTo(thumbUpButton)
        }

        dislikeButton = NormalButton(image: "icon_thumb_down_gray", title: "不喜欢")
        addTapAndLongPress(for: dislikeButton)
        coverImageView.addSubview(dislikeButton)
        dislikeButton.snp.makeConstraints { make in
            make.leading.equalTo(coinButton.snp.trailing).offset(20)
            make.centerY.equalTo(coinButton)
        }

        playButton.addTapGesture(target: self, action: #selector(play))
        coverImageView.addSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.leading.equalTo(uperProfileView)
            make.top.equalTo(collectionButton.snp.bottom).offset(30)
            make.leading.equalTo(collectionButton)
            make.trailing.equalTo(dislikeButton)
            make.height.equalTo(80)
        }

        tagLabel.textColor = .lightGray
        coverImageView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints { make in
            make.leading.equalTo(dislikeButton.snp.trailing).offset(80)
            make.centerY.equalTo(dislikeButton)
            make.trailing.equalTo(coverImageView).offset(-20)
        }

        descLabel.numberOfLines = 0
        descLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        descLabel.font = UIFont.systemFont(ofSize: 26)
        coverImageView.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(tagLabel)
            make.top.equalTo(tagLabel.snp.bottom).offset(10)
            make.trailing.equalTo(coverImageView).offset((-20))
            make.bottom.lessThanOrEqualTo(playButton)
        }

        episodesLabel.text = "剧集"
        contentScrollView.addSubview(episodesLabel)
        episodesLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentScrollView).offset(60)
            make.top.equalTo(coverImageView.snp.bottom).offset(20)
        }

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = 20

        episodesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        episodesCollectionView.contentInset = UIEdgeInsets(top: Self.CollectionViewInset,
                                                           left: Self.CollectionViewInset,
                                                           bottom: Self.CollectionViewInset,
                                                           right: Self.CollectionViewInset)
        episodesCollectionView.backgroundColor = .clear
        episodesCollectionView.register(NormalVideoCell.self, forCellWithReuseIdentifier: NSStringFromClass(NormalVideoCell.self))
        episodesCollectionView.delegate = self
        episodesCollectionView.dataSource = self
        contentScrollView.addSubview(episodesCollectionView)
        episodesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(episodesLabel.snp.bottom).offset(20)
            make.height.equalTo(NormalVideoCell.CellSize.height + 2 * Self.CollectionViewInset)
            make.width.equalTo(NormalVideoCell.CellSize.width * 4 + (20.0 * 3) + (2 * Self.CollectionViewInset))
            make.centerX.equalTo(coverImageView)
        }

        lottieView.isHidden = true
        view.addSubview(lottieView)
        lottieView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.width.equalTo(1200)
            make.height.equalTo(400)
        }
    }

    func loadData() {
        Task {
            if let seasonID = self.playInfo.seasonID, seasonID > 0 {
                isSession = true
                let info = try await WebRequest.requestSessionInfo(seasonID: seasonID)
                if let epi = info.main_section?.episodes.last ?? info.section.last?.episodes.last {
                    playInfo = PlayInfo(aid: epi.aid, cid: epi.cid, seasonID: seasonID, episodeID: epi.id)
                }

                if let epi = info.main_section?.episodes.last {
                    playInfo = PlayInfo(aid: epi.aid, cid: epi.cid, seasonID: seasonID, episodeID: epi.id)
                    episodes = info.main_section?.episodes.reversed() ?? [Episode]()
                } else if let epi = info.section.last?.episodes.last {
                    playInfo = PlayInfo(aid: epi.aid, cid: epi.cid, seasonID: seasonID, episodeID: epi.id)
                    episodes = info.section.last?.episodes.reversed() ?? [Episode]()
                    assert(info.section.count > 1, "应该是有多个 Season")
                }

                pages = info.main_section?.episodes.map({ VideoPage(cid: $0.cid, page: $0.aid, from: "", part: $0.title) }) ?? [VideoPage]()
            } else if let epid = playInfo.episodeID, epid > 0 {
                isSession = true
                let info = try await WebRequest.requestSessionInfo(epid: epid)
                if let epi = info.episodes.last(where: { $0.id == epid }) ?? info.episodes.last {
                    playInfo = PlayInfo(aid: epi.aid, cid: epi.cid)
                } else {
                    throw NSError(domain: "get epi fail", code: -1)
                }
                episodes = info.episodes.reversed()
                pages = info.episodes.map({ VideoPage(cid: $0.cid, page: $0.aid, from: "", part: $0.title) })
            }

            if let bvid = self.playInfo.bvid {
                let data = try await WebRequest.requestDetailVideo(bvid: bvid)
                self.data = data
            } else if playInfo.isAidValid {
                let data = try await WebRequest.requestDetailVideo(aid: playInfo.aid)
                self.data = data
            } else {
                assertionFailure("缺少视频唯一标识")
            }

            if let redirect = data?.View.redirect_url?.lastPathComponent, redirect.starts(with: "ep"),
               let id = Int(redirect.dropFirst(2)),
               !isSession,
               let epid = playInfo.episodeID
            {
                isSession = true
                let info = try await WebRequest.requestSessionInfo(epid: epid)
                pages = info.episodes.map({ VideoPage(cid: $0.cid, page: $0.aid, from: "", part: $0.title + " " + $0.long_title) })
                episodes = info.episodes.reversed()
            }

            guard let aid = data?.View.aid, let cid = data?.View.cid else {
                throw NSError(domain: "未获取到视频 aid & cid", code: -1)
            }
            let playInfo = try? await WebRequest.requestPlayerInfo(aid: aid, cid: cid)

            var hasSentCoin = false
            WebRequest.RequestGetCoinStatus(aid: aid) { coinCount in
                if coinCount > 0 {
                    self.coinButton.imageView.image = UIImage(named: "icon_coin")
                    hasSentCoin = true
                }
            }

            var hasCollected = false
            WebRequest.RequestCollectionStatus(aid: aid) { collected in
                if collected {
                    self.collectionButton.imageView.image = UIImage(named: "icon_collect")
                    hasCollected = true
                }
            }
            var hasLiked = false
            WebRequest.RequestLikeStatus(aid: aid) { liked in
                if liked {
                    self.thumbUpButton.imageView.image = UIImage(named: "icon_thumb_up")
                    hasLiked = true
                }
            }

            hasTripled = hasSentCoin && hasCollected && hasLiked
            update(with: data, info: playInfo)
        }
    }

    private func update(with data: VideoDetail?, info: PlayerInfo?) {
        coverImageView.kf.setImage(with: data?.pic)
        uperProfileView.imageView.kf.setImage(with: data?.avatar)
        uperProfileView.titleLabel.text = data?.ownerName
        titleLabel.text = data?.title

        let attributedString = NSMutableAttributedString()

        if let viewCount = data?.View.stat.playCountString {
            attributedString.append(NSAttributedString(string: "\(viewCount)播放", attributes: [
                .foregroundColor: UIColor.lightGray,
                .font: UIFont.systemFont(ofSize: 22),
            ]))
        }

        if let duration = data?.View.durationString {
            attributedString.append(NSAttributedString(string: "   \(duration)", attributes: [
                .foregroundColor: UIColor.lightGray,
                .font: UIFont.systemFont(ofSize: 22),
            ]))
        }

        if let publish = data?.date {
            attributedString.append(NSAttributedString(string: "   \(publish)", attributes: [
                .foregroundColor: UIColor.lightGray,
                .font: UIFont.systemFont(ofSize: 22),
            ]))
        }

        if let width = data?.View.dimension?.width,
           let height = data?.View.dimension?.height
        {
            attributedString.append(NSAttributedString(string: "   \(width) x \(height)", attributes: [
                .foregroundColor: UIColor.lightGray,
                .font: UIFont.systemFont(ofSize: 22),
            ]))
        }

        if let tag = data?.View.tname {
            attributedString.append(NSAttributedString(string: "   \(tag)", attributes: [
                .foregroundColor: UIColor.lightGray,
                .font: UIFont.systemFont(ofSize: 22),
            ]))
        }
        tagLabel.attributedText = attributedString

        descLabel.text = data?.View.desc

        if let favCount = data?.View.stat.favorite {
            if favCount == 0 {
                collectionButton.label.text = "收藏"
            } else {
                collectionButton.label.text = "\(favCount.numberString())"
            }
        }

        if let likeCount = data?.View.stat.like {
            if likeCount == 0 {
                thumbUpButton.label.text = "点赞"
            } else {
                thumbUpButton.label.text = "\(likeCount.numberString())"
            }
        }

        if let coinCount = data?.View.stat.coin {
            if coinCount == 0 {
                coinButton.label.text = "投币"
            } else {
                coinButton.label.text = "\(coinCount.numberString())"
            }
        }

        if let dislikeCount = data?.View.stat.dislike {
            if dislikeCount == 0 {
                dislikeButton.label.text = "不喜欢"
            } else {
                dislikeButton.label.text = "\(dislikeCount.numberString())"
            }
        }

        if let playTimeInSecond = info?.playTimeInSecond,
           playTimeInSecond > 0,
           let duration = data?.View.duration
        {
            let progress = Double(playTimeInSecond) / Double(duration)
            playButton.progress = progress
            if progress > 0.95 {
                playButton.label.text = "已看完"
            } else {
                playButton.label.text = "继续播放\(playTimeInSecond.standardDurationString)"
            }
        }

        if episodes.count > 0 {
            coverImageView.snp.remakeConstraints { make in
                make.leading.top.equalTo(contentScrollView)
                make.size.equalTo(UIScreen.main.bounds.size)
                make.trailing.equalTo(contentScrollView)
            }

            episodesLabel.snp.remakeConstraints { make in
                make.leading.equalTo(contentScrollView).offset(60)
                make.top.equalTo(coverImageView.snp.bottom).offset(20)
            }

            episodesCollectionView.snp.remakeConstraints { make in
                make.top.equalTo(episodesLabel.snp.bottom).offset(20)
                make.height.equalTo(NormalVideoCell.CellSize.height + 2 * Self.CollectionViewInset)
                make.width.equalTo(NormalVideoCell.CellSize.width * 4 + (20.0 * 3) + (2 * Self.CollectionViewInset))
                make.centerX.equalTo(coverImageView)
                make.bottom.equalTo(contentScrollView).offset(-20)
            }
            episodesCollectionView.reloadData()
        }
    }

    private func addTapAndLongPress(for button: NormalButton) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        button.addGestureRecognizer(tapGesture)
        button.addGestureRecognizer(longPressGesture)
    }

    @objc func tapAction(gesture: UIGestureRecognizer) {
        if gesture.view == collectionButton {
            debugPrint("收藏")
        } else if gesture.view == thumbUpButton {
            debugPrint("点赞")
        } else if gesture.view == coinButton {
            debugPrint("投币")
        } else if gesture.view == dislikeButton {
            debugPrint("不喜欢")
        } else {
            debugPrint("Why?")
        }
    }

    @objc func longPressAction(gesture: UIGestureRecognizer) {
        if hasTripled {
            return
        }
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.0
        self.view.addSubview(view)
        if gesture.state == .began {
            tripleStartTime = CFAbsoluteTimeGetCurrent()
            view.snp.makeConstraints { make in
                make.edges.equalTo(self.view)
            }
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3) {
                view.alpha = 0.3
                self.view.layoutIfNeeded()
            }
            lottieView.isHidden = false
            view.bringSubviewToFront(lottieView)
            isTripleCanceled = false
            lottieView.play { completed in
                if !self.isTripleCanceled, let aid = self.data?.View.aid {
                    debugPrint("一键三连")
                    WebRequest.RequestTriple(aid: aid) { succeed in
                        if succeed {
                            self.collectionButton.imageView.image = UIImage(named: "icon_collect")
                            self.thumbUpButton.imageView.image = UIImage(named: "icon_thumb_up")
                            self.coinButton.imageView.image = UIImage(named: "icon_coin")
                            self.hasTripled = true
                        }
                    }
                }
                self.lottieView.isHidden = true
                UIView.animate(withDuration: 0.3) {
                    view.alpha = 0.0
                    self.view.layoutIfNeeded()
                } completion: { completed in
                    if completed {
                        view.removeFromSuperview()
                    }
                }
            }
        }

        if gesture.state == .ended {
            let duration = CFAbsoluteTimeGetCurrent() - tripleStartTime
            if duration < 1.2 {
                lottieView.stop()
                isTripleCanceled = true
                UIView.animate(withDuration: 0.3) {
                    view.alpha = 0.0
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [playButton]
    }

    @objc func play() {
        guard let aid = data?.View.aid, let cid = data?.View.cid else {
            return
        }
        let player = VideoPlayerViewController(playInfo: PlayInfo(aid: aid, cid: cid))
        present(player, animated: true)
    }

    @objc func goUperSpace() {
        if let mid = data?.View.owner.mid {
            let uperSpaceVC = UperSpaceViewController(mid: mid)
            present(uperSpaceVC, animated: true)
        }
    }
}

extension NewVideoDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(NormalVideoCell.self), for: indexPath)

        if let videoCell = cell as? NormalVideoCell {
            let item = episodes[indexPath.row]
            videoCell.update(title: item.title, subTitle: item.long_title, imageURL: item.cover)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = episodes[indexPath.row]
        let player = VideoPlayerViewController(playInfo: PlayInfo(aid: item.aid, cid: item.cid))
        present(player, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return NormalVideoCell.CellSize
    }

    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
