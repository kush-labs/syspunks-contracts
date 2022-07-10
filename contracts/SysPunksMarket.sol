// SPDX-License-Identifier: MIT

// @@@@@@@@@@@@@@@@@@@@@@@@@@ SYSPUNKS - 0G NFTS 0N THE NEVM &@@@@@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@@@@@@%#*.................................*.@%@@@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@&,,*** *.#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%, /****,,@@@@@@@@@@@
// @@@@@@@@@@@@@@@*//////(/(%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%(//////(*.&&@@@@@@@@
// @@@@@@@@@@@,#&& (%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#,,/@@@@@@@@
// @@@@@@@@@/,*#%%%%%%%%%%%%%%%%%%%%#.................................../@@@@@@@@@@
// @@@@@@#*//.,%%%%%%%%%%%%%%%%%%%%&(.@/(((( (*///////  ((((((((((((((#@@@@@@@@@@@@
// @@@@#/ /%%%%%%%%%%%%%%%%#.       (, &@@*% *%%%%%%%&/ #@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@@@(, /%%%%%%%%%%%%%%%%#, .@@@@@@@@.#*...*%%%%%%%&/ ...........((/@@@@@@@@@@@@@
// @@@&.  /%%%%%%%%%%%%%%%%#,  @@@@@@/,*.(%%%%%%%%%%%%%%%%%%%%%%%%%/ @.##@@@@@@@@@@
// @,,****(%%%%%%%%%%%%%%%%#,  @@@@@@/.*.(%%%%%%%%%%%%%%%%%%%%%%%%%(***,.((@@@@@@@@
// . .#%%%%%%%%%%%%%%%%%%%%#,@,/*%@@@/  .#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#,%.,*(@@@@@
// , .#%%%%%%%%%%%%%%%%%%%%%%%%#,*,@@@@...   *%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#,(,&@@@
//   .%%%%%%%%%%%%%%%%%%%%%%%%%%,   &..@@,.@ *%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*   @@@
// @/&    /%%%%%%%%%%%%%%%%%%%%%%&%&(.@.@@@@,&   .%%%%%%%%%%%%%%%%%%%%%%%%%%* @ @@@
// @@@@,. /%%%%%%%%%%%%%%%%%%%%%%%%%# ...& @@@@,..#%%%%%%%%%%%%%%%%%%%%%%%%%*..., /
// @@@@.. /%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%,/ @@@@@%&&% /&%%%%%%%%%%%%%%%%%%%%%%%%(.@
// @@@@@.#*///(%%%%%%%%%%%%%%%%%%%%%%%%%%/(((*%/@@@@( *///(%%%%%%%%%%%%%%%%%%%%%(.@
// @@@@@@&,/%,,%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%/ %&@@@@@@*# ,%%%%%%%%%%%%%%%%%%%%%(.@
// @@@@@@@@@#*,.,,.(%%%%%%%%%%%%%%%%%%%%%%%%%/ %&@@@@@@/( ,%%%%%%%%%%%%%%%%%/.,,/.@
// @@@@@@@@@@@@# & (%%%%%%%%%%%%%%%%%%%%%%%%%/ %&@@@@@@@/ ,%%%%%%%%%%%%%%%%%*.. @@@
// @@@@@@@@@@@@@@%(             (&%%%%%%%,   (*@@@@@@@@#( ,%%%%%%%%%%%%%%%%%*   @@@
// @@@@@@@@@@@@@@@@@///////// * /&%%%%%%%*//%@@@%*.       ,%%%%%%%%%%%%%%%%%*(/&@@@
// @@@@@@@@@@@@################*#.,...,,,,,####*..%%%%%%%%%%%%%%%%%%%%%#.., .%@@@@@
// @@@@@@@@@@##*,*******,***********************,*%%%%%%%%%%%%%%%%%#(((/,%&@@@@@@@@
// @@@@@@@@@.,,%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%/ #&,%@@@@@@@@@@
// @@@@@@@@@.%,.,,,,,,./%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%(.,,,,,,..,*@@@@@@@@@@@@@
// @@@@@@@@@@@%.       ,&%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%( ,.     %@@@@@@@@@@@@@@@
// @@@@@@@@@@@@@@@@@@# %@&@@@@@@@@@*  @@@@@@@@@@@@@@@@@@#%@.%@@@@@@@@@@@@@@@@@@@@@@

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721Enumerable.sol";

contract SysPunksMarket is ERC721Enumerable, Ownable, ReentrancyGuard {

    struct Offer {
        bool isForSale;
        uint256 punkIndex;
        address seller;
        uint256 minValue;          // in ether
        address onlySellTo;     // specify to sell only to a specific person
    }

    struct Bid {
        bool hasBid;
        uint256 punkIndex;
        address bidder;
        uint256 value;
    }

    mapping(uint256 => uint256) private assignOrders;

    mapping (uint256 => Offer) public punksOfferedForSale;
    mapping (uint256 => Bid) public punkBids;
    mapping (address => uint256) public pendingWithdrawals;

    modifier onlyTradablePunk (address from, uint256 tokenId) {
        require(tokenId < 10000, "Out of tokenId");
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        _;
    }

    event Assign(address indexed to, uint256 punkIndex);
    event PunkTransfer(address indexed from, address indexed to, uint256 punkIndex);
    event PunkOffered(uint256 indexed punkIndex, uint256 minValue, address indexed toAddress);
    event PunkBidEntered(uint256 indexed punkIndex, uint256 value, address indexed fromAddress);
    event PunkBidWithdrawn(uint256 indexed punkIndex, uint256 value, address indexed fromAddress);
    event PunkBought(uint256 indexed punkIndex, uint256 value, address indexed fromAddress, address indexed toAddress);
    event PunkNoLongerForSale(uint256 indexed punkIndex);

    constructor () ERC721("SysPunks", "\xC7\xB7\xC7\x9C\xC6\x9D\xC5\x8A\xC4\xB8\xCF\x9A") {}

    // on-chain marketplace -> you should use luxy tho :P

    function transferPunk(address to, uint256 tokenId) public {
        _safeTransfer(_msgSender(), to, tokenId, "");
    }

    function punkNoLongerForSale(uint256 tokenId) public {
        _punkNoLongerForSale(_msgSender(), tokenId);
    }

    function offerPunkForSale(uint256 tokenId, uint256 minSalePriceInWei) public onlyTradablePunk(_msgSender(), tokenId) {
        punksOfferedForSale[tokenId] = Offer(true, tokenId, _msgSender(), minSalePriceInWei, address(0));
        emit PunkOffered(tokenId, minSalePriceInWei, address(0));
    }

    function offerPunkForSaleToAddress(uint256 tokenId, uint256 minSalePriceInWei, address toAddress) public onlyTradablePunk(_msgSender(), tokenId) {
        punksOfferedForSale[tokenId] = Offer(true, tokenId, _msgSender(), minSalePriceInWei, toAddress);
        emit PunkOffered(tokenId, minSalePriceInWei, toAddress);
    }

    function buyPunk(uint256 tokenId) payable public {
        Offer memory offer = punksOfferedForSale[tokenId];
        require(tokenId < 10000, "Out of tokenId");
        require(offer.isForSale, "Punk is not for sale");
        require(offer.onlySellTo == address(0) || offer.onlySellTo == _msgSender(), "Unable to sell");
        require(msg.value >= offer.minValue, "Insufficient amount to pay");
        require(ownerOf(tokenId) == offer.seller, "Not punk seller");

        address seller = offer.seller;
        _safeTransfer(seller, _msgSender(), tokenId, "");
        pendingWithdrawals[seller] += msg.value;
        emit PunkBought(tokenId, msg.value, seller, _msgSender());
    }

    function withdraw() public nonReentrant {
        uint256 amount = pendingWithdrawals[_msgSender()];
        pendingWithdrawals[_msgSender()] = 0;
        (bool success,) = _msgSender().call{value: amount}("");
        require(success);
    }

    function enterBidForPunk(uint256 tokenId) public payable {
        require(tokenId < 10000, "Out of tokenId");
        require(ownerOf(tokenId) != _msgSender(), "Invalid bid");
        require(msg.value > punkBids[tokenId].value, "Require bigger amount");
        Bid memory existing = punkBids[tokenId];
        if (existing.value > 0) {
            // Refund the failing bid
            pendingWithdrawals[existing.bidder] += existing.value;
        }
        punkBids[tokenId] = Bid(true, tokenId, _msgSender(), msg.value);
        emit PunkBidEntered(tokenId, msg.value, _msgSender());
    }

    function acceptBidForPunk(uint256 tokenId, uint256 minPrice) public onlyTradablePunk(_msgSender(), tokenId) {
        require(punkBids[tokenId].value >= minPrice, "Bid price is low");
        Bid memory bid = punkBids[tokenId];

        punkBids[tokenId] = Bid(false, tokenId, address(0), 0);
        _safeTransfer(_msgSender(), bid.bidder, tokenId, "");

        uint256 amount = bid.value;
        pendingWithdrawals[_msgSender()] += amount;
        emit PunkBought(tokenId, bid.value, _msgSender(), bid.bidder);
    }

    function withdrawBidForPunk(uint256 tokenId) public {
        require(tokenId < 10000, "Out of tokenId");
        require(ownerOf(tokenId) != _msgSender(), "Invalid bid");
        require(punkBids[tokenId].bidder == _msgSender(), "Invalid bidder");
        uint256 amount = punkBids[tokenId].value;
        punkBids[tokenId] = Bid(false, tokenId, address(0), 0);
        // Refund the bid money
        (bool success,) = _msgSender().call{value: amount}("");
        require(success);
        emit PunkBidWithdrawn(tokenId, punkBids[tokenId].value, _msgSender());
    }

    // internal
    function _fillAssignOrder(uint256 orderA, uint256 orderB) internal returns(uint256) {
        uint256 temp = orderA;
        if (assignOrders[orderA] > 0) temp = assignOrders[orderA];
        assignOrders[orderA] = orderB;
        if (assignOrders[orderB] > 0) assignOrders[orderA] = assignOrders[orderB];
        assignOrders[orderB] = temp;
        return assignOrders[orderA];
    }

    function _transfer(address from, address to, uint256 tokenId) internal override onlyTradablePunk(from, tokenId) {
        super._transfer(from, to, tokenId);
        emit PunkTransfer(from, to, tokenId);
        if (punksOfferedForSale[tokenId].isForSale) {
            _punkNoLongerForSale(to, tokenId);
        }

        if (punkBids[tokenId].bidder == to) {
            pendingWithdrawals[to] += punkBids[tokenId].value;
            punkBids[tokenId] = Bid(false, tokenId, address(0), 0);
        }
    }

    function _punkNoLongerForSale(address from, uint256 tokenId) internal onlyTradablePunk(from, tokenId) {
        punksOfferedForSale[tokenId] = Offer(false, tokenId, from, 0, address(0));

        emit PunkNoLongerForSale(tokenId);
    }

}