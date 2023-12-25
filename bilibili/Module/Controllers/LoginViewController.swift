//
//  LoginViewController.swift
//  BilibiliLive
//
//  Created by Etan Chen on 2021/3/28.
//

import Alamofire
import Foundation
import Lottie
import SwiftyJSON
import UIKit

class LoginViewController: UIViewController {
    var QRCodeImageView: UIImageView!
    var refreshButton: UIButton!
    var lottieAnimationView: LottieAnimationView!
    var currentLevel: Int = 0, finalLevel: Int = 200
    var timer: Timer?
    var authKey: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        BLTabBarViewController.clearSelected()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configUI()
        requestQRCode()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        invalidateTimer()
    }

    private func configUI() {
        let sepLine = UIView()
        sepLine.backgroundColor = .gray
        view.addSubview(sepLine)
        sepLine.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(1)
            make.top.equalTo(view).offset(100)
            make.bottom.equalTo(view).offset(-100)
        }

        let leftContainer = UIView()
        view.addSubview(leftContainer)
        leftContainer.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(view)
            make.trailing.equalTo(sepLine.snp.leading)
        }

        QRCodeImageView = UIImageView()
        leftContainer.addSubview(QRCodeImageView)
        QRCodeImageView.snp.makeConstraints { make in
            make.width.height.equalTo(500)
            make.centerX.equalTo(leftContainer)
            make.centerY.equalTo(leftContainer)
        }

        let rightContainer = UIView()
        view.addSubview(rightContainer)
        rightContainer.snp.makeConstraints { make in
            make.trailing.top.bottom.equalTo(view)
            make.leading.equalTo(sepLine.snp.trailing)
        }

        let tipsLabel = UILabel()
        tipsLabel.textAlignment = .center
        tipsLabel.numberOfLines = 1
        let attributedString = NSMutableAttributedString(string: "使用手机登录", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 40),
            .foregroundColor: UIColor.white,
        ])

        attributedString.append(NSAttributedString(string: "哔哩哔哩", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 40),
            .foregroundColor: UIColor.biliPink,
        ]))

        attributedString.append(NSAttributedString(string: "扫描二维码登录", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 40),
            .foregroundColor: UIColor.white,
        ]))

        tipsLabel.attributedText = attributedString
        rightContainer.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.leading.equalTo(rightContainer).offset(100)
            make.trailing.equalTo(rightContainer).offset(-100)
            make.top.equalTo(QRCodeImageView)
        }

        let subTipsLabel = UILabel()
        subTipsLabel.textAlignment = .center
        subTipsLabel.numberOfLines = 1
        subTipsLabel.textColor = .white
        subTipsLabel.font = .systemFont(ofSize: 25)
        subTipsLabel.text = "你不会还没有安装哔哩哔哩吧？快去 App Store 下载吧！"
        rightContainer.addSubview(subTipsLabel)
        subTipsLabel.snp.makeConstraints { make in
            make.top.equalTo(tipsLabel.snp.bottom).offset(30)
            make.centerX.equalTo(tipsLabel)
        }

        lottieAnimationView = LottieAnimationView(name: "coin")
        lottieAnimationView.loopMode = .loop
        lottieAnimationView.play()
        rightContainer.addSubview(lottieAnimationView)
        lottieAnimationView.snp.makeConstraints { make in
            make.width.height.equalTo(500)
            make.top.equalTo(subTipsLabel.snp.bottom)
            make.centerX.equalTo(rightContainer)
        }

        refreshButton = UIButton(type: .roundedRect)
        refreshButton.isHidden = true
        refreshButton.addTarget(self, action: #selector(onRefreshButtonClick), for: .primaryActionTriggered)
        refreshButton.setTitle("重新获取二维码", for: .normal)
        leftContainer.addSubview(refreshButton)
        refreshButton.snp.makeConstraints { make in
            make.top.equalTo(QRCodeImageView.snp.bottom).offset(40)
            make.centerX.equalTo(QRCodeImageView)
        }
    }

    func requestQRCode() {
        timer?.invalidate()
        ApiRequest.requestLoginQR { [weak self] code, url in
            guard let self else { return }
            let image = Tools.generateQRCode(from: url)
            self.QRCodeImageView.image = image
            self.refreshButton.isHidden = true
            self.authKey = code
            self.startValidationTimer()
        }
    }

    func startValidationTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentLevel += 1
            if self.currentLevel > self.finalLevel {
                self.invalidateTimer()
            }
            if self.currentLevel == 45 {
                // 3 分钟后默认失效，可以刷新二维码
                self.refreshButton.isHidden = false
            }
            self.queryLoginStatus()
        }
    }

    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    func didValidationSuccess() {
        AppDelegate.shared.showMainView()
    }

    @objc func onRefreshButtonClick() {
        debugPrint("aaaa")
        requestQRCode()
    }

    func queryLoginStatus() {
        ApiRequest.verifyLoginQR(code: authKey) {
            [weak self] state in
            guard let self = self else { return }
            switch state {
            case .expire:
                self.invalidateTimer()
                self.refreshButton.isHidden = false
            case .waiting:
                break
            case let .success(token):
                print(token)
                UserDefaults.standard.set(codable: token, forKey: "token")
                self.didValidationSuccess()
            case .fail:
                break
            }
        }
    }
}
