//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Leela Krishna Chaitanya Koravi on 2/28/21.
//  Copyright © 2021 Leela Krishna Chaitanya Koravi. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient{
    
    static var flickrKey = "5f7d5ec43e14203f72cb6c5d2e837e96"
    static var flickrSecret = "ebe2478c582524c1"
    
    struct searchAttributes{
        static var latitude = 0.0
        static var longitude = 0.0
        static var itemsPerPage = 24
        static var pageNumber = 0
        static var radius = 20
    }
    
    enum Endpoints{
        
        static let base = "https://www.flickr.com/services/rest"
        
        case searchPhotos
        
        var stringValue:String {
            switch self{
            case .searchPhotos:
                return Endpoints.base + "/?method=flickr.photos.search"
                    + "&api_key=\(flickrKey)"
                    + "&lat=\(searchAttributes.latitude)"
                    + "&lon=\(searchAttributes.longitude)"
                    + "&radius=\(searchAttributes.radius)"
                    + "&per_page=\(searchAttributes.itemsPerPage)"
                    + "&page=\(searchAttributes.pageNumber)"
                + "&format=json&nojsoncallback=1&extras=url_m"
        }
        }
        
        var url:URL{
            return URL(string: stringValue)!
        }
    }
    
    
    class func getPhotos(latitude: Double, longitude: Double, pageCount: Int = 0, completion:
        @escaping ([PhotoStruct], Int, Error?) -> Void) -> Void{
        let FUNC_TAG = "getPhotos"
        searchAttributes.latitude = latitude //40.7580
        searchAttributes.longitude = longitude //73.9855
        self.setPageNumber(pageCount: pageCount)
        taskForGetRequest(url: Endpoints.searchPhotos.url , responseType: PhotoResponse.self) {
            response, error in
            if let response = response {
                completion(response.photos.photo, response.photos.pages, nil)
            } else {
                print(FUNC_TAG, error)
                completion([], 0, error)
            }
        }
    }
    
    class func setPageNumber(pageCount: Int){
        let flickrLimit = 4000
        // Available total number of pics or flickr limit
        let numberPages = min(pageCount, flickrLimit) / searchAttributes.itemsPerPage
        let randomPageNum = Int.random(in: 0...numberPages)
        searchAttributes.pageNumber = randomPageNum
        print("pageCount from Pin: ", pageCount, ", itemsPerPage: ", searchAttributes.itemsPerPage,
              "ransomPageNum: ", randomPageNum)
    }
    
    class func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?)->Void){
        let FUNC_TAG = "taskForGetRequest"
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            guard let data = data else {
                DispatchQueue.main.async{
                    print(FUNC_TAG, error)
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do{
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    print( FUNC_TAG, "responseObject: ", responseObject)
                    completion(responseObject, nil)
                }
            }catch{
                DispatchQueue.main.async {
                    print( FUNC_TAG, "error: ", error)
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }

}
