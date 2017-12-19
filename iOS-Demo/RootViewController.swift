//
//  RootViewController.swift
//  iOS-Demo
//
//  Created by Zhu Shengqi on 18/12/2017.
//

import UIKit
import MarqueeLabel

class RootViewController: UIViewController {
  
  private lazy var label: MarqueeLabel = {
    let label = MarqueeLabel(leftPadding: 10, rightPadding: 10)
    
    label.text = "addafas"
    label.textColor = .black
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 17)
    label.backgroundColor = UIColor(white: 0, alpha: 0.3)
    label.layer.cornerRadius = 6
    label.scrollingSpeed = 50
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }
  
  private func setupUI() {
    view.backgroundColor = .white
    
    view.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
  
  
}

