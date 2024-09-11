//
//  TestItemNode.swift
//  TelegramDemo
//
//  Created by qmk on 2024/8/20.
//

import UIKit
import Display
import AsyncDisplayKit
import ComponentFlow

private enum RevealOptionKey: Int32 {
    case read
    case pin
    case unpin
    case mute
    case unmute
    case delete
    case group
    case ungroup
    case toggleMarkedUnread
    case archive
    case unarchive
    case hide
    case unhide
    case hidePsa
    case open
    case close
    case edit
}

private let separatorHeight = 1.0 / UIScreen.main.scale

class ChatListItemNode: ItemListRevealOptionsItemNode, UIContextMenuInteractionDelegate {
    var item: ChatListItem?
    
    private let backgroundNode: ASDisplayNode
    private let highlightedBackgroundNode: ASDisplayNode
    
    let contextContainer: ContextControllerSourceNode
    let mainContentContainerNode: ASDisplayNode
    
    public let avatarContainerNode: ASDisplayNode
    public let avatarNode: ASImageNode

    public let titleNode: TextNode
    public let dateNode: TextNode
    public let authorNode: TextNode
    public let textNode: TextNode
    
    public let separatorNode: ASDisplayNode
    
    let badgeNode: ChatListBadgeNode
        
    var interactionAdded = false
    
    init() {     
        self.backgroundNode = ASDisplayNode()
        self.backgroundNode.isLayerBacked = true
        self.backgroundNode.displaysAsynchronously = false
        
        self.highlightedBackgroundNode = ASDisplayNode()
        self.highlightedBackgroundNode.isLayerBacked = true
        
        self.contextContainer = ContextControllerSourceNode()
        
        self.mainContentContainerNode = ASDisplayNode()
        self.mainContentContainerNode.clipsToBounds = true

        self.avatarContainerNode = ASDisplayNode()
        self.avatarContainerNode.isLayerBacked = true
        
        self.avatarNode = ASImageNode()
        self.avatarNode.isLayerBacked = true
        
        self.authorNode = TextNode()
        self.authorNode.isUserInteractionEnabled = false
        self.authorNode.isLayerBacked = true
        
        self.titleNode = TextNode()
        self.titleNode.isUserInteractionEnabled = false
        self.titleNode.displaysAsynchronously = true

        self.textNode = TextNode()

        
        self.dateNode = TextNode()
        self.dateNode.isUserInteractionEnabled = false
        self.dateNode.displaysAsynchronously = true
        
        self.separatorNode = ASDisplayNode()
        self.separatorNode.isLayerBacked = true
        
        self.badgeNode = ChatListBadgeNode()
        
        super.init(layerBacked: false, dynamicBounce: false, rotated: false, seeThrough: false)
        
//        self.backgroundColor = .blue
        self.isAccessibilityElement = true
        
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.separatorNode)
        
        self.addSubnode(self.contextContainer)
        self.contextContainer.addSubnode(self.mainContentContainerNode)
        
        self.mainContentContainerNode.addSubnode(self.titleNode)
        self.mainContentContainerNode.addSubnode(self.avatarContainerNode)
        self.avatarContainerNode.addSubnode(self.avatarNode)
        self.mainContentContainerNode.addSubnode(self.authorNode)
        self.mainContentContainerNode.addSubnode(self.dateNode)
        self.mainContentContainerNode.addSubnode(self.textNode)
        self.mainContentContainerNode.addSubnode(self.badgeNode)
        
//        self.mainContentContainerNode.backgroundColor = .gray
        
    }
    
    func setupItem(item: ChatListItem) {
        self.item = item
        
        if !self.interactionAdded {
            self.interactionAdded = true
            let interaction = UIContextMenuInteraction(delegate: self)
            self.view.addInteraction(interaction)
        }
        
    }
    
    deinit {
        print("ChatListItemNode deinit: \(self.item?.title)")
    }
    
    func asyncLayout() -> (_ item: ChatListItem, _ params: ListViewItemLayoutParams, _ first: Bool, _ last: Bool, _ firstWithHeader: Bool, _ nextIsPinned: Bool) -> (ListViewItemNodeLayout, (Bool, Bool) -> Void) {
        //sub thread
        let dateLayout = TextNode.asyncLayout(self.dateNode)
        let textLayout = TextNode.asyncLayout(self.textNode)
        let titleLayout = TextNode.asyncLayout(self.titleNode)
        let authorLayout = TextNode.asyncLayout(self.authorNode)
        let badgeLayout = self.badgeNode.asyncLayout()
        
        return { item, params, first, last, firstWithHeader, nextIsPinned  in
            //sub thread
            
            //mock data
            let titleStr = item.cellData.title
            let authorStr = "Micheal"
            let textStr = "Hello, I'm Micheal, are you ok?"
            let dateStr = "08/09"
            var unreadCount = 15
            
            let baseFontSize = 17.0
            let baseDisplaySize = 17.0
            let itemListBaseFontSize = 17.0
            
            //itemHeight
            var itemHeight: CGFloat = 0.0
            
            //padding
            var titleTopPaddig = 10.0
            var titleLeftPaddig = 10.0
            var titleBottomPadding = 0.0
            var authorBottomPadding = 0.0
            var textBottomPadding = 10.0
            
            //size
            var avatarLeft = 10.0
            var nodeRightPadding = 10.0
            var avatarDiameter  = 55.0
            let avatarLeftInset = avatarLeft + avatarDiameter
            
            let leftInset: CGFloat = params.leftInset + avatarLeftInset
            let editingOffset: CGFloat = 0
            
            let layoutOffset: CGFloat = 0.0
            
            let rawContentWidth = params.width - leftInset - params.rightInset - nodeRightPadding
            
            itemHeight += titleTopPaddig
            
            //string
            var authorAttributedString: NSAttributedString?
            var authorIsCurrentChat: Bool = false
            var textAttributedString: NSAttributedString?
            var textLeftCutout: CGFloat = 0.0
            var dateAttributedString: NSAttributedString?
            var titleAttributedString: NSAttributedString?
            
            titleAttributedString = NSAttributedString(string: titleStr, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])

            textAttributedString = NSAttributedString(string: textStr, font: UIFont.systemFont(ofSize: 14), textColor: .black)
            
            authorAttributedString = NSAttributedString(string: authorStr, font: UIFont.systemFont(ofSize: 14), textColor: .black)
            
            dateAttributedString = NSAttributedString(string: dateStr, font: UIFont.systemFont(ofSize: 14), textColor: .black)
            
            //badge
            var currentBadgeBackgroundImage: UIImage?
            
            let badgeFont = Font.with(size: floor(itemListBaseFontSize * 14.0 / 17.0), design: .regular, weight: .regular, traits: [.monospacedNumbers])
            
            let badgeDiameter = floor(baseDisplaySize * 20.0 / 17.0)
            
            var badgeContent = ChatListBadgeContent.none
            
            let badgeTextColor: UIColor = .white
            
            if unreadCount > 0 {
                //TODO:YIBIN:unread count convert
                let unreadCountText = "\(unreadCount)"
                badgeContent = .text(NSAttributedString(string: unreadCountText, font: badgeFont, textColor: badgeTextColor))                
                
                currentBadgeBackgroundImage = generateFilledRoundedRectImage(size: CGSize(width: badgeDiameter, height: badgeDiameter), cornerRadius: 0, color: .red)
                
            }
            
            let (badgeLayout, badgeApply) = badgeLayout(CGSize(width: rawContentWidth, height: CGFloat.greatestFiniteMagnitude), badgeDiameter, badgeFont, currentBadgeBackgroundImage, badgeContent)
            
            //date
            let (dateLayout, dateApply) = dateLayout(TextNodeLayoutArguments(attributedString: dateAttributedString, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: rawContentWidth, height: CGFloat.greatestFiniteMagnitude), alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
            
            //title
            let titleRectWidth = rawContentWidth - dateLayout.size.width - 10.0
            
            let (titleLayout, titleApply) = titleLayout(TextNodeLayoutArguments(attributedString: titleAttributedString!, backgroundColor: .clear, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: titleRectWidth, height: CGFloat.greatestFiniteMagnitude), alignment: .natural, cutout: nil, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
            
            itemHeight += titleLayout.size.height
            
            //author
            let (authorLayout, authorApply) = authorLayout(TextNodeLayoutArguments(attributedString: authorAttributedString, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: rawContentWidth, height: CGFloat.greatestFiniteMagnitude), alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
            
            itemHeight += authorLayout.size.height
            itemHeight += authorBottomPadding
            
            //text
            let (textLayout, textApply) = textLayout(TextNodeLayoutArguments(attributedString: textAttributedString, backgroundColor: nil, maximumNumberOfLines: 1, truncationType: .end, constrainedSize: CGSize(width: rawContentWidth, height: CGFloat.greatestFiniteMagnitude), alignment: .natural, cutout: nil, insets: UIEdgeInsets()))
            
            itemHeight += textLayout.size.height
            itemHeight += textBottomPadding
            
            let rawContentRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: rawContentWidth, height: itemHeight))
            
            let layout = ListViewItemNodeLayout(contentSize: CGSize(width: params.width, height: itemHeight), insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            
            return (layout, { [weak self] synchronousLoad, animated in
                //main thread
                if let strongSelf = self {
                    strongSelf.backgroundColor = .brown
                    
                    let transition: ContainedViewLayoutTransition
                    if animated {
                        transition = ContainedViewLayoutTransition.animated(duration: 0.4, curve: .spring)
                    } else {
                        transition = .immediate
                    }
                    
                    var mainContentFrame: CGRect
                    var mainContentBoundsOffset: CGFloat
                    var mainContentAlpha: CGFloat = 1.0
                    
                    
                    mainContentFrame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: layout.contentSize.width, height: layout.contentSize.height))
                    mainContentBoundsOffset = mainContentFrame.origin.x
                    
                    
                    transition.updatePosition(node: strongSelf.mainContentContainerNode, position: mainContentFrame.center)
                    
                    transition.updateBounds(node: strongSelf.mainContentContainerNode, bounds: CGRect(origin: CGPoint(x: mainContentBoundsOffset, y: 0.0), size: mainContentFrame.size))
                    transition.updateAlpha(node: strongSelf.mainContentContainerNode, alpha: mainContentAlpha)
                    
                    let contentRect = rawContentRect.offsetBy(dx:leftInset, dy: 0.0)

                    //date
                    var dateFrame = CGRect(origin: CGPoint(x: contentRect.origin.x + contentRect.size.width - dateLayout.size.width, y: titleTopPaddig), size: dateLayout.size)
                    strongSelf.dateNode.frame = dateFrame
                    strongSelf.dateNode.backgroundColor = .yellow
                    
                    let _ = dateApply()
                    
                    //title
                    let titleFrame = CGRect(origin: CGPoint(x: leftInset + titleLeftPaddig, y: titleTopPaddig), size: titleLayout.size)
                    strongSelf.titleNode.frame = titleFrame
                    strongSelf.titleNode.backgroundColor = .green
                    
                    let _ = titleApply() //render actual title text
                    
                    //author
                    let authorNodeFrame = CGRect(origin: CGPoint(x: titleFrame.minX, y: titleFrame.maxY + titleBottomPadding), size: authorLayout.size)
                    strongSelf.authorNode.frame = authorNodeFrame
                    strongSelf.authorNode.backgroundColor = .cyan
                    
                    let _ = authorApply()
                    
                    //text
                    let textNodeFrame = CGRect(origin: CGPoint(x: titleFrame.minX, y: authorNodeFrame.maxY + authorBottomPadding), size: textLayout.size)
                    strongSelf.textNode.frame = textNodeFrame
                    strongSelf.textNode.backgroundColor = .systemPink
                    
                    let _ = textApply()
                    
                    //seperator
                    let separatorInset = 0.0
                    
                    transition.updateFrame(node: strongSelf.separatorNode, frame: CGRect(origin: CGPoint(x: separatorInset, y: layoutOffset + itemHeight - separatorHeight), size: CGSize(width: params.width - separatorInset, height: separatorHeight)))
                    strongSelf.separatorNode.backgroundColor = .gray
                    
                    //avatar
                    let avatarFrame = CGRect(x: avatarLeft, y: (itemHeight - avatarDiameter)/2 , width: avatarDiameter, height: avatarDiameter)
                    let avatarScaleOffset: CGFloat = 0.0
                    let avatarScale: CGFloat = 1.0

//                    strongSelf.avatarNode.image = UIImage(named: "star")
//                    strongSelf.avatarNode.setImage(with: URL(string: "https://media.istockphoto.com/id/497004261/ja/%E3%82%B9%E3%83%88%E3%83%83%E3%82%AF%E3%83%95%E3%82%A9%E3%83%88/%E3%83%8B%E3%83%A3%E3%83%BC.jpg?s=1024x1024&w=is&k=20&c=LxKL5hLgBgCDjsZ0mmvUG5_dQF91ajTf_6SwU1I1MJI="))
                    
                    //svg image
                    strongSelf.avatarNode.setImage(with: URL(string:"https://static.sending.me/beam/120/@sdn_8763776c166cf6ea3a3a9f5b3bedcc43b05edd76:8763776c166cf6ea3a3a9f5b3bedcc43b05edd76?colors=FC774B,FFB197,B27AFF,DAC2FB,F0E7FD&square"))
                    strongSelf.avatarNode.cornerRadius = avatarFrame.width / 2
                    strongSelf.avatarNode.clipsToBounds = true
                    transition.updateFrame(node: strongSelf.avatarContainerNode, frame: avatarFrame)
                    transition.updatePosition(node: strongSelf.avatarNode, position: avatarFrame.offsetBy(dx: -avatarFrame.minX, dy: -avatarFrame.minY).center.offsetBy(dx: avatarScaleOffset, dy: 0.0))
                    transition.updateBounds(node: strongSelf.avatarNode, bounds: CGRect(origin: CGPoint(), size: avatarFrame.size))
                    transition.updateTransformScale(node: strongSelf.avatarNode, scale: avatarScale)
                    
                    //badge
                    let badgeFrame = CGRect(x: contentRect.maxX - badgeLayout.width, y: dateFrame.maxY + 10.0, width: badgeLayout.width, height: 30)
                    
                    transition.updateFrame(node: strongSelf.badgeNode, frame: badgeFrame)
                    strongSelf.badgeNode.backgroundNode.cornerRadius = badgeLayout.height / 2
                    strongSelf.badgeNode.backgroundNode.clipsToBounds = true
                    
                    let animateBadges = true
                    let isMuted = false
                    
                    let _ = badgeApply(animateBadges, !isMuted)
                    
                    //update node layout
                    strongSelf.updateLayout(size: CGSize(width: layout.contentSize.width, height: itemHeight), leftInset: layout.insets.left, rightInset: layout.insets.right
                    )
                    
                    //revealOptions
                    let readOption = ItemListRevealOption(
                        key: RevealOptionKey.read.rawValue,
                        title: "Read",
                        icon: .image(image: UIImage(named: "icon_read_small")!),
                        color: .lightGray,
                        textColor: .white
                    )
                    
                    let pinOption = ItemListRevealOption(
                        key: RevealOptionKey.pin.rawValue,
                        title: "Pin",
                        icon: .image(image: UIImage(named: "x_pin")!),
                        color: .gray,
                        textColor: .white
                    )
                    
                    let muteOption = ItemListRevealOption(
                        key: RevealOptionKey.mute.rawValue,
                        title: "Mute",
                        icon: .image(image: UIImage(named: "icon_mute_small")!),
                        color: .systemYellow,
                        textColor: .white
                    )
                    
                    let deleteOption = ItemListRevealOption(
                        key: RevealOptionKey.delete.rawValue,
                        title: "Delete",
                        icon: .image(image: UIImage(named: "icon_delete_group")!),
                        color: .red,
                        textColor: .white
                    )
                    
                    let peerRevealOptions:[ItemListRevealOption] = [readOption, pinOption, muteOption, deleteOption]
                    
                    strongSelf.setRevealOptions((left:[], right:peerRevealOptions), enableAnimations: true)
                }
            })
        }
    }
    
    override public func updateRevealOffset(offset: CGFloat, transition: ContainedViewLayoutTransition) {
        super.updateRevealOffset(offset: offset, transition: transition)
        
        transition.updateBounds(node: self.contextContainer, bounds: self.contextContainer.frame.offsetBy(dx: -offset, dy: 0.0))
    }
    
    override public func revealOptionSelected(_ option: ItemListRevealOption, animated: Bool) {
        guard let item = self.item else {
            return
        }                
        
        switch option.key {
        case RevealOptionKey.read.rawValue:
            item.interaction.setRead(item,true)
        
        case RevealOptionKey.pin.rawValue:
            item.interaction.setItemPinned(item, true)
            
        case RevealOptionKey.mute.rawValue:
            item.interaction.setPeerMuted(item, true)
            
        case RevealOptionKey.delete.rawValue:
            item.interaction.deletePeer(item)
            
        default:
            break
        }
        
        
        var close = true                
        
        if close {
            self.setRevealOptionsOpened(false, animated: true)
            self.revealOptionsInteractivelyClosed()
        }
    }
    
    //long press menu
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            // preview vc
            let previewVC = UIViewController()
            previewVC.view.backgroundColor = .green
            return previewVC
        }, actionProvider: { _ in
            // menu items
            let action1 = UIAction(title: "操作1") { _ in print("选择了操作1") }
            let action2 = UIAction(title: "操作2") { _ in print("选择了操作2") }
            return UIMenu(title: "", children: [action1, action2])
        })
    }
    
}

