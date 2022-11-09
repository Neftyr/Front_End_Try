// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ProofOfProp.sol";

contract ProofOfPropCreator is Ownable {
    
    mapping(address => address[]) public addressToContract;
    ProofOfProp[] private certificatesStorageArray;

    uint256 public usdEntryFee; // variable storing minimum fee
    AggregatorV3Interface internal ethUsdPriceFeed;

    constructor(address _priceFeedAddress) {
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress); // Assignment of price feed variable
        usdEntryFee = 50 * (10**18);
    }

    // Client needs to pay us in order to use addCertificate() function.
    function addCertificate(
        string memory _certificate,
        string memory _date,
        string memory _title,
        address _address,
        string memory _name,
        string memory _additional,
        string memory _hash
    ) public payable {
        // Money All Clients pay should be stored on ProofOfPropCreator Contract, so as owners of that Contract we can withdraw it.
        require(msg.value >= getMinimumFee(), "Not Enough ETH, you have to pay to create certificate!");
        ProofOfProp certificateStorage = new ProofOfProp(
            _certificate,
            _date,
            _title,
            _address,
            _name,
            _additional,
            _hash
        );
        // Below adding new Certificate(Contract) to array, which contains all certificates ever created by all clients.
        certificatesStorageArray.push(certificateStorage);
        // Below is mapping Client address with all Certificates(Contracts) he deployed (tracking all certificates, which given Client is owner of).
        addressToContract[msg.sender].push(address(certificateStorage));
        //return address(certificateStorage); // MO: to read deployed POP
    }

    // NI: function that returns last certificate.
    function getLastCertificate() public view onlyOwner returns (address) {
        uint256 lastIndex = certificatesStorageArray.length - 1;
        return address(certificatesStorageArray[lastIndex]);
    }

    // NI: Below function allows client to check all certificates(contracts) he owns.
    function getCertificatesYouOwn(address _yourAddress)
        public
        view
        returns (address[] memory)
    {
        return addressToContract[_yourAddress];
    }

    // NI: Below function defines minimal fee's to use addCertificate() and transferOwnership() functions.
    function getMinimumFee() public view returns (uint256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData(); // Takes this from AggregatorV3 latestRoundData
        uint256 adjustedPrice = uint256(price) * 10**10; // adjustedPrice has to be expressed with 18 decimals. From Chainlink pricefeed, we know ETH/USD has 8 decimals, so we need to multiply by 10^10
        uint256 costToEnter = (usdEntryFee * 10**18) / adjustedPrice; // We cannot return decimals, hence we need to express 50$ with 50 * 10*18 / 2000 (adjusted price of ETH)
        return costToEnter; // for testing
    }

    // NI: Read balance of contract factory
    function showBalance() public view onlyOwner returns (uint256) {
        uint256 POPbalance = address(this).balance;
        return POPbalance;
    }

    // NI: Below function allows us as Owners of this contract to withdraw money gathered on this contract.
    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // NI: Function created for test's purposes
    function arrayLengthGetter(address _yourAddress) public view onlyOwner returns (uint, uint) {
        uint all_certs_array = certificatesStorageArray.length;
        uint clients_owned_certs_array = getCertificatesYouOwn(_yourAddress).length;
        return (all_certs_array, clients_owned_certs_array);
    }

    // NI: Function to change owner of certificate
    function transferOwnership(address current_owner, address new_owner, address cert_address) public payable {
        
        require(current_owner == msg.sender, "You Are Not Owner Of This Certificate!");
        require(msg.value >= getMinimumFee(), "Not Enough ETH, you have to pay to create certificate!");
        
        address[] memory current_owner_certs = getCertificatesYouOwn(current_owner);
        
        delete(addressToContract[current_owner]);

        // NI: Below transfer ownership method with require() statement above will prevent any malicious attempts of ownership transfers.        
        for (uint i=0; i < current_owner_certs.length; i++){
            if (current_owner_certs[i] == cert_address){
                addressToContract[new_owner].push(cert_address);
            }
            if (current_owner_certs[i] != cert_address){
                addressToContract[current_owner].push(current_owner_certs[i]);
            }
        }
    }
}
