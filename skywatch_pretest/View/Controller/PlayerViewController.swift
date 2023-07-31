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
        return view
    }()
    
    lazy private var scrollView : UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.backgroundColor = .white
        view.showsVerticalScrollIndicator = false
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
        label.backgroundColor = .white
        let ges = UITapGestureRecognizer(target: self, action: #selector(showMoreDescription))
        label.addGestureRecognizer(ges)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy private var msgTableView : UITableView = {
        let view = UITableView()
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.isScrollEnabled = false
        return view
    }()
    
    private var scrollViewOffset : CGPoint = .zero
    private var tableViewOffset : CGPoint = .zero
    
    var interactor:Interactor? = nil
    var cancelables : Set<AnyCancellable> = []
    @Published var viewmodel : PlayerViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPara()
        setupUI()
        setDataBinding()
    }
    
    func setupUI(){
        view.backgroundColor = .white
        view.addSubview(videoPlayView)
        videoPlayView.snp.makeConstraints{ make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(view.safeAreaLayoutGuide.snp.width).dividedBy(Double(1920)/1080)
        }
        
        //設定Scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints{ make in
            make.top.equalTo(videoPlayView.snp.bottom)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.addSubview(channelImg)
        channelImg.snp.makeConstraints{ make in
            make.width.height.equalTo(50)
            make.left.top.equalToSuperview().offset(5)
        }
        
        scrollView.addSubview(videoTitleLabel)
        videoTitleLabel.snp.makeConstraints{ make in
            make.centerY.top.equalTo(channelImg)
            make.left.equalTo(channelImg.snp.right).offset(10)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-5)
        }
        
        scrollView.addSubview(ownerLabel)
        ownerLabel.snp.makeConstraints{ make in
            make.top.equalTo(videoTitleLabel.snp.bottom).offset(5)
            make.left.equalTo(videoTitleLabel)
        }
        
        scrollView.addSubview(uploadDateLabel)
        uploadDateLabel.snp.makeConstraints{ make in
            make.top.equalTo(ownerLabel)
            make.left.equalTo(ownerLabel.snp.right).offset(5)
            make.right.equalTo(videoTitleLabel)
        }
        
        scrollView.addSubview(descriptionLabel)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 5
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints{ make in
            make.top.equalTo(uploadDateLabel.snp.bottom).offset(15)
            make.left.equalTo(channelImg)
            make.right.equalTo(videoTitleLabel)
            make.bottom.equalToSuperview().offset(-5)
        }
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(msgTableView)
        let videoViewHeight = Double(view.safeAreaLayoutGuide.layoutFrame.width)/1920*1080+10
        msgTableView.snp.makeConstraints{ make in
            make.width.equalToSuperview()
            make.height.equalTo(view.safeAreaLayoutGuide).offset(-videoViewHeight)
        }
        
        scrollView.contentSize = CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width, height: msgTableView.frame.maxY + 15)
        setupTableView()
    }
    
    func setupTableView(){
        msgTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "CommentCell")
        msgTableView.mj_footer = MJRefreshAutoNormalFooter{ [unowned self] in
            Task {
                var vm = viewmodel
                let status = await vm?.loadMoreComment()
                DispatchQueue.main.async { [unowned self] in
                    if status == .noMoreData{
                        msgTableView.mj_footer?.endRefreshingWithNoMoreData()
                        return
                    }
                    if status == .success{
                        viewmodel = vm
                    }
                    msgTableView.mj_footer?.endRefreshing()
                }
            }
        }
    }
    
    func initPara(){
        guard let id = viewmodel?.videoInfo?.id else { return }
        videoPlayView.load(withVideoId: id)
        Task{
            guard var vm = viewmodel,
                  await vm.loadCommentList() else { return }
            viewmodel = vm
        }
    }
    
    func setDataBinding(){
        $viewmodel.receive(on: DispatchQueue.main).sink{ [unowned self] model in
            videoTitleLabel.text = model?.videoInfo?.name
            uploadDateLabel.text = model?.videoInfo?.createDate?.stringWith("YYYY-MM-dd HH:mm:ss")
            if let url = model?.channelInfo?.thumbnails{
                channelImg.load(url: url)
            }
            ownerLabel.text = model?.channelInfo?.name
            descriptionLabel.text = model?.videoInfo?.description
            channelImg.layer.cornerRadius = channelImg.bounds.midX
            msgTableView.reloadData()
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
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        //自動播放
        playerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        print(state.rawValue)
        viewmodel.playstatus = state
    }
}

extension PlayerViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewOffsetY = scrollView.contentOffset.y
        if !msgTableView.isScrollEnabled {
            // 如果 scrollView 已經滾動到底部，就讓 tableView 捕捉滑動事件
            if scrollViewOffsetY >= scrollView.contentSize.height - scrollView.bounds.height{
                msgTableView.isScrollEnabled = true
                scrollView.isScrollEnabled = false
            } else {
                msgTableView.isScrollEnabled = false
            }
        }else if !self.scrollView.isScrollEnabled{
            // 如果 tableView 已經滾動到頂部，就讓 scrollView 捕捉滑動事件
            if scrollViewOffsetY <= 0 {
                self.scrollView.isScrollEnabled = true
                scrollView.isScrollEnabled = false
            } else {
                self.scrollView.isScrollEnabled = false
            }
        }
    }
}

extension PlayerViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.commentList?.list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell
        guard let comments = viewmodel.commentList?.list else { return CommentTableViewCell() }
        cell?.setCommentInfo(comments[indexPath.row])
        return cell ?? CommentTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
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
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
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
            view.backgroundColor = interactor.shouldFinish ? .clear : .white
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
    
    @objc func showMoreDescription(){
        descriptionLabel.numberOfLines = descriptionLabel.numberOfLines != 0 ? 0 : 10
    }
}
