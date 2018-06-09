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

    // Beach house availability
    bool public available;

    // Rental agreement terms
    bool public agreeTerms;

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

    // @notice BeachHouseRental fallback function.
    //         Requires rentalTotal to be established (>0)
    //         and renter to have sufficient funds before
    //         transferring rental payment to owner.
    function deposit() payable external onlyRenter {
        require(rentalTotal > 0);
        require(msg.value == rentalTotal);
        require(renter.balance >= rentalTotal);

        // Transfer ether from renter to owner
        owner.transfer(msg.value);

        // Broadcast to blockchain
        emit Transfer(renter, owner, msg.value);

        // @dev To Do: Mark calendar dates as rented
    }

    // Setter for renter address
    function setRenter(address _renter) public {
        renter = _renter;
    }

    // Check-in day (just enter uint > 0 for now)
    function setRentalCheckin(uint _rentalCheckin) public {
        rentalCheckin = _rentalCheckin;
    }

    // Require rentalDays within min/max and calculate rentalTotal.
    function setRentalDays(uint _rentalDays) public {
        rentalDays = _rentalDays;
        require(rentalDays >= DAYS_MIN && rentalDays <= DAYS_MAX);
        rentalTotal = RENTAL_DAILY_RATE * rentalDays;
    }

    // @dev To Do: Update to work as a calendar (currently a test function).
    //
    // Check if rental is available for requested stay.
    function checkAvailable(
        uint _rentalCheckin,
        uint _rentalDays
    )
        pure internal returns (bool)
    {
        if(_rentalCheckin > 0 && _rentalDays > 0) {
            return true;
        }
    }

    // @notice Renter reservation that ensures params are
    //         valid before proceeding to payment.
    function reserve(
        address _renter,
        uint _rentalCheckin,
        uint _rentalDays,
        bool _agreeTerms
    )
      public
    {
        setRenter(_renter);
        setRentalCheckin(_rentalCheckin);
        setRentalDays(_rentalDays);
        available = checkAvailable(_rentalCheckin, _rentalDays);

        // Ask renter to agree to rental agreement terms
        agreeTerms = _agreeTerms;

        require(available == true);
        require(agreeTerms == true);
    }

    event Transfer(
        address indexed _renter,
        address indexed _owner,
        uint256 _value
    );

    // @notice Option for owner to cancel rental and
    //         return (partial) funds to renter.
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
