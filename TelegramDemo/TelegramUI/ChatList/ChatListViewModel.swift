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
    
    var items:[ChatListItem] = []
    
    var interaction: ChatListNodeInteraction
    
    init(interaction: ChatListNodeInteraction) {
        self.interaction = interaction
    }
    
    func createInsertItemsTranstion() -> ChatListViewTransition {
        let count = 20
        
        for i in 0..<count {
            let listViewItem = ChatListItem(interaction: self.interaction)
            listViewItem.title = "title \(currentCount)"
                        
            self.items.append(listViewItem)
            
            currentCount += 1
        }
        
        return self.createTestViewTransition(from: nil, to: self.items, scrollPosition: nil, stationaryItemRange: nil)
    }
    
    func createInsertItemsWithOneItemTransition() -> ChatListViewTransition {
        let previousItems = self.items
        
        let listViewItem = ChatListItem(interaction: self.interaction)
        listViewItem.title = "title \(currentCount)"

        self.items.append(listViewItem)        
            
        currentCount += 1
        
        let scrollToItem = ListViewScrollToItem(index: self.items.count - 1, position: ListViewScrollPosition.bottom(0), animated: true, curve: .Default(duration: 0.1), directionHint: .Down)
        
        return self.createTestViewTransition(from: previousItems, to: self.items, scrollPosition: scrollToItem, stationaryItemRange: nil)
    }
    
    func createDeleteItemTransition(item:ChatListItem) -> ChatListViewTransition {
        let previousItems = self.items
        
        let listViewItem = ChatListItem(interaction: self.interaction)
        listViewItem.title = "title \(currentCount)"
        
        let itemIndex = self.items.firstIndex(of: item)
        var stationaryIndex : Int?
        var stationaryItemRange :(Int, Int)?
        
        if let index = itemIndex {
            self.items.remove(at: index)
            
            stationaryIndex = index - 1
        }
        
        if let stationaryIndex = stationaryIndex {
            if stationaryIndex >= 0 {
                stationaryItemRange = (stationaryIndex, stationaryIndex)
            }
                
        }                                

        let scrollToItem = ListViewScrollToItem(index: stationaryIndex ?? 0, position: ListViewScrollPosition.visible, animated: true, curve: .Default(duration: 0.1), directionHint: .Down)
                
        
        return self.createTestViewTransition(from: previousItems, to: self.items, scrollPosition: scrollToItem, stationaryItemRange: stationaryItemRange)
    }
    
    func createDeleteItemsTransition() -> ChatListViewTransition {
        let previousItems = self.items
        
        if self.items.count > 0 {
            self.items.removeLast()
        }        
        
        let scrollToItem = ListViewScrollToItem(index: self.items.count - 1, position: ListViewScrollPosition.bottom(0), animated: true, curve: .Default(duration: 0.1), directionHint: .Down)
        
        return self.createTestViewTransition(from: previousItems, to: self.items, scrollPosition: scrollToItem, stationaryItemRange: nil)
    }
    
    func createUpdateItemsTransition() -> ChatListViewTransition {
        let previousItems = self.items
        
        let count = self.items.count
        if self.items.count > 0 {
            let updateViewItem = ChatListItem(interaction: self.interaction)
            updateViewItem.id = self.items[count - 1].id
            updateViewItem.title = "title update \(self.updateCount)"
            self.items[count - 1] = updateViewItem
            
            self.updateCount += 1
        }
        
        return self.createTestViewTransition(from: previousItems, to: self.items, scrollPosition: nil, stationaryItemRange: nil)
    }
    
    func createBatchTransition() -> ChatListViewTransition {
        let previousItems = self.items
        
        //delete
        if self.items.count > 0 {
            self.items.remove(at: 0)
        }
        
        if self.items.count > 0 {
            self.items.remove(at: 0)
        }
        
        let count = self.items.count
        if count > 0 {
            //update
            let updateViewItem = ChatListItem(interaction: self.interaction)
            updateViewItem.id = self.items[count - 1].id
            updateViewItem.title = "title update \(self.updateCount)"
            self.items[count - 1] = updateViewItem
        }
        
        self.updateCount += 1
        
        //insert
//        let listViewItem = TestListItem()
//        listViewItem.title = "title batch \(self.batchCount)"
//        self.items.append(listViewItem)
//        
//        self.batchCount += 1
        
        return self.createTestViewTransition(from: previousItems, to: self.items, scrollPosition: nil, stationaryItemRange: nil)
    }
    
    
    func createTestViewTransition(from fromView: [ChatListItem]?, to toView: [ChatListItem]?, scrollPosition: ListViewScrollToItem?, stationaryItemRange: (Int, Int)?) -> ChatListViewTransition {
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
    
    
    func preparedChatListNodeViewTransition(from fromView: [ChatListItem]?, to toView: [ChatListItem]?, scrollPosition: ListViewScrollToItem?, stationaryItemRange: (Int, Int)?) -> Signal<ChatListViewTransition, NoError> {
        
        return Signal<ChatListViewTransition, NoError> { subscriber in
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
            
            subscriber.putNext(ChatListViewTransition(deleteItems: adjustedDeleteIndices, insertEntries: adjustedIndicesAndItems, updateEntries: adjustedUpdateItems, scrollToItem: scrollPosition, stationaryItemRange: stationaryItemRange))
            subscriber.putCompletion()
            
            return EmptyDisposable
        }
    }
    
    
}
