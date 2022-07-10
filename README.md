# syspunks-contracts

Be part of the first official NFT collection on Syscoin NEVM as a Syspunk OG.

![img]()

## Links
- IPFS Data - [ipfs:///](https://gateway.pinata.cloud/ipfs/)
- Contract - [](https://polygonscan.com/address/)
- [Luxy Collection](https://beta.luxy.io/collection/)
- [OpenSea Collection](https://opensea.io/collection/)

## Running
These contracts are compiled and deployed using [Hardhat](https://hardhat.org/).

To prepare the dev environment, run `yarn install`. To compile the contracts, run `npx hardhat compile`. Yarn is available to install [here](https://classic.yarnpkg.com/en/docs/install/#debian-stable) if you need it.

## Deploy Contract
1. Run hardhat command
```shell
npx harhdat run scripts/... --network chosen-network
```

## Generating NFT Collection
```
# create out dir
mkdir -p out
# bootstrap config
nftool traits dump --layers ./layers --out ./out/config.yaml
# - EDIT config.yaml -
# create traits for nft collection
nftool traits make --amount 45 --config ./out/config.yaml --out ./out/collection.json
# generate images 
mkdir -p ./out/images
nftool img gen --width 7000 --height 7000 --collection ./out/collection.json --config ./out/config.yaml --out ./out/images
# generate traits rarity report
nftool rarity traits --collection ./out/collection.json --out ./out/traits_rarity.json
# generate collection rarity rank report
nftool rarity collection --collection ./out/collection.json --out ./out/collection_rarity.json
# generate provenance
nftool provenance --images ./out/images --out ./out/provenance.json --startingIndex 0
# - UPLOAD images to IPFS -
# - EDIT config.yaml to have correct IPFS hash for folder -
# generate ERC-721 metadata
mkdir -p ./out/metadata
nftool metadata --collection ./out/collection.json --config ./out/config.yaml --out ./out/metadata
```

## License
MIT
