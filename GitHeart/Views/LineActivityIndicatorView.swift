//
//  LineActivityIndicatorView.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 30.06.2021.
//

import CoreGraphics
import UIKit

/// An activity indicator view as line to indicate processing.
///
/// The animation duration adapts automatically by calculating the duration of previous processing task.
class LineActivityIndicatorView: UIView {
    private let preferredHeight: CGFloat

    private var startAnimationDate: Date?
    private var stopAnimationDate: Date?

    private let barLayer: CALayer = {
        let layer = CALayer()
        layer.anchorPoint = CGPoint(x: 0.0, y: 1.0)
        return layer
    }()

    /// The default animation of the bar.
    ///
    /// By updating this property you will reset the automatically calculated duraton.
    var defaultAnimationDuration: TimeInterval = 2.0 {
        didSet {
            startAnimationDate = nil
            stopAnimationDate = nil
        }
    }

    /// The color of the bar.
    var barColor = UIColor.systemBlue {
        didSet {
            barLayer.backgroundColor = barColor.cgColor
        }
    }

    override init(frame: CGRect) {
        preferredHeight = frame.size.height
        super.init(frame: frame)
        layer.addSublayer(barLayer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        barLayer.frame = CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: preferredHeight)
    }

    /// Starts the animation of a progressing bar.
    func startAnimating() {
        // Calculate the animation duration based on previous runs assuming it will be approx the same.
        var duration = defaultAnimationDuration
        if let start = startAnimationDate, let stop = stopAnimationDate {
            duration = max(0.2, abs(start.timeIntervalSince(stop)))
        }

        stopAnimating()

        let animation = CABasicAnimation(keyPath: "bounds")
        animation.duration = duration
        animation.fromValue = NSValue(cgRect: CGRect(x: 0.0, y: 0.0, width: 0.0, height: bounds.size.height))
        animation.toValue = NSValue(cgRect: CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height))
        barLayer.add(animation, forKey: animation.keyPath)

        startAnimationDate = Date()
    }

    /// Stops the animation.
    func stopAnimating() {
        barLayer.removeAllAnimations()
        setNeedsLayout()
        layoutIfNeeded()

        stopAnimationDate = Date()
    }
}
