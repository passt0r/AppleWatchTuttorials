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

import WatchKit
import Foundation
import WatchConnectivity

class MovieRatingController: WKInterfaceController {
  
  var movie: Movie!
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    if let movie = context as? Movie {
      self.movie = movie
      setTitle(movie.title)
    }
  }
  
  @IBAction func oneStarWasTapped() {
    rateMovieWithRating("★☆☆☆☆")
  }
  
  @IBAction func twoStarWasTapped() {
    rateMovieWithRating("★★☆☆☆")
  }
  
  @IBAction func threeStarWasTapped() {
    rateMovieWithRating("★★★☆☆")
  }
  
  @IBAction func fourStarWasTapped() {
    rateMovieWithRating("★★★★☆")
  }
  
  @IBAction func fiveStarWasTapped() {
    rateMovieWithRating("★★★★★")
  }
  
  private func rateMovieWithRating(_ rating: String) {
    TicketOffice.sharedInstance.rateMovie(movie.id, rating: rating)
    sendRatingToPhone(rating)
    pop()
  }
}

// MARK: - Watch Connectivity

extension MovieRatingController {
  
  func sendRatingToPhone(_ rating: String) {
    if WCSession.isSupported() {
      let session = WCSession.default()
      let userInfo = ["movie_id":movie.id, "rating":rating]
      session.transferUserInfo(userInfo)
    }
  }
}
