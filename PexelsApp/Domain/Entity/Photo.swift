import Foundation

public struct Photo: Codable, Identifiable, Equatable {
    public let id: Int
    public let width: Int
    public let height: Int
    public let aspectRatio: CGFloat
    public let photographerName: String
    public let photographerURL: URL
    public let avgColorHex: String?
    public let urls: URLs
    public let alt: String
    public let liked: Bool

    public struct URLs: Codable, Equatable {
        public let original: URL
        public let large: URL
        public let large2x: URL
        public let medium: URL
        public let small: URL
        public let portrait: URL
        public let landscape: URL
        public let tiny: URL
    }

    public init(id: Int, width: Int, height: Int, aspectRatio: CGFloat, photographerName: String, photographerURL: URL, avgColorHex: String?, urls: URLs, alt: String, liked: Bool) {
        self.id = id
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.photographerName = photographerName
        self.photographerURL = photographerURL
        self.avgColorHex = avgColorHex
        self.urls = urls
        self.alt = alt
        self.liked = liked
    }
}
