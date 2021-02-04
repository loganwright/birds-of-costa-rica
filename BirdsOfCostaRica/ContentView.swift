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
    @State private var present: Bool = false

    init(imageUrl: String) {
        self.imageUrl = imageUrl
    }

    var body: some View {
        if let image = result?.value {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .sheet(isPresented: $present) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    self.present = true
                }
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
    var allImages: [String]? {
        guard let files = details?.imageFiles else { return nil }
        var unique = [String]()
        for file in files where !unique.contains(file) {
            unique.append(file)
        }

        var found: [ImageMeta] = []
        for next in birdDetailsImageInfoPreFiltered {
            guard unique.contains(next.filename), !found.contains(where: { $0.filename == next.filename }) else { continue }
            found.append(next)
        }

        return found.compactMap { meta in
            meta.info.responsiveUrls?.values.first
        }
    }

    var firstThreeImages: [String]? {
        guard let files = details?.imageFiles else { return nil }
        var unique = [String]()
        for file in files where !unique.contains(file) {
            unique.append(file)
        }

        let three: [String]
        if unique.count > 3 {
            three = unique.collectFirst(3)
        } else {
            three = unique
        }


        var found: [ImageMeta] = []
        for next in birdDetailsImageInfoPreFiltered where found.count < 3 {
            guard three.contains(next.filename), !found.contains(where: { $0.filename == next.filename }) else { continue }
            found.append(next)
        }
//        let found = birdDetailsImageInfoPreFiltered.filter { three.contains($0.filename) }

//        let three: [ImageMeta]
//        if all.count > 3 {
//            three = all.collectFirst(3)
//        } else {
//            three = all
//        }
        print(found.map(\.filename))
        print()
        return found.compactMap { meta in
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
            ZStack {
            VStack(alignment: .leading) {
                Text(bird.name).font(.system(size: 16, weight: .bold, design: .monospaced))
                Text(bird.latin).font(.system(size: 16, weight: .light, design: .monospaced))

                if let tag = bird.tag {
                    Text(tag.rawValue.capitalized)
                        .font(.system(size: 16, weight: .light, design: .monospaced))
                        .italic()
                }

                Spacer()
                if let summary = bird.details?.summary {
                    Text(summary).font(.system(size: 16, weight: .regular, design: .default))
                }
                Spacer()

                if let images = bird.firstThreeImages {
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
                NavigationLink(
                    destination: ImageList(bird: bird),
                    label: { EmptyView()
                    }).hidden()
    //                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct CircleLabel: View {
    let text: String
    var body: some View {
//        Text(" " + text + " ")
//            .font(.system(size: 14, weight: .bold, design: .monospaced))
//            .foregroundColor(.white)
//            .background(Circle().fill(Color.black).frame(width: 18, height: 18))
        Text(text)
            .font(.system(size: 14, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .frame(width: 22, height: 22, alignment: .center)
//            .padding()
            .background(
                Circle().fill(Color.black)
//                .padding(6)
            )
    }
}

struct ImageList: View {
    let bird: BirdGroup.Bird

    var body: some View {
        if let images = bird.allImages {
            List(images) { imageUrl in
                AsyncImage(imageUrl: imageUrl)
                    .frame(alignment: .center)
            }.frame(alignment: .center)
        } else {
            Text("No images for \(bird.name).")
        }
    }
}

struct ContentView: View {
    let groups = birdGroups
    var body: some View {
        List(groups, id: \.category) { group in
            ZStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
//                            CircleLabel(text: group.birds.count.description)
                    Text(group.category)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
//                            Spacer()
//                            CircleLabel(text: group.birds.count.description)
                }
                HStack {

                    VStack(alignment: .leading) {
                        HStack {
                            Text("Order: ")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                            Text(group.order.name)
                                .font(.system(size: 14, weight: .thin, design: .monospaced))

                        }
                        HStack {
                            Text("Family: ")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                            Text(group.family.name)
                                .font(.system(size: 14, weight: .thin, design: .monospaced))
                        }
                    }
                                                Spacer()
                                                CircleLabel(text: group.birds.count.description)
                }

//                        CircleLabel(text: group.birds.count.description)

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
                Text(group.summary).font(.system(size: 14, weight: .thin, design: .monospaced))

            }
            NavigationLink(
                destination: BirdsView(birds: group.birds),
                label: { EmptyView()
                }).hidden()
//                .buttonStyle(PlainButtonStyle())
            }
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
