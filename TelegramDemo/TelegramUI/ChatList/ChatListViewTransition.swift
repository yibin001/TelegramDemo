//
//  TestViewTransion.swift
//  TelegramDemo
//
//  Created by qmk on 2024/8/23.
//

import UIKit
import Display

struct ChatListNodeView {
    let originalList: [ChatCellData]
//    let filteredEntries: [ChatListNodeEntry]
//    let isLoading: Bool
//    let filter: ChatListFilter?
}

struct ChatListViewTransition {
//    let chatListView: ChatListNodeView
    let deleteItems: [ListViewDeleteItem]
    let insertEntries: [ListViewInsertItem]
    let updateEntries: [ListViewUpdateItem]
//    let options: ListViewDeleteAndInsertOptions
    let scrollToItem: ListViewScrollToItem?
    let stationaryItemRange: (Int, Int)?
//    let adjustScrollToFirstItem: Bool
//    let animateCrossfade: Bool
}
