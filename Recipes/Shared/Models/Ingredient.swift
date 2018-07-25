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

public class Ingredient: NSObject, NSCoding {

  public let quantity: String
  public let name: String
  public let type: IngredientType
  public var purchased: Bool

  // MARK: NSCoding

  private let QuantityKey = "QuantityKey"
  private let NameKey = "NameKey"
  private let TypeKey = "TypeKey"
  private let PurchasedKey = "Purchased"

  init(quantity: String, name: String, type: IngredientType) {
    self.quantity = quantity
    self.name = name
    self.type = type
    self.purchased = false
  }

  public required init?(coder aDecoder: NSCoder) {
    quantity = aDecoder.decodeObject(forKey: QuantityKey) as! String
    name = aDecoder.decodeObject(forKey: NameKey) as! String
    type = IngredientType(rawValue: aDecoder.decodeObject(forKey: TypeKey) as! String)!
    purchased = aDecoder.decodeBool(forKey: PurchasedKey)
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(quantity, forKey: QuantityKey)
    aCoder.encode(name, forKey: NameKey)
    aCoder.encode(type.rawValue, forKey: TypeKey)
    aCoder.encode(purchased, forKey: PurchasedKey)
  }

}

public func ==(lhs: Ingredient, rhs: Ingredient) -> Bool {
  return lhs.quantity == rhs.quantity &&
  lhs.name == rhs.name &&
  lhs.type == rhs.type
}
