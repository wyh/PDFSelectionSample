//
//  ContentView.swift
//  Shared
//
//  Created by 科研猫 on 2021/12/24.
//

import SwiftUI
import PDFKit


struct ContentView: View {
    
    @State var data: Data = Data()
    @State var texts:String = ""
    
    var body: some View {
        
        TextField("Test FieldBox", text: $texts).onAppear{
            
            guard let path = Bundle.main.path(forResource: "wang", ofType: "pdf") else {
                    return
            }
            
            let fm = FileManager()
                    
            guard let data = fm.contents(atPath: path) else {
                return
            }
            self.data  = data
        }
        
        if (data.count > 0 ) {
            PDFKitView(data: data) { pdfview in
                print("pdfview selection", pdfview.currentSelection)
                
            } setSelection: { pdfview, selection in
                
                print("pdfview", pdfview, selection)
                
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
