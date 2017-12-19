//
//  MarqueeLabel.swift
//  MarqueeLabel-iOS
//
//  Created by Zhu Shengqi on 18/12/2017.
//

import UIKit

@objc
public final class MarqueeLabel: UIView {
  
  @objc
  public var isPaused: Bool = true {
    didSet {
      if isPaused != oldValue {
        updateScrollState()
      }
    }
  }
  
  @objc
  public var scrollingSpeed: CGFloat = 50 // points per second
  
  @objc
  public let leftPadding: CGFloat
  
  @objc
  public let rightPadding: CGFloat
  
  private let firstSublabel = UILabel()
  private let secondSublabel = UILabel()
  
  private var sublabelLeftConstraints: (NSLayoutConstraint, NSLayoutConstraint)!
  
  private var displayLink: CADisplayLink!
  private var lastTimestamp: CFTimeInterval?
  
  private var panGestureRecognizer: UIPanGestureRecognizer!
  
  // MARK: - Init & Deinit
  @objc
  public init(leftPadding: CGFloat, rightPadding: CGFloat) {
    self.leftPadding = leftPadding
    self.rightPadding = rightPadding
    
    super.init(frame: .zero)
    
    self.clipsToBounds = true
    
    setupUI()
    setupDisplayLink()
    setupGestureRecognizer()
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
    
    resetScrollOffset()
  }
  
  private func setupDisplayLink() {
    let link = CADisplayLink(target: WeakProxy(target: self), selector: #selector(self.displayLinkRefreshed(_:)))
    link.isPaused = true
    link.add(to: .main, forMode: .commonModes)
    self.displayLink = link
  }
  
  private func setupGestureRecognizer() {
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGestureRecognizer(_:)))
    panGestureRecognizer.maximumNumberOfTouches = 1
    addGestureRecognizer(panGestureRecognizer)
  }
  
  // MARK: - UIView Overrides
  public override var frame: CGRect {
    didSet {
      if frame.size != oldValue.size {
        resetScrollOffset()
        updateScrollState()
      }
    }
  }
  
  public override var intrinsicContentSize: CGSize {
    let size = firstSublabel.intrinsicContentSize
    return CGSize(width: size.width + leftPadding + rightPadding, height: size.height)
  }
  
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    let size = firstSublabel.sizeThatFits(size)
    return CGSize(width: size.width + leftPadding + rightPadding, height: size.height)
  }
  
  public override func didMoveToWindow() {
    super.didMoveToWindow()
    
    updateScrollState()
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
        resetScrollOffset()
      } else {
        sublabelLeftConstraints.0.constant -= distanceToScroll
        sublabelLeftConstraints.1.constant -= distanceToScroll
      }
    } else {
      if sublabelLeftConstraints.0.constant - distanceToScroll > leftPadding {
        sublabelLeftConstraints = (sublabelLeftConstraints.1, sublabelLeftConstraints.0)
        resetScrollOffset()
      } else {
        sublabelLeftConstraints.0.constant -= distanceToScroll
        sublabelLeftConstraints.1.constant -= distanceToScroll
      }
    }
  }
  
  @objc
  private func handlePanGestureRecognizer(_ recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
    case .began:
      guard !isPaused else {
        recognizer.isEnabled = false
        recognizer.isEnabled = true
        return
      }
      displayLink.isPaused = true
    case .changed:
      let translation = recognizer.translation(in: self)
      
      sublabelLeftConstraints.0.constant += translation.x
      sublabelLeftConstraints.1.constant += translation.x
      
      if sublabelLeftConstraints.1.constant < leftPadding {
        sublabelLeftConstraints.0.constant += 2 * intrinsicContentSize.width
        sublabelLeftConstraints = (sublabelLeftConstraints.1, sublabelLeftConstraints.0)
      } else if sublabelLeftConstraints.0.constant > leftPadding {
        sublabelLeftConstraints.1.constant -= 2 * intrinsicContentSize.width
        sublabelLeftConstraints = (sublabelLeftConstraints.1, sublabelLeftConstraints.0)
      }
      
      recognizer.setTranslation(.zero, in: self)
    case .ended, .cancelled, .failed, .possible:
      updateScrollState()
    }
  }
  
  // MARK: - Public Methods
  @objc
  dynamic
  public var text: String? {
    get {
      return firstSublabel.text
    }
    set {
      modifyBothSublabels { $0.text = newValue }
    }
  }
  
  @objc
  dynamic
  public var attributedText: NSAttributedString? {
    get {
      return firstSublabel.attributedText
    }
    set {
      modifyBothSublabels { $0.attributedText = newValue }
    }
  }
  
  @objc
  public var font: UIFont! {
    get {
      return firstSublabel.font
    }
    set {
      modifyBothSublabels { $0.font = newValue }
    }
  }
  
  @objc
  public var textColor: UIColor! {
    get {
      return firstSublabel.textColor
    }
    set {
      modifyBothSublabels { $0.textColor = newValue }
    }
  }
  
  @objc
  public var textAlignment: NSTextAlignment {
    get {
      return firstSublabel.textAlignment
    }
    set {
      modifyBothSublabels { $0.textAlignment = newValue }
    }
  }
  
  @objc
  public func transformToNormalLabel() {
    lastTimestamp = nil
    resetScrollOffset()
    self.isPaused = true
  }
  
  // MARK: - Private Methods
  private func modifyBothSublabels(_ block: (UILabel) -> Void) {
    block(firstSublabel)
    block(secondSublabel)
    invalidateIntrinsicContentSize()
    resetScrollOffset()
    updateScrollState()
  }
  
  private func resetScrollOffset() { 
    if scrollingSpeed > 0 {
      sublabelLeftConstraints.0.constant = leftPadding
      sublabelLeftConstraints.1.constant = intrinsicContentSize.width + leftPadding
    } else {
      sublabelLeftConstraints.0.constant = -(intrinsicContentSize.width - leftPadding)
      sublabelLeftConstraints.1.constant = leftPadding
    }
    layoutIfNeeded()
  }
  
  private func updateScrollState() {
    lastTimestamp = nil
    
    if frame.size.width >= intrinsicContentSize.width {
      displayLink.isPaused = true
      
      firstSublabel.isHidden = !(firstSublabel.frame.minX == leftPadding)
      secondSublabel.isHidden = !(secondSublabel.frame.minX == leftPadding)
    } else {
      displayLink.isPaused = window == nil || self.isPaused
      
      firstSublabel.isHidden = false
      secondSublabel.isHidden = false
    }
  }
}

