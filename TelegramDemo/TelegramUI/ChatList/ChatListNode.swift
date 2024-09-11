//
//  ChatListNode.swift
//  TelegramDemo
//
//  Created by qmk on 2024/9/3.
//

import UIKit
import Display
import MergeLists

class ChatListNode: ListView {
        
    public var deletePeer: ((_ item: ChatCellData) -> Void)?
    public var peerSelected: ((_ item: ChatCellData) -> Void)?
    public var setItemPinned: ((_ item: ChatCellData, _ pinned: Bool) -> Void)?
    public var setPeerMuted: ((_ item: ChatCellData, _ muted: Bool) -> Void)?
    public var setRead: ((_ item: ChatCellData, _ read: Bool) -> Void)?
    
    private var interaction: ChatListNodeInteraction?
    
    var dataArray:[ChatCellData] = []
    
    override init() {
        super.init()
        
        let interaction = ChatListNodeInteraction { item in
            self.peerSelected?(item.cellData)
        } setItemPinned: { item, pinned in
            self.setItemPinned?(item.cellData, pinned)
        } setPeerMuted: { item, muted in
            self.setPeerMuted?(item.cellData, muted)
        } deletePeer: { item in
            self.deletePeer?(item.cellData)
        } setRead: { item, read in
            self.setRead?(item.cellData, read)
        }
        
        self.interaction = interaction
    }
    
    func updateDataArray(cellDataArray:[ChatCellData], scrollToIndex:Int? = nil) {
        let previousDataArray = self.dataArray
        self.dataArray = cellDataArray
        
        let previousItemArray = self.mapCellDataToItemArray(cellDataArray: previousDataArray)
        let currentItemArray = self.mapCellDataToItemArray(cellDataArray: self.dataArray)  
        
        var index = 0
        var scrollToItem :ListViewScrollToItem?
        if let scrollToIndex = scrollToIndex {
            if scrollToIndex > 0 && scrollToIndex < self.dataArray.count {
                index = scrollToIndex
                scrollToItem = ListViewScrollToItem(index: index, position: ListViewScrollPosition.bottom(0), animated: true, curve: .Default(duration: 0.1), directionHint: .Down)
            }
        }
        
        let transition = self.createChatListNodeViewTransition(from: previousItemArray, to: currentItemArray, scrollPosition: scrollToItem, stationaryItemRange: nil)
        
        self.updateListView(transition: transition)
    }
    
    func updateListView(transition:ChatListViewTransition) {
        self.transaction(deleteIndices: transition.deleteItems, insertIndicesAndItems: transition.insertEntries, updateIndicesAndItems: transition.updateEntries, options: .AnimateAlpha, scrollToItem: transition.scrollToItem, stationaryItemRange: transition.stationaryItemRange, updateOpaqueState: nil)
    }
    
    func mapCellDataToItemArray(cellDataArray:[ChatCellData]) -> [ChatListItem] {
        return cellDataArray.map { cellData in
            let item = ChatListItem(cellData: cellData, interaction: self.interaction!)
            return item
        }
    }
    
    func createChatListNodeViewTransition(from fromView: [ChatListItem]?, to toView: [ChatListItem]?, scrollPosition: ListViewScrollToItem?, stationaryItemRange: (Int, Int)?) -> ChatListViewTransition {
        var adjustedDeleteIndices:[ListViewDeleteItem] = []
        var adjustedIndicesAndItems:[ListViewInsertItem] = []
        var adjustedUpdateItems:[ListViewUpdateItem] = []
        
        let (deleteIndices, indicesAndItems, updateIndices) = mergeListsStableWithUpdates(leftList: fromView ?? [], rightList: toView ?? [], allUpdated: false)
        
        for index in deleteIndices {
            adjustedDeleteIndices.append(ListViewDeleteItem(index: index, directionHint: nil))
        }
        
        for (index, entry, previousIndex) in indicesAndItems {
            adjustedIndicesAndItems.append(ListViewInsertItem(index: index, previousIndex: previousIndex, item: entry, directionHint: nil))
        }
        
        
        for (index, entry, previousIndex) in updateIndices {
            adjustedUpdateItems.append(ListViewUpdateItem(index: index, previousIndex: previousIndex, item: entry, directionHint: nil))
        }
        
        return ChatListViewTransition(deleteItems: adjustedDeleteIndices, insertEntries: adjustedIndicesAndItems, updateEntries: adjustedUpdateItems, scrollToItem: scrollPosition, stationaryItemRange: nil)
    }
    
    func scrollToLastItem() {
        let scrollToItem = ListViewScrollToItem(index: self.dataArray.count - 1, position: ListViewScrollPosition.bottom(0), animated: true, curve: .Default(duration: 0.1), directionHint: .Down)
        let transition = self.createChatListNodeViewTransition(from: [], to: [], scrollPosition: scrollToItem, stationaryItemRange: nil)
        self.updateListView(transition: transition)
    }
}
