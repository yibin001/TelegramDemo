//
//  MyCellData.swift
//  TelegramDemo
//
//  Created by qmk on 2024/9/3.
//

import UIKit

class ChatCellData: NSObject {
    var roomid:String
    var title: String = ""
    
    init(roomid: String, title: String) {
        self.roomid = roomid
        self.title = title
    }
}
