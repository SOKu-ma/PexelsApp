import Foundation

// 検索レスポンス全体
struct SearchPhotosResponseDTO: Decodable {
    let page: Int
    let perPage: Int
    let photos: [PhotoDTO]
    let totalResults: Int
    let nextPage: URL?

    private enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case photos
        case totalResults = "total_results"
        case nextPage = "next_page"
    }
}

// 個々の写真
struct PhotoDTO: Decodable {
    let id: Int
    let width: Int
    let height: Int
    let url: URL
    let photographer: String
    let photographerURL: URL
    let photographerID: Int
    let avgColorHex: String?
    let src: SrcDTO
    let liked: Bool
    let alt: String

    private enum CodingKeys: String, CodingKey {
        case id, width, height, url, photographer, src, liked, alt
        case photographerURL = "photographer_url"
        case photographerID = "photographer_id"
        case avgColorHex = "avg_color"
    }
}

// 各サイズの画像URL
struct SrcDTO: Decodable {
    let original: URL
    let large2x: URL
    let large: URL
    let medium: URL
    let small: URL
    let portrait: URL
    let landscape: URL
    let tiny: URL
}
