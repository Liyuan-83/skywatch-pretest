//
//  PlayListViewController.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/22.
//

import UIKit
import Combine

class PlayListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var cancelables : Set<AnyCancellable> = []
    @Published var channelInfo : ChannelInfo?
    @Published var playList : PlayList?
//    @IBOutlet weak var player: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        player.load(withVideoId: "M7lc1UVf-VE")
        setupUI()
    }
    
    func setupUI(){
        setupNavigation()
        
    }
    
    func setupNavigation(){
        navigationItem.title = "YOASOBI Channel"
        let btn = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(searchClick))
        navigationItem.rightBarButtonItem =  btn
    }

    
    func setDataBinding(){
        $channelInfo.sink{ [unowned self] info in
            guard let playListID = info?.uploadID else { return }
            playList = try? await HttpMeneger.shared.getPlayList(playListID)
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
        return playList?.list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
