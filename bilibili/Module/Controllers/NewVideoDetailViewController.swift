//
//  NewVideoDetailViewController.swift
//  bilibili
//
//  Created by Zackary on 2023/11/26.
//

import UIKit

class NewVideoDetailViewController: UIViewController {
    static var CollectionViewInset = 20.0

    private var aid = 0
    private var cid = 0
    private var data: VideoDetail?
    private var seasonId = 0
    private var isSession = false
    private var epid = 0
    private var pages = [VideoPage]()
    private var episodes = [Episode]()
    var episodesCollectionView: UICollectionView!

    let coverImageView = UIImageView()
    let contentScrollView = UIScrollView()
    let uperAvatarView = UIImageView()
    let uperNameLabel = UILabel()
    let titleLabel = UILabel()
    let playButton = ProgressPlayButton()
    let tagLabel = UILabel()
    let descLabel = UILabel()
    var collectionButton: NormalButton!
    var thumbUpButton: NormalButton!
    var coinButton: NormalButton!
    var dislikeButton: NormalButton!
    var episodesLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadData()
    }

    convenience init(aid: Int = 0, cid: Int = 0) {
        self.init()
        self.aid = aid
        self.cid = cid
    }

    convenience init(seasonID: Int) {
        self.init()
        seasonId = seasonID
    }

    convenience init(episodeID: Int) {
        self.init()
        epid = episodeID
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

        coverImageView.addSubview(uperAvatarView)
        uperAvatarView.layer.cornerRadius = 40
        uperAvatarView.layer.masksToBounds = true
        uperAvatarView.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView).offset(80)
            make.bottom.equalTo(coverImageView).offset(-380)
            make.width.height.equalTo(80)
        }

        coverImageView.addSubview(uperNameLabel)
        uperNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(uperAvatarView.snp.trailing).offset(30)
            make.centerY.equalTo(uperAvatarView)
        }

        coverImageView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(uperAvatarView.snp.bottom).offset(30)
            make.leading.equalTo(coverImageView).offset(80)
        }

        collectionButton = NormalButton(image: "icon_collect", title: "0")
        coverImageView.addSubview(collectionButton)
        collectionButton.snp.makeConstraints { make in
            make.leading.equalTo(uperAvatarView)
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
        }

        thumbUpButton = NormalButton(image: "icon_thumb_up", title: "0")
        coverImageView.addSubview(thumbUpButton)
        thumbUpButton.snp.makeConstraints { make in
            make.leading.equalTo(collectionButton.snp.trailing).offset(20)
            make.centerY.equalTo(collectionButton)
        }

        coinButton = NormalButton(image: "icon_coin", title: "0")
        coverImageView.addSubview(coinButton)
        coinButton.snp.makeConstraints { make in
            make.leading.equalTo(thumbUpButton.snp.trailing).offset(20)
            make.centerY.equalTo(thumbUpButton)
        }

        dislikeButton = NormalButton(image: "icon_thumb_down", title: "不喜欢")
        coverImageView.addSubview(dislikeButton)
        dislikeButton.snp.makeConstraints { make in
            make.leading.equalTo(coinButton.snp.trailing).offset(20)
            make.centerY.equalTo(coinButton)
        }

        playButton.addTapGesture(target: self, action: #selector(play))
        coverImageView.addSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.leading.equalTo(uperAvatarView)
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
    }

    func loadData() {
        Task {
            if seasonId > 0 {
                isSession = true
                let info = try await WebRequest.requestSessionInfo(seasonID: seasonId)
                if let epi = info.main_section?.episodes.last ?? info.section.last?.episodes.last {
                    aid = epi.aid
                    cid = epi.cid
                }

                if let epi = info.main_section?.episodes.last {
                    aid = epi.aid
                    cid = epi.cid
                    episodes = info.main_section?.episodes.reversed() ?? [Episode]()
                } else if let epi = info.section.last?.episodes.last {
                    aid = epi.aid
                    cid = epi.cid
                    episodes = info.section.last?.episodes.reversed() ?? [Episode]()
                    assert(info.section.count > 1, "应该是有多个 Season")
                }

                pages = info.main_section?.episodes.map({ VideoPage(cid: $0.cid, page: $0.aid, from: "", part: $0.title) }) ?? [VideoPage]()
            } else if epid > 0 {
                isSession = true
                let info = try await WebRequest.requestSessionInfo(epid: epid)
                if let epi = info.episodes.last(where: { $0.id == epid }) ?? info.episodes.last {
                    aid = epi.aid
                    cid = epi.cid
                } else {
                    throw NSError(domain: "get epi fail", code: -1)
                }
                episodes = info.episodes.reversed()
                pages = info.episodes.map({ VideoPage(cid: $0.cid, page: $0.aid, from: "", part: $0.title) })
            }
            let data = try await WebRequest.requestDetailVideo(aid: aid)
            self.data = data

            if let redirect = data.View.redirect_url?.lastPathComponent, redirect.starts(with: "ep"), let id = Int(redirect.dropFirst(2)), !isSession {
                isSession = true
                epid = id
                let info = try await WebRequest.requestSessionInfo(epid: epid)
                pages = info.episodes.map({ VideoPage(cid: $0.cid, page: $0.aid, from: "", part: $0.title + " " + $0.long_title) })
                episodes = info.episodes.reversed()
            }
            let cid = UserDefaults.standard.integer(forKey: "\(aid)")
            let playInfo = try? await WebRequest.requestPlayerInfo(aid: aid, cid: cid)
            update(with: data, info: playInfo)
        }
    }

    private func update(with data: VideoDetail?, info: PlayerInfo?) {
        coverImageView.kf.setImage(with: data?.pic)
        uperAvatarView.kf.setImage(with: data?.avatar)
        uperNameLabel.text = data?.ownerName
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
            playButton.progress = Double(playTimeInSecond) / Double(duration)
            playButton.label.text = "继续播放\(playTimeInSecond.standardDurationString)"
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

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [playButton]
    }

    @objc func play() {
        let player = VideoPlayerViewController(playInfo: PlayInfo(aid: aid, cid: cid))
        present(player, animated: true)
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