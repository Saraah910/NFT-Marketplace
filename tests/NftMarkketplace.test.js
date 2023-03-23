const { network, ethers, getNamedAccounts, deployments } = require("hardhat");
const { DevelopmentChains } = require("../helper-hardhat-config");

!DevelopmentChains.includes(network.name) ? describe.skip : describe("Nft marketplace test", function(){
    let nftMarketplace, basicNft, players;
    const PRICE = ethers.utils.parseEther("0.1");
    const TOKENID = 0;

    beforeEach(async function(){
        deployer = (await getNamedAccounts()).deployer;
        players = (await getNamedAccounts).players;
    })
})