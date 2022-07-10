// SPDX-License-Identifier: MIT

// PunkLabs -> bringing you SysPunks & more
// MMMMMMMMMMMMMMMMMMMMWWNNNNNNNNNNNNNNNNNNNNNNNNNNNNNWWMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMKo:::::::::::::::::::::::::::::l0MMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMNXXXXXXk;.............................,xXXXXXXNWMMMMMMMM
// MMMMMMMMMMMMNx:;;;;;;'...'.........................',;;;;;:dXMMMMMMMM
// MMMMMMMMMNXK0l'............',;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:dXMMMMMMMM
// MMMMMMMMWk:,,'.............'oKXXXXXXXXXXXXXXXXXXXXXXXXXXXXXNWMMMMMMMM
// MMMMMNK0Ol'.'.'.....,;:::::cOWMMMMMMWK000000XWMMMMMMMMMMMMMMMMMMMMMMM
// MMMMWO:,,'...''.....:0NNNNNNWMMMMMMMKl,,,,,,oNMMMMMMMMMMMMMMMMMMMMMMM
// MMMMWk,.............cKMMMMMMMMMWKOOOd;.....':xOOOOOOOOO0NMMMMMMMMMMMM
// MMMMWk,.............cKMMMMMMMMMXo,''''.''...'''''''''''cKMMMMMMMMMMMM
// MNOxxl,.............cKMMMMMMMMMXl'..'..'''...''........;oxk0WMMMMMMMM
// W0:.''..............cKMMMMMMMMMXl'............'...........'lXMMMMMMMM
// WO:.................,ldd0WMMMMMWOdddo;'..'...'.............;odd0WMMMM
// W0:'''.................'oXWWMMMMMMMMKc'''.....................'oNMMMM
// MN0kkl,..............'..;llo0WMMMMMMN0kko,....................'oNMMMM
// MMMMWk,....................'dXNWWMMMMMMW0:'''.................'oXWWWM
// MMMMWk,..'.................';cco0WMMMMMMNKOOo,.'..............',cclOW
// MMMMWO:,,''....................,xXNNNWMMMMMWO:,,'.....'...........,xW
// MMMMMNKK0o'.................'..';:::oKMMMMMMNKKOl'........'.......,xW
// MMMMMMMMWk:;;'.............'........:0MMMMMMMMMNd'...'....'....';;:kW
// MMMMMMMMMNXX0l'..............'......:0MMMMMMMMMNo'....''....'.'l0XXWM
// MMMMMMMMMMMMNx::::::::::,'.....';:::oKMMMMMMMMMNd'........'...'oNMMMM
// MMMMMMMMMMMMMWNNNNNNNNNXd,.....,xXNNNWMMMMMMMMMNo'.....'.''...'oNMMMM
// MMMMMMMMMMMMMMMMMMMMMMMW0occccco0WMMMMMMNKOOOOOkc'..'.....',:clkWMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMWWWWWWWWWMMMMMMW0:'''''''''.......'cKWWWMMMMM
// MMMMMMMMWXOkkkkkkkkkkkkkkkkkkkkkkkkkkkkko,...'..'.'....,clokNMMMMMMMM
// MMMMMMMMWx,.'''''''''''''''''''''''''''''..'...........:0WWWMMMMMMMMM
// MMMMMMMMWKxdddddl;..........................'..':odddddkNMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMKc''''''''''''''''''''''''''''',xWMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMN0kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkKWMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

pragma solidity ^0.8.1;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract TokenMintLib is Ownable, ReentrancyGuard {

    uint256 constant WET = 10 ** 18; // 18 decimals for most tokens compatibility

    address public tierTokenAddress; // token address to be used as whitelist

    // eternal mint floor - change it as you will
    uint256 public constant lowestPrice = 50 ether;

    // in ether
    struct MintPrices {
        uint256 mintPrice0;
        uint256 mintPrice1;
        uint256 mintPrice2;
        uint256 mintPrice3;
        uint256 mintPrice4;
    }

    // in WET (18 decimals)
    struct MintTiers {
        uint256 tokenTier0;
        uint256 tokenTier1;
        uint256 tokenTier2;
        uint256 tokenTier3;
    }

    MintPrices public prices;

    MintTiers public tiers;

    // Events for admin functions
    event TokenAddressUpdate(address addr);
    event MintPricesChanged(MintPrices);
    event MintTiersChanged(MintTiers);


    function setTokenAddress(address addr) public onlyOwner {
        tierTokenAddress = addr;
        emit TokenAddressUpdate(addr);
    }

    function setMintPrices(MintPrices memory newPrices) public onlyOwner {
            require(newPrices.mintPrice0 > newPrices.mintPrice1, "Prices out of order::0");
            require(newPrices.mintPrice1 > newPrices.mintPrice2, "Prices out of order::1");
            require(newPrices.mintPrice2 > newPrices.mintPrice3, "Prices out of order::2");
            require(newPrices.mintPrice3 > newPrices.mintPrice4, "Prices out of order::3");

        prices = newPrices;

        emit MintPricesChanged(prices);
        }

    function setMintTiers(MintTiers memory newTiers) public onlyOwner {
            require(newTiers.tokenTier0 > newTiers.tokenTier1, "Tiers out of order::0");
            require(newTiers.tokenTier1 > newTiers.tokenTier2, "Tiers out of order::1");
            require(newTiers.tokenTier2 > newTiers.tokenTier3, "Tiers out of order::2");

        tiers = newTiers;

        emit MintTiersChanged(tiers);
        }

    function checkMintPrice(address addr) public view returns (uint256) {
        uint256 luxyHeld = IERC20(tierTokenAddress).balanceOf(addr);
        if (luxyHeld >= tiers.tokenTier0) {
            return prices.mintPrice4;
        } else if (luxyHeld >= tiers.tokenTier1) {
            return prices.mintPrice3;
        } else if (luxyHeld >= tiers.tokenTier2) {
            return prices.mintPrice2;
        } else if (luxyHeld >= tiers.tokenTier3) {
            return prices.mintPrice1;
        } else {
            return prices.mintPrice0;
        }
    }
}
