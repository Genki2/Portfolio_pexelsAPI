//
//  SearchViewController.swift
//  pexelsAPI
//
//  Created by GENKIFUJIMOTO on 2022/11/07.
//

import UIKit
import SDWebImage
import RxSwift
import RxCocoa

class SearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
    
    //定義
    @IBOutlet weak var searchber: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    let apiModel = ApiListModel()
    var apiGetlist:[ListItem] = []
    
    //Rxswift
    let viewModel: ViewModel = ViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲート設定
        tableview.delegate = self
        tableview.dataSource = self
        searchber.delegate = self
        
        //入力されたワードをviewModelにバインド
        self.searchber.rx.text.orEmpty
            .filter { $0.count > 0 }
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(viewModel.searchWord) //新たにSubscriptionを生成
            .disposed(by: disposeBag)
        
        // イベントの検索結果のストリームを購読する
        viewModel.events
            .subscribe(onNext: {[weak self] getapi in
                if let events = getapi {
                    self!.apiGetlist = events.photos
                    self!.tableview.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    //=================
    //MARK: 検索バー処理
    //=================
    
    // 検索バー編集開始時にキャンセルボタン有効化
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    // キャンセルボタンでキャセルボタン非表示
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    
    //==================
    //MARK: tableView処理
    //==================
    
    //Cellの個数searchber
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiGetlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //cell定義
        let cell =  tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //cellのタグを使用し定義
        let contentsImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let Photographer = cell.contentView.viewWithTag(2) as! UILabel
        let ArtName = cell.contentView.viewWithTag(3) as! UILabel
        
        //値代入
        contentsImageView.sd_setImage(with:  URL(string:(apiGetlist[indexPath.row].src?.tiny)!), placeholderImage: nil, options: .continueInBackground, completed: nil)
        Photographer.text = "撮影者: " + apiGetlist[indexPath.row].photographer!
        ArtName.text = "【作品名】\n" + apiGetlist[indexPath.row].alt!
        
        return cell
    }
    
    //cellの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    //cellをタップ時の動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //選択解除
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        //画面遷移
        let ViewController = self.storyboard?.instantiateViewController(identifier: "VC") as! ViewController
        ViewController.tappedPhotoLargeUrl = (apiGetlist[indexPath.row].src?.large)!
        self.navigationController?.pushViewController(ViewController, animated: true)
    }

}
