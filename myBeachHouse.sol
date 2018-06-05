pragma solidity ^0.4.24;

contract BeachHouseRental {

    // Set owner, renter
    address public owner;
    address public renter;

    // Name and location of beach house
    string public name;
    string public location;

    // Rental rate per day
    uint public rentalDailyRate;

    // Min and max days stay
    uint public daysMin;
    uint public daysMax;

    // Modifier that allows only owner to call
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Modifier that allows only renter to call
    modifier onlyRenter() {
        require(msg.sender == renter);
        _;
    }

    constructor() public {
        owner = msg.sender;
        name = "Beach House";
        location = "101 Ocean Drive";
        daysMin = 1;
        daysMax = 14;
        rentalDailyRate = 500000000000000000 wei;  // (5e17 wei = 0.5 ether)
    }

    function setRenter(address _renter) public {
        renter = _renter;
    }

    // Renter requested check-in date (uses a placeholder uint > 0 for now)
    uint public rentalCheckin;

    // Renter requested rental days
    uint public rentalDays;

    // Total rent price
    uint public rentalTotal;

    // Check-in day (just enter uint > 0 for now)
    function setRentalCheckin(uint _rentalCheckin) public {
        rentalCheckin = _rentalCheckin;
    }

    function setRentalDays(uint _rentalDays) public {
        rentalDays = _rentalDays;
        require(rentalDays >= daysMin && rentalDays <= daysMax);
        rentalTotal = rentalDailyRate * rentalDays;
    }

    function getRentalTotal() constant public returns (uint) {
        return rentalTotal;
    }

    // Beach house availability
    bool public available;

    // To do: update to work as a calendar (currently a test function)
    // Check if rental is available for requested stay
    function checkAvailable(uint _rentalCheckin, uint _rentalDays) pure internal returns (bool) {
        if(_rentalCheckin > 0 && _rentalDays > 0) {
            return true;
        }
    }

    // Rental agreement terms
    bool public agreeTerms;

    // Renter reservation
    function reserve(
        address _renter,
        uint _rentalCheckin,
        uint _rentalDays,
        bool _agreeTerms
    ) public {

        setRenter(_renter);
        setRentalCheckin(_rentalCheckin);
        setRentalDays(_rentalDays);
        available = checkAvailable(_rentalCheckin, _rentalDays);

        // Ask renter to agree to rental agreement terms
        agreeTerms = _agreeTerms;

        require(available == true);
        require(agreeTerms == true);
    }

    event Transfer(address indexed _renter, address indexed _owner, uint256 _value);

    function deposit() payable external onlyRenter {
        require(msg.value == rentalTotal);
        require(msg.value > 0);
        require(renter.balance >= rentalTotal);

        // Transfer ether from renter to owner
        owner.transfer(msg.value);

        // Broadcast to blockchain
        emit Transfer(renter, owner, msg.value);

        // To do: mark calendar dates as rented
    }

    // Option for owner to cancel rental and return (partial) funds to renter
    function cancelRental() public payable onlyOwner {

        // Only refund up to original rentalTotal
        require(msg.value <= rentalTotal);
        renter.transfer(msg.value);

        // Reset parameters
        renter = address(0);
        rentalCheckin = 0;
        rentalDays = 0;
        rentalTotal = 0;
        available = false;
        agreeTerms = false;
    }
}
