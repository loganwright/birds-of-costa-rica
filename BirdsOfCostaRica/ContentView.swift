//
//  ContentView.swift
//  BirdsOfCostaRica
//
//  Created by Logan Wright on 2/4/21.
//

import SwiftUI
import Endpoints

struct AsyncImage: View {
    let imageUrl: String
    @State private var result: Result<UIImage, Error>? = nil
    init(imageUrl: String) {
        self.imageUrl = imageUrl
    }

    var body: some View {
        if let image = result?.value {
            Image(uiImage: image)
        } else if let error = result?.error {
            Text(error.display)
        } else {
            Text("loading...")
                .onAppear(perform: load)
        }
    }

    private func load() {
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

                self.result = .success(img)
            }
            .on.error {
                self.result = .failure($0)
            }
            .send()
    }
}

struct ContentView: View {
    let groups = birdGroups
    var body: some View {
        List(groups, id: \.category) { group in
            VStack {
                HStack {
                    Text(group.category)
                    Spacer()
                    Text(group.birds.count.description)
                }
                HStack {
                    ForEach(group.images, id: \.filehref) { file  in
                        AsyncImage(imageUrl: file.imageUrl)
                    }
                }
            }
        }
    }
}

extension BirdGroup.File {
    var imageUrl: String {
        "https:" + img.src
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
