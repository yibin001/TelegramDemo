//
//  TestViewController.swift
//  TelegramDemo
//
//  Created by qmk on 2024/8/14.
//

import UIKit
import AsyncDisplayKit
import Display
import SwiftSignalKit

class ChatListViewController: UIViewController {

    let listView = ChatListNode()
    var viewModel:ChatListViewModel!
    
    let _contentsReady = ValuePromise<Bool>()

    //create an insert button
    private let insertButton = UIButton()

    //create a delete button
    private let deleteButton = UIButton()

    //create an update button
    private let updateButton = UIButton()

    //create a batch button
    private let batchButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
        self.viewModel = ChatListViewModel()
        
        self.view.backgroundColor = .yellow
    
        self.setupListView()
        
        //create an insert button
        self.view.addSubview(insertButton)
        insertButton.setTitle("Insert", for: .normal)
        insertButton.setTitleColor(.red, for: .normal)
        insertButton.addTarget(self, action: #selector(insertButtonClick), for: .touchUpInside)
        insertButton.frame = CGRect(x: 0, y: listView.frame.origin.y +
                                    listView.frame.size.height, width: 100, height: 50)

        //create a delete button
        self.view.addSubview(deleteButton)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonClick), for: .touchUpInside)
        deleteButton.frame = CGRect(x: 100, y: listView.frame.origin.y + listView.frame.size.height, width: 100, height: 50)

        //create an update button
        self.view.addSubview(updateButton)
        updateButton.setTitle("Update", for: .normal)
        updateButton.setTitleColor(.red, for: .normal)
        updateButton.addTarget(self, action: #selector(updateButtonClick), for: .touchUpInside)
        updateButton.frame = CGRect(x: 200, y: listView.frame.origin.y + listView.frame.size.height, width: 100, height: 50)

        //create a batch button
        self.view.addSubview(batchButton)
        batchButton.setTitle("Batch", for: .normal)
        batchButton.setTitleColor(.red, for: .normal)
        batchButton.addTarget(self, action: #selector(batchButtonClick), for: .touchUpInside)
        batchButton.frame = CGRect(x: 300, y: listView.frame.origin.y + listView.frame.size.height, width: 100, height: 50)       
        
        
        //initial item list
        self.viewModel.mockData()
        let initialCellDataArray = self.viewModel.cellDataArray
        self.listView.updateDataArray(cellDataArray: initialCellDataArray)
        
    }
    
    func setupListView() {
        let viewHeight = self.view.bounds.height
        let viewWidth = self.view.bounds.width
        
        self.listView.frame = CGRect(x: 0, y: 84, width: viewWidth, height: viewHeight - 200)
        self.listView.verticalScrollIndicatorColor = .lightGray
        
        self.view.addSubnode(self.listView)
        
        let sizeAndInsets = ListViewUpdateSizeAndInsets(size: self.listView.frame.size, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), duration: 0, curve: .Spring(duration: 1))
        
        self.listView.transaction(deleteIndices: [], insertIndicesAndItems: [], updateIndicesAndItems: [], options: .AnimateAlpha, scrollToItem: nil, additionalScrollDistance: 0, updateSizeAndInsets: sizeAndInsets, stationaryItemRange: nil, updateOpaqueState: nil, completion: { _ in })

//add listView event
        self.listView.deletePeer = { item in
            print("peer delete:\(item.title)")
        }

        self.listView.setItemPinned = { item, pinned in
            print("peer pinned:\(item.title) \(pinned)")
        }

        self.listView.setPeerMuted = { item, muted in
            print("peer muted:\(item.title) \(muted)")
        }

        self.listView.setRead = { item, read in
            print("peer read:\(item.title) \(read)")
        }        
        
        self.listView.peerSelected = { item in
            print("peer selected:\(item.title)")
        }

    }

    @objc func insertButtonClick() {
        self.viewModel.insertOneMockData()
        self.listView.updateDataArray(cellDataArray: self.viewModel.cellDataArray, scrollToIndex: self.viewModel.cellDataArray.count - 1)
    }

    @objc func deleteButtonClick() {
        self.viewModel.deleteLastItem()
        self.listView.updateDataArray(cellDataArray: self.viewModel.cellDataArray, scrollToIndex: self.viewModel.cellDataArray.count - 1)
    }

    @objc func updateButtonClick() {
        self.viewModel.updateLastItem()
        self.listView.updateDataArray(cellDataArray: self.viewModel.cellDataArray)
    }

    @objc func batchButtonClick() {
        self.viewModel.batchUpdate()
        self.listView.updateDataArray(cellDataArray: self.viewModel.cellDataArray)
    }
}
