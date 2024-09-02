//
//  TestItem.swift
//  TelegramDemo
//
//  Created by qmk on 2024/8/16.
//

import UIKit
import Display
import SwiftSignalKit
import MergeLists

class ChatListItem: ListViewItem, Comparable, Identifiable {
    static func < (lhs: ChatListItem, rhs: ChatListItem) -> Bool {
        return lhs.title < rhs.title
    }
    
    static func == (lhs: ChatListItem, rhs: ChatListItem) -> Bool {
        return lhs.title == rhs.title
    }
        
    var stableId: AnyHashable {
        return AnyHashable(self.id)
    }
    
    var id:UUID
    
    let interaction: ChatListNodeInteraction
    
    init(interaction: ChatListNodeInteraction) {
        self.id = UUID()
        self.interaction = interaction
    }
    
    var title: String = ""
    
    func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        async {
            let node = ChatListItemNode()
            
            let (nodeLayout, apply) = node.asyncLayout()(self, params, false, false, false, false)
            
            node.insets = nodeLayout.insets
            node.contentSize = nodeLayout.size
            
            let startTime = Date()
            
//            var array = [1]
//            for i in 0...10000 {
//                array.append(i)
//            }
            
            let endTime = Date()
            let executionTime = endTime.timeIntervalSince(startTime) * 1000
            //                print("executed: \(executionTime) ms")
            print("create node:\(self.title)")
            
            Queue.mainQueue().async {
                completion(node, {
                    return (nil, { _ in
                        node.setupItem(item: self)
                        apply(synchronousLoads, false)
                    })
                })
            }
        }
    }
    
    func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: @escaping () -> ListViewItemNode, params: ListViewItemLayoutParams, previousItem: ListViewItem?, nextItem: ListViewItem?, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping (ListViewItemApply) -> Void) -> Void) {
        
        let a = 1
        
        Queue.mainQueue().async {
            print("update node:\(self.title)")
            if let nodeValue = node() as? ChatListItemNode {
                nodeValue.setupItem(item: self)
                let layout = nodeValue.asyncLayout()
                
                async {
                    let (nodeLayout, apply) = layout(self, params, false, false, false, false)
                    
                    Queue.mainQueue().async {
                        completion(nodeLayout, { _ in
                            apply(false, false)
                        })
                    }
                }
            }
        }
    }
    
    var accessoryItem: ListViewAccessoryItem? {
        return nil
    }
    
    var headerAccessoryItem: ListViewAccessoryItem? {
        return nil
    }
    
    var selectable: Bool {
        return true
    }
    
    var approximateHeight: CGFloat {
        return 70
    }
    
    func selected(listView: ListView) {
        self.interaction.peerSelected(self)
        
    }
    
    
}
