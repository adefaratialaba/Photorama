//
//  FlickrAPI.swift
//  Photorama
//
//  Created by Sumit Ganju on 2018-03-12.
//  Copyright © 2018 Centennial College. All rights reserved.
//

import Foundation
enum FlickrError : Error{
    case invalidJSONData
}
enum Method: String{
    case interestingPhotos = "flickr.interestingness.getList"
}

struct  FlickrAPI {
    
    private  static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "462281f851c60d12627b6a7b5825c7b1"
    private static let dataFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat="yyyy-mm-dd hh:mm:ss"
        return formatter
    }()
    private static func flickrURL(method:Method, parameters: [String:String]?) -> URL {
        var components = URLComponents(string: baseURLString)!
        var queryItem = [URLQueryItem]()
        let baseParams = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback":"1",
            "api_key": apiKey
        ]
        for (key,value) in baseParams{
            let item = URLQueryItem(name:key,value:value)
            queryItem.append(item)
        }
        
        if let additionalParams = parameters{
            for (key, value) in additionalParams{
                let item = URLQueryItem(name:key,value:value)
                queryItem.append(item)
            }
        }
        components.queryItems = queryItem
        return components.url!
    }
    static var interestingPhotosURL: URL {
        return flickrURL(method: .interestingPhotos, parameters: ["extras": "url_h,date_taken"])
    }
    static func photos(fromJSON data: Data)-> PhotoResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
            let jsonDictionary = jsonObject as?[AnyHashable:Any],
            let photos = jsonDictionary["photo"]as? [String:Any],
                let photoArray = photos["photo"]as? [[String:Any]] else{
                    return .failure([FlickrError.invalidJSONData])
            }
            var finalPhotos = [Photo]()
            for photoJSON in photoArray{
                if let photo = photo(fromJSON: photoJSON){
                    finalPhotos.append(photo)
                }
            }
            if finalPhotos.isEmpty && !photoArray.isEmpty{
                return .failure([FlickrError.invalidJSONData])
            }
            return .success(finalPhotos)
        } catch let error {
            return .failure([error])
            
        }
    }
    
    private static func photo(fromJSON json: [String: Any])->Photo?{
        guard
            let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["dateString"] as? String,
            let photoURLString = json["photoURLString"] as? String,
            let url = URL(string: photoURLString),
            let dateTaken = dataFormatter.date(from: dateString) else {
                return nil
        }
        return Photo(title:title, photoID: photoID, remoteURL:url, dateTaken:dateTaken)
    }
}

