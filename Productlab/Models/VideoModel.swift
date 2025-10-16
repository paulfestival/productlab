//
//  Video.swift
//  Productlab
//
//  Created by Pavel Mac on 10/14/25.
//

import Foundation

struct VideoResponse: Decodable {
    let total: Int
    let offset: Int
    let limit: Int
    let count: Int
    let filter: Filter?
    let items: [Video]
    
    struct Filter: Decodable {
        let search: String?
        let video_id: Int?
        let category: String?
        let channel_id: Int?
        let user_id: Int?
        let is_free: Bool?
        let auth_required: Bool?
        let date_period: String?
        let date_filter_type: String?
        let sort_by: String?
        let sort_order: String?
    }
}

struct Video: Identifiable, Decodable {
    let id: Int
    let title: String
    let previewImage: String
    let postImage: String?
    let channelId: Int
    let channelName: String
    let channelAvatar: String
    let views: Int
    let duration: Int
    let free: Bool
    let vertical: Bool
    let seoUrl: String
    let date: Date
    let draft: Bool
    let timeNotReg: Int?
    let timeNotPay: Int?
    let hasAccess: Bool
    let contentType: String
    let latitude: Double?
    let longitude: Double?
    let location: String?

    enum CodingKeys: String, CodingKey {
        case id = "video_id"
        case title
        case previewImage = "preview_image"
        case postImage = "post_image"
        case channelId = "channel_id"
        case channelName = "channel_name"
        case channelAvatar = "channel_avatar"
        case views = "numbers_views"
        case duration = "duration_sec"
        case free, vertical
        case seoUrl = "seo_url"
        case date = "date_publication"
        case draft
        case timeNotReg = "time_not_reg"
        case timeNotPay = "time_not_pay"
        case hasAccess = "has_access"
        case contentType = "content_type"
        case latitude, longitude
        case location = "location_text"
    }
}
