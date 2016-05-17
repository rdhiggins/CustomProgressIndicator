//
// CustomProgressView.swift
// MIT License
//
// Copyright (c) 2016 Spazstik Software, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

@IBDesignable
class CustomProgressView: UIView {
    
    @IBInspectable var progress: CGFloat = 0 {
        didSet {
            if progress < 0.0 {
                progress = 0.0
            } else if progress > 1.0 {
                progress = 1.0
            }
            
            self.circlePathLayer.strokeEnd = progress
        }
    }
    
    @IBInspectable var color: UIColor? {
        didSet {
            circlePathLayer.strokeColor = color?.CGColor
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 1 {
        didSet {
            circlePathLayer.lineWidth = lineWidth
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 10 {
        didSet {
            circlePathLayer.shadowRadius = shadowRadius
        }
    }
        
    private let circlePathLayer = CustomShapeLayer()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupShapeLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupShapeLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().CGPath
    }

    private func setupShapeLayer() {
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = lineWidth
        circlePathLayer.fillColor = UIColor.clearColor().CGColor
        circlePathLayer.strokeColor = color?.CGColor
        circlePathLayer.lineCap = kCALineCapRound
        
        layer.addSublayer(circlePathLayer)
    }
    
    
    private func circleFrame() -> CGRect {
        let radius = min(self.center.x, self.center.y)
        var circleFrame = CGRect(x: 0, y: 0, width: 2 * radius - lineWidth, height: 2 * radius - lineWidth)
        circleFrame.origin.x = CGRectGetMidX(circlePathLayer.bounds) - CGRectGetMidX(circleFrame)
        circleFrame.origin.y = CGRectGetMidY(circlePathLayer.bounds) - CGRectGetMidY(circleFrame)
        
        return circleFrame
    }
    
    
    private func circlePath() -> UIBezierPath {
        let frame = circleFrame()
        let center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        let radius = frame.width / 2.0 - lineWidth - shadowRadius
        
        let topAngle: CGFloat = CGFloat(-M_PI_2)
        let endAngle: CGFloat = CGFloat(2 * M_PI - M_PI_2)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: topAngle, endAngle: endAngle, clockwise: true)
        
        return path
    }
}


private class CustomShapeLayer: CAShapeLayer {
    
    private override func actionForKey(event: String) -> CAAction? {
        if event == "strokeEnd" {
            let animation = CABasicAnimation(keyPath: event)
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction(name:  kCAMediaTimingFunctionEaseInEaseOut)
            
            return animation
        } else {
            return super.actionForKey(event)
        }
    }
}
