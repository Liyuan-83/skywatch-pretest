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
        // Do any additional setup after loading the view.
//        player.load(withVideoId: "M7lc1UVf-VE")
        setupUI()
        initPara()
        setDataBinding()
    }
    
    func initPara() {
        Task {
            viewmodel.channelInfo = try? await HttpMeneger.shared.getChannelInfo(YOASOBI_Channel_ID)
            guard let playListID = viewmodel.channelInfo?.uploadID,
                  let playList = try? await HttpMeneger.shared.getPlayList(playListID),
                  let list = playList.list else { return }
            viewmodel.allList = list
            viewmodel.nextPageToken = playList.nextPageToken
        }
    }
    
    func setupUI(){
        setupNavigation()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlayListTableViewCell.self, forCellReuseIdentifier: "playListCell")
        tableView.mj_footer = MJRefreshAutoNormalFooter{ [unowned self] in
            guard let id = viewmodel.channelInfo?.uploadID,
                  let token = viewmodel.nextPageToken else {
                DispatchQueue.main.async { [unowned self] in
                    tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
                return
            }
            Task {
                guard let nextPageList = try? await HttpMeneger.shared.getPlayList(id,20,token),
                      let list = nextPageList.list else { return }
                viewmodel.nextPageToken = nextPageList.nextPageToken
                viewmodel.allList += list
                DispatchQueue.main.async { [unowned self] in
                    tableView.mj_footer?.endRefreshing()
                }
            }
        }
    }
    
    func setupNavigation(){
        navigationItem.title = "YOASOBI Channel"
        let btn = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(searchClick))
        navigationItem.rightBarButtonItem =  btn
    }

    
    func setDataBinding(){
        $viewmodel.sink{ [unowned self] info in
//            print(info?.uploadID)
            DispatchQueue.main.async { [unowned self] in
                tableView.reloadData()
            }
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
}
