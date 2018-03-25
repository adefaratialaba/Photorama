//
//  Photo.swift
//  Photorama
//
//  Created by alaba azeezadefarati on 2018-03-25.
//  Copyright © 2018 alaba azeezadefarati. All rights reserved.
//

import Foundation
class Photo {
    
    let title: String
    let remoteURL: URL
    let photoID: String
    let dateTaken: Date
    
    init(title: String, photoID: String, remoteURL: URL, dateTaken: Date) {
        self.title = title
        self.photoID = photoID
        self.remoteURL = remoteURL
        self.dateTaken = dateTaken
    }
}
