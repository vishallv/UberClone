//
//  CircularProgressView.swift
//  UberClone
//
//  Created by Vishal Lakshminarayanappa on 2/23/20.
//  Copyright © 2020 Vishal Lakshminarayanappa. All rights reserved.
//

import UIKit

class CircularProgressView : UIView{
    
    //MARK: Properties
    
    var progressLayer: CAShapeLayer!
    var trackLayer : CAShapeLayer!
    var pulsatingLayer : CAShapeLayer!
    
    //MARK: Life Cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCircleLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Selectors
    
    //MARK: Helper Functions
    
    private func configureCircleLayer(){
        
        pulsatingLayer = circleShapeLayer(strokeColer: .clear, fillColor: .pulsatinFillColor)
        layer.addSublayer(pulsatingLayer)
        
        trackLayer = circleShapeLayer(strokeColer: .trackStrokeColor, fillColor: .clear)
        layer.addSublayer(trackLayer)
        trackLayer.strokeEnd = 1
        
        progressLayer = circleShapeLayer(strokeColer: .outlineStrokeColor, fillColor: .clear)
        layer.addSublayer(progressLayer)
        progressLayer.strokeEnd = 1
        
    }
    
    private func circleShapeLayer(strokeColer : UIColor, fillColor: UIColor)->CAShapeLayer{
        
        let layer = CAShapeLayer()
        let center = CGPoint(x: 0, y: 32)
        let circularPath = UIBezierPath(arcCenter: center, radius: self.frame.width/2.5, startAngle: -(.pi/2), endAngle: 1.5 * .pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColer.cgColor
        layer.lineWidth = 12
        layer.fillColor = fillColor.cgColor
        layer.lineCap = .round
        layer.position = self.center
        return layer
    }
    
     func animatePulsatingLayer(){
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.25
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        pulsatingLayer.add(animation, forKey: "pulsing")
        
        
    }
    
    func setProgressWithAnimation(duration: TimeInterval,value: Float, completion: @escaping()->Void){
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 1
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateProgress")
        
        CATransaction.commit()
    }
}
