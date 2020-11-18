-- constants (redeclaring from blizzard)
local PRICE_DISPLAY_WIDTH = 120;
local PRICE_DISPLAY_WITH_CHECKMARK_WIDTH = 140;
local PRICE_DISPLAY_PADDING = 0;
local BUYOUT_DISPLAY_PADDING = 0;
local STANDARD_PADDING = 10;

-- override sell list layout
function AuctionHouseTableBuilder.GetItemSellListLayout(owner, itemList, isEquipment, isPet)
    local function LayoutItemSellListTableBuilder(tableBuilder)
        tableBuilder:SetHeaderContainer(itemList:GetHeaderContainer());
        tableBuilder:SetColumnHeaderOverlap(2);

        tableBuilder:AddFixedWidthColumn(owner, PRICE_DISPLAY_PADDING, PRICE_DISPLAY_WIDTH, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Bid, "AuctionHouseTableCellBidTemplate");
        tableBuilder:AddFixedWidthColumn(owner, BUYOUT_DISPLAY_PADDING, PRICE_DISPLAY_WITH_CHECKMARK_WIDTH, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Buyout, "AuctionHouseTableCellItemBuyoutTemplate");

        local emptyColumn = tableBuilder:AddFillColumn(owner, 0, 1.0, 0, 0, nil, "AuctionHouseTableEmptyTemplate");
        emptyColumn:SetDisplayUnderPreviousHeader(true);

        if isEquipment then
            local socketColumn = tableBuilder:AddFixedWidthColumn(owner, 0, 24, 0, STANDARD_PADDING, nil, "AuctionHouseTableCellExtraInfoTemplate");
            socketColumn:SetDisplayUnderPreviousHeader(true);

            local itemLevelColumn = tableBuilder:AddFixedWidthColumn(owner, 0, 50, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Level, "AuctionHouseTableCellAuctionsItemLevelTemplate");
            itemLevelColumn:GetHeaderFrame():SetText(ITEM_LEVEL_ABBR);
        elseif isPet then
            -- these two lines are the only difference, just adding the item level column to pet listings
            local itemLevelColumn = tableBuilder:AddFixedWidthColumn(owner, 0, 50, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Level, "AuctionHouseTableCellAuctionsItemLevelTemplate");
            itemLevelColumn:GetHeaderFrame():SetText(AUCTION_HOUSE_BROWSE_HEADER_PET_LEVEL);

            tableBuilder:AddFixedWidthColumn(owner, 0, 90, 0, STANDARD_PADDING, nil, "AuctionHouseTableCellOwnersTemplate");
        else
            local hideBidStatus = true;
            local quantityColumn = tableBuilder:AddFixedWidthColumn(owner, 0, 60, 0, STANDARD_PADDING, nil, "AuctionHouseTableCellItemQuantityRightTemplate", hideBidStatus);
            quantityColumn:SetDisplayUnderPreviousHeader(true);
        end
    end

    return LayoutItemSellListTableBuilder;
end

-- override itemlevel frame data
function AuctionHouseTableCellAuctionsItemLevelMixin:Populate(rowData, dataIndex)
    local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(rowData.itemKey);
    local text = rowData.itemKey.itemLevel;
    if itemKeyInfo then
        if (itemKeyInfo.isPet and rowData.itemLink) then
            -- this block takes care of setting the item level frame text for pets
            -- (the default value, rowData.itemKey.itemLevel, is 0 for pets)
            local linkType, linkOptions, _ = LinkUtil.ExtractLink(rowData.itemLink);
            local _, level, breedQuality = strsplit(":", linkOptions);
            local qualityColor = BAG_ITEM_QUALITY_COLORS[tonumber(breedQuality)];
            text = qualityColor:WrapTextInColorCode(level);
        else
            local itemQualityColor = ITEM_QUALITY_COLORS[itemKeyInfo.quality];
            self.Text:SetTextColor(itemQualityColor.color:GetRGB());
        end
    end

    self.Text:SetText(text);
end

-- remove the dumb warning that pets may vary
function AuctionHouseUtil.AppendBattlePetVariationLines(tooltip)
    return
end