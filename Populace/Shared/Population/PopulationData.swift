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

protocol PopulationFactObject {
  var country: String {get}
  var populationFactString: String {get}
}

extension PopulationFactObject {
  var readableCountryName: String {
    switch country {
    case "World":                     return "the world"
    case "United States":             return "the United States"
    case "United Kingdom":            return "the United Kingdom"
    case "Rep of Korea":              return "South Korea"
    case "Dem Peoples Rep of Korea":  return "North Korean"
    case "Islamic Republic of Iran":  return "Iran"
      
    default: return country
    }
  }
}

struct PopulationRank : PopulationFactObject {
  let gender: Gender
  let country: String
  let rank: Double
  
  init?(withJson json: NSDictionary) {
    
    guard let genderString = json["sex"] as? String,
      let gender = Gender(serviceKey: genderString),
      let rank = (json["rank"] as AnyObject?)?.doubleValue,
      let country = json["country"] as? String
      else {
        return nil
    }
    
    self.gender = gender
    self.country = country
    self.rank = rank
  }
  
  var populationFactString: String {
    return "You are older than \(commaFormatter.string(from: NSNumber(value: rank))!) of the \(gender.genderNoun) in \(readableCountryName)."
  }
}

struct LifeExpectancy : PopulationFactObject {
  let gender: Gender
  let country: String
  let lifeExpectancy: Double
  
  init?(withJson json: NSDictionary) {
    guard let genderString = json["sex"] as? String,
      let gender = Gender(serviceKey: genderString),
      let country = json["country"] as? String,
      let expectancy = (json["total_life_expectancy"] as AnyObject?)?.doubleValue
      else {
        return nil
    }
    
    self.gender = gender
    self.country = country
    self.lifeExpectancy = expectancy
  }
  
  var populationFactString: String {
    return "The life expectancy of \(gender.genderNoun) in \(readableCountryName) is \(numberFormatter.string(from: NSNumber(value: lifeExpectancy))!) years."
  }
}

struct PopulationData {
  let year: Int
  let ageCohort: Int
  
  let totalPopulation: Int
  let malesPopulation: Int
  let femalesPopulation: Int
  
  init?(withJson json: NSDictionary) {
    guard let year = (json["year"] as AnyObject?)?.integerValue,
      let ageCohort = (json["age"] as AnyObject?)?.integerValue,
      let totalPopulation = (json["total"] as AnyObject?)?.integerValue,
      let malesPopulation = (json["males"] as AnyObject?)?.integerValue,
      let femalesPopulation = (json["females"] as AnyObject?)?.integerValue
      else {
        return nil
    }
    self.year = year
    self.ageCohort = ageCohort
    self.totalPopulation = totalPopulation
    self.malesPopulation = malesPopulation
    self.femalesPopulation = femalesPopulation
  }
}

