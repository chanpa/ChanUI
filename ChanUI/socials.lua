local CUI = CUI

function CUI:CreateFriends()
    if not CUI.db.profile.socials.enableFriendlist then return end
    
    self.friendsTable = {}

    CUI:CreateFriendRoot()
    CUI:CreateFriendsTable()
    CUI:CreateFriendsOnlineFontString()
end