//
//  UpSpaceViewController.swift
//  BilibiliLive
//
//  Created by yicheng on 2022/10/20.
//

import Foundation
import UIKit

class UpSpaceViewController: StandardVideoCollectionViewController<UpSpaceListData> {
    var mid: Int!

    private var lastAid: Int?

    override func request(page: Int) async throws -> [UpSpaceListData] {
        let res = try await WebRequest.requestUpSpaceVideo(mid: mid, lastAid: lastAid, pageSize: 20)
        lastAid = res.last?.aid
        return res
    }
}
