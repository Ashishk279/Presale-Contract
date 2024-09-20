// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./CFT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Presale {

    IERC20 public USDT;
    ChainForgeToken public CFT;

    address public admin;

    uint256 public supply = 1_000_000 * 10**18;

    uint256 public constant CFT_ALLOCATION = 500_000 * 10**18;
    uint256 public constant CFT_PRICE = 0.001 * 10**6;

    uint256 public presaleTimeStamp;

    bool public presaleActive = false;

    bool public presaleSuccessfull = false;

    // Refrral System
    uint16 public constant LEVEL_1 = 1000;
    uint16 public constant LEVEL_2 = 700;
    uint16 public constant LEVEL_3 = 500;
    uint16 public constant LEVEL_4 = 300;
    uint8 public constant LEVEL_5 = 100;

    struct Participant {
        address participent;
        uint256 noOfCFTPurchased;
        uint256 noOfUSDTContribute;
        bool hasClaimed;
    }

    struct Presaled{
        address[] participants;
        uint256[] noOfUSDTContributes;
    }
     
    Presaled private presaleData; 

    mapping(address => Participant) public participants;
    
    event PurchasedCFT(
        address indexed _participent,
        uint256 indexed _cftTokens,
        uint256 _usdtContributed
    );
    event ClaimedReward(address indexed _participant, uint256 indexed _cftTokens);
    event PresaleActive(bool active);

    constructor(address _usdtInstance, address _cftInstance) {
        require(
            _usdtInstance != address(0) && _cftInstance != address(0),
            "Address can't be zero address"
        );
        admin = msg.sender;
        USDT = IERC20(_usdtInstance);
        CFT = ChainForgeToken(_cftInstance);
        CFT.setPresaleContractAddress(address(this));
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    function CFT_Allocation() external onlyAdmin {
        CFT.mint(admin, supply);
        CFT.approve(address(this), CFT_ALLOCATION);
    }

    function Activate_Presale() external onlyAdmin {
        require(
            CFT.allowance(admin, address(this)) >= CFT_ALLOCATION,
            "CFT TOkens are not Allocated"
        );
        presaleActive = true;
        presaleTimeStamp = block.timestamp;
        emit PresaleActive(presaleActive);
    }

    function PurchasedCFTTokens(uint256 cftTokens) external {
        require(cftTokens > 0, "Tokens > 0");
        uint256 usdt = cftTokens * CFT_PRICE;
        require(
            USDT.balanceOf(msg.sender) >= usdt,
            "Insufficient USDT balance."
        );
        USDT.transferFrom(msg.sender, address(this), usdt);
        Participant memory participate = participants[msg.sender];
        participate.participent = msg.sender;
        participate.noOfCFTPurchased = cftTokens;
        participate.noOfUSDTContribute = usdt;
        participants[msg.sender] = participate;

        presaleData.participants.push(msg.sender);
        presaleData.noOfUSDTContributes.push(usdt);

        emit PurchasedCFT(msg.sender, cftTokens, usdt);
    }

    function Refund() external onlyAdmin {
        require(
            block.timestamp < presaleTimeStamp + 1 minutes,
            "Presale is Successfull."
        );

         for (uint256 i = 0; i < presaleData.participants.length; i++) {
            address participant = presaleData.participants[i];
            uint256 contribution = presaleData.noOfUSDTContributes[i];

            USDT.transfer(participant, contribution);
        }
    }

    function Widthdraw() external onlyAdmin {
        require(presaleActive, "Presale is not Active.");
        require(
            block.timestamp >= presaleTimeStamp + 1 minutes,
            "Presale is not Successfull."
        );
        USDT.transfer(admin, USDT.balanceOf(address(this)));
    }

    function Claim() external {
        require(presaleActive, "Presale is not Active.");
         require(
            block.timestamp >= presaleTimeStamp + 1 minutes,
            "Presale is not Successfull."
        );
        Participant memory participate = participants[msg.sender];
        require(
            msg.sender == participate.participent,
            "Partcipent not exists."
        );
        CFT.transferFrom(admin,msg.sender, participate.noOfCFTPurchased);
        participate.hasClaimed = true;
        participants[msg.sender] = participate;
        emit ClaimedReward(participate.participent,  participate.noOfCFTPurchased);
    }

    function getAllParticipantsAndContributions() public view returns (address[] memory, uint256[] memory) {
        return (presaleData.participants, presaleData.noOfUSDTContributes);
    }
}
