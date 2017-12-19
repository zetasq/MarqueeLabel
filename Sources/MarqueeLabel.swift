//
//  MarqueeLabel.swift
//  MarqueeLabel-iOS
//
//  Created by Zhu Shengqi on 18/12/2017.
//

import UIKit

public final class MarqueeLabel: UIView {

  public var scrollingSpeed: CGFloat = 100 // points per second
  
  public let leftPadding: CGFloat
  public let rightPadding: CGFloat
  
  private let firstSublabel = UILabel()
  private let secondSublabel = UILabel()
  
  private var sublabelLeftConstraints: (NSLayoutConstraint, NSLayoutConstraint)!
  
  private var displayLink: CADisplayLink!
  
  private var lastTimestamp: CFTimeInterval?
  
  // MARK: - Init & Deinit
  public init(leftPadding: CGFloat, rightPadding: CGFloat) {
    self.leftPadding = leftPadding
    self.rightPadding = rightPadding
    
    super.init(frame: .zero)
    
    self.clipsToBounds = true
    
    setupUI()
    setupDisplayLink()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    displayLink.invalidate()
  }
  
  // MARK: - Setup
  private func setupUI() {    
    addSubview(firstSublabel)
    firstSublabel.translatesAutoresizingMaskIntoConstraints = false
    firstSublabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    firstSublabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    let firstLabelXConstraint = firstSublabel.leftAnchor.constraint(equalTo: self.leftAnchor)
    firstLabelXConstraint.isActive = true
    
    addSubview(secondSublabel)
    secondSublabel.translatesAutoresizingMaskIntoConstraints = false
    secondSublabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    secondSublabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    let secondLabelXConstraint = secondSublabel.leftAnchor.constraint(equalTo: self.leftAnchor)
    secondLabelXConstraint.isActive = true
    
    self.sublabelLeftConstraints = (firstLabelXConstraint, secondLabelXConstraint)
    
    resetSublabelOffsets()
  }
  
  private func setupDisplayLink() {
    let link = CADisplayLink(target: WeakProxy(target: self), selector: #selector(self.displayLinkRefreshed(_:)))
    link.isPaused = true
    link.add(to: .main, forMode: .commonModes)
    self.displayLink = link
  }
  
  // MARK: - UIView Overrides
  public override var intrinsicContentSize: CGSize {
    let size = firstSublabel.intrinsicContentSize
    return CGSize(width: size.width + leftPadding + rightPadding, height: size.height)
  }
  
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    let size = firstSublabel.sizeThatFits(size)
    return CGSize(width: size.width + leftPadding + rightPadding, height: size.height)
  }
  
  public override func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)
    
    guard self.window != newWindow else {
      return
    }
    
    if newWindow == nil {
      displayLink.isPaused = true
    } else {
      displayLink.isPaused = false
    }
  }
  // MARK: - Action Handlers
  @objc
  private func displayLinkRefreshed(_ link: CADisplayLink) {
    let currentTimestamp = link.timestamp
    defer {
      lastTimestamp = currentTimestamp
    }
    
    guard let lastRefreshTimestamp = lastTimestamp else {
      return
    }
    
    let timeInterval = currentTimestamp - lastRefreshTimestamp
    
    let distanceToScroll = CGFloat(timeInterval) * scrollingSpeed
    
    if scrollingSpeed >= 0 {
      if sublabelLeftConstraints.1.constant - distanceToScroll < leftPadding {
        sublabelLeftConstraints = (sublabelLeftConstraints.1, sublabelLeftConstraints.0)
        resetSublabelOffsets()
      } else {
        sublabelLeftConstraints.0.constant -= distanceToScroll
        sublabelLeftConstraints.1.constant -= distanceToScroll
      }
    } else {
      if sublabelLeftConstraints.0.constant - distanceToScroll > leftPadding {
        sublabelLeftConstraints = (sublabelLeftConstraints.1, sublabelLeftConstraints.0)
        resetSublabelOffsets()
      } else {
        sublabelLeftConstraints.0.constant -= distanceToScroll
        sublabelLeftConstraints.1.constant -= distanceToScroll
      }
    }
  }
  
  // MARK: - Public Methods
  public var text: String? {
    get {
      return firstSublabel.text
    }
    set {
      modifyBothSublabels { $0.text = newValue }
      resetSublabelOffsets()
    }
  }
  
  public var attributedText: NSAttributedString? {
    get {
      return firstSublabel.attributedText
    }
    set {
      modifyBothSublabels { $0.attributedText = newValue }
      resetSublabelOffsets()
    }
  }
  
  public var font: UIFont! {
    get {
      return firstSublabel.font
    }
    set {
      modifyBothSublabels { $0.font = newValue }
      resetSublabelOffsets()
    }
  }
  
  public var textColor: UIColor! {
    get {
      return firstSublabel.textColor
    }
    set {
      modifyBothSublabels { $0.textColor = newValue }
      resetSublabelOffsets()
    }
  }
  
  public var textAlignment: NSTextAlignment {
    get {
      return firstSublabel.textAlignment
    }
    set {
      modifyBothSublabels { $0.textAlignment = newValue }
      resetSublabelOffsets()
    }
  }
  
  public func startAnimating() {
    displayLink?.isPaused = false
  }
  
  public func stopAnimating() {
    displayLink?.isPaused = true
  }
  
  public func transformToNormalLabel() {
    displayLink.isPaused = true
    resetSublabelOffsets()
  }
  
  // MARK: - Private Methods
  private func modifyBothSublabels(_ block: (UILabel) -> Void) {
    block(firstSublabel)
    block(secondSublabel)
    invalidateIntrinsicContentSize()
  }
  
  private func resetSublabelOffsets() { 
    if scrollingSpeed > 0 {
      sublabelLeftConstraints.0.constant = leftPadding
      sublabelLeftConstraints.1.constant = intrinsicContentSize.width + leftPadding
    } else {
      sublabelLeftConstraints.0.constant = -(intrinsicContentSize.width - leftPadding)
      sublabelLeftConstraints.1.constant = leftPadding
    }
  }
}
