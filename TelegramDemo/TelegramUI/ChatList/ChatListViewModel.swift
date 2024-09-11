//
//  TestViewModel.swift
//  TelegramDemo
//
//  Created by qmk on 2024/8/22.
//

import UIKit
import Display
import MergeLists
import SwiftSignalKit

class ChatListViewModel: NSObject {
    var currentCount = 0
    var updateCount = 0
    var batchCount = 0
    
    var cellDataArray:[ChatCellData] = []
        
    func mockData() {
        for i in 0..<20 {
            let cellData = ChatCellData(roomid:"\(currentCount)", title: "title \(currentCount)")
            self.cellDataArray.append(cellData)
            currentCount += 1
        }
    }

    func insertOneMockData() {
        let cellData = ChatCellData(roomid:"\(currentCount)", title: "title \(currentCount)")
        self.cellDataArray.append(cellData)
        currentCount += 1
    }

    func deleteLastItem() {
        if self.cellDataArray.count > 0 {
            self.cellDataArray.removeLast()
        }
    }

    func updateLastItem() {
        if self.cellDataArray.count > 0 {
            let lastCellData = self.cellDataArray[self.cellDataArray.count - 1]
            let newCellData = ChatCellData(roomid:"\(lastCellData.roomid)", title: "title \(updateCount)")            
            self.cellDataArray[self.cellDataArray.count - 1] = newCellData
            updateCount += 1
        }
    }    

    func batchUpdate() {
        if self.cellDataArray.count > 0 {
            self.cellDataArray.removeLast()
        }

        if self.cellDataArray.count > 0 {
            let lastCellData = self.cellDataArray[self.cellDataArray.count - 1]
            let newCellData = ChatCellData(roomid:"\(lastCellData.roomid)", title: "title \(updateCount)")            
            self.cellDataArray[self.cellDataArray.count - 1] = newCellData
            updateCount += 1
        }

        let cellData = ChatCellData(roomid:"\(currentCount)", title: "title \(currentCount)")
        self.cellDataArray.append(cellData)
        currentCount += 1        
    }
}
