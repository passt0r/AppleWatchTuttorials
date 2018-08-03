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

import Foundation

class WorldPopulationService: WebService {
  private let baseURL = URL(string: "http://api.population.io")!
  
  init () {
    super.init(rootURL: baseURL)
  }
  
  /**
   Gets a `PopulationRank` object from the population.io `wp-rank` Web Service.
   
   **Note:** The GET request will have a URL pattern like the following:
   
   ```
   /wp-rank/{dob}/{sex}/{country}/today/
   ```
   - parameter configuration: A configuration object that contains, gender, age and country information
   - parameter completion: A completion block that returns the rank data or an error
   */
  func getRankInCountry(_ configuration: PopulationConfiguration,
                        completion: @escaping (_ rank:PopulationRank?, _ error: Error?) -> Void) {
    
    // GET /wp-rank/{dob}/{sex}/{country}/today/
    let path = "/1.0/wp-rank/\(configuration.dobString)/\(configuration.gender.serviceKey)/\(configuration.country)/today/"
    let encodedPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)
    executeDictionaryRequest(encodedPath!) { (dictionary, error) -> Void in
      
      // Make sure you get a dictionary back
      guard let dictionary = dictionary else {
        completion(nil, error)
        return
      }
      
      // Convert the parsed dictionary to a real object
      completion(PopulationRank(withJson: dictionary), error)
    }
  }
  
  /**
   Gets a `LifeExpectancy` object from the population.io `life-expectancy` Web Service.
   
   **Note:** The GET request will have a URL pattern like the following:
   
   ```
   /life-expectancy/total/{sex}/{country}/{dob}/
   ```
   - parameter configuration: A configuration object that contains, gender, age and country information
   - parameter completion: A completion block that returns the life expectancy data or an error
   */
  func getLifeExpectancy(_ configuration: PopulationConfiguration,
                         completion: @escaping (_ expectancy:LifeExpectancy?, _ error: Error?) -> Void) {
    
    let path = "/1.0/life-expectancy/total/\(configuration.gender.serviceKey)/\(configuration.country)/\(configuration.dobString)/"
    let encodedPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)
    executeDictionaryRequest(encodedPath!) { (dictionary, error) -> Void in
      
      // Make sure you get a dictionary back
      guard let dictionary = dictionary else {
        completion(nil, error)
        return
      }
      
      // Convert the parsed dictionary to a real object
      completion(LifeExpectancy(withJson: dictionary), error)
    }
  }
  
  /**
   Gets a `PopulationTable` object from the population.io `population` Web Service.
   
   **Note:** The GET request will have a URL pattern like the following:
   
   ```
   /population/{year}/{country}/
   ```
   - parameter configuration: A configuration object that contains, gender, age and country information
   - parameter completion: A completion block that returns a table of population data or an error
   */
  func getPopulationTable(_ year: Int, country: String,
                          completion: @escaping (_ table:PopulationTable?, _ error: Error?) -> Void) {
    
    // 1
    let path = "/1.0/population/\(year)/\(country)"
    
    // 2
    let encodedPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)
    
    // 3
    executeArrayRequest(encodedPath!) { (array, error) -> Void in
      
      // 4
      // Make sure you get an array back
      guard let array = array else {
        completion(nil, error)
        return
      }
      
      // 5
      completion(PopulationTable(withJson: array), error)
    }
  }
  
}
