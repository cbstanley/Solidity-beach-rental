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

    // Flag for rental agreement terms
    bool public agreeTerms;

    // Flag for deposit made
    bool public paid;

    mapping(address => uint256) public balanceOf;

    event Transfer(
        address indexed _renter,
        address indexed _owner,
        uint256 _value
    );

    event RentalReserved(
        bool _paid
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
    //         Requires rentalTotal to be established (> 0)
    //         and a single, initial deposit (paid == false).
    function deposit() payable external onlyRenter {
        require(rentalTotal > 0);
        require(msg.value == rentalTotal);
        require(paid == false);

        balanceOf[owner] += rentalTotal;

        paid = true;

        // Broadcast to blockchain
        emit Transfer(renter, owner, msg.value);
        emit RentalReserved(paid);

        // @dev To Do: Mark calendar dates as rented
    }

    // Option for owner to deposit funds back into contract
    function ownerDeposit() payable external onlyOwner {
        balanceOf[owner] += msg.value;
    }

    // Get current balance of contract
    function getBalance() view public returns (uint balance) {
        return address(this).balance;
    }

    // @notice Renter reservation that ensures parameters are
    //         valid before proceeding to payment. Will initiate
    //         renter's address or, if renter re-runs the function,
    //         will allow _rentalCheckin and _rentalDays to be updated.
    //         Once deposit() is successfully run, reserve() is disabled.
    function reserve(
        uint _rentalCheckin,
        uint _rentalDays,
        bool _agreeTerms
    )
      public
    {
        require(renter == address(0) || renter == msg.sender);
        require(paid == false);
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
    //         Can be called by owner or renter (if given a refund).
    function withdraw(uint amount) public {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[msg.sender] -= amount;
        msg.sender.transfer(amount);
    }

    // @notice Option for owner to (partially) refund to renter.
    //         Renter then uses withdraw() to pull funds.
    function ownerRefund(uint amount) payable public onlyOwner {
        // Only refund up to original rentalTotal
        require(amount <= rentalTotal);
        balanceOf[msg.sender] -= amount;
        balanceOf[renter] += amount;
    }

    // @notice Option for owner to cancel rental and reset values.
    function ownerCancel() public onlyOwner {
        require(balanceOf[msg.sender] >= rentalTotal);
        ownerRefund(rentalTotal);
        rentalCheckin = 0;
        rentalDays = 0;
        rentalTotal = 0;
        agreeTerms = false;
        paid = false;
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
    
    // Check-in day (just enter uint > 0 for now)
    function setRentalCheckin(uint _rentalCheckin) internal {
        rentalCheckin = _rentalCheckin;
    }

    // Require rentalDays within min/max and calculate rentalTotal.
    function setRentalDays(uint _rentalDays) internal {
        require(_rentalDays >= DAYS_MIN && _rentalDays <= DAYS_MAX);
        rentalDays = _rentalDays;
        rentalTotal = RENTAL_DAILY_RATE * rentalDays;
    }
}
