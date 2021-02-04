import Foundation
import Commons

let birdGroups: [BirdGroup] = load(name: "bird-groups")
let birdGroupsImageInfo: [ImageMeta] = load(name: "bird-groups-image-meta")
let birdDetails: [BirdDetails] = load(name: "bird-details")
let imageInfo: [ImageMeta] = load(name: "image-meta")

func load<T: Codable>(name: String, as: T.Type = T.self) -> T {
    let filePath  = Bundle.main.path(
        forResource: name,
        ofType: "json"
    )!
    let data = NSData(contentsOfFile: filePath)!
    return try! T(jsonData: .init(data))
}
