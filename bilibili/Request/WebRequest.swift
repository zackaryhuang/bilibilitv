//
//  WebRequest.swift
//  BilibiliLive
//
//  Created by yicheng on 2021/4/29.
//

import Alamofire
import Foundation
import SwiftyJSON

enum RequestError: Error {
    case networkFail
    case statusFail(code: Int, message: String)
    case decodeFail(message: String)
}

enum WebRequest {
    static let Domain = "https://api.bilibili.com/"
    static let AppDomain = "https://app.bilibili.com/"
    enum EndPoint {
        static let Related = Domain + "x/web-interface/archive/related"
        static let Logout = "https://passport.bilibili.com/login/exit/v2"
        static let Info = Domain + "x/web-interface/view"
        static let Favorite = Domain + "x/v3/fav/resource/list"
        static let FavoriteList = Domain + "x/v3/fav/folder/created/list-all"
        static let ReportHistory = Domain + "/x/v2/history/report"
        static let UPerSpace = Domain + "x/space/arc/search"
        static let Like = Domain + "x/web-interface/archive/like"
        static let LikeStatus = Domain + "x/web-interface/archive/has/like"
        static let SendCoin = Domain + "x/web-interface/coin/add"
        static let CoinStatus = Domain + "x/web-interface/archive/coins"
        static let PlayerInfo = Domain + "x/player/v2"
        static let PlayUrl = Domain + "x/player/playurl"
        static let PGCPlayUrl = Domain + "pgc/player/web/playurl"
        static let AddCollection = Domain + "x/v3/fav/resource/deal" // 添加收藏
        static let CollectionStatus = Domain + "x/v2/fav/video/favoured" // 收藏状态
        static let Triple = Domain + "x/v2/view/like/triple" // 一键三连
        static let History = Domain + "x/v2/history" // 播放记录
        static let VideoDetail = Domain + "x/web-interface/view/detail" // 视频详情
        static let UPerSpaceVide = AppDomain + "x/v2/space/archive/cursor" // 获取 UP 主的视频
    }

    static func requestData(method: HTTPMethod = .get,
                            url: URLConvertible,
                            parameters: Parameters = [:],
                            headers: [String: String]? = nil,
                            complete: ((Result<Data, RequestError>) -> Void)? = nil)
    {
        var parameters = parameters
        if method != .get {
            parameters["biliCSRF"] = CookieHandler.shared.csrf()
            parameters["csrf"] = CookieHandler.shared.csrf()
        }

        var afheaders = HTTPHeaders()
        if let headers {
            for (k, v) in headers {
                afheaders.add(HTTPHeader(name: k, value: v))
            }
        }

        if !afheaders.contains(where: { $0.name == "User-Agent" }) {
            afheaders.add(.userAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Safari/605.1.15"))
        }

        if !afheaders.contains(where: { $0.name == "Referer" }) {
            afheaders.add(HTTPHeader(name: "Referer", value: "https://www.bilibili.com"))
        }

        AF.request(url,
                   method: method,
                   parameters: parameters,
                   encoding: URLEncoding.default,
                   headers: afheaders,
                   interceptor: nil)
            .responseData { response in
                switch response.result {
                case let .success(data):
                    complete?(.success(data))
                case let .failure(err):
                    print(err)
                    complete?(.failure(.networkFail))
                }
            }
    }

    static func requestJSON(method: HTTPMethod = .get,
                            url: URLConvertible,
                            parameters: Parameters = [:],
                            headers: [String: String]? = nil,
                            dataObj: String = "data",
                            complete: ((Result<JSON, RequestError>) -> Void)? = nil)
    {
        requestData(method: method, url: url, parameters: parameters, headers: headers) { response in
            switch response {
            case let .success(data):
                let json = JSON(data)
                let errorCode = json["code"].intValue
                if errorCode != 0 {
                    let message = json["message"].stringValue
                    print("😭\(errorCode), \(message)")
                    complete?(.failure(.statusFail(code: errorCode, message: message)))
                    return
                }
                let data = json[dataObj]
                print("😄\(url) response: \(json)")
                complete?(.success(data))
            case let .failure(err):
                complete?(.failure(err))
            }
        }
    }

    static func request<T: Decodable>(method: HTTPMethod = .get,
                                      url: URLConvertible,
                                      parameters: Parameters = [:],
                                      headers: [String: String]? = nil,
                                      decoder: JSONDecoder? = nil,
                                      dataObj: String = "data",
                                      complete: ((Result<T, RequestError>) -> Void)?)
    {
        requestJSON(method: method, url: url, parameters: parameters, headers: headers, dataObj: dataObj) { response in
            switch response {
            case let .success(data):
                do {
                    let data = try data.rawData()
                    let object = try (decoder ?? JSONDecoder()).decode(T.self, from: data)
                    complete?(.success(object))
                } catch let err {
                    print("decode fail:", err)
                    complete?(.failure(.decodeFail(message: err.localizedDescription + String(describing: err))))
                }
            case let .failure(err):
                complete?(.failure(err))
            }
        }
    }

    static func requestJSON(method: HTTPMethod = .get,
                            url: URLConvertible,
                            parameters: Parameters = [:],
                            headers: [String: String]? = nil) async throws -> JSON
    {
        return try await withCheckedThrowingContinuation { configure in
            requestJSON(method: method, url: url, parameters: parameters, headers: headers) { resp in
                configure.resume(with: resp)
            }
        }
    }

    static func request<T: Decodable>(method: HTTPMethod = .get,
                                      url: URLConvertible,
                                      parameters: Parameters = [:],
                                      headers: [String: String]? = nil,
                                      decoder: JSONDecoder? = nil,
                                      dataObj: String = "data") async throws -> T
    {
        return try await withCheckedThrowingContinuation { configure in
            request(method: method, url: url, parameters: parameters, headers: headers, decoder: decoder, dataObj: dataObj) {
                (res: Result<T, RequestError>) in
                switch res {
                case let .success(content):
                    configure.resume(returning: content)
                case let .failure(err):
                    configure.resume(throwing: err)
                }
            }
        }
    }
}

// MARK: - Video

extension WebRequest {
    static func requestFollowedBangumi(pageSize: Int, pageNum: Int) async throws -> BangumiInfo {
        let info: BangumiInfo = try await request(url: "http://api.bilibili.com/pgc/app/follow/v2/bangumi", parameters: ["ps": pageSize, "pn": pageNum, "status": 2], dataObj: "result")
        return info
    }

    static func requestSessionInfo(epid: Int) async throws -> BangumiInfo {
        let info: BangumiInfo = try await request(url: "http://api.bilibili.com/pgc/view/web/season", parameters: ["ep_id": epid], dataObj: "result")
        return info
    }

    static func requestSessionInfo(seasonID: Int) async throws -> BangumiSeasonInfo {
        let res: BangumiSeasonInfo = try await request(url: "https://api.bilibili.com/pgc/web/season/section", parameters: ["season_id": seasonID], dataObj: "result")
        return res
    }

    /// 请求最近播放历史纪录
    /// - Parameter complete: 完成回调
    static func requestHistory(complete: (([HistoryData]) -> Void)?) {
        request(url: WebRequest.EndPoint.History) {
            (result: Result<[HistoryData], RequestError>) in
            if let data = try? result.get() {
                complete?(data)
            }
        }
    }

    /// 请求前 20 条播放历史纪录
    /// - Parameter complete: 完成回调
    static func requestTopHistory(complete: (([HistoryData]) -> Void)?) {
        request(url: WebRequest.EndPoint.History, parameters: ["pn": 1, "ps": 20]) {
            (result: Result<[HistoryData], RequestError>) in
            if let data = try? result.get() {
                complete?(data)
            }
        }
    }

    static func requestPlayerInfo(aid: Int, cid: Int) async throws -> PlayerInfo {
        try await request(url: EndPoint.PlayerInfo, parameters: ["aid": aid, "cid": cid])
    }

    static func requestRelatedVideo(aid: Int, complete: (([VideoDetail.Info]) -> Void)? = nil) {
        request(method: .get, url: EndPoint.Related, parameters: ["aid": aid]) {
            (result: Result<[VideoDetail.Info], RequestError>) in
            if let details = try? result.get() {
                complete?(details)
            }
        }
    }

    static func requestDetailVideo(aid: Int) async throws -> VideoDetail {
        try await request(url: EndPoint.VideoDetail, parameters: ["aid": aid])
    }

    static func requestFavVideosList() async throws -> [FavListData] {
        guard let mid = ApiRequest.getToken()?.mid else { return [] }
        struct Resp: Codable {
            let list: [FavListData]
        }
        let res: Resp = try await request(method: .get, url: EndPoint.FavoriteList, parameters: ["up_mid": mid])
        return res.list
    }

    static func requestFavVideos(mid: String, page: Int) async throws -> [FavData] {
        struct Resp: Codable {
            let medias: [FavData]?
        }
        let res: Resp = try await request(method: .get, url: EndPoint.Favorite, parameters: ["media_id": mid, "ps": "20", "pn": page, "platform": "web"])
        return res.medias ?? []
    }

    static func ReportWatchHistory(aid: Int, cid: Int, currentTime: Int) {
        if !Settings.syncWatchHistory {
            return
        }
        requestJSON(method: .post,
                    url: EndPoint.ReportHistory,
                    parameters: ["aid": aid, "cid": cid, "progress": currentTime]) { response in
            switch response {
            case .success:
                if Settings.syncWatchHistory {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BiliBiliWatchHistoryChangedNotification"), object: nil)
                }
            case .failure:
                debugPrint("Warning: 上报观看历史失败")
            }
        }
    }

    static func RequestUPerSpaceVideos(mid: Int, page: Int, pageSize: Int = 50) async throws -> [UpSpaceReq.List.VListData] {
        let resp: UpSpaceReq = try await request(url: EndPoint.UPerSpace, parameters: ["mid": mid, "pn": page, "ps": pageSize])
        return resp.list.vlist
    }

    static func RequestUPerSpaceVideos(mid: Int, lastAid: Int?, pageSize: Int = 20) async throws -> [UpSpaceListData] {
        struct Resp: Codable {
            let item: [UpSpaceListData]
        }

        var param: Parameters = ["vmid": mid, "ps": pageSize, "actionKey": "appkey", "disable_rcmd": 0, "fnval": 976, "fnver": 0, "force_host": 0, "fourk": 1, "order": "pubdate", "player_net": 1, "qn": 120]
        if let lastAid {
            param["aid"] = lastAid
        }
        let resp: Resp = try await request(url: EndPoint.UPerSpaceVide, parameters: param)
        return resp.item
    }

    /// 点赞
    /// - Parameters:
    ///   - aid: 稿件 aid
    ///   - like: true 点赞，false 取消点赞
    /// - Returns: 完成回调
    static func RequestLike(aid: Int, like: Bool) async -> Bool {
        do {
            _ = try await requestJSON(method: .post, url: EndPoint.Like, parameters: ["aid": aid, "like": like ? "1" : "2"])
            return true
        } catch {
            return false
        }
    }

    /// 获取点赞状态
    /// - Parameters:
    ///   - aid: 稿件 aid
    ///   - complete: 完成回调
    static func RequestLikeStatus(aid: Int, completion: ((Bool) -> Void)?) {
        requestJSON(url: EndPoint.LikeStatus, parameters: ["aid": aid]) {
            response in
            switch response {
            case let .success(data):
                completion?(data.intValue == 1)
            case .failure:
                completion?(false)
            }
        }
    }

    /// 一键三连
    /// - Parameters:
    ///   - aid: 视频 aid
    ///   - completion: 完成回调
    static func RequestTriple(aid: Int, completion: ((Bool) -> Void)?) {
        requestJSON(method: .post, url: EndPoint.Triple, parameters: ["aid": aid], headers: ["content-type": "application/x-www-form-urlencoded"]) {
            response in
            switch response {
            case let .success(data):
                debugPrint("一键三连成功😄")
                completion?(data["like"].boolValue && data["coin"].boolValue && data["fav"].boolValue)
            case .failure:
                debugPrint("一键三连失败😭")
                completion?(false)
            }
        }
    }

    /// 投币
    /// - Parameters:
    ///   - aid: 稿件 ID
    ///   - num:  投币数量（上限为 2）
    ///   - thumbUp: 投币同时点赞
    static func RequestSendCoin(aid: Int, num: Int, thumbUp: Bool = false) {
        requestJSON(method: .post, url: EndPoint.SendCoin, parameters: ["aid": aid, "multiply": num, "select_like": thumbUp ? 1 : 0])
    }

    /// 获取投币状态
    /// - Parameters:
    ///   - aid: 稿件 aid
    ///   - complete: 完成回调，回调已投币数
    static func RequestGetCoinStatus(aid: Int, complete: ((Int) -> Void)?) {
        requestJSON(url: EndPoint.CoinStatus, parameters: ["aid": aid]) {
            response in
            switch response {
            case let .success(data):
                complete?(data["multiply"].intValue)
            case .failure:
                complete?(0)
            }
        }
    }

    static func requestTodayCoins(complete: ((Int) -> Void)?) {
        requestData(url: "http://www.bilibili.com/plus/account/exp.php") {
            response in
            switch response {
            case let .success(data):
                let json = JSON(data)
                complete?(json["number"].intValue)
            case .failure:
                complete?(0)
            }
        }
    }

    /// 收藏视频
    /// - Parameters:
    ///   - aid: 视频 aid
    ///   - mid: 需要加入的收藏夹 mlid
    static func RequestAddCollection(aid: Int, mid: Int) {
        requestJSON(method: .post, url: WebRequest.EndPoint.AddCollection, parameters: ["rid": aid, "type": 2, "add_media_ids": mid])
    }

    /// 获取视频收藏状态
    /// - Parameters:
    ///   - aid: 视频 aid
    ///   - complete: 完成回调
    static func RequestCollectionStatus(aid: Int, complete: ((Bool) -> Void)?) {
        requestJSON(url: WebRequest.EndPoint.CollectionStatus, parameters: ["aid": aid]) {
            response in
            switch response {
            case let .success(data):
                complete?(data["favoured"].boolValue)
            case .failure:
                complete?(false)
            }
        }
    }

    static func RequestPlayUrl(aid: Int, cid: Int) async throws -> VideoPlayURLInfo {
        let quality = Settings.mediaQuality
        return try await request(url: EndPoint.PlayUrl,
                                 parameters: ["avid": aid, "cid": cid, "qn": quality.qn, "type": "", "fnver": 0, "fnval": quality.fnval, "otype": "json"])
    }

    static func RequestPGCPlayUrl(aid: Int, cid: Int) async throws -> VideoPlayURLInfo {
        let quality = Settings.mediaQuality
        return try await request(url: EndPoint.PGCPlayUrl,
                                 parameters: ["avid": aid, "cid": cid, "qn": quality.qn, "support_multi_audio": true, "fnver": 0, "fnval": quality.fnval, "fourk": 1],
                                 dataObj: "result")
    }

    static func RequestReplies(aid: Int, complete: ((Replys) -> Void)?) {
        request(url: "http://api.bilibili.com/x/v2/reply", parameters: ["type": 1, "oid": aid, "sort": 1, "nohot": 0]) {
            (result: Result<Replys, RequestError>) in
            if let details = try? result.get() {
                complete?(details)
            }
        }
    }

    static func requestSearchResult(key: String, page: Int, complete: ((SearchResult) -> Void)?) {
        request(url: "http://api.bilibili.com/x/web-interface/search/type", parameters: ["search_type": "video", "keyword": key, "page": page]) {
            (result: Result<SearchResult, RequestError>) in
            if var details = try? result.get() {
                details.result.indices.forEach({ details.result[$0].title = details.result[$0].title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) })
                complete?(details)
            }
        }
    }

    static func requestSubtitle(url: URL) async throws -> [SubtitleContent] {
        struct SubtitlContenteResp: Codable {
            let body: [SubtitleContent]
        }
        let resp = try await AF.request(url).serializingDecodable(SubtitlContenteResp.self).value
        return resp.body
    }

    static func RequestCid(aid: Int) async throws -> Int {
        let res = try await requestJSON(url: "https://api.bilibili.com/x/player/pagelist?aid=\(aid)&jsonp=jsonp")
        let cid = res[0]["cid"].intValue
        return cid
    }

    static func requestFollowsFeed(offset: String, page: Int) async throws -> DynamicFeedInfo {
        var param: [String: Any] = ["type": "all", "timezone_offset": "-480", "page": page]
        if let offsetNum = Int(offset) {
            param["offset"] = offsetNum
        }
        let res: DynamicFeedInfo = try await request(url: "https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all", parameters: param)
        if res.videoFeeds.isEmpty, res.has_more {
            return try await requestFollowsFeed(offset: res.offset, page: page)
        }
        return res
    }
}

// MARK: - User

extension WebRequest {
    static func follow(mid: Int, follow: Bool) {
        requestJSON(method: .post, url: "https://api.bilibili.com/x/relation/modify", parameters: ["fid": mid, "act": follow ? 1 : 2, "re_src": 14])
    }

    static func logout(complete: (() -> Void)? = nil) {
        request(method: .post, url: EndPoint.Logout) {
            (result: Result<[String: String], RequestError>) in
            if let details = try? result.get() {
                print("logout success")
                print(details)
            } else {
                print("logout fail")
            }
            CookieHandler.shared.removeCookie()
            complete?()
        }
    }

    static func requestLoginInfo(complete: ((Result<JSON, RequestError>) -> Void)?) {
        requestJSON(url: "http://api.bilibili.com/x/web-interface/nav", complete: complete)
    }

    static func requestUserInfo() async throws -> UserInfoResp {
        let resp: UserInfoResp = try await request(url: "http://api.bilibili.com/x/web-interface/nav")
        return resp
    }

    static func requestUserInfo(mid: Int) async throws -> UperData {
        let resp: UperData = try await request(url: "https://api.bilibili.com/x/web-interface/card", parameters: ["mid": mid, "photo": true])
        return resp
    }
}

struct HistoryData: DisplayData, Codable {
    struct HistoryPage: Codable, Hashable {
        let cid: Int
    }

    let title: String
    var ownerName: String { owner.name }
    var avatar: URL? { URL(string: owner.face) }
    let pic: URL?

    let owner: VideoOwner
    let cid: Int?
    let aid: Int
    let progress: Int
    let duration: Int
    let stat: Stat
//    let bangumi: BangumiData?
}

struct FavData: DisplayData, Codable {
    var cover: String
    var upper: VideoOwner
    var id: Int
    var type: Int?
    var title: String
    var ogv: Ogv?
    var ownerName: String { upper.name }
    var pic: URL? { URL(string: cover) }

    struct Ogv: Codable, Hashable {
        let season_id: Int?
    }
}

class FavListData: Codable, Hashable {
    let title: String
    let id: Int
    var currentPage = 1
    var end = false
    var loading = false
    enum CodingKeys: String, CodingKey {
        case title, id
    }

    static func == (lhs: FavListData, rhs: FavListData) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    init(title: String, id: Int, currentPage: Int = 1) {
        self.title = title
        self.id = id
        self.currentPage = currentPage
    }
}

struct Stat: Codable, Hashable {
    let favorite: Int
    let coin: Int
    let like: Int
    let share: Int
    let danmaku: Int
    let view: Int
    let dislike: Int

    var playCountString: String {
        if view > 10000 {
            let format = NumberFormatter()
            format.numberStyle = .decimal
            format.minimumFractionDigits = 0 // 最少小数位
            format.maximumFractionDigits = 1 // 最多小数位
            format.formatterBehavior = .default
            format.roundingMode = .down // 小数位以截取方式。不同枚举的截取方式不同
            if let str = format.string(from: NSNumber(value: view / 10000)) {
                return "\(str)万"
            }
            return "\(view)"
        }
        return "\(view)"
    }

    var danmakuCountString: String {
        if danmaku > 10000 {
            let format = NumberFormatter()
            format.numberStyle = .decimal
            format.minimumFractionDigits = 0 // 最少小数位
            format.maximumFractionDigits = 1 // 最多小数位
            format.formatterBehavior = .default
            format.roundingMode = .down // 小数位以截取方式。不同枚举的截取方式不同
            if let str = format.string(from: NSNumber(value: danmaku / 10000)) {
                return "\(str)万"
            }
            return "\(danmaku)"
        }
        return "\(danmaku)"
    }
}

struct VideoDetail: Codable, Hashable {
    struct Info: Codable, Hashable {
        let aid: Int
        let cid: Int
        let title: String
        let videos: Int?
        let tname: String?
        let pic: URL?
        let desc: String?
        let owner: VideoOwner
        let pages: [VideoPage]?
        let dynamic: String?
        let bvid: String?
        let duration: Int
        let pubdate: Int?
        let ugc_season: UgcSeason?
        let redirect_url: URL?
        let stat: Stat
        let dimension: Dimension?
//        let rcmd_reason: RCMReason?
//
//        struct RCMReason: Codable, Hashable {
//            let content: String?
//        }

        struct UgcSeason: Codable, Hashable {
            let id: Int
            let title: String
            let cover: URL
            let mid: Int
            let intro: String
            let attribute: Int
            let sections: [UgcSeasonDetail]

            struct UgcSeasonDetail: Codable, Hashable {
                let season_id: Int
                let id: Int
                let title: String
                let episodes: [UgcVideoInfo]
            }

            struct UgcVideoInfo: Codable, Hashable, DisplayData {
                var ownerName: String { "" }
                var pic: URL? { arc.pic }
                let aid: Int
                let cid: Int
                let arc: Arc
                let title: String

                struct Arc: Codable, Hashable {
                    let pic: URL
                }
            }
        }

        struct Dimension: Codable, Hashable {
            let width: Int
            let height: Int
            let rotate: Int?
        }

        var durationString: String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .brief
            return formatter.string(from: TimeInterval(duration)) ?? ""
        }
    }

    struct Owner: Hashable, Codable {
        let following: Bool
        let follower: Int?
    }

    let View: Info
    let Related: [Info]
    let Card: Owner
}

extension VideoDetail: DisplayData {
    var title: String { View.title }
    var ownerName: String { View.owner.name }
    var pic: URL? { View.pic }
    var avatar: URL? { URL(string: View.owner.face) }
    var date: String? { DateFormatter.stringFor(timestamp: View.pubdate) }
}

extension VideoDetail.Info: DisplayData, PlayableData {
    var ownerName: String { owner.name }
    var avatar: URL? { URL(string: owner.face) }
    var date: String? { DateFormatter.stringFor(timestamp: pubdate) }
}

struct SubtitleResp: Codable {
    let subtitles: [SubtitleData]
}

struct SubtitleData: Codable, Hashable {
    let lan_doc: String
    let subtitle_url: URL
    let lan: String

    var url: URL { subtitle_url.addSchemeIfNeed() }
    var subtitleContents: [SubtitleContent]?
}

struct Replys: Codable, Hashable {
    struct Reply: Codable, Hashable {
        struct Member: Codable, Hashable {
            let uname: String
            let avatar: String
        }

        struct Content: Codable, Hashable {
            let message: String
        }

        let member: Member
        let content: Content
    }

    let replies: [Reply]?
}

struct BangumiSeasonInfo: Codable {
    let main_section: BangumiInfo?
    let section: [BangumiInfo]
}

struct Episode: Codable, Hashable {
    let id: Int
    let aid: Int
    let cid: Int
    let cover: URL
    let long_title: String
    let title: String
}

struct BangumiInfo: Codable, Hashable {
    let episodes: [Episode] // 正片剧集列表
}

struct VideoOwner: Codable, Hashable {
    let mid: Int
    let name: String
    let face: String
}

struct VideoPage: Codable, Hashable {
    let cid: Int
    let page: Int
    let from: String
    let part: String
}

struct UpSpaceListData: Codable, Hashable, DisplayData, PlayableData {
    var pic: URL? { return cover }

    var aid: Int { return Int(param) ?? 0 }

    let title: String
    let author: String
    let param: String
    let cover: URL?
    let duration: Int?
    let view_content: String?
    let danmaku: Int?
    var ownerName: String {
        return author
    }

    var cid: Int { return 0 }
}

struct UperData: Codable, Hashable {
    let space: UperSpace?
    let isFollowing: Bool
    let fansCount: Int?
    let archiveCount: Int?
    let likeCount: Int?
    let card: SpaceCard?

    enum CodingKeys: String, CodingKey {
        case isFollowing = "following"
        case space
        case fansCount = "follower"
        case archiveCount = "archive_count"
        case card
        case likeCount = "like_num"
    }

    struct UperSpace: Codable, Hashable {
        let banner: String
        var bannerURL: URL? { URL(string: banner) ?? nil }
        enum CodingKeys: String, CodingKey {
            case banner = "l_img"
        }
    }

    struct SpaceCard: Codable, Hashable {
        let face: String?
        var faceURL: URL? { (face != nil) ? URL(string: face!) : nil }
        let sex: String?
        let sign: String?
        let name: String?
        let levelInfo: LevelInfoData?
        let official: Official?

        enum CodingKeys: String, CodingKey {
            case levelInfo = "level_info"
            case face
            case sex
            case sign
            case official = "Official"
            case name
        }

        struct Official: Codable, Hashable {
            let title: String?
        }
    }
}

struct UpSpaceReq: Codable, Hashable {
    let list: List
    struct List: Codable, Hashable {
        let vlist: [VListData]
        struct VListData: Codable, Hashable, DisplayData, PlayableData {
            let title: String
            let author: String
            let aid: Int
            let pic: URL?
            var ownerName: String {
                return author
            }

            var cid: Int { return 0 }
        }
    }
}

struct PlayerInfo: Codable {
    let last_play_time: Int
    let subtitle: SubtitleResp?
    let view_points: [ViewPoint]?
    let dm_mask: MaskInfo?
    let last_play_cid: Int
    var playTimeInSecond: Int {
        last_play_time / 1000
    }

    struct ViewPoint: Codable {
        let type: Int
        let from: TimeInterval
        let to: TimeInterval
        let content: String
        let imgUrl: URL?
    }

    struct MaskInfo: Codable {
        let mask_url: URL?
        let fps: Int
    }
}

struct UserInfoResp: Codable {
    let coinBalance: Int?
    let userName: String?
    let vipInfo: VipInfoData?
    let levelInfo: LevelInfoData?
    let walletInfo: WalletInfoData?
    let avatarUrl: String?
    let vipType: Int?
    let vipStatus: Int?
    var isBigVip: Bool { vipType == 2 && vipStatus == 1 }

    enum CodingKeys: String, CodingKey {
        case coinBalance = "money"
        case userName = "uname"
        case vipInfo = "vip_label"
        case levelInfo = "level_info"
        case walletInfo = "wallet"
        case avatarUrl = "face"
        case vipType
        case vipStatus
    }

    struct VipInfoData: Codable {
        let vipString: String?
        let imageUrl: String?

        enum CodingKeys: String, CodingKey {
            case vipString = "text"
            case imageUrl = "img_label_uri_hans_static"
        }
    }

    struct WalletInfoData: Codable {
        let BCoinBalance: Int?

        enum CodingKeys: String, CodingKey {
            case BCoinBalance = "bcoin_balance"
        }
    }
}

struct LevelInfoData: Codable, Hashable {
    let nextLevelExp: Int?
    let currentLevel: Int?
    let currentExp: Int?
    let currentLevelExpMin: Int?

    enum CodingKeys: String, CodingKey {
        case nextLevelExp = "next_exp"
        case currentLevel = "current_level"
        case currentExp = "current_exp"
        case currentLevelExpMin = "current_min"
    }
}

struct VideoPlayURLInfo: Codable {
    let quality: Int
    let format: String
    let timelength: Int
    let accept_format: String
    let accept_description: [String]
    let accept_quality: [Int]
    let video_codecid: Int
    let support_formats: [SupportFormate]
    let dash: DashInfo
    let clip_info_list: [ClipInfo]?

    class ClipInfo: Codable {
        let start: CGFloat
        let end: CGFloat
        let clipType: String?
        let toastText: String?
        var a11Tag: String {
            "\(start)\(end)"
        }

        var skipped: Bool? = false

        var customText: String {
            if clipType == "CLIP_TYPE_OP" {
                return "跳过片头"
            } else if clipType == "CLIP_TYPE_ED" {
                return "跳过片尾"
            } else {
                return toastText ?? "跳过"
            }
        }

        init(start: CGFloat, end: CGFloat, clipType: String?, toastText: String?) {
            self.start = start
            self.end = end
            self.clipType = clipType
            self.toastText = toastText
        }
    }

    struct SupportFormate: Codable {
        let quality: Int
        let format: String
        let new_description: String
        let display_desc: String
        let codecs: [String]
    }

    struct DashInfo: Codable {
        let duration: Int
        let minBufferTime: CGFloat
        let video: [DashMediaInfo]
        let audio: [DashMediaInfo]?
        let dolby: DolbyInfo?
        let flac: FlacInfo?
        struct DashMediaInfo: Codable, Hashable {
            let id: Int
            let base_url: String
            let backup_url: [String]?
            let bandwidth: Int
            let mime_type: String
            let codecs: String
            let width: Int?
            let height: Int?
            let frame_rate: String?
            let sar: String?
            let start_with_sap: Int?
            let segment_base: DashSegmentBase
            let codecid: Int?
        }

        struct DashSegmentBase: Codable, Hashable {
            let initialization: String
            let index_range: String
        }

        struct DolbyInfo: Codable {
            let type: Int
            let audio: [DashMediaInfo]?
        }

        struct FlacInfo: Codable {
            let display: Bool
            let audio: DashMediaInfo?
        }
    }
}

struct SearchResult: Codable, Hashable {
    struct Result: Codable, Hashable, DisplayData {
        let author: String
        let upic: URL
        let aid: Int

        // DisplayData
        var title: String
        var ownerName: String { author }
        let pic: URL?
        var avatar: URL? { upic }
    }

    var result: [Result]
}

struct SubtitleContent: Codable, Hashable {
    let from: CGFloat
    let to: CGFloat
    let location: Int
    let content: String
}

extension URL {
    func addSchemeIfNeed() -> URL {
        if scheme == nil {
            return URL(string: "https:\(absoluteString)")!
        }
        return self
    }
}
