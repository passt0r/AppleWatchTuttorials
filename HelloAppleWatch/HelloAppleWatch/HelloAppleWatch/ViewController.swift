/*
* Copyright (c) 2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var emojiHelloLabel: UILabel!
  @IBOutlet weak var emojiFortuneLabel: UILabel!
  
  let emoji = EmojiData()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    emojiHelloLabel.text = "👋🍎⌚️‼"
    showFortune()
  }
  
  func showFortune() {
    let peopleIndex = emoji.people.count.random()
    let natureIndex = emoji.nature.count.random()
    let objectsIndex = emoji.objects.count.random()
    let placesIndex = emoji.places.count.random()
    let symbolsIndex = emoji.symbols.count.random()
    
    emojiFortuneLabel.text = "\(emoji.people[peopleIndex])\(emoji.nature[natureIndex])\(emoji.objects[objectsIndex])\(emoji.places[placesIndex])\(emoji.symbols[symbolsIndex])"
  }
  
  @IBAction func newFortune(_ sender: AnyObject) {
    showFortune()
  }
  
}

