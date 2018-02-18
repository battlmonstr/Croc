//
//  EmojiReference.swift
//  JKEmoji
//
//  Created by Joseph Kalash on 2/17/18.
//  Copyright © 2018 Joseph Kalash. All rights reserved.
//

internal class EmojiReference {
    
    private var emojiList : Array<Emoji> = []
    
    //For fast lookup of hashcodes
    private var emojiHashcodes : Dictionary<String, Bool> = [:]
    
    init() {
        //Try to read path to file
        if let path = Bundle(for: EmojiReference.self).path(forResource: "emojis", ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
                if let jsonData = try? JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as! Dictionary<String, Dictionary<String, Array<Dictionary<String, AnyObject>>>> {
                    for (group, subgroups) in jsonData {
                        for (subgroup, emojis) in subgroups {
                            for emoji in emojis {
                                if let codepoints_strings  = emoji["codepoints"] as? Array<String>, let description = emoji["description"] as? String {
                                    //Convert codepoints into UInt32
                                    let codepoints = codepoints_strings.flatMap({ return Unicode.Scalar(UInt32($0, radix: 16)!) })
                                    emojiList.append(Emoji(group: EmojiGroup(rawValue: group) ?? .objects,
                                                           subgroup: subgroup,
                                                           codePoints: codepoints,
                                                           description: description))
                                    //Fill in the hashcode of the emojiList
                                    emojiHashcodes[codepoints_strings.joined()] = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func isEmoji(_ unicode_scalar: Array<Unicode.Scalar>) -> Bool {
        //Convert to array of strings and check if maps to dictionary element
        let hex_string = unicode_scalar.flatMap({ String(format:"%04X", UInt32($0))  }).joined()
        return emojiHashcodes[hex_string] != nil
    }
    
    func description(for emoji: Array<Unicode.Scalar>) -> String? {
        for e in self.emojiList {
            if e.codePoints == emoji {
                return e.description
            }
        }
        return nil
    }
    
}

// MARK: Emoji Lookup
extension EmojiReference {
    func subGroups(for group: EmojiGroup) -> [EmojiSubGroup] {
        var subgroups : Set<EmojiSubGroup> = []
        for emoji in self.emojiList {
            if emoji.group == group {
                subgroups.insert(emoji.subgroup)
            }
        }
        
        return Array(subgroups)
    }
    
    func emojis(for subgroup: EmojiSubGroup, limit : Int) -> Array<Character> {
        
        var emojis : Array<Character> = []
        
        for emoji in self.emojiList {
            if emoji.subgroup == subgroup {
                
                // Some of the grapheme types may not yet be supported (Unicode 11.0)
                // As such, converting them to Character type from String will fail.
                // For that, check String element count before appending
                let emojiString = String(String.UnicodeScalarView(emoji.codePoints))
                if emojiString.count == 1 {
                    emojis.append(Character(emojiString))
                }
            }
            
            if emojis.count == limit {
                break
            }
        }
        
        return emojis
        
    }
    
    func emojis(for group: EmojiGroup, limit : Int) -> Array<Character> {
        
        var emojis : Array<Character> = []
        
        for emoji in self.emojiList {
            if emoji.group == group {
                
                // Some of the grapheme types may not yet be supported (Unicode 11.0)
                // As such, converting them to Character type from String will fail.
                // For that, check String element count before appending
                let emojiString = String(String.UnicodeScalarView(emoji.codePoints))
                if emojiString.count == 1 {
                    emojis.append(Character(emojiString))
                }
            }
            
            if emojis.count == limit {
                break
            }
        }
        
        return emojis
        
    }
    
}
