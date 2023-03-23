const { ethers } = require("hardhat");

const PRICE = ethers.utils.parseEther("0.1");
async function mintAndList(){
    const nftMarketplace = await ethers.getContract("nftMarketplace");
    const basicNft = await ethers.getContract("BasicNft");

    console.log("Minting...");

    const mintTx = await basicNft.mintNft();
    const mintTxReciept = await mintTx.wait(1);
    const tokenId = await mintTxReciept.events[0].args.tokenId;
    console.log("Aproving....");
    const nftApproved = await basicNft.approve(nftMarketplace.address, tokenId);
    await nftApproved.wait(1);
    console.log("Listing Nft...");
    const Tx = await nftMarketplace.listingNft(basicNft.address, tokenId, PRICE);
    await Tx.wait(1);
    console.log("Listed!");

}

mintAndList()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })