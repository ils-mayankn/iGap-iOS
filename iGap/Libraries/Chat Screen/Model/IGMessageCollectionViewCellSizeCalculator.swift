/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit

typealias RoomMessageCalculatedSize = (bubbleSize: CGSize,
                                       forwardedMessageBodyHeight: CGFloat,
                                       forwardedMessageAttachmentHeight: CGFloat,
                                       messageBodyHeight: CGFloat,
                                       MessageAttachmentHeight: CGFloat)

class IGMessageCollectionViewCellSizeCalculator: NSObject {
    
    var cache : NSCache<NSString, AnyObject>
    
    static let sharedCalculator = IGMessageCollectionViewCellSizeCalculator()
    
    private override init() {
        cache = NSCache()
        cache.countLimit = 200
        cache.name = "im.igap.cache.IGMessageCollectionViewCellSizeCalculator"
    }
    
    //min image=> 50 x 50
    
    func mainBubbleCountainerSize(for message:IGRoomMessage) -> RoomMessageCalculatedSize {
        var maximumWidth: CGFloat = 0.0
        if message.authorRoom != nil {
            //channel
            maximumWidth = IGMessageCollectionViewCell.ConstantSizes.Bubble.Width.MaximumForChannels
        } else {
            maximumWidth = IGMessageCollectionViewCell.ConstantSizes.Bubble.Width.Maximum
        }
        
        let cacheKey = "\(message.primaryKeyId)_\(message.messageVersion)" as NSString
        let cachedSize = cache.object(forKey: cacheKey)
        if cachedSize != nil {
            return cachedSize as! RoomMessageCalculatedSize
        }
        
        var finalSize = CGSize.zero
        var forwardedMessageBodyHeight: CGFloat = 0.0
        var forwardedMessageAttachmentHeight: CGFloat = 0.0
        var messageBodyHeight: CGFloat = 0.0
        var messageAttachmentHeight: CGFloat = 0.0
        
        
        //let topPadding: CGFloat = 10
        
        if message.forwardedFrom != nil {
            finalSize.height += 20
        } else if message.repliedTo != nil {
            if message.repliedTo!.attachment != nil {
                finalSize.height += 50
            } else {
                finalSize.height += 50
            }
        }
        
        
        //MARK: forwarded
        if let originalMessage = message.forwardedFrom {
            
            //finalSize.height += 30 //height of "forwarded from @..." section
            //TODO: calculate width based on original message sender name
            finalSize.width = 0 // max(finalSize.width, maximumWidth)
            
            //attachment
            if originalMessage.attachment != nil {
                let attachmentFrame = mediaFrame(media: originalMessage.attachment!,
                                                 maxWidth:  maximumWidth,
                                                 maxHeight: IGMessageCollectionViewCell.ConstantSizes.Bubble.Height.Maximum.AttachmentFiled,
                                                 minWidth:  IGMessageCollectionViewCell.ConstantSizes.Bubble.Width.Minimum,
                                                 minHeight: IGMessageCollectionViewCell.ConstantSizes.Bubble.Height.Minimum.WithAttachment)
                
                switch originalMessage.type {
                case .text:
                    break
                case .image, .imageAndText, .video, .videoAndText, .gif, .gifAndText:
                    forwardedMessageAttachmentHeight = attachmentFrame.height
                    finalSize.height += attachmentFrame.height
                    finalSize.width = max(finalSize.width, attachmentFrame.width)
                    finalSize.width = min(finalSize.width, maximumWidth)
                case .audio, .audioAndText:
                    forwardedMessageAttachmentHeight = 91.0
                    finalSize.width = max(finalSize.width, attachmentFrame.width)
                    finalSize.width = min(finalSize.width, maximumWidth)
                    finalSize.height = 91.0 + 4.0
                case .voice:
                    forwardedMessageAttachmentHeight = 68
                    finalSize.width = max(finalSize.width, attachmentFrame.width)
                    finalSize.width = min(finalSize.width, maximumWidth)
                    finalSize.height += 68.0 + 4.0
                case .file, .fileAndText:
                    forwardedMessageAttachmentHeight = 55.0
                    finalSize.width = max(finalSize.width, attachmentFrame.width)
                    finalSize.width = min(finalSize.width, maximumWidth)
                    finalSize.height += 55.0 + 4.0
                case .location:
                    fallthrough
                case .log:
                    finalSize.height = 450.0
                //return finalSize
                case .contact:
                    finalSize.height += 50
                case .unknown:
                    break
                }
            }
            
            //body
            if let text = originalMessage.message as NSString? {
                let stringRect = IGMessageCollectionViewCell.bodyRect(text: text, isEdited: false, addArbitraryTexts: false)
                finalSize.height += stringRect.height
                finalSize.width = max(finalSize.width, stringRect.width)
                finalSize.width = min(finalSize.width, maximumWidth)
                forwardedMessageBodyHeight = stringRect.height
            }
        }
        
        //MARK: attachment
        if message.attachment != nil {
            let attachmentFrame = mediaFrame(media: message.attachment!,
                                             maxWidth:  maximumWidth,
                                             maxHeight: IGMessageCollectionViewCell.ConstantSizes.Bubble.Height.Maximum.AttachmentFiled,
                                             minWidth:  IGMessageCollectionViewCell.ConstantSizes.Bubble.Width.Maximum,
                                             minHeight: IGMessageCollectionViewCell.ConstantSizes.Bubble.Height.Minimum.WithAttachment)
            
            switch message.type {
            case .text:
                break
            case .image, .imageAndText, .video, .videoAndText, .gif, .gifAndText:
                finalSize.height += attachmentFrame.height
                messageAttachmentHeight = attachmentFrame.height
                //finalSize.width = attachmentFrame.width
                finalSize.width = max(finalSize.width, attachmentFrame.width)
                finalSize.width = min(finalSize.width, maximumWidth)
            case .audio, .audioAndText:
                finalSize.width = max(finalSize.width, attachmentFrame.width)
                finalSize.width = min(finalSize.width, maximumWidth)
                finalSize.height += 91.0 + 4.0
            case .voice:
                finalSize.width = max(finalSize.width, attachmentFrame.width)
                finalSize.width = min(finalSize.width, maximumWidth)
                finalSize.height += 68.0 + 4.0
            case .file, .fileAndText:
                finalSize.width = max(finalSize.width, attachmentFrame.width)
                finalSize.width = min(finalSize.width, maximumWidth)
                finalSize.height += 55.0 + 4.0
                break
            case .location:
                break
            case .log:
                finalSize.height = 600.0
                break
            case .contact:
                finalSize.height += 50
            case .unknown :
                break
            }
        }
        
        
    
        
        
        
       
        
        
        
        if let text = message.message as NSString? {
            let stringRect = IGMessageCollectionViewCell.bodyRect(text: text, isEdited: message.isEdited, addArbitraryTexts: true)
            finalSize.height += stringRect.height
            //finalSize.width = min(finalSize.width, stringRect.width + 25)
            finalSize.width = max(finalSize.width, stringRect.width + 25)
            finalSize.width = min(finalSize.width, maximumWidth)
            messageBodyHeight = stringRect.height
            //print("Hieght for  \(text) : \(stringRect.height)")
        } else {
            //finalSize.height += 4.0 //padding
        }
        
        if message.type == .log {
            finalSize.height = 30.0
        } else if message.type == .contact {
            let contactSize = IGContactInMessageCellView.sizeForContact(message.contact!)
            finalSize.width = min(finalSize.width, contactSize.width)
            finalSize.height += contactSize.height
        } else {
            finalSize.height = max(IGMessageCollectionViewCell.ConstantSizes.Bubble.Height.Minimum.TextOnly + 6, finalSize.height)
        }
        
        
        finalSize.height += 7.5
        
        let result = (finalSize,
                      forwardedMessageBodyHeight,
                      forwardedMessageAttachmentHeight,
                      messageBodyHeight,
                      messageAttachmentHeight)
        
        cache.setObject(result as AnyObject, forKey: cacheKey)
        
        return result
    }
    
    func mediaFrame(media: IGFile, maxWidth: CGFloat, maxHeight: CGFloat, minWidth: CGFloat, minHeight: CGFloat) -> CGSize {
        if media.width != 0 && media.height != 0 {
            var width = CGFloat(media.width)
            var height = CGFloat(media.height)
            if width > maxWidth && height > maxHeight {
                if width/maxWidth > height/maxHeight {
                    height = height * maxWidth/width
                    width = maxWidth
                } else {
                    width = width * maxHeight/height
                    height = maxHeight
                }
            } else if width > maxWidth {
                height = height * maxWidth/width
                width = maxWidth
            } else if height > maxHeight {
                width = width * maxHeight/height
                height = maxHeight
            }
            width  = max(width, minWidth)
            height = max(height, minHeight)
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: minWidth, height: minHeight)
        }
    }
    
}
