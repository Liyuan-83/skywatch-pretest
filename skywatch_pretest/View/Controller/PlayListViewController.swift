//
//  PlayListViewController.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import UIKit
import Combine
import MJRefresh

class PlayListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var cancelables : Set<AnyCancellable> = []
    @Published var viewmodel : PlayListViewModel = PlayListViewModel()
//    @IBOutlet weak var player: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initPara()
        setDataBinding()
    }
    
    func initPara() {
        //讀取看看是否有本地資料，沒有才需要去要Api
        guard !viewmodel.loadFromLocal() else { return }
        Task {
            viewmodel.channelInfo = try? await HttpMeneger.shared.getChannelInfo(YOASOBI_Channel_ID)
            guard let playListID = viewmodel.channelInfo?.uploadID,
                  let playList = try? await HttpMeneger.shared.getPlayList(playListID),
                  let list = playList.list else { return }
            viewmodel.allList = list
            viewmodel.nextPageToken = playList.nextPageToken
            //儲存至本地
            viewmodel.saveToLocal()
            DispatchQueue.main.async { [unowned self] in
                tableView.mj_header?.endRefreshing()
            }
        }
    }
    
    func setupUI(){
        setupNavigation()
        setupTableView()
        searchBar.delegate = self
    }
    
    func setupNavigation(){
        navigationItem.title = "YOASOBI Channel"
        let btn = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(searchClick))
        navigationItem.rightBarButtonItem =  btn
    }
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlayListTableViewCell.self, forCellReuseIdentifier: "playListCell")
        //下拉刷新，清除本地資料重新讀取線上資料
        tableView.mj_header = MJRefreshNormalHeader{ [unowned self] in
            viewmodel.clearFromLocal()
            initPara()
        }
        //滑到底自動加載
        tableView.mj_footer = MJRefreshAutoNormalFooter{ [unowned self] in
            Task {
                var vm = viewmodel
                let status = await vm.loadNextPage()
                DispatchQueue.main.async { [unowned self] in
                    if status == .noMoreData{
                        tableView.mj_footer?.endRefreshingWithNoMoreData()
                        return
                    }
                    if status == .success{
                        viewmodel = vm
                        viewmodel.saveToLocal()
                    }
                    tableView.mj_footer?.endRefreshing()
                }
            }
        }
    }
    
    func setDataBinding(){
        $viewmodel.receive(on: DispatchQueue.main).sink{ [unowned self] model in
            searchBar.text = model.searchKeyword
            searchBar.isHidden = !searchBar.isFirstResponder && model.searchKeyword.isEmpty
            tableView.reloadData()
        }.store(in: &cancelables)
    }

}

extension PlayListViewController {
    @objc func searchClick(_ btn: UIButton){
        searchBar.isHidden = !searchBar.isHidden
    }
}

extension PlayListViewController : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        viewmodel.searchKeyword = searchText
        viewmodel.saveToLocal()
    }
}


extension PlayListViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.showList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playListCell", for: indexPath) as? PlayListTableViewCell
        
        if let channelInfo = viewmodel.channelInfo {
            cell?.setChannelInfo(channelInfo)
        }
        cell?.setVideoInfo(viewmodel.showList[indexPath.row])
        return cell ?? PlayListTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
