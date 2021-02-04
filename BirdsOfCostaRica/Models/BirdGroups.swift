import Foundation

struct BirdGroup: Codable {
    struct Order: Codable {
        let name: String
        let link: String
    }
    struct Family: Codable {
        let name: String
        let link: String
    }

    struct Bird: Codable {
        enum Tag: String, Codable, CaseIterable {
            // (A) Accidental - a species that rarely or accidentally occurs in Costa Rica
            case accidental
            // (R?) Residence uncertain - a species which might be resident
            case residenceUncertain
            // (E) Endemic - a species endemic to Costa Rica
            case endemic
            // (E-R) Regional endemic - a species found only in Costa Rica and Panama
            case regionalEndemic
            // (I) Introduced - a species introduced to Costa Rica as a consequence, direct or indirect, of human actions
            case introduced

            static let map: [String: Tag] = [
                "(A)": .accidental,
                "(R?)": .residenceUncertain,
                "(E)": .endemic,
                "(E-R)": .regionalEndemic,
                "(I)": .introduced
            ]
            static let matching = map.map { (suffix: $0.key, tag: $0.value) }

            init?(displayedHTML: String) {
                guard let matched = Tag.matching.first(where: { displayedHTML.hasSuffix($0.suffix) }) else {
                    return nil
                }
                self = matched.tag
            }
        }

        let name: String
        let link: String
        let latin: String
        let tag: Tag?
    }

    struct File: Codable {
        struct Image: Codable {
            let src: String
            let srcset: String
            let width: String
            let height: String
            let dataFileWidth: String
            let dataFileHeight: String
        }

        let filename: String
        let title: String
//        let img: Image
    }

    let category: String
    let order: Order
    let family: Family
    let summary: String
    let summaryHTML: String
    let images: [File]
    let birds: [Bird]
}

extension BirdGroup.Bird {
    var title: String {
        name.components(separatedBy: " ").joined(separator: "_")
    }
}
