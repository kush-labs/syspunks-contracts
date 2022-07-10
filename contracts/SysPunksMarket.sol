// SPDX-License-Identifier: MIT

// @@@@@@@@@@@@@@@@@@@@@@@@@@  SYSPUNKS - 0G NFTS 0N THE NEVM &@@@@@@@@@@@@@@@@@@@@
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
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

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
    string public baseURI;
    string public imageHash = "ac39af4793119ee46bbff351d8cb6b5f23da60222126add4268e261199a2921b";
    uint256 public punksRemainingToAssign = 0;
    uint256 public claimPrice = 100 wei;

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

    constructor () ERC721("SysPunks", "\xC7\xB7\xC7\x9C\xC6\x9D\xC5\x8A\xC4\xB8\xCF\x9A") {
        punksRemainingToAssign = 10000;
    }
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    function mint() payable public {
        require(punksRemainingToAssign > 0, "No remainig punk");
        require(msg.value >= claimPrice, "Need pay at least claim amount");
        uint256 randIndex = _random() % punksRemainingToAssign;
        uint256 punkIndex = _fillAssignOrder(--punksRemainingToAssign, randIndex);
        _safeMint(_msgSender(), punkIndex);
        (bool success,) = owner().call{value: msg.value}("");
        require(success);
        emit Assign(_msgSender(), punkIndex);
    }

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

    function _random() internal view returns(uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / block.timestamp) + block.gaslimit + ((uint256(keccak256(abi.encodePacked(_msgSender())))) / block.timestamp) + block.number)
            )
        ) / punksRemainingToAssign;
    }

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

    receive() external payable {}

}