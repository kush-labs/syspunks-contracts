// SPDX-License-Identifier: MIT

//                    .........................                
//                   ?^~~~~~~~~~~~~~~~~~~~~~~~~!!              
//             :!~~~?Y:::::::::::::::::::::::::^Y~~~~~~        
//           .G!:::::::::::::^^^^^^^^^^^^^^^^^^^^^^^^^Y:       
//         7~!!^::::::::::::5!~!!~~~~~~~~~~!!!~~!~!~!~.        
//      .~!J:::::::::~!!!!!77     .^~~~~~:                     
//     7Y:^::::::::::?^.....     :P^^^^^:Y: ......             
//     ?5::::::::::::?.       .!~!!::::::~!~!!!!!!~7           
//   :^J?::::::::::::?.       !5:::::::::::::::::::5!^^        
//  5!:::::::::::::::?^       !5::::::::::::::::::::^:5~       
//  P!:::::::::::::::~!~7^     ^YJJ^::::::::::::::::::~!~7^    
//  7?!7~:::::::::::::::~Y::.     !!!7^::::::::::::::::::7!    
//   ..Y5:::::::::::::::::^^B:     ..P!::::::::::::::::::77    
//     75.::::::::::::::::::7!~7      ^!5?:::::::::::::::^!~~! 
//     .?!!~:::::::::::::::::::?: .     ^?!7~:::::::::::::::^Y 
//       .:Y^:::::::::::::::::::::7!      .~G:::::::::::::::^J 
//         .!7P^::::::::::::::::::7!       ~G::::::::::::~J7^. 
//            J7!!!!!!!!~::::::^!~7^       :G::::::::::::7!    
//             .:::::::^G^:::::Y~:         JB::::::::::::7!    
//                      :~7!!7~.     :~~~~~?7:::::::::7Y7:     
//          .::::::::::::::::::::::::P!::::::::::::~!~J.       
//        .5^^^^^^^^^^^^^^^^^^^^^^^^^^::::::::::::^G~:         
//         ^777775!:::::::::::::::::::::::::757777!:           
//               ~7.:::::::::::::::::::::::.7^   


pragma solidity ^0.8.1;
import "./ERC721Enumerable.sol";
import "./TokenMintLib.sol";
import "./SysPunksMarket.sol";

contract SysPunks is Ownable, TokenMintLib, SysPunksMarket {

    string public baseURI = "https://api.syspunks.org";
    string public imageHash = "ac39af4793119ee46bbff351d8cb6b5f23da60222126add4268e261199a2921b";

    uint256 public punksRemainingToAssign = 0;

    event BaseURIUpdate(string uri);

    constructor () {
        punksRemainingToAssign = 10000;

        // launch parameters
        tierTokenAddress = 0x7c896AA52A795EF7559bdcA5c2e046C4CB436760;

        prices = MintPrices({
            mintPrice0:350 ether,
            mintPrice1:300 ether,
            mintPrice2:200 ether,
            mintPrice3:100 ether,
            mintPrice4:50 ether});

        tiers = MintTiers({
        tokenTier0:50000 * WET,
        tokenTier1:20000 * WET,
        tokenTier2:5000 * WET,
        tokenTier3:1000 * WET});

    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
        emit BaseURIUpdate(uri);
    }

    // mint :)
    function mint() payable public nonReentrant {
        require(punksRemainingToAssign > 0, "No punks remaining");
        require(msg.value >= lowestPrice, "Need pay more than lowest amount");
        require(msg.value >= checkMintPrice(msg.sender), "Need to pay more than mint price");
        uint256 randIndex = _random() % punksRemainingToAssign;
        uint256 punkIndex = _fillAssignOrder(--punksRemainingToAssign, randIndex);
        _safeMint(_msgSender(), punkIndex);
        (bool success,) = owner().call{value: msg.value}("");
        require(success);
        emit Assign(_msgSender(), punkIndex);
    }


    // pseudo-random function that's pretty robust because of syscoin's pow chainlocks
    function _random() internal view returns(uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / block.timestamp) + block.gaslimit + ((uint256(keccak256(abi.encodePacked(_msgSender())))) / block.timestamp) + block.number)
            )
        ) / punksRemainingToAssign;
    }

    receive() external payable {
        mint();
    }

}