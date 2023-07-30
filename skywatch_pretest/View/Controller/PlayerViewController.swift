//
//  PlayerViewController.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/30.
//

import UIKit
import Combine
import YouTubeiOSPlayerHelper

class PlayerViewController: UIViewController {
    
    lazy var videoPlayView : YTPlayerView = {
        let view = YTPlayerView()
        view.delegate = self
        let ges = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        ges.delegate = self
        view.addGestureRecognizer(ges)
        return view
    }()
    
    lazy var scrollView : UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var channelImg: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.adjustsImageSizeForAccessibilityContentSizeCategory = false
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var videoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var ownerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var uploadDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 1
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 10
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var msgTableView : UITableView = {
        let view = UITableView()
        return view
    }()
    
    var interactor:Interactor? = nil
    var cancelables : Set<AnyCancellable> = []
    @Published var viewmodel : PlayerViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        descriptionLabel.snp.makeConstraints{ make in
            make.top.equalTo(uploadDateLabel.snp.bottom).offset(15)
            make.left.equalTo(channelImg)
            make.right.equalTo(videoTitleLabel)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        scrollView.contentSize = CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width, height: ownerLabel.frame.maxY + 15)
        
    }
    
    func setDataBinding(){
        $viewmodel.receive(on: DispatchQueue.main).sink{ [unowned self] model in
            if model?.playstatus == .unknown {
                videoPlayView.load(withVideoId: model?.videoInfo.id ?? "")
            }
            videoTitleLabel.text = model?.videoInfo.name
            uploadDateLabel.text = model?.videoInfo.createDate?.stringWith("YYYY-MM-dd HH:mm:ss")
            if let url = model?.channelInfo.thumbnails{
                channelImg.load(url: url)
            }
            ownerLabel.text = model?.channelInfo.name
            descriptionLabel.text = model?.videoInfo.description
            channelImg.layer.cornerRadius = channelImg.bounds.midX
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
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
}
