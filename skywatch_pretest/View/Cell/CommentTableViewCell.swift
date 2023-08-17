//
//  CommentTableViewCell.swift
//  skywatch_pretest
//
//  Created by liyuan chang on 2023/7/31.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    lazy private var userImg: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.adjustsImageSizeForAccessibilityContentSizeCategory = false
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy private var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy private var uploadDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy private var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    lazy private var likeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()
    
    private var commentInfo: CommentThread?
    
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        userImg.layer.cornerRadius = userImg.bounds.midX
    }
    
    private func setupUI() {
        contentView.addSubview(userImg)
        userImg.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.top.left.equalTo(contentView).offset(5)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(userImg)
            make.left.equalTo(userImg.snp.right).offset(10)
        }
        
        contentView.addSubview(uploadDateLabel)
        uploadDateLabel.snp.makeConstraints { make in
            make.top.equalTo(userImg)
            make.left.equalTo(nameLabel.snp.right).offset(5)
            make.centerY.equalTo(nameLabel)
            make.right.equalTo(contentView).offset(-5)
        }
        
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(nameLabel)
            make.right.equalTo(uploadDateLabel)
        }
        
        contentView.addSubview(likeLabel)
        likeLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(5)
            make.right.equalTo(contentLabel)
        }
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = .darkGray
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(likeLabel.snp.bottom).offset(5)
            make.right.left.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-5)
        }
    }
    
    func setCommentInfo(_ info: CommentThread) {
        commentInfo = info
        if let url = info.thumbnail {
            userImg.load(url: url)
        }
        nameLabel.text = info.authorName.toProtectPersonalName()
        contentLabel.text = info.content
        likeLabel.text = "\(info.likeCount) like."
        uploadDateLabel.text = info.createDate.stringWith("YYYY-MM-dd HH:mm:ss")
    }

}
