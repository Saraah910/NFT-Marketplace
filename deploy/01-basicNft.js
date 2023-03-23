const { network } = require("hardhat");
const { DevelopmentChains } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async function({getNamedAccounts,deployments}){
    const {deploy, log} = deployments;
    const {deployer} = await getNamedAccounts();
    log("--------------------------")

    args = [];
    const basicNft = await deploy("BasicNft",{
        from: deployer,
        args: args,
        log: true,        
        blockConfirmations: network.config.blockConfirmations || 1
    })

    log("Deployed sucessfully!")
    if(!DevelopmentChains.includes(network.name) || process.env.ETHERSCAN_API){
        await verify(basicNft.address, args);
    }
    log("Contract verified sucessfully!")
}

module.exports.tags = ["all","basicNft"]