//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error nftMarketPlace__nftPriceZero();
error nftMarkeetplace__notApprovedNFT();
error nftMarketplace__AlreadyListed(address nftAddress, uint256 tokenId);
error nftMarketplace__notOwner();
error nftMarketplace__isNotListed(address nftAddress, uint256 tokenId);
error nftMarketplace__insufficientFundtoBuy(address nftAddress, uint256 token, uint256 price);
error nftMarketplace__NoProceeds();
error nftMarketplace__TransactionFailed();

contract nftMarketplace{

    /////////////////////
    ////Main Functions///
    /////////////////////

    //1. Listing of the nft ✅
    //2. Buying the nft ✅
    //3. Cancelling nft ✅
    //4. Updating nft price ✅
    //5. Withdrawing the amount ✅

    //contractAddress => tokenID => listing item

    struct ListItem{

        uint256 price;
        address seller;
    }

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    event ItemBrought(
        address indexed Buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    event ItemCancelled(
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    modifier AlreadyListed(address nftAddress, uint256 tokenId){
        ListItem memory listingitem = s_nftlisting[nftAddress][tokenId];
        if(listingitem.price > 0){
            revert nftMarketplace__AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    modifier onlyOwner(address nftAddress, uint256 tokenId, address seller){
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if(owner != seller){
            revert nftMarketplace__notOwner();
        }
        _;
    }

    modifier isNotListed(address nftAddress, uint256 tokenId){
        ListItem memory listingitem = s_nftlisting[nftAddress][tokenId];
        if(listingitem.price <= 0){
            revert nftMarketplace__isNotListed(nftAddress,tokenId);
        }
        _;
    }

    mapping(address => mapping(uint256 => ListItem)) private s_nftlisting;
    mapping(address => uint256) private s_proceeds;

    function listingNft(
        
        address nftAddress, 
        uint256 tokenId, 
        uint256 price
        ) external 
        AlreadyListed(nftAddress,tokenId)
        onlyOwner(nftAddress,tokenId,msg.sender){
        
        if(price <= 0){
            revert nftMarketPlace__nftPriceZero();
        }

        IERC721 ierc = IERC721(nftAddress);
        if(ierc.getApproved(tokenId) != address(this)){
            revert nftMarkeetplace__notApprovedNFT();
        }

        s_nftlisting[nftAddress][tokenId] = ListItem({
            price : price,
            seller: msg.sender

        });

        emit ItemListed(msg.sender,nftAddress,tokenId,price);

    }

    function buyItem(
        address nftAddress, 
        uint256 tokenId
        ) external payable 
        isNotListed(nftAddress,tokenId){

        ListItem memory listingitem = s_nftlisting[nftAddress][tokenId];
        if(msg.value < listingitem.price){
            revert nftMarketplace__insufficientFundtoBuy(nftAddress,tokenId,listingitem.price);
        }
        s_proceeds[listingitem.seller] += msg.value;
        delete(s_nftlisting[nftAddress][tokenId]);

        IERC721 ierc = IERC721(nftAddress);
        ierc.safeTransferFrom(listingitem.seller, msg.sender, tokenId);

        emit ItemBrought(msg.sender, nftAddress, tokenId, listingitem.price);
    
        
    }

    function cancelListing(
        address nftAddress, 
        uint256 tokenId
        )external onlyOwner(nftAddress,tokenId,msg.sender) AlreadyListed(nftAddress,tokenId){

        delete(s_nftlisting[nftAddress][tokenId]);
        emit ItemCancelled(nftAddress,tokenId);


    }

    function updateListing(
        address nftAddress, 
        uint256 tokenId, 
        uint256 newPrice
        )external AlreadyListed(nftAddress,tokenId) onlyOwner(nftAddress,tokenId,msg.sender) {
        
        ListItem memory listingitem = s_nftlisting[nftAddress][tokenId];
        listingitem.price = newPrice;

        emit ItemListed(msg.sender,nftAddress,tokenId,newPrice);

    }

    function withDrawProceeds()external{
        uint256 proceed = s_proceeds[msg.sender];
        if(proceed <= 0){
            revert nftMarketplace__NoProceeds();
        }
        s_proceeds[msg.sender] = 0;
        (bool sucess,) = payable(msg.sender).call{value:proceed}("");
        if(!sucess){
            revert nftMarketplace__TransactionFailed();
        }

    }

    /////////////////////
    //////Getters///////
    ////////////////////

    function getListing(address nftAddress, uint256 tokenId)external view returns(ListItem memory){
        return s_nftlisting[nftAddress][tokenId];
    }

    function getProceeds(address seller)external view returns(uint256){
        return s_proceeds[seller];
    }
    
}