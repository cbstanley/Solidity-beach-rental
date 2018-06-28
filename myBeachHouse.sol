pragma solidity ^0.4.24;

/// @title BeachHouseRental
contract BeachHouseRental {
    // Owner and renter
    address public owner;
    address public renter;

    // Name and location of beach house
    string public name;
    string public location;

    // Rental rate per day
    uint public RENTAL_DAILY_RATE;

    // Min and max days stay
    uint public DAYS_MIN;
    uint public DAYS_MAX;

    // Renter requested check-in date (uses a placeholder uint > 0 for now)
    uint public rentalCheckin;

    // Renter requested rental days
    uint public rentalDays;

    // Total rent price
    uint public rentalTotal;

    // Rental agreement terms
    bool public agreeTerms;
    
    mapping(address => uint256) public balanceOf;
    
    event Transfer(
        address indexed _renter,
        address indexed _owner,
        uint256 _value
    );

    // Allows only owner to call
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Allows only renter to call
    modifier onlyRenter() {
        require(msg.sender == renter);
        _;
    }

    // @notice BeachHouseRental constructor
    //
    // @param owner = contract creator
    // @param name = rental property name
    // @param location = rental property address
    // @param DAYS_MIN = minimum stay
    // @param DAYS_MAX = maximum stay
    // @param RENTAL_DAILY_RATE = daily rental rate in wei
    constructor() public {
        owner = msg.sender;
        name = "Beach House";
        location = "101 Ocean Drive";
        DAYS_MIN = 1;
        DAYS_MAX = 14;
        RENTAL_DAILY_RATE = 500000000000000000 wei;  // (5e17 wei = 0.5 ether)
    }

    // @notice Renter deposit into contract to pay owner.
    //         Requires rentalTotal to be established (> 0).
    function deposit() payable external onlyRenter {
        require(rentalTotal > 0);
        require(msg.value == rentalTotal);

        balanceOf[owner] += rentalTotal;

        // Broadcast to blockchain
        emit Transfer(renter, owner, msg.value);

        // @dev To Do: Mark calendar dates as rented
    }

    // Check-in day (just enter uint > 0 for now)
    function setRentalCheckin(uint _rentalCheckin) internal {
        rentalCheckin = _rentalCheckin;
    }

    // Require rentalDays within min/max and calculate rentalTotal.
    function setRentalDays(uint _rentalDays) internal {
        rentalDays = _rentalDays;
        require(rentalDays >= DAYS_MIN && rentalDays <= DAYS_MAX);
        rentalTotal = RENTAL_DAILY_RATE * rentalDays;
    }

    // @notice Renter reservation that ensures parameters are
    //         valid before proceeding to payment. Will initiate
    //         renter's address or, if renter re-runs the function,
    //         will allow _rentalCheckin and _rentalDays to be updated.
    function reserve(
        uint _rentalCheckin,
        uint _rentalDays,
        bool _agreeTerms
    )
      public
    {
        require(renter == address(0) || renter == msg.sender);
        require(checkAvailable(_rentalCheckin, _rentalDays) == true);

        agreeTerms = _agreeTerms;
        require(_agreeTerms == true);

        if (renter == address(0)) {
            renter = msg.sender;
        }

        setRentalCheckin(_rentalCheckin);
        setRentalDays(_rentalDays);
    }
    
    // @notice Allows funds to be withdrawn from contract.
    function withdraw(uint amount) public {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[msg.sender] -= amount;
        msg.sender.transfer(amount);
    }
    
    // @dev To Do: Update to work as a calendar (currently a test function).
    //
    // Check if rental is available for requested stay.
    function checkAvailable(
        uint _rentalCheckin,
        uint _rentalDays
    )
      view internal returns (bool)
    {
        if (_rentalCheckin > 0 &&
            _rentalDays >= DAYS_MIN &&
            _rentalDays <= DAYS_MAX) {
            return true;
        } else {
            return false;
        }
    }
}
