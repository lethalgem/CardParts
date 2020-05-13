//
//  CardPartBarView.swift
//  Gala
//
//  Created by Urs, Bharath on 3/29/17.
//  Copyright © 2017 Mint.com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class CardPartBarView: UIView, CardPartView {
    public var margins: UIEdgeInsets = CardParts.theme.cardPartMargins
    public var backgroundLayer: CALayer!
    public var barLayer: CALayer!
    public var verticalLine: CALayer!
    public var barTitle: CATextLayer!
    public var barDescription: CATextLayer!

    
    public init() {
        super.init(frame: CGRect.zero)
        
        backgroundLayer = CALayer()
        backgroundLayer.anchorPoint = .zero
        backgroundLayer.backgroundColor = CardParts.theme.barBackgroundColor.cgColor
        
        barLayer = CALayer()
        barLayer.anchorPoint = .zero
        
        verticalLine = CALayer()
        verticalLine.anchorPoint = .zero
        verticalLine.backgroundColor = CardParts.theme.todayLineColor.cgColor
        
        barTitle = CATextLayer()
        barTitle.anchorPoint = .zero
        
        barDescription = CATextLayer()
        barDescription.anchorPoint = .zero

        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(barLayer)
        self.layer.addSublayer(barTitle)
        self.layer.addSublayer(barDescription)
        
        if CardParts.theme.showTodayLine {
            self.layer.addSublayer(verticalLine)
        }
    }
    
    /**
     The value of percent has to be between 0 and 1.
     If percent is 0.3, the bar will be filled 30% of its width.
     */
    public var percent: Double = 0.0 {
        didSet {
            if percent.isNaN {
                percent = 0
            }
            if percent.isInfinite {
                percent = 0
            }
            updateBarLayer()
        }
    }
    
    public var barHeight: CGFloat? = CardParts.theme.barHeight {
        didSet {
            updateBarLayer()
        }
    }
    
    public var barColor: UIColor = CardParts.theme.barColor {
        didSet {
            updateBarLayer()
        }
    }
    
    public var barTitleString: String = "Text" {
        didSet {
            updateBarLayer()
        }
    }
    
    public var barTextColor: UIColor = UIColor.Gray8 {
        didSet {
            updateBarLayer()
        }
    }
    
    public var barTextTopPadding: CGFloat = 6 {
        didSet {
            updateBarLayer()
        }
    }
    
    public var barTitleLeftPadding: CGFloat = 10 {
        didSet {
            updateBarLayer()
        }
    }
    
    public var barTextFontSize: CGFloat = CGFloat(FontSize.normal.rawValue) {
        didSet {
            updateBarLayer()
        }
    }
    
    public var barDescriptionString: String = "Description" {
        didSet {
            updateBarLayer()
        }
    }
    
    public var barDescriptionRightPadding: CGFloat = 10 {
        didSet {
            updateBarLayer()
        }
    }
    
    public var showBarTitle: Bool = false {
        didSet {
            updateBarLayer()
        }
    }
    
    public var showBarDescription: Bool = false {
        didSet {
            updateBarLayer()
        }
    }
    
    override public func layoutSubviews() {
        updateBarLayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 18.0)
    }
    
    fileprivate func updateBarLayer() {
        
        let desiredHeight = self.barHeight ?? CGFloat(0.75 * self.bounds.height)
        let barWidth = CGFloat(percent) * self.bounds.width
        
        let bounds = CGRect(x: 0, y: 0, width: barWidth , height: desiredHeight)
        barLayer.bounds = bounds
        barLayer.backgroundColor = barColor.cgColor
        if CardParts.theme.roundedCorners {
            barLayer.cornerRadius = bounds.height / 4
        }
        
        let backgroundBounds = CGRect(x: 0, y: 0, width: self.bounds.width , height: desiredHeight)
        backgroundLayer.bounds = backgroundBounds
        if CardParts.theme.roundedCorners {
            backgroundLayer.cornerRadius = bounds.height / 4
        }
        
        if CardParts.theme.showTodayLine {
            let verticalLineBounds = CGRect(x: 0, y: 0, width: 1.0 , height: self.bounds.height)
            verticalLine.bounds = verticalLineBounds
            
            let numberOfDivisions = self.bounds.width / CGFloat(Date().numberOfDaysThisMonth)
            let today = CGFloat(Date().day)
            verticalLine.position = CGPoint(x: today * numberOfDivisions, y: 0)
        }
        
        let barTitleBounds = CGRect(x: 0, y: 0, width: self.bounds.width , height: desiredHeight)
        if showBarTitle {
            barTitle.contentsScale = UIScreen.main.scale
            barTitle.bounds = barTitleBounds
            barTitle.string = barTitleString
            barTitle.foregroundColor = barTextColor.cgColor
            barTitle.font = UIFont.turboGenericMediumFont(.normal)
            barTitle.fontSize = barTextFontSize
            let stringWidth = barTitle.preferredFrameSize().width
            if stringWidth + barTitleLeftPadding >= barWidth {
                barTitle.position = CGPoint(x: barWidth + barTitleLeftPadding, y: barTextTopPadding)
            } else {
                barTitle.position = CGPoint(x: barTitleLeftPadding, y: barTextTopPadding)
            }
        }
        
        let barDescriptionBounds = CGRect(x: 0, y: 0, width: self.bounds.width , height: desiredHeight)
        if showBarDescription {
            barDescription.contentsScale = UIScreen.main.scale
            barDescription.bounds = barDescriptionBounds
            barDescription.string = barDescriptionString
            barDescription.foregroundColor = barTextColor.cgColor
            barDescription.alignmentMode = .left
            barDescription.font = UIFont.turboGenericMediumFont(.normal)
            barDescription.fontSize = barTextFontSize
            let minTitleDescriptionSpacing: CGFloat = 10
            let endOfTitlePosition = barTitle.position.x + barTitle.preferredFrameSize().width + minTitleDescriptionSpacing
            let stringWidth = barDescription.preferredFrameSize().width
            if barWidth <= endOfTitlePosition {
                barDescription.position = CGPoint(x: endOfTitlePosition, y: barTextTopPadding)
                return
            }
            if endOfTitlePosition + stringWidth + barDescriptionRightPadding >= barWidth {
                barDescription.position = CGPoint(x: barWidth + barDescriptionRightPadding, y: barTextTopPadding)
                return
            }
            barDescription.position = CGPoint(x: barWidth - stringWidth - barDescriptionRightPadding, y: barTextTopPadding)
        }
    }
}

extension Reactive where Base: CardPartBarView {
    
    /**
     The value of percent has to be between 0 and 1.
     If percent is 0.3, the bar will be filled 30% of its width.
     */
    public var percent: Binder<Double>{
        return Binder(self.base) { (barView, percent) -> () in
            barView.percent = percent
        }
    }
    
    public var barColor: Binder<UIColor>{
        return Binder(self.base) { (barView, barColor) -> () in
            barView.barColor = barColor
        }
    }
}
