//
//  TabBarView.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/10/26.
//

import UIKit

class TabBarView: UIView {
    
    var onTabSelected: ((Int) -> Void)?
    var selectedTab = 0
    var stackView = UIStackView()
    var underlineLeadConstraint: NSLayoutConstraint!
    
    let journalButton = UIButton()
    let mentionsButton = UIButton()
    let underline = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        underline.backgroundColor = UIColor.secondaryLabel
        setButton(button: journalButton, icon: "book.fill", tag: 0)
        setButton(button: mentionsButton, icon: "person.crop.square", tag: 1)
        setStack()
        print(stackView.arrangedSubviews)
        addSubview(stackView)
        addSubview(underline)
        setConstraints()
        selectTab(0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConstraints() {
        underline.translatesAutoresizingMaskIntoConstraints = false
        underlineLeadConstraint = underline.leadingAnchor.constraint(equalTo: leadingAnchor)
        NSLayoutConstraint.activate([
            
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            underline.bottomAnchor.constraint(equalTo: bottomAnchor),
            underline.heightAnchor.constraint(equalToConstant: 2),
            underline.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            underlineLeadConstraint
        ])
    }
    
    func setStack() {
        stackView.addArrangedSubview(journalButton)
        stackView.addArrangedSubview(mentionsButton)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setButton(button b: UIButton, icon: String, tag: Int) {
        b.setImage(UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .default)), for: .normal)
        b.tag = tag
        b.translatesAutoresizingMaskIntoConstraints = false
        let bAction = UIAction { action in
            print("\(b.tag) button tapped")
            self.selectTab(b.tag)
        }
        b.addAction(bAction, for: .touchUpInside)
    }
    
    func selectTab(_ tab: Int) {
        selectedTab = tab
        if (tab == 0) {
            journalButton.tintColor = UIColor.audioRed
            mentionsButton.tintColor = UIColor.systemGray2
        } else {
            mentionsButton.tintColor = UIColor.audioRed
            journalButton.tintColor = UIColor.systemGray2
        }
        
        UIView.animate(withDuration: 0.2) {
            if (tab == 0) {
                self.underlineLeadConstraint.constant = 0
            } else {
                self.underlineLeadConstraint.constant = self.bounds.width / 2
            }
            //print("UNDERLINE LEAD CONSTRAINT: \(self.underlineLeadConstraint.constant, default: "error lol")")
            self.layoutIfNeeded()
        }
        
        onTabSelected?(tab)
    }
}
