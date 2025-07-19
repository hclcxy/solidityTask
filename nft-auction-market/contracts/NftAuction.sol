// SPDX-License-Identifier: MIT
pragma solidity  ~0.8;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract NftAuction is Initializable, UUPSUpgradeable {
    // Auction structure
    struct Auction {

        //卖家
        address seller;
        //拍卖持续时间
        uint256 duration;

        //起拍价格
        uint256 startPrice;
        //最高出价者
        address highestBidder;
        //最高价格
        uint256 highestBid;

        //拍卖开始时间
        uint256 startTime;
        //是否结束
        bool ended;

        //合约地址
        address contractAddress;
        //NFT ID
        uint256 tokenId;

        //参加竞价的资产类型
        //0x地址表示eth 其他的地址ERC20
        address tokenAddress;
    }

    //状态变量
    mapping(uint256 => Auction) public auctions;

    //下一个拍卖ID
    uint256 public nextAuctionId;
    //管理员地址
    address public admin;

     // AggregatorV3Interface internal priceETHFeed;

    mapping(address => AggregatorV3Interface) public priceFeeds;


    function initialize() initializer public {
        admin = msg.sender; // 设置合约创建者为管理员
    }

    //设置价格预言机
    function setPriceFeed(address tokenAddress, address _priceFeed) public {
        priceFeeds[tokenAddress] = AggregatorV3Interface(_priceFeed);
    }

    //获取ETH的最新价格
    function getChainlinkDataFeedLatestAnswer(address tokenAddress) public view returns (int) {
        AggregatorV3Interface priceFeed = priceFeeds[tokenAddress];
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return answer;
    }

    //创建拍卖
    function createAuction(uint256 _duration, uint256 _startPrice, address _contractAddress, uint256 _tokenId) external {
        //只有管理员可以创建拍卖
        require(msg.sender == admin, "Only admin can create auctions");
        //确保持续时间和起拍价格大于0
        require(_duration >= 10, "Duration must be greater than 10 seconds");
        require(_startPrice > 0, "Start price must be greater than 0");

        // 转移NFT到合约
        IERC721(_contractAddress).approve(address(this), _tokenId);
        IERC721(_contractAddress).safeTransferFrom(msg.sender, address(this), _tokenId);
        auctions[nextAuctionId] = Auction({
            seller: msg.sender,
            duration: _duration,
            startPrice: _startPrice,
            highestBidder: address(0),
            highestBid: 0,
            startTime: block.timestamp,
            ended: false,
            contractAddress: _contractAddress,
            tokenId: _tokenId,
            tokenAddress: address(0) // 默认使用ETH
        });
        nextAuctionId++; // 增加下一个拍卖ID
    }
    //买家参与拍卖

    function placeBid( uint256 _auctionID,uint256 amount,address _tokenAddress) external payable {
        Auction storage auction = auctions[_auctionID];

        //判断拍卖是否结束
        require(!auction.ended && auction.startTime + auction.duration > block.timestamp, "Auction has already ended");


        //判断出价是否大于当前最高出价

         uint payValue;
        if (_tokenAddress != address(0)) {
            // 处理 ERC20
            // 检查是否是 ERC20 资产
            payValue = amount * uint(getChainlinkDataFeedLatestAnswer(_tokenAddress));
        } else {
            // 处理 ETH
            amount = msg.value;

            payValue = amount * uint(getChainlinkDataFeedLatestAnswer(address(0)));
        }
        
        //换算后起拍价
        uint startPriceValue = auction.startPrice *  uint(getChainlinkDataFeedLatestAnswer(auction.tokenAddress));
        //换算后最高出价
        uint highestBidValue = auction.highestBid *   uint(getChainlinkDataFeedLatestAnswer(auction.tokenAddress));
        require(payValue > highestBidValue && payValue >= startPriceValue, "Bid must be higher than current highest bid");

         // 转移 ERC20 到合约
        if (_tokenAddress != address(0)) {
            IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount);
        }

        // 退还前最高价
        if (auction.highestBid > 0) {
            if (auction.tokenAddress == address(0)) {
                // auction.tokenAddress = _tokenAddress;
                payable(auction.highestBidder).transfer(auction.highestBid);
            } else {
                // 退回之前的ERC20
                IERC20(auction.tokenAddress).transfer(
                    auction.highestBidder,
                    auction.highestBid
                );
            }
        }
        
        auction.tokenAddress = _tokenAddress;
        auction.highestBid = amount;
        auction.highestBidder = msg.sender;
    }

    //结束拍卖
    function endAuction(uint256 _auctionId) external {
        Auction storage auction = auctions[_auctionId];

        console.log("endAuction:", auction.seller, auction.startTime+ auction.duration, block.timestamp);
        require(!auction.ended, "---Auction has already ended");
        require(!(auction.startTime + auction.duration <= block.timestamp),"---Auction is still ongoing");
        require(msg.sender == auction.seller || msg.sender == admin, "---Only seller or admin can end the auction");

        //转移给出价高的
        IERC721(auction.contractAddress).safeTransferFrom(admin, auction.highestBidder, auction.tokenId);
        //转移剩余资金到卖家
        //payable(address(this)).transfer(address(this).balance);
        
        //标记拍卖结束

        auction.ended = true;

      
    }
    function _authorizeUpgrade(address) internal view override {
        // 只有管理员可以升级合约
        require(msg.sender == admin, "Only admin can upgrade");
    }
}