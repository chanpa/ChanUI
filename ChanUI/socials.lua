local CUI = CUI

function CUI:CreateFriends()
    if not CUI.db.profile.socials.enableFriendlist then return end

    -- enabled
    CUI:CreateFriendRoot()
    CUI:CreateFriendsOnline()
end