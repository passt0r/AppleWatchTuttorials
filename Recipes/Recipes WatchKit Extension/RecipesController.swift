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
import WatchKit

class RecipesController: WKInterfaceController {
    @IBOutlet var table: WKInterfaceTable!
    let recipeStore = RecipeStore()
    let rowType = "RecipeRowType"
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        var map = [String: [Recipe]]()
        for recipe in recipeStore.recipes {
            var arr = map[recipe.type] ?? [Recipe]()
            arr.append(recipe)
            map[recipe.type] = arr
        }
        for (type, recipes) in map {
            add(withType: type, recipes: recipes)
        }
    }
    
    func add(withType type: String, recipes: [Recipe]) {
        let rows = table.numberOfRows
        table.insertRows(at: IndexSet(integer: rows), withRowType: "HeaderRowType")
        let itemRows = NSIndexSet(indexesIn: NSRange(location: rows + 1, length: recipes.count)) as IndexSet
        table.insertRows(at: itemRows, withRowType: "RecipeRowType")
        
        for rowIndex in rows..<table.numberOfRows {
            let controller = table.rowController(at: rowIndex)
            if let controller = controller as? HeaderRowController {
                controller.image.setImageNamed(type.lowercased())
                controller.label.setText(type)
            } else if let controller = controller as? RecipeRowController {
                let recipe = recipes[rowIndex - rows - 1]
                controller.titleLabel.setText(recipe.name)
                controller.ingredientsLabel.setText("\(recipe.ingredients.count)ingredients")
            }
        }
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return recipeStore.recipes[rowIndex]
    }
}
