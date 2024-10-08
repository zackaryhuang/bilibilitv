//
//  VideoCell.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/25.
//

import Kingfisher
import SnapKit
import UIKit

class VideoCell: UICollectionViewCell {
    var coverImageView: UIImageView!
    var shadowView: UIImageView!
    var titleLabel: UILabel!
    var danmakuCountIcon: UIImageView!
    var danmakuCountLabel: UILabel!
    var playCountIcon: UIImageView!
    var playCountLabel: UILabel!
    var durationLabel: UILabel!
    var recommendLabel: UILabel!
    var uperIcon: UIImageView!
    var uperNameLabel: UILabel!

    static let CellSize = CGSizeMake(420, 345)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        coverImageView = UIImageView()
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.layer.cornerRadius = 15
        coverImageView.clipsToBounds = true
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(10)
            make.centerX.equalTo(self)
            make.width.equalTo(400)
            make.height.equalTo(225)
        }

        shadowView = UIImageView()
        shadowView.image = UIImage(named: "bg_shadow")
        coverImageView.addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(coverImageView)
            make.height.equalTo(45)
        }

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 25)
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView).offset(5)
            make.trailing.equalTo(coverImageView).offset(-5)
            make.top.equalTo(coverImageView.snp.bottom).offset(10)
        }

        playCountIcon = UIImageView()
        playCountIcon.image = UIImage(named: "icon_play_count")
        shadowView.addSubview(playCountIcon)
        playCountIcon.snp.makeConstraints { make in
            make.leading.equalTo(shadowView).offset(10)
            make.centerY.equalTo(shadowView)
            make.width.height.equalTo(35)
        }

        playCountLabel = UILabel()
        playCountLabel.font = .systemFont(ofSize: 20)
        shadowView.addSubview(playCountLabel)
        playCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(playCountIcon.snp.trailing).offset(10)
            make.centerY.equalTo(playCountIcon)
        }

        danmakuCountIcon = UIImageView()
        danmakuCountIcon.image = UIImage(named: "icon_danmaku_count")
        shadowView.addSubview(danmakuCountIcon)
        danmakuCountIcon.snp.makeConstraints { make in
            make.leading.equalTo(playCountLabel.snp.trailing).offset(10)
            make.centerY.equalTo(playCountIcon)
            make.width.height.equalTo(35)
        }

        danmakuCountLabel = UILabel()
        danmakuCountLabel.font = .systemFont(ofSize: 20)
        shadowView.addSubview(danmakuCountLabel)
        danmakuCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(danmakuCountIcon.snp.trailing).offset(10)
            make.centerY.equalTo(danmakuCountIcon)
        }

        durationLabel = UILabel()
        durationLabel.font = .systemFont(ofSize: 20)
        shadowView.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { make in
            make.trailing.equalTo(shadowView).offset(-10)
            make.centerY.equalTo(playCountIcon)
        }

        uperIcon = UIImageView()
        uperIcon.image = UIImage(named: "icon_up")
        contentView.addSubview(uperIcon)
        uperIcon.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView).offset(5)
            make.bottom.equalTo(self)
        }

        recommendLabel = UILabel()
        recommendLabel.font = .boldSystemFont(ofSize: 18)
        recommendLabel.textAlignment = .center
        recommendLabel.backgroundColor = UIColor(hex: 0xFCF1E4)
        recommendLabel.layer.cornerRadius = 8
        recommendLabel.layer.masksToBounds = true
        recommendLabel.textColor = UIColor(hex: 0xEF863E)
        contentView.addSubview(recommendLabel)
        recommendLabel.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView).offset(5)
            make.centerY.equalTo(uperIcon)
            make.height.equalTo(35)
        }

        uperNameLabel = UILabel()
        uperNameLabel.textColor = UIColor(hex: 0xA0A4A9)
        uperNameLabel.font = .systemFont(ofSize: 20)
        contentView.addSubview(uperNameLabel)
        uperNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(uperIcon.snp.trailing).offset(10)
            make.centerY.equalTo(uperIcon)
            make.trailing.lessThanOrEqualTo(coverImageView).offset(-5)
        }
    }

    func install(with display: any DisplayData) {
        coverImageView.kf.setImage(with: display.pic)
        titleLabel.text = display.title
        uperNameLabel.text = display.ownerName
        uperIcon.clipsToBounds = true
        uperIcon.layer.cornerRadius = 17.5
        uperIcon.contentMode = .scaleAspectFill
        uperIcon.kf.setImage(with: display.avatar)
        uperIcon.snp.makeConstraints { make in
            make.width.height.equalTo(35)
        }

        if let playCount = (display as? DynamicFeedData)?.modules.module_dynamic.major?.archive?.stat?.play {
            playCountLabel.text = playCount
        }

        if let danmakuCount = (display as? DynamicFeedData)?.modules.module_dynamic.major?.archive?.stat?.danmaku {
            danmakuCountLabel.text = danmakuCount
        }
    }

    func update(with data: DisplayableData) {
        coverImageView.kf.setImage(with: URL(string: data.cover))
        titleLabel.text = data.title
        uperNameLabel.text = data.ownerName
        playCountLabel.text = data.viewCount
        danmakuCountLabel.text = data.danmakuCount
    }

    func update(with display: AnyDisplayableData) {
        if let areaLiveRoom = display.data as? AreaLiveRoom {
            coverImageView.kf.setImage(with: areaLiveRoom.pic)
            titleLabel.text = areaLiveRoom.title
            uperNameLabel.text = areaLiveRoom.ownerName
            if let watchedCount = areaLiveRoom.watched_show?.num {
                playCountLabel.text = "\(watchedCount.numberString())"
            }
            uperIcon.snp.makeConstraints { make in
                make.width.height.equalTo(35)
            }
            danmakuCountIcon.isHidden = true
            durationLabel.text = areaLiveRoom.area_name
            uperIcon.clipsToBounds = true
            uperIcon.layer.cornerRadius = 17.5
            uperIcon.contentMode = .scaleAspectFill
            uperIcon.kf.setImage(with: areaLiveRoom.face)
        } else if let liveRoom = display.data as? LiveRoom {
            coverImageView.kf.setImage(with: liveRoom.pic)
            titleLabel.text = liveRoom.title
            uperNameLabel.text = liveRoom.ownerName
            if let watchedCount = liveRoom.online {
                playCountLabel.text = "\(watchedCount.numberString())"
            }
            uperIcon.snp.makeConstraints { make in
                make.width.height.equalTo(35)
            }
            danmakuCountIcon.isHidden = true
            durationLabel.text = liveRoom.area_name
            uperIcon.clipsToBounds = true
            uperIcon.layer.cornerRadius = 17.5
            uperIcon.contentMode = .scaleAspectFill
            uperIcon.kf.setImage(with: liveRoom.face)
        } else if let season = display.data as? Season {
            coverImageView.kf.setImage(with: season.pic)
            titleLabel.text = season.title
            uperNameLabel.text = season.ownerName
            danmakuCountIcon.isHidden = true
        } else if let info = display.data as? VideoDetail.Info {
            update(with: info)
        } else if let feed = display.data as? FeedData {
            coverImageView.kf.setImage(with: feed.pic)
            titleLabel.text = feed.title
            playCountLabel.text = feed.stat?.playCountString
            danmakuCountLabel.text = feed.stat?.danmakuCountString
            durationLabel.text = feed.duration?.durationString
            recommendLabel.isHidden = true
            uperIcon.isHidden = false
            uperIcon.snp.makeConstraints { make in
                make.width.height.equalTo(35)
            }
            danmakuCountIcon.isHidden = feed.stat?.danmaku == nil
            playCountIcon.isHidden = feed.stat?.view == nil
            uperIcon.clipsToBounds = true
            uperIcon.layer.cornerRadius = 17.5
            uperIcon.contentMode = .scaleAspectFill
            uperIcon.kf.setImage(with: feed.avatar)

            uperNameLabel.snp.remakeConstraints { make in
                if uperIcon.isHidden {
                    make.leading.equalTo(recommendLabel.snp.trailing).offset(10)
                } else {
                    make.leading.equalTo(uperIcon.snp.trailing).offset(10)
                }
                make.centerY.equalTo(uperIcon)
                make.trailing.lessThanOrEqualTo(coverImageView).offset(-5)
            }
            uperNameLabel.text = feed.ownerName
        }
    }

    func update(with item: VideoDetail.Info) {
        coverImageView.kf.setImage(with: item.pic)
        titleLabel.text = item.title
        playCountLabel.text = item.stat.playCountString
        danmakuCountLabel.text = item.stat.danmakuCountString
        durationLabel.text = item.durationString

//        if let recommendString = item.rcmd_reason?.content, !recommendString.isEmpty {
//            uperIcon.isHidden = true
//            recommendLabel.isHidden = false
//            recommendLabel.text = "\(recommendString)   "
//        } else {
//            recommendLabel.isHidden = true
//            uperIcon.isHidden = false
//        }

        uperNameLabel.snp.remakeConstraints { make in
            if uperIcon.isHidden {
                make.leading.equalTo(recommendLabel.snp.trailing).offset(10)
            } else {
                make.leading.equalTo(uperIcon.snp.trailing).offset(10)
            }
            make.centerY.equalTo(uperIcon)
            make.trailing.lessThanOrEqualTo(coverImageView).offset(-5)
        }
        uperNameLabel.text = item.ownerName
    }

    func update(with item: ApiRequest.FeedResp.Items) {
        coverImageView.kf.setImage(with: item.pic)
        titleLabel.text = item.title
        if let playCountString = item.cover_left_text_1,
           let danmakuCountString = item.cover_left_text_2,
           let durationString = item.cover_right_text
        {
            playCountLabel.text = playCountString
            danmakuCountLabel.text = danmakuCountString
            durationLabel.text = durationString
        }

        if let recommendString = item.rcmd_reason {
            uperIcon.isHidden = true
            recommendLabel.isHidden = false
            recommendLabel.text = "\(recommendString)   "
        } else {
            recommendLabel.isHidden = true
            uperIcon.isHidden = false
        }

        uperNameLabel.snp.remakeConstraints { make in
            if uperIcon.isHidden {
                make.leading.equalTo(recommendLabel.snp.trailing).offset(10)
            } else {
                make.leading.equalTo(uperIcon.snp.trailing).offset(10)
            }
            make.centerY.equalTo(uperIcon)
            make.trailing.lessThanOrEqualTo(coverImageView).offset(-5)
        }

        if let desc = item.desc {
            uperNameLabel.text = desc
        } else {
            uperNameLabel.text = item.ownerName
        }
    }

    func update(with item: HistoryData) {
        coverImageView.kf.setImage(with: item.pic)
        titleLabel.text = item.title
        uperIcon.kf.setImage(with: item.avatar)
        uperNameLabel.text = item.ownerName
        durationLabel.text = item.duration.durationString
        playCountLabel.text = item.stat.playCountString
        danmakuCountLabel.text = item.stat.danmakuCountString
        uperIcon.snp.makeConstraints { make in
            make.width.height.equalTo(35)
        }
        uperIcon.clipsToBounds = true
        uperIcon.layer.cornerRadius = 17.5
        uperIcon.contentMode = .scaleAspectFill
    }

    func update(with item: ToViewData) {
        coverImageView.kf.setImage(with: item.pic)
        titleLabel.text = item.title
        uperIcon.kf.setImage(with: item.avatar)
        uperNameLabel.text = item.ownerName
//        durationLabel.text = item.duration.durationString
//        playCountLabel.text = item.stat.playCountString
//        danmakuCountLabel.text = item.stat.danmakuCountString
        uperIcon.snp.makeConstraints { make in
            make.width.height.equalTo(35)
        }
        uperIcon.clipsToBounds = true
        uperIcon.layer.cornerRadius = 17.5
        uperIcon.contentMode = .scaleAspectFill
    }

    func update(with item: UpSpaceListData) {
        coverImageView.kf.setImage(with: item.pic)
        titleLabel.text = item.title
        uperIcon.kf.setImage(with: item.cover)
        uperNameLabel.text = item.ownerName
        durationLabel.text = item.duration?.durationString
        playCountLabel.text = item.view_content
        danmakuCountLabel.text = item.danmaku?.numberString()
        uperIcon.snp.makeConstraints { make in
            make.width.height.equalTo(35)
        }
        uperIcon.clipsToBounds = true
        uperIcon.layer.cornerRadius = 17.5
        uperIcon.contentMode = .scaleAspectFill
    }

    func update(with item: Episode) {
        coverImageView.kf.setImage(with: item.cover)
        titleLabel.text = item.long_title
//        uperIcon.kf.setImage(with: item.cover)
//        uperNameLabel.text = item.long_title
//        durationLabel.text = item.duration?.durationString
//        playCountLabel.text = item.view_content
//        danmakuCountLabel.text = item.danmaku?.numberString()
        uperIcon.snp.makeConstraints { make in
            make.width.height.equalTo(35)
        }
        uperIcon.clipsToBounds = true
        uperIcon.layer.cornerRadius = 17.5
        uperIcon.contentMode = .scaleAspectFill
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self {
            coordinator.addCoordinatedAnimations({ () in
                self.coverImageView.layer.borderWidth = 10
                self.coverImageView.layer.borderColor = UIColor.white.cgColor
            }, completion: nil)
        } else if context.previouslyFocusedView == self {
            coordinator.addCoordinatedAnimations({ () in
                self.coverImageView.layer.borderWidth = 0
                self.coverImageView.layer.borderColor = UIColor.clear.cgColor
            }, completion: nil)
        }
    }

    override var canBecomeFocused: Bool {
        return true
    }
}
