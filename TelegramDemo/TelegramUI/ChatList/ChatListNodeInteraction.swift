//
//  ChatListNode.swift
//  TelegramDemo
//
//  Created by qmk on 2024/8/28.
//

import UIKit

class ChatListNodeInteraction {
    let peerSelected:(_ item:ChatListItem) -> Void
    let setItemPinned: (_ item:ChatListItem, Bool) -> Void
    let setPeerMuted: (_ item:ChatListItem, Bool) -> Void
    let deletePeer: (_ item:ChatListItem) -> Void
    let setRead: (_ item:ChatListItem, Bool) -> Void
    
    init(peerSelected: @escaping (_: ChatListItem) -> Void, setItemPinned: @escaping (_: ChatListItem, Bool) -> Void, setPeerMuted: @escaping (_: ChatListItem, Bool) -> Void, deletePeer: @escaping (_: ChatListItem) -> Void, setRead: @escaping (_: ChatListItem, Bool) -> Void) {
        self.peerSelected = peerSelected
        self.setItemPinned = setItemPinned
        self.setPeerMuted = setPeerMuted
        self.deletePeer = deletePeer
        self.setRead = setRead
    }
}
