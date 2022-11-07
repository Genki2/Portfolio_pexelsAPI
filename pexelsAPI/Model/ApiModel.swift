//
//  ApiModel.swift
//  pexelsAPI
//
//  Created by GENKIFUJIMOTO on 2022/11/07.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift

class ApiListModel{
    
    //検索イベント
    func searchEvents(keyword: String)-> Observable<Api?>{
        
        //クロージャからストリームを生成
        return Observable.create { observer in
            
            //apiキー
            let headers: HTTPHeaders = [
                "Authorization": "563492ad6f91700001000001bf70f8ac0fec4a169e874cb63b6d10d0",
            ]
            
            //リクエスト先URL
            let urlString = "https://api.pexels.com/v1/search?query=\(keyword)&locale=ja-JP&per_page=10"
            
            //エンコーディング
            let encodeUrlString:String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            //API通信
            AF.request(encodeUrlString,method: .get,headers: headers).responseData { (response) in
                
                switch response.result {
                case .success:
                    
                    if let data = response.data {
                        let decoder = JSONDecoder()
                        if let result = try? decoder.decode(Api.self, from: data) {
                            print(result)
                            
                            //onNext「値が更新された」イベント
                            observer.onNext(result)
                        }
                    }
                case .failure(let error):
                    
                    //onError「エラーが発生した」イベント
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}

struct Api : Codable {
    var photos:[ListItem]
    
    init(photos:[ListItem]) {
        self.photos = photos
    }
}

struct ListItem : Codable {
    var alt:String?
    var photographer:String?
    var src:srctype?
    
    struct srctype:Codable {
        var tiny:String?
        var large:String?
    }
}
