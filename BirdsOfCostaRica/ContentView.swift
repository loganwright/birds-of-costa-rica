//
//  ContentView.swift
//  BirdsOfCostaRica
//
//  Created by Logan Wright on 2/4/21.
//

import SwiftUI
import Endpoints

let cache = NSCache<NSString, UIImage>()

struct AsyncImage: View {
    let imageUrl: String
    @State private var result: Result<UIImage, Error>? = nil
    init(imageUrl: String) {
        self.imageUrl = imageUrl
    }

    var body: some View {
        if let image = result?.value {
            Image(uiImage: image).resizable().scaledToFit()
        } else if let error = result?.error {
            Text(error.display)
        } else {
            Text("loading...")
                .onAppear(perform: load)
        }
    }

    private func load() {
        if let existing = cache.object(forKey: imageUrl as NSString) {
            self.result = .success(existing)
        } else {
            Base(imageUrl).get
                .on.success { resp in
                    guard let data = resp.body else {
                        self.result = .failure("missing body")
                        return
                    }
                    guard let img = UIImage(data: data) else {
                        self.result = .failure("unable to make image from data")
                        return
                    }
                    cache.setObject(img, forKey: imageUrl as NSString)
                    self.result = .success(img)
                }
                .on.error {
                    self.result = .failure($0)
                }
                .send()
        }
    }
}

extension BirdGroup.Bird {
    var details: BirdDetails? {
        birdDetails.first { $0.birdTitle == title }
    }
}

extension BirdGroup.Bird {
    var images: [String]? {
        guard let files = details?.imageFiles else { return nil }
        return imageInfo.filter { files.contains($0.filename) } .collectFirst(3).compactMap { meta in
            meta.info.responsiveUrls?.values.first
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

struct BirdsView: View {
    let birds: [BirdGroup.Bird]
    init(birds: [BirdGroup.Bird]) {
        self.birds = birds
    }

    var body: some View {
        List(birds, id: \.name) { bird in
            VStack(alignment: .leading) {
                Text(bird.name).font(.system(size: 18, weight: .bold, design: .monospaced))
                Text(bird.latin).font(.system(size: 18, weight: .light, design: .monospaced))
                if let tag = bird.tag {
                    Text(tag.rawValue)
                }

                Spacer()
                if let summary = bird.details?.summary {
                    Text(summary).font(.system(size: 14, weight: .regular, design: .default))
                }
                Spacer()

                if let images = bird.images {
                    ScrollView(.horizontal, showsIndicators: false, content: {
                        HStack {
                            ForEach(images) { url  in
                                AsyncImage(imageUrl: url).frame(height: 88)
                            }
                        }
                    })
                    .frame(height: 100)
                }
            }
        }
    }
}

struct ContentView: View {
    let groups = birdGroups
    var body: some View {
        List(groups, id: \.category) { group in
            NavigationLink(
                destination: BirdsView(birds: group.birds),
                label: {
                    VStack {
                        HStack {
                            Text(group.category)
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                            Spacer()
                            Text(group.birds.count.description)
                        }
//                        LabelView(html: group.summary)
                        if !group.images.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false, content: {
                                HStack {
                                    ForEach(group.images, id: \.filename) { file  in
                                        AsyncImage(imageUrl: file.imageUrl).frame(height: 88)
                                    }
                                }
                            })
                            .frame(height: 100)
                        }


//                        Text(group.summary).font(.system(size: 14, weight: .regular, design: .default))
                    }
                    .clipped()
                })
        }
        .navigationBarTitle(Text("Bird Groups"), displayMode: .inline)
    }
}

import WebKit
import SwiftUI


extension BirdGroup.File {
    var imageUrl: String {
        birdGroupsImageInfo.first { $0.filename == filename } .flatMap { img in
            img.info.responsiveUrls?.values.first
        }!

//        guard let files = details?.imageFiles else { return nil }
//        return imageInfo.filter { files.contains($0.filename) } .collectFirst(3).compactMap { meta in
//            meta.info.responsiveUrls?.values.first
//        }
//        "https:" + img.src
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: HTML
extension BirdGroup {
    var attributedSummary: NSAttributedString {
        try! NSAttributedString(data: summary.data,
                           options: [
                            .documentType: NSAttributedString.DocumentType.html
                           ],
                           documentAttributes: nil)
    }
}

import Foundation

final class HTML {
    static let shared = HTML()
    private init() {}

    func render(html: String) throws -> NSAttributedString {
        let rendered = try NSAttributedString(data: html.data,
                                              options: [
                                                .documentType: NSAttributedString.DocumentType.html
                                              ],
                                              documentAttributes: nil)
        return rendered.trimmed()
    }

    private func wrap(_ html: String) -> String {
        return "<html>" + html + "</html>"
    }
}

extension NSAttributedString {
    /// https://stackoverflow.com/a/41300031/2611971
    /// html is adding a newline and a bit of space at the end
    fileprivate func trimmed() -> Self {
        let invertedSet = CharacterSet.whitespacesAndNewlines.inverted
        let nsstring = string as NSString
        var range = nsstring.rangeOfCharacter(from: invertedSet)
        let loc = range.length > 0 ? range.location : 0

        range = nsstring.rangeOfCharacter(
            from: invertedSet,
            options: .backwards)
        let len = (range.length > 0 ? NSMaxRange(range) : string.count) - loc

        let r = self.attributedSubstring(from: NSMakeRange(loc, len))
        return Self(attributedString: r)
    }
}
