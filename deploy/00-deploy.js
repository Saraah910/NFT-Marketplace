const {network} = require("hardhat");
const {DevelopmentChains} = require("../helper-hardhat-config");
const {verify} = require("../utils/verify");

module.exports = async function({getNamedAccounts,deployments }){
    const {deploy, log} = deployments;
    const {deployer} = await getNamedAccounts();
    log("-------------------------------------------------")
    args = [];
    
    const nftMarketplace = await deploy("nftMarketplace",{
        from: deployer,
        args: args,
        log: true,      
        blockConfirmations: network.config.blockConfirmations || 1
    })
    log("Deployed sucessfully!")
    if(!DevelopmentChains.includes(network.name) || process.env.ETHERSCAN_API){
        await verify(nftMarketplace.address, args);
    }
}

module.exports.tags = ["all","nftMarketplace"]