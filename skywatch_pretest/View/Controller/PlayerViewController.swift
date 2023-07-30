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
    
    var interactor:Interactor? = nil
    var cancelables : Set<AnyCancellable> = []
    @Published var viewmodel : PlayerViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(videoPlayView)
        videoPlayView.snp.makeConstraints{ make in
            make.top.left.right.equalTo(view.safeAreaInsets)
            make.height.equalTo(300)
        }
        videoPlayView.load(withVideoId: viewmodel.videoInfo.id ?? "")
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
