//
//  PlayListTableViewCell.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/23.
//

import UIKit
import SnapKit

class PlayListTableViewCell: UITableViewCell {
    lazy private var thumbnailView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.adjustsImageSizeForAccessibilityContentSizeCategory = false
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapThumbnailView))
        view.addGestureRecognizer(tapGes)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy private var channelImg: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.adjustsImageSizeForAccessibilityContentSizeCategory = false
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy private var videoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy private var ownerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy private var uploadDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()
    
    private var videoInfo : VideoInfo?
    private var channelInfo : ChannelInfo?
    var clickThumbnail : ((ChannelInfo, VideoInfo) -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        channelImg.layer.cornerRadius = channelImg.bounds.midX
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupUI(){
        var imgRate : Double = Double(4)/3
        switch UIScreen.main.bounds.width{
        case 641...1280:
            imgRate = Double(1280)/720
            break
        case 481...640:
            imgRate = Double(640)/480
            break
        case 321...480:
            imgRate = Double(480)/360
            break
        case 121...320:
            imgRate = Double(320)/180
            break
        default:
            imgRate = Double(4)/3
        }
        contentView.addSubview(thumbnailView)
        thumbnailView.snp.makeConstraints{ make in
            make.centerX.width.equalToSuperview()
            make.top.left.equalTo(contentView)
            make.height.equalTo(contentView.snp.width).dividedBy(imgRate)
        }
        
        contentView.addSubview(channelImg)
        channelImg.snp.makeConstraints{ make in
            make.width.height.equalTo(50)
            make.left.equalTo(contentView).offset(5)
            make.top.equalTo(thumbnailView.snp.bottom).offset(5)
        }
        
        contentView.addSubview(videoTitleLabel)
        videoTitleLabel.snp.makeConstraints{ make in
            make.centerY.top.equalTo(channelImg)
            make.left.equalTo(channelImg.snp.right).offset(10)
            make.right.equalTo(contentView).offset(-5)
        }
        
        contentView.addSubview(ownerLabel)
        ownerLabel.snp.makeConstraints{ make in
            make.top.equalTo(videoTitleLabel.snp.bottom).offset(5)
            make.left.equalTo(videoTitleLabel)
            make.bottom.equalTo(contentView).offset(-15)
        }
        
        contentView.addSubview(uploadDateLabel)
        uploadDateLabel.snp.makeConstraints{ make in
            make.top.equalTo(ownerLabel)
            make.left.equalTo(ownerLabel.snp.right).offset(5)
            make.right.equalTo(videoTitleLabel)
        }
    }
    
    func setVideoInfo(_ info:VideoInfo){
        videoInfo = info
        if let thumbnails = info.thumbnails{
            thumbnailView.loadThumbnails(thumbnails)
        }
        videoTitleLabel.text = info.name
        uploadDateLabel.text = info.createDate?.stringWith("YYYY-MM-dd HH:mm:ss")
    }
    
    func setChannelInfo(_ info:ChannelInfo){
        channelInfo = info
        if let url = info.thumbnails{
            channelImg.load(url: url)
        }
        ownerLabel.text = info.name
    }
    
    @objc private func tapThumbnailView(){
        guard let action = clickThumbnail,
              let channelInfo = channelInfo,
              let videoInfo = videoInfo else { return }
        action(channelInfo, videoInfo)
    }
}
