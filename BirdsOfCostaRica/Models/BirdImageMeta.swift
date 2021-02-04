import Foundation

struct ImageMeta: Codable {
    let filename: String
    let info: ImageInfo
}

struct ImageInfo: Codable {
    let timestamp: String
    let user: String
    let size: Int
    let width: Int
    let height: Int
    let comment: String
    let thumburl: String
    let thumbwidth: Int
    let thumbheight: Int
    let url: String
    let descriptionurl: String
    let descriptionshorturl: String
    let mime: String

    /// seems to return one or other
    let responsiveUrls: [String: String]?
    let duration: TimeInterval?
}
