//
//  SettingsViewController.swift
//  bilibili
//
//  Created by Zackary on 2023/11/25.
//

import UIKit

struct CellModel {
    let title: String
    let options: [SettingOptions]
}

struct SettingOptions {
    let title: String
    var checkSelected: () -> Bool
    var action: (() -> Void)? = nil
}

class SettingViewController: UIViewController {
    var collectionView: UICollectionView!
    var cellModels = [CellModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setupData()
    }

    private func configUI() {
        let label = UILabel()
        label.text = "设置"
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

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: 300, height: 60)
        flowLayout.headerReferenceSize = CGSizeMake(view.frame.size.width, 90)

        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.remembersLastFocusedIndexPath = true
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        collectionView.register(SettingCell.self,
                                forCellWithReuseIdentifier: NSStringFromClass(SettingCell.self))
        collectionView.register(SettingSectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: NSStringFromClass(SettingSectionHeader.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.equalTo(line)
            make.trailing.equalTo(line)
            make.top.equalTo(line.snp.bottom).offset(20)
            make.bottom.equalTo(view)
        }
    }

    func setupData() {
        cellModels.removeAll()

        // 直接播放视频
        let option_1 = SettingOptions(title: "开", checkSelected: {
            Settings.playVideoDirectly == true
        }) { [weak self] in
            Settings.playVideoDirectly = true
            self?.collectionView.reloadData()
        }
        let option_2 = SettingOptions(title: "关", checkSelected: {
            Settings.playVideoDirectly == false
        }) { [weak self] in
            Settings.playVideoDirectly = false
            self?.collectionView.reloadData()
        }

        let playVideoDirectly = CellModel(title: "直接播放视频", options: [option_1, option_2])
        cellModels.append(playVideoDirectly)

        // 弹幕显示区域
        var options = [SettingOptions]()
        for style in DanmuArea.allCases {
            let option = SettingOptions(title: style.title) {
                Settings.danmuArea == style
            } action: { [weak self] in
                Settings.danmuArea = style
                self?.collectionView.reloadData()
            }
            options.append(option)
        }
        let danmuArea = CellModel(title: "弹幕显示区域", options: options)
        cellModels.append(danmuArea)

//        // 时间线显示模式
//        options.removeAll()
//        for style in FeedDisplayStyle.allCases.filter({ !$0.hideInSetting }) {
//            let option = SettingOptions(title: style.desp) {
//                Settings.displayStyle == style
//            } action: { [weak self] in
//                Settings.displayStyle = style
//                self?.collectionView.reloadData()
//            }
//            options.append(option)
//        }
//        let displayStyle = CellModel(title: "时间线显示模式", options: options)
//        cellModels.append(displayStyle)

        // 继续播放
        let option_3 = SettingOptions(title: "开", checkSelected: {
            Settings.continuePlay == true
        }) { [weak self] in
            Settings.continuePlay = true
            self?.collectionView.reloadData()
        }
        let option_4 = SettingOptions(title: "关", checkSelected: {
            Settings.continuePlay == false
        }) { [weak self] in
            Settings.continuePlay = false
            self?.collectionView.reloadData()
        }

        let continuePlay = CellModel(title: "继续播放", options: [option_3, option_4])
        cellModels.append(continuePlay)

        // 自动跳过片头
        let option_5 = SettingOptions(title: "开", checkSelected: {
            Settings.autoSkip == true
        }) { [weak self] in
            Settings.autoSkip = true
            self?.collectionView.reloadData()
        }
        let option_6 = SettingOptions(title: "关", checkSelected: {
            Settings.autoSkip == false
        }) { [weak self] in
            Settings.autoSkip = false
            self?.collectionView.reloadData()
        }
        let autoSkip = CellModel(title: "自动跳过片头", options: [option_5, option_6])
        cellModels.append(autoSkip)

        // 最高画质
        options.removeAll()
        for style in MediaQualityEnum.allCases {
            let option = SettingOptions(title: style.desp) {
                Settings.mediaQuality == style
            } action: { [weak self] in
                Settings.mediaQuality = style
                self?.collectionView.reloadData()
            }
            options.append(option)
        }
        let mediaQuality = CellModel(title: "最高画质", options: options)
        cellModels.append(mediaQuality)

        // 无损和杜比全景声 losslessAudio
        let option_7 = SettingOptions(title: "开", checkSelected: {
            Settings.losslessAudio == true
        }) { [weak self] in
            Settings.losslessAudio = true
            self?.collectionView.reloadData()
        }
        let option_8 = SettingOptions(title: "关", checkSelected: {
            Settings.losslessAudio == false
        }) { [weak self] in
            Settings.losslessAudio = false
            self?.collectionView.reloadData()
        }
        let losslessAudio = CellModel(title: "无损和杜比全景声", options: [option_7, option_8])
        cellModels.append(losslessAudio)

        // 连续播放 continouslyPlay
        let option_9 = SettingOptions(title: "开", checkSelected: {
            Settings.continouslyPlay == true
        }) { [weak self] in
            Settings.continouslyPlay = true
            self?.collectionView.reloadData()
        }
        let option_10 = SettingOptions(title: "关", checkSelected: {
            Settings.continouslyPlay == false
        }) { [weak self] in
            Settings.continouslyPlay = false
            self?.collectionView.reloadData()
        }
        let continouslyPlay = CellModel(title: "连续播放", options: [option_9, option_10])
        cellModels.append(continouslyPlay)

        // 弹幕大小 danmuSize
        options.removeAll()
        for style in DanmuSize.allCases {
            let option = SettingOptions(title: style.title) {
                Settings.danmuSize == style
            } action: { [weak self] in
                Settings.danmuSize = style
                self?.collectionView.reloadData()
            }
            options.append(option)
        }
        let danmuSize = CellModel(title: "弹幕大小", options: options)
        cellModels.append(danmuSize)

        // 智能防挡弹幕 danmuMask
        let option_11 = SettingOptions(title: "开", checkSelected: {
            Settings.danmuMask == true
        }) { [weak self] in
            Settings.danmuMask = true
            self?.collectionView.reloadData()
        }
        let option_12 = SettingOptions(title: "关", checkSelected: {
            Settings.danmuMask == false
        }) { [weak self] in
            Settings.danmuMask = false
            self?.collectionView.reloadData()
        }
        let danmuMask = CellModel(title: "智能防挡弹幕", options: [option_11, option_12])
        cellModels.append(danmuMask)

        // 按需本地运算智能防档弹幕(Exp) vnMask
        let option_13 = SettingOptions(title: "开", checkSelected: {
            Settings.vnMask == true
        }) { [weak self] in
            Settings.vnMask = true
            self?.collectionView.reloadData()
        }
        let option_14 = SettingOptions(title: "关", checkSelected: {
            Settings.vnMask == false
        }) { [weak self] in
            Settings.vnMask = false
            self?.collectionView.reloadData()
        }
        let vnMask = CellModel(title: "按需本地运算智能防档弹幕(Exp)", options: [option_13, option_14])
        cellModels.append(vnMask)

        // 匹配视频内容 contentMatch
        let option_15 = SettingOptions(title: "开", checkSelected: {
            Settings.contentMatch == true
        }) { [weak self] in
            Settings.contentMatch = true
            self?.collectionView.reloadData()
        }
        let option_16 = SettingOptions(title: "关", checkSelected: {
            Settings.contentMatch == false
        }) { [weak self] in
            Settings.contentMatch = false
            self?.collectionView.reloadData()
        }
        let contentMatch = CellModel(title: "匹配视频内容", options: [option_15, option_16])
        cellModels.append(contentMatch)

        collectionView.reloadData()
    }
}

extension SettingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cellModels.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cellModel = cellModels[section]
        return cellModel.options.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(SettingCell.self), for: indexPath)

        if let optionCell = cell as? SettingCell {
            let cellModel = cellModels[indexPath.section]
            let item = cellModel.options[indexPath.row]
            optionCell.update(with: item)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(SettingSectionHeader.self), for: indexPath)
        if let sectionView = view as? SettingSectionHeader {
            let cellModel = cellModels[indexPath.section]
            sectionView.update(with: cellModel.title)
        }
        return view
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellModel = cellModels[indexPath.section]
        let option = cellModel.options[indexPath.row]
        option.action?()
    }

    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
