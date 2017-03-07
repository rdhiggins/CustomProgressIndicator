//
// ViewController.swift
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

class ViewController: UIViewController {

   
    @IBOutlet weak var outerRing: CustomProgressView!
    @IBOutlet weak var middleRing: CustomProgressView!
    @IBOutlet weak var innerRing: CustomProgressView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var lessButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outerRing.progress = 0.0
        middleRing.progress = 0.0
        innerRing.progress = 0.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func moreProgress(_ sender: UIButton) {
        outerRing.progress += bumpSmall()
        middleRing.progress += bumpSmall()
        innerRing.progress += bumpSmall()
    }
    
    @IBAction func lessProgress(_ sender: UIButton) {
        outerRing.progress -= bumpSmall()
        middleRing.progress -= bumpSmall()
        innerRing.progress -= bumpSmall()
    }
    
    @IBAction func evenMoreProgress(_ sender: UIButton) {
        outerRing.progress += bumpLarge()
        middleRing.progress += bumpLarge()
        innerRing.progress += bumpLarge()
    }
    
    @IBAction func evenLessProgress(_ sender: UIButton) {
        outerRing.progress -= bumpLarge()
        middleRing.progress -= bumpLarge()
        innerRing.progress -= bumpLarge()
    }
    
    fileprivate func bumpSmall() -> CGFloat {
        return CGFloat(drand48()) / 10.0
    }
    
    fileprivate func bumpLarge() -> CGFloat {
        return 2.0 * CGFloat(drand48())
    }
}

