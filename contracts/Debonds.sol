// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Ownable.sol";
import "./IERC20.sol";
import "./BondToken.sol";

contract Debonds is Ownable {
    mapping(string => BondInfo) bondRegistry; // bondID => BondInfo
    mapping(string => BondInfo) approvedBonds; // bondID => BondInfo
    mapping(address => AccountInfo) accountInfo; // daoAddress => AccountInfo


    // BondInfo Determines Full Data of Bonds
    struct BondInfo {
        string bondID;
        string daoName;
        uint startDate;
        uint endDate;
        uint maturityDate;
        uint payoutInterval;
        uint maxSupply;
        uint returnRatio;
        uint amountSold;
        uint tokenBalance;
        address daoAddress;
        address tokenAddress;
        address bondTokenAddress;
    }

    struct AccountInfo {
        string bondID;
        address tokenAddress;
        uint balance;
    }

    function mintBondToken(string memory _tokenName, _tokenSymbol, uint256 _amount) external onlyOwner returns (address bondTokenAddress) {
        bytes memory bytecode = type(BondToken).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_tokenName, _tokenSymbol));
        assembly {
            newToken := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IERC20(newToken).setTokenInfo(_tokenName, _tokenSymbol);
        IERC20(newToken).proxyMint(address(this). _amount);
        return address(newToken);
    }
    
    // Set duration (Function)
    // {_duration} months. 1months = 30days = 2,592,000 timestamp
    function setDuration(uint _duration) public returns (uint timeStamp) {
        uint timeStamp = _duration * 2592000;
        return timeStamp;
    }

    // Register Bond (Issuer)
    function registerBond(string _bondID, string _daoName, uint _startDate, uint _endDate, uint _maturityDate, uint _payoutInterval, uint _maxSupply, uint _returnRatio, address _tokenAddress) public returns(bool success) {
        require(bondRegistry[_bondID].daoAddress==0x0000000000000000000000000000000000000000, "Existing Bond ID");
        BondInfo memory bondInfo = BondInfo(_bondID,
                                            _daoName,
                                            _startDate,
                                            _endDate,
                                            _maturityDate,
                                            _payoutInterval,
                                            _maxSupply,
                                            _returnRatio,
                                            0,
                                            0,
                                            msg.sender,
                                            _tokenAddress,
                                            0x000000000000000000000000000000000000dEaD);
        bondRegistry[_bondID] = bondInfo;
        return true;
    }

    // Update Bonds (Issuer) : Approved Bonds Cannot be Updated
    function updateBond(string _bondID, string _daoName, uint _startDate, uint _endDate, uint _maturityDate, uint _payoutInterval, uint _maxSupply, uint _returnRatio, address _tokenAddress) public returns (bool success) {
        // Regsitered address can update info
        require(bondRegistry[_bondID].daoAddress==msg.sender, "Not Issuer of Bond");
        
        // Update is possible 24h before start date
        uint oneDay = 1588671070; // Unix Timestamp
        uint currentTime = block.timestamp;
        uint startDate = bondRegistry[_bondID].startDate;
        require(currentTime < startDate - oneDay, "Update is possible 24h before start date");

        BondInfo memory newBondInfo = BondInfo(_bondID,
                                            _daoName,
                                            _startDate,
                                            _endDate,
                                            _maturityDate,
                                            _payoutInterval,
                                            _maxSupply,
                                            _returnRatio,
                                            0,
                                            0,
                                            msg.sender,
                                            _tokenAddress,
                                            0x000000000000000000000000000000000000dEaD);
        bondRegistry[_bondID] = newBondInfo;
        return true;
    }

    // Approve Bond (Admin)
    function approveBond(string _bondID, string _tokenName, string _tokenSymbol) public returns (bool success) {
        address owner = 0x8f54a42a8F144967DBEFccA1F724704B0Bb36C1a;
        require(msg.sender==owner, "Admin can access approveBond function");

        BondInfo memory bondInfo = bondRegistry[_bondID];
        uint supply = bondInfo.maxSupply;
        // Mint ERC20 Bond Tokens
        address bondTokenAddress = mintBondToken(_tokenName, _tokenSymbol, supply);

        bondInfo.bondTokenAddress = bondTokenAddress;

        approvedBonds[_bondID] = bondInfo;
        return true;
    }

    // Remove Bond From Registry (Admin)
    function removeBondFromRegistry(string _bondID) public returns (bool success) {
        address owner = 0x8f54a42a8F144967DBEFccA1F724704B0Bb36C1a;
        require(msg.sender==owner, "Admin can access removeBondFromRegistry function");
        bondRegistry[_bondID] = BondInfo();
        return true;
    }

    // Remove approved bond if contract is finalized (Admin)
    function removeApprovedBond(string _bondID) public returns (bool success) {
        address owner = 0x8f54a42a8F144967DBEFccA1F724704B0Bb36C1a;
        require(msg.sender==owner, "Admin can access removeApprovedBond function");
        approvedBonds[_bondID] = BondInfo();
        return true;
    }

    // Supply tokens and mint bond tokens (Investor)
    function purchaseBond

    // Return bond tokens and redeem supplied tokens (Investor)
    function returnBond

    // Redeem regularly paid out interest corresponding to payoutInterval (Investor)
    function redeemInterest

    // Top up tokens to payout interest (Issuer)
    function payInterest

    // Repay full amount of tokens before maturity date (Issuer)
    function repayFull

    // Withdraw funds raised through bond sale
    function withdrawFund

}