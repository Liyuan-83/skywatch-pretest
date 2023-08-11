//
//  PlayerViewController.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/30.
//

import UIKit
import Combine
import YouTubeiOSPlayerHelper
import MJRefresh

class PlayerViewController: UIViewController {
    
    lazy private var videoPlayView : YTPlayerView = {
        let view = YTPlayerView()
        view.delegate = self
        let ges = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        ges.delegate = self
        view.addGestureRecognizer(ges)
        view.backgroundColor = .systemBackground
        return view
    }()
    
    lazy private var tableView : UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    lazy private var channelInfoView : UIView = {
       let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var channelImg: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.adjustsImageSizeForAccessibilityContentSizeCategory = false
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var videoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var ownerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var uploadDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 1
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 10
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemBackground
        let ges = UITapGestureRecognizer(target: self, action: #selector(showMoreDescription))
        label.addGestureRecognizer(ges)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    var interactor:Interactor? = nil
    var cancelables : Set<AnyCancellable> = []
    @Published internal var viewmodel : PlayerViewModel<HttpService>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPara()
        setupUI()
        setDataBinding()
    }
    
    func setupUI(){
        view.backgroundColor = .systemBackground
        view.addSubview(videoPlayView)
        videoPlayView.snp.makeConstraints{ make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(view.safeAreaLayoutGuide.snp.width).dividedBy(Double(1920)/1080)
        }
        
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints{ make in
            make.top.equalTo(videoPlayView.snp.bottom)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        setupTableView()
    }
    
    func setupTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.mj_footer = MJRefreshAutoNormalFooter{ [unowned self] in
            Task {
                var vm = viewmodel
                let status = await vm?.loadMoreComment()
                DispatchQueue.main.async { [unowned self] in
                    if status == .noMoreData{
                        tableView.mj_footer?.endRefreshingWithNoMoreData()
                        return
                    }
                    if status == .success{
                        viewmodel = vm
                    }
                    tableView.mj_footer?.endRefreshing()
                }
            }
        }
    }
    
    func initPara(){
        guard let id = viewmodel.videoID else { return }
        videoPlayView.load(withVideoId: id, playerVars: ["fs" : 1,
                                                         "controls" : 1,
                                                         "autoplay": 1,
                                                         "loop" : 1,
                                                         "start" : Int(viewmodel.currentTime),
                                                         "modestbranding" : 1])
        Task{
            guard var vm = viewmodel,
                  await vm.fetchData() else { return }
            viewmodel = vm
        }
    }
    
    func setDataBinding(){
        $viewmodel.receive(on: DispatchQueue.main).sink{ [unowned self] model in
            videoTitleLabel.text = model?.videoName
            uploadDateLabel.text = model?.videoCreatDate?.stringWith("YYYY-MM-dd HH:mm:ss")
            if let url = model?.channelInfo?.thumbnails{
                channelImg.load(url: url)
            }
            ownerLabel.text = model?.channelInfo?.name
            descriptionLabel.text = model?.videoDescription
            channelImg.layer.cornerRadius = channelImg.bounds.midX
            tableView.reloadData()
        }.store(in: &cancelables)
    }
}

extension PlayerViewController : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //多首是同時觸發，讓播放器手勢與下拉關閉手勢不要衝突
        return true
    }
}

extension PlayerViewController : YTPlayerViewDelegate{
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        print(state.rawValue)
        viewmodel.playstatus = state
        //循環播放
        guard viewmodel.playstatus == .ended else { return }
        videoPlayView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        print(playTime)
        guard viewmodel != nil else { return }
        viewmodel.currentTime = playTime
        viewmodel.saveToLocal()
    }
}

extension PlayerViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? viewmodel.comments?.count ?? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            cell.contentView.addSubview(descriptionLabel)
            descriptionLabel.snp.makeConstraints{ make in
                make.top.bottom.equalToSuperview()
                make.right.left.equalToSuperview().offset(10)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell
        guard let comments = viewmodel.comments else { return CommentTableViewCell() }
        cell?.setCommentInfo(comments[indexPath.row])
        return cell ?? CommentTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let view = UIView()
            view.backgroundColor = .systemBackground
            view.addSubview(channelImg)
            channelImg.snp.makeConstraints{ make in
                make.width.height.equalTo(50)
                make.left.top.equalToSuperview().offset(5)
            }
            
            view.addSubview(videoTitleLabel)
            videoTitleLabel.snp.makeConstraints{ make in
                make.centerY.top.equalTo(channelImg)
                make.left.equalTo(channelImg.snp.right).offset(10)
                make.right.equalToSuperview().offset(-5)
            }
            
            view.addSubview(ownerLabel)
            ownerLabel.snp.makeConstraints{ make in
                make.top.equalTo(videoTitleLabel.snp.bottom).offset(5)
                make.left.equalTo(videoTitleLabel)
            }
            
            view.addSubview(uploadDateLabel)
            uploadDateLabel.snp.makeConstraints{ make in
                make.top.equalTo(ownerLabel)
                make.left.equalTo(ownerLabel.snp.right).offset(5)
                make.right.equalTo(videoTitleLabel)
                make.bottom.equalToSuperview().offset(-5)
            }
            return view
        }else{
            let view = UIView()
            view.backgroundColor = .systemBackground
            view.layer.borderColor = UIColor.black.cgColor
            view.layer.borderWidth = 2
            let label = UILabel()
            label.text = "留言"
            label.font = .systemFont(ofSize: 30)
            label.textAlignment = .left
            view.addSubview(label)
            label.snp.makeConstraints{ make in
                make.left.equalTo(view).offset(10)
                make.centerY.right.equalTo(view)
                make.top.equalTo(view).offset(5)
            }
            return view
        }
    }
}

extension PlayerViewController{
    ///下拉關閉手勢觸發
    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
        let percentThreshold:CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch sender.state {
        case .began:
            videoPlayView.pauseVideo()
            interactor.hasStarted = true
            view.backgroundColor = .clear
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            view.backgroundColor = interactor.shouldFinish ? .clear : .systemBackground
            interactor.shouldFinish
            ? interactor.finish()
            : interactor.cancel()
            //確認離開此畫面後清除本地緩存
            guard interactor.shouldFinish else {
                videoPlayView.playVideo()
                return
            }
            for cancelable in cancelables {
                cancelable.cancel()
            }
            viewmodel.clearFromLocal()
            viewmodel = nil
        default:
            break
        }
    }
    
    @objc func showMoreDescription(){
        descriptionLabel.numberOfLines = descriptionLabel.numberOfLines != 0 ? 0 : 10
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}
