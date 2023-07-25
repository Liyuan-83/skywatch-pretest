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
    lazy var refreshControl : UIRefreshControl = {
        var refresh = UIRefreshControl()
        return refresh
    }()
    var cancelables : Set<AnyCancellable> = []
    @Published var channelInfo : ChannelInfo?
    @Published var playList : PlayList?
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
            channelInfo = try? await HttpMeneger.shared.getChannelInfo("UCvpredjG93ifbCP1Y77JyFA")
            guard let playListID = channelInfo?.uploadID else { return }
            playList = try? await HttpMeneger.shared.getPlayList(playListID)
            print(channelInfo?.uploadID)
            print(playList?.list?.count)
        }
    }
    
    func setupUI(){
        setupNavigation()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlayListTableViewCell.self, forCellReuseIdentifier: "playListCell")
        tableView.mj_footer = MJRefreshAutoNormalFooter{ [unowned self] in
            guard let id = channelInfo?.uploadID,
            let token = playList?.nextPageToken else {
                DispatchQueue.main.async { [unowned self] in
                    tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
                return
            }
            Task {
                let nextPageList = try? await HttpMeneger.shared.getPlayList(id,20,token)
                guard let list = nextPageList?.list else { return }
                playList?.nextPageToken = nextPageList?.nextPageToken
                for info in list{
                    playList?.list?.append(info)
                }
                DispatchQueue.main.async { [unowned self] in
                    tableView.mj_footer?.endRefreshing()
                    tableView.reloadData()
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
        $channelInfo.sink{ [unowned self] info in
//            print(info?.uploadID)
            DispatchQueue.main.async { [unowned self] in
                tableView.reloadData()
            }
        }.store(in: &cancelables)
        
        $playList.sink{  list in
            DispatchQueue.main.async { [unowned self] in
//                print(list?.list?.count)
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


extension PlayListViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playList?.list?.filter({
            guard let keyword = searchBar.text,
                  !keyword.isEmpty else { return true }
            return $0.name?.contains(keyword) ?? false
        }).count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playListCell", for: indexPath) as? PlayListTableViewCell
        
        if let channelInfo = channelInfo {
            cell?.setChannelInfo(channelInfo)
        }
        
        if let videoInfo = playList?.list?[indexPath.row] {
            cell?.setVideoInfo(videoInfo)
        }
        
        return cell ?? PlayListTableViewCell()
    }
}
