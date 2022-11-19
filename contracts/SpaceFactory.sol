// NFT Auction Contract 
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
interface IERC20 {
	function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);  
	function symbol() external view returns (string memory);	
    function decimals() external view returns (uint256);    
}

contract SpaceFactory is OwnableUpgradeable {
    using SafeMath for uint256;    

    address public feeAddress;
    uint256 public createFee;
    address public paymentTokenAddress;
    
    // Auction struct which holds all the required info
    struct Space {
        uint256 spaceId;
        string logo;
        string name;
        string about;
        string category;
        address powerToken;
        address creator;
        uint256 createLimit; // holder who has over createLimit powerToken can create proposal
        string socialMetadata;        
    }

    // spaceId => Space mapping
    mapping(uint256 => Space) public spaces;
	uint256 public currentSpaceId;   
    
    // SpaceCreated is fired when an space is created
    event SpaceCreated(
        uint256 spaceId,
        string logo,
        string name,
        string about,
        string category,
        address powerToken,
        address creator,
        uint256 createLimit,
        string socialMetadata
    );
    
    event SpaceUpdated(
        uint256 spaceId,
        string logo,
        string name,
        string about,
        string category,
        address powerToken,
        address creator,
        uint256 createLimit,
        string socialMetadata
    );
    


    function initialize(
        address _feeAddress,
        address _paymentTokenAddress
    ) public initializer {
        __Ownable_init();
        require(_feeAddress != address(0), "Invalid commonOwner");
        feeAddress = _feeAddress;
        createFee = 0 ether;
        paymentTokenAddress = _paymentTokenAddress;
        currentSpaceId = 0;
    }	
    
    function setFeeAddress(address _feeAddress) external onlyOwner {
        require(_feeAddress != address(0x0), "invalid address");		
        feeAddress = _feeAddress;		
    }
    function setFeeValue(uint256 _createFee) external onlyOwner {	
        createFee = _createFee;
    }

    function createSpace(
        string memory _logo, 
        string memory _name,
        string memory _about, 
        string memory _category, 
        address _powerToken, 
        uint256 _createLimit,
        string memory _socialMetadata
        ) external payable 
    {   
        require((_powerToken == address(0x0)) || (canGetSymbol(_powerToken) && canGetDecimals(_powerToken)), '_powerToken have to be ERC20 token contract');
        
        if (paymentTokenAddress == address(0x0)) {
            if (createFee > 0) {
                require(msg.value >= createFee, "too small amount");
                (bool result, ) = payable(feeAddress).call{value: createFee}("");
        		require(result, "Failed to send fee to feeAddress");
            }
        } else {
            if (createFee > 0) {
                IERC20 paymentToken = IERC20(paymentTokenAddress);
                require(paymentToken.transferFrom(msg.sender, address(this), createFee), "insufficient token balance");
		        require(paymentToken.transfer(feeAddress, createFee));
            }
        }
        
		currentSpaceId = currentSpaceId.add(1);
		spaces[currentSpaceId].spaceId = currentSpaceId;
		spaces[currentSpaceId].logo = _logo;
		spaces[currentSpaceId].name = _name;
        spaces[currentSpaceId].about = _about;
        spaces[currentSpaceId].category = _category;
        spaces[currentSpaceId].powerToken = _powerToken;
        spaces[currentSpaceId].creator = msg.sender;
        spaces[currentSpaceId].createLimit = _createLimit;
		spaces[currentSpaceId].socialMetadata = _socialMetadata;
        emit SpaceCreated(currentSpaceId, _logo, _name, _about, _category, _powerToken, msg.sender, _createLimit, _socialMetadata);
    }

    function updateSpace(
        uint256 _spaceId,
        string memory _logo, 
        string memory _name,
        string memory _about, 
        string memory _category, 
        address _powerToken, 
        uint256 _createLimit,
        string memory _socialMetadata
        ) external 
    {   
        require((_powerToken == address(0x0)) || (canGetSymbol(_powerToken) && canGetDecimals(_powerToken)), '_powerToken have to be ERC20 token contract');
        require(_spaceId <= currentSpaceId, 'invalid _spaceId');
        require(msg.sender == spaces[_spaceId].creator || msg.sender == owner(), "Error, you are not the creator"); 

		spaces[_spaceId].logo = _logo;
		spaces[_spaceId].name = _name;
        spaces[_spaceId].about = _about;
        spaces[_spaceId].category = _category;
        spaces[_spaceId].powerToken = _powerToken;
        spaces[_spaceId].createLimit = _createLimit;
		spaces[_spaceId].socialMetadata = _socialMetadata;
        emit SpaceUpdated(_spaceId, _logo, _name, _about, _category, _powerToken, msg.sender, _createLimit, _socialMetadata);
    }
    
    function canGetSymbol(address _address) view private returns(bool) {
        IERC20 token = IERC20(_address); 
        try token.symbol() {
            return true;
        } catch {
            return false;
        }
    }

    function canGetDecimals(address _address) view private returns(bool) {
        IERC20 token = IERC20(_address); 
        try token.decimals() {
            return true;
        } catch {
            return false;
        }
    }

    receive() external payable {}
}