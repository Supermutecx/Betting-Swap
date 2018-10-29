/**
 *Submitted for verification at BscScan.com on 2021-10-18
*/

// SPDX-License-Identifier: GPL-3.0

/**
 * @Author Vron
*/

pragma solidity >=0.7.0 <0.9.0;

contract context {

    mapping(address => bool) private admins;
    
    event AddAdmin(address indexed _address, bool decision);
    event RemoveAdmin(address indexed _address, bool decision);
    
    address private _owner;
    
    // restricts access to only owner
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner allowed.");
        _;
    }
    
    // restricts access to only admins
    modifier onlyAdmin() {
        require(admins[msg.sender] == true, "Only admins allowed.");
        _;
    }
    
    constructor(){
        _owner = msg.sender;
        admins[msg.sender] = true;
    }
    
    // function returns contract owner
    function getOwner() public view returns (address) {
        return _owner;
    }
    
    function addAdmin(address _address) public {
        _addAdmin(_address, true);
    }
    
    // sets an admin
    function _addAdmin(address _address, bool _decision) private onlyOwner returns (bool) {
        require(_address != _owner, "Owner already added.");
        admins[_address] = _decision;
        emit AddAdmin(_address, _decision);
        return true;
    }
    
    function removeAdmin(address _address) public {
        _removeAdmin(_address, false);
    }
    
    // removes an admin
    function _removeAdmin(address _address, bool _decision) private onlyOwner returns (bool) {
        require(_address != _owner, "Owner cannot be removed.");
        admins[_address] = _decision;
        emit RemoveAdmin(_address, _decision);
        return true;
    }
    
}

/**
 * SafeMath
 * Math operations with safety checks that throw on error
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 1;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

interface BUSD {
    function balanceOf(address _address) external returns (uint256);
    function transfer(address _address, uint256 value) external returns (bool);
    function transferFrom(address _sender, address recipient, uint256 value) external returns (bool);
}

interface BETS {
    function balanceOf(address _address) external returns (uint256);
    function transfer(address _address, uint256 value) external returns (bool);
    function transferFrom(address _sender, address recipient, uint256 value) external returns (bool);
}

contract BetswampMVP is context {
    using SafeMath for uint256;
    
    // mapping stores event sub-category
    mapping(Category => string[]) private sub_category;
    
    // mapping stores sub-category index
    mapping(string => uint256) private category_index;
    
    // mapping maps event to its index in allActiveEvent
    mapping(uint256 => uint256) private event_index;
    
    // [eventID][MSG.SENDER] = true or false determines if user betted on an event
    mapping (uint256 => mapping (address => bool)) private bets;

    // [eventID] = true or false - determines if a BetEvent is still active
    mapping (uint256 => bool) private activeEvents;

    // maps an event to its record
    mapping (uint256 => BetEvent) private events;
    
    // maps an event and a bettor to bettors bets information [eventID][msg.sender]
    mapping (uint256 => mapping (address => Betted)) private userBets;
    
    // maps bet event occurrence to the number of users who selected it
    mapping (uint256 => mapping (Occurences => address[])) private eventBetOccurenceCount;
    
    // maps bet event occurence and the amount betted on it
    mapping (uint256 => mapping (Occurences => uint256)) private eventBetOccurenceAmount;
    
    // maps an event to the occurence that won after validation
    mapping (uint256 => Occurences) private occuredOccurrence;
    
    // maps a user to all their bets
    mapping (address => BetEvent[]) private  userBetHistory;
    
    // maps a user to the number of their bets
    mapping (address => uint256[]) private userBetCounts;
    
        // map indicates if user locked funds for validation point
    mapping (address => bool) private _lock_validator_address;
    
    // map sets wallet lock time
    mapping (address => uint) private _validator_wallet_lock_time;
    
    // maps amount user locked
    mapping (address => uint256) private _validator_lock_amount;
    
    // maps user wallet to points earned
    mapping (address => uint256) private _wallet_validation_points;
    
    /////////////////////////////////////
    // maps a validator to an event - used in checking if a validator validated an event
    mapping (address => mapping (uint256 => bool)) private validatorValidatedEvent;

    // maps a validator to the occurrence chosen
    mapping (uint256 => mapping (address => mapping (Occurences => bool))) private selectedValidationOccurrence;
    
    // maps an event and its occurence to validators that chose it
    mapping (uint256 => mapping (Occurences => address[])) private eventOccurenceValidators;

        // maps an event and a user to know if user has reclaimed the event's wager
    mapping (uint256 => mapping (address => bool)) private reclaimedBetWager;
    
    // maps an event to the amount lost in bet by bettors who choose the wrong event outcome
    mapping (uint256 => uint256) private amountLostInBet;

    // maps a bet event to validators who validated it
    mapping (uint256 => address[]) private eventValidators;

    // maps an event and a bettor to whether the reward has been claimed
    mapping (uint256 => mapping (address => bool)) private claimedReward;
    
    // maps an event to the divs for validators, system and all event bettors
    mapping (uint256 => Distribution) private divs;
    
    // maps an event to whether its crumbs have been withdrawn
    mapping (uint256 => bool) private hasTransferredCrumbs;
    
    // event is emitted when a validator validates an event
    event ValidateEvent(uint256 indexed eventID, Occurences occurence, address validator_address);
    
    ////////////////////////////////////
    
    // event emitted once event is created
    event CreateEvent(uint256 indexed event_id, Category category, string sub_category, string eventName,
        uint256 pool_size, uint256 eventTime, string eventOne, string eventTwo, address betCreator);
        
    // event emitted when a wager is made
    event PlaceBet(uint256 indexed event_id, address bettor_address, uint256 amount, Occurences occured);
    
    // event emitted when a user claims bet reward/winnings
    event Claim(address indexed user_address, uint256 _amount);
    
    /**
     * @dev WIN = 0, LOOSE = 1, LOOSE_OR_WIN = 2 and INVALID = 3
     * On the client side, the user is only to see the follwoing
     * {WIN}, {LOOSE}, {DRAW}
    */
    enum Occurences{WIN, LOOSE, LOOSE_OR_WIN, INVALID, UNKNOWN}  //  possible bet outcome
    enum Category{SPORTS, WEATHER, REALITY_TV_SHOWS, POLITICS, ENTERTAINMENT_AWARDS, DEAD_POOL, NOBEL_PRIZE, FUTURE_BET, OTHERS}  // event categories
    
    /**
     * @dev stores Betevent information
     * 
     * Requirement:
     * event creator must be an admin
    */
    struct BetEvent {
        uint256 eventID;
        Category categories;
        string sub_category;
        string eventName;
        uint256 poolSize;  // size of event pool
        uint256 startTime;  // time event will occur
        uint256 endTime;
        string eventOne;  // eventOne vs
        string eventTwo;  //eventTwo 
        bool validated;  // false if event is not yet validated
        uint256 validatorsNeeded;
        Occurences occured;
        uint256 bettorsCount;
        uint256 noOfBettorsRewarded;
        uint256 amountClaimed;
        address betCreator;
    }
    
    /**
     * @dev stores user bet records
     * bettor balance must be greater or equal to 0
    */
    struct Betted {
        uint eventID;
        address bettorAddress;
        uint256 amount;
        Occurences occurence;
    }
    
    struct Distribution {
        uint256 bettorsDiv;
    }
    
    // wrapped BUSD mainnet: 0xe9e7cea3dedca5984780bafc599bd69add087d56
    // wrapped BUSD testnet: 0x1d566540f39fd80cb2680461c8cf10bccc2a6fa1
    BUSD private BUSD_token;
    BETS private BETS_token;
    
    bool private platformStatus;
    BetEvent[] private _event_id;
    BetEvent[] allActiveEvent; // list of active events
    uint256[] private validatedEvent;  // list of validated events
    uint256 private totalAmountBetted;  // total amount that has been betted on the platform
    uint256 private totalAmountClaimed;  // total amount claimed on the platform
    
    // used to check if platform is active
    modifier isPlatformActive() {
        require(platformStatus == false, "Platfrom activity paused.");
        _;
    }
    
     /**
     * @dev modifier ensures user can only select WIN, LOOSE or LOOSE_OR_WIN
     * as the occurence they wager on or pick as occured occurence (for validators)
    */
    modifier isValidOccurence(Occurences chosen) {
        require(chosen == Occurences.WIN || chosen == Occurences.LOOSE || chosen == Occurences.LOOSE_OR_WIN, "Invalid occurence selected.");
        _;
    }

       /**
     * @dev modifier check if a user has already claimed their bet reward
    */
    modifier hasClaimedReward(uint256 event_id) {
        // check if user betted
        if (bets[event_id][msg.sender] == true) {
            // checks if user claimed reward
            require(claimedReward[event_id][msg.sender] == false, "Reward already claimed.");
            _;
        } else {
            revert("You have no stake on event.");
        }
        
    }

     /**
     * @dev modifier hinders validators from Validating
     * events that do not have opposing bets.
    */
    modifier hasOpposingBets(uint256 event_id) {
        if (eventBetOccurenceCount[event_id][Occurences.WIN].length != 0 && eventBetOccurenceCount[event_id][Occurences.LOOSE].length != 0) {
            _;
        } else if (eventBetOccurenceCount[event_id][Occurences.WIN].length != 0 && eventBetOccurenceCount[event_id][Occurences.LOOSE_OR_WIN].length != 0) {
            _;
        } else if (eventBetOccurenceCount[event_id][Occurences.LOOSE].length != 0 && eventBetOccurenceCount[event_id][Occurences.LOOSE_OR_WIN].length != 0) {
            _;
        } else {
            revert("Validating events with none opposing bets not allowed.");
        }
    }
    
    constructor(address busd_token, address bets_token) {
        BUSD_token = BUSD(address(busd_token));
        BETS_token = BETS(address(bets_token));
    }
    
    // function adds sub-category
    function addSubbCategory(Category _category, string memory _sub_category) public onlyAdmin returns (bool) {
        sub_category[_category].push(_sub_category);
        category_index[_sub_category] = sub_category[_category].length - 1;
        return true;
    }
    
    // function removes a sub-category
    function removeSubCategory(Category _category, string memory _sub_category) public onlyAdmin returns (bool) {
        uint256 index = category_index[_sub_category];
        sub_category[_category][index] = sub_category[_category][sub_category[_category].length - 1];
        sub_category[_category].pop();
        return true;
    }
    
    // function shows event category
    function getSubCategory(Category _category) public view returns (string[] memory) {
        return sub_category[_category];
    }
    
    // create even
    function createEvent(Category _category, string memory _sub_category, string memory _name, 
        uint256 _time, uint256 _endTime, string memory _event1, string memory _event2) public returns (bool) {
        _createEvent(_category,_sub_category, _name,_time,_endTime,  _event1, _event2, msg.sender);
        return true;
    }
    
    // function creates betting event
    function _createEvent(Category _category, string memory _sub_category, string memory _name, 
        uint256 _time, uint256 _endTime, string memory _event1, string memory _event2, address _creator) 
            private onlyAdmin isPlatformActive returns (bool) {
         // ensure eventTime is greater current timestamp
        require(_time > block.timestamp, "Time of event must be greater than current time");
        events[_event_id.length] = BetEvent(_event_id.length, _category,_sub_category, _name, 0, _time,_endTime, _event1, _event2, false, 3, Occurences.UNKNOWN, 0, 0, 0, _creator); // create event
        activeEvents[_event_id.length] = true; // set event as active
        allActiveEvent.push(events[_event_id.length]);  // add event to active event list
        event_index[_event_id.length] = allActiveEvent.length - 1;
        _event_id.push(events[_event_id.length]); // increment number of events created
        emit CreateEvent(_event_id.length - 1, _category, _sub_category, _name, 0, _time, _event1, _event2, _creator);
        return true;
    }
    
    // function places bet
    function placeBet(uint256 event_id, uint256 _amount, Occurences _occured) public returns (bool) {
        _placeBet(event_id, _amount, _occured, msg.sender);
        return true;
    }
    
    // function places a bet
    function _placeBet(uint256 event_id, uint256 _amount, Occurences _occurred, address _bettor) private isPlatformActive returns (bool) {
        // check 
        require(BUSD_token.balanceOf(_bettor) >= _amount, "Insufficient balance.");
        // check if bet event date has passed
        require(events[event_id].startTime >= block.timestamp, "You're not allowed to bet on elapsed or null events");
        // check if event exist and is active
        require(activeEvents[event_id] == true, "Betting on none active bet events is not allowed.");
        BetEvent storage newEvent = events[event_id];  // get event details
        // check if user already Betted - increase betted amount on previous bet
        if (bets[event_id][msg.sender] == true) {
            // user already betted on event - increase stake on already placed bet
            BUSD_token.transferFrom(_bettor, address(this), _amount);
            userBets[event_id][msg.sender].amount = userBets[event_id][msg.sender].amount.add(_amount);
            eventBetOccurenceAmount[event_id][_occurred] = eventBetOccurenceAmount[event_id][_occurred].add(_amount);  // increment the amount betted on the occurence
            newEvent.poolSize = newEvent.poolSize.add(_amount);  // update pool amount
             _incrementTotalAmountBetted(_amount);  // increment amount betted on platform
             return true;
        }
        BUSD_token.transferFrom(_bettor, address(this), _amount);
        addUserToOccurrenceBetCount(event_id, _occurred, _bettor);  // increment number of users who betted on an event occurencece
        _incrementEventOccurrenceBetAmount(event_id, _occurred, _amount);  // increment the amount betted on the occurence
        bets[event_id][_bettor] = true;  // mark user as betted on event
        userBets[event_id][_bettor] = Betted(event_id, _bettor, _amount, _occurred);  // place user bet
        newEvent.poolSize = newEvent.poolSize.add(_amount);  // update pool amount
        newEvent.bettorsCount = newEvent.bettorsCount.add(1);  // increment users that betted on the event
        addEventToUserHistory(newEvent);

        userBetCounts[_bettor].push(event_id);  // increment number of events user has better on
        _incrementTotalAmountBetted(_amount);  // increment amount betted on platform
        emit PlaceBet(event_id, _bettor, _amount, _occurred);
        return true;

    }
    
    // function gets users who selected a specific outcome for a betting event
    function getOccurrenceBetCount(uint256 event_id, Occurences _occured) public view returns (uint256) {
        return eventBetOccurenceCount[event_id][_occured].length;
    } 
    
    // function adds a user to list of users who wagered on an event outcome
    function addUserToOccurrenceBetCount(uint256 event_id, Occurences _occurred, address _address) private {
        eventBetOccurenceCount[event_id][_occurred].push(_address);
    }
    
    // function gets amount wagered on a specific event occurrence
    function getEventOccurrenceBetAmount(uint256 event_id, Occurences _occurred) public view returns (uint256) {
        return eventBetOccurenceAmount[event_id][_occurred];
    }
    
    // finction increments amount wagered on an event outcome
    function _incrementEventOccurrenceBetAmount(uint256 event_id, Occurences _occurred, uint256 _amount) private {
        eventBetOccurenceAmount[event_id][_occurred] = eventBetOccurenceAmount[event_id][_occurred].add(_amount);   
    }
    
    // functions sets event occured occurrence after validation
    function setEventOccurredOccurrence(uint256 event_id, Occurences _occured) private {
        occuredOccurrence[event_id] = _occured;
    }
    
    // function gets event  occurred occurrence after validation
    function getEventOccurredOccurrence(uint256 event_id) private view returns (Occurences) {
        return occuredOccurrence[event_id];
    }
    
    // function remove event form active event list and puts it in validated event list
    function removeFromActiveEvents(uint256 event_id) private {
        // check if event is active
        require(activeEvents[event_id] == false, "Event not found.");
        allActiveEvent[event_index[event_id]] = allActiveEvent[allActiveEvent.length - 1];
        allActiveEvent.pop();
    }
    
    // function gets all active events
    function getActiveEvents() public view returns (BetEvent[] memory) {
        return allActiveEvent;
    }
    
    // function gets all validated event
    function getValidatedEvents() public view returns (uint256[] memory) {
        return validatedEvent;
    }
    
    // function get total betting event
    function totalEvents() public view returns (uint256) {
        return _event_id.length;
    }
    
    // function adds event to user bet history
    function addEventToUserHistory(BetEvent memory betEvent) private {
        userBetHistory[msg.sender].push(betEvent);
    }
    
    // function returns user bet histroy
    function getUserEventHistory() public view returns (BetEvent[] memory) {
        return userBetHistory[msg.sender];
    }
    
    // function 
    function _incrementTotalAmountBetted(uint256 _amount) private {
        totalAmountBetted = totalAmountBetted.add(_amount);
    }
    
     function claimValidationPoint() public returns (bool) {
        _calculateValidationPoint();
        return true;
    }
    
    /**
     * @dev function calculates the users validation points
     * and rewards him his validation point.
     * function is triggered once user logs in
    */
    function _calculateValidationPoint() internal {
        // check if wallet has any amount locked
        require(_lock_validator_address[msg.sender] == true, "Wallet don't earn points");
        _wallet_validation_points[msg.sender] =  _wallet_validation_points[msg.sender].add(_validator_lock_amount[msg.sender] * (block.timestamp - _validator_wallet_lock_time[msg.sender]) / 100000);  // calculate point
        _validator_wallet_lock_time[msg.sender] = block.timestamp;  // reset validation point timer
        
    }
    
    /**
     * @dev function displays user validation points
    */
    function showValidationPoints() public view returns (uint256) {
        // return validationPoints
        return _wallet_validation_points[msg.sender];
    }
    
    /**
     * @dev function rewards users validator rights through points.
     * 
     * Requirement: user must have [amount] or more in wallet
    */
    function earnValidationPoints(uint256 amount) public returns (bool) {
        _earnValidationPoints(msg.sender, amount);
        return true;
    }
    
    /**
     * @dev function rewards users validator rights through points.
     * 
     * Requirement: user must have [amount] or more in wallet
    */
    function  _earnValidationPoints(address userAddress, uint256 amount) private isPlatformActive {
        // check if user balance greater or equal to amount
        require(BETS_token.balanceOf(userAddress) >= amount, "Insufficient balance.");
        // check if amount is zero => zero amount locking  not allowed
        require(amount != 0, "Lockinng zero amount not allowed.");
        // check if user wallet is already earning points
        if ( _lock_validator_address[userAddress] == true && _validator_lock_amount[userAddress] != 0) {
            // wallect locked - check if amount specified matches balance after lock amount
            require((BETS_token.balanceOf(userAddress) -_validator_lock_amount[userAddress]) >= amount, "Insufficient balance.");
            BETS_token.transferFrom(userAddress, address(this), amount);  // transfer funds to smart contract
            _validator_lock_amount[userAddress] = _validator_lock_amount[userAddress].add(amount);
        } else {
            // wallet not earning points - lock amount in wallet to earn points
            BETS_token.transferFrom(userAddress, address(this), amount);  // transfer funds to smart contract
            _validator_wallet_lock_time[userAddress] = block.timestamp;  // save user lock time
            _lock_validator_address[userAddress] = true;  // user wallet locked
            _validator_lock_amount[userAddress] = amount;  // user amount locked
        }

    }
    
    /**
     * @dev function renounces user point earning ability
    */
    function revokeValidationPointsEarning() public {
        _revokeValidationPointsEarning(msg.sender);
    }
    
    /**
     * @dev function revokes user's ability to earn validation points
    */
    function _revokeValidationPointsEarning(address userAddress) private {
        // claim user earned points and revoke user point earning
        _calculateValidationPoint();
        // check if user is signed up for earning points
        require(_lock_validator_address[userAddress] == true &&  _validator_lock_amount[userAddress] != 0, "Wallet don't earn points.");
        // send locked amount back to user
        uint256 refund_amount = _validator_lock_amount[userAddress];
        _validator_wallet_lock_time[userAddress] = 0;  // reset user lock time
        _lock_validator_address[userAddress] = false;  // user wallet unlocked
        _validator_lock_amount[userAddress] = 0;  // reset locked amount to zero
        BETS_token.transfer(userAddress, refund_amount);  // send user funds back to user
    }
    
    /**
     * @dev function returns the information
     * of a bet event and the number of bettors it has
    */
    function getEvent(uint256 index) external view returns (BetEvent memory) {
        // check if bet event exist
        require(events[index].startTime > 0, "Bet event not found"); 
        return events[index];
    }
    
    /**
     * @dev function is used to validate an event
     * by validators.
     * 
     * Requirements:
     * validator must have 1000 or more points
     * event validationElapseTime must not exceed block.timestamp.
     * eventTime must exceed block.timestamp
    */
     function validateEvent(uint256 event_id, Occurences occurence) public returns (bool) {
        _validateEvent(event_id, occurence, msg.sender);
        return true;
     }
       
   /**
    * @dev function is used to validate an event
    * by validators.
    * 
    * Requirements:
    * valdator must provide the event intended to be validated and the occurence that occured for the event
    * number of validators required to validate event must not have been exceeded
    * validator must have 1000 or more points
    * event validationElapseTime must not exceed block.timestamp.
    * eventTime must exceed block.timestamp
    * 
    * Restriction:
    * validator cannot validate an event twice or more
   */
   function _validateEvent(uint256 event_id, Occurences occurence, address validator_address) 
       internal 
       hasOpposingBets(event_id)
       isValidOccurence(occurence) isPlatformActive onlyAdmin {
           // check if event exist
           require(event_id <= _event_id.length, "Event not found.");
           // check if event has been validated
           require(events[event_id].validated == false, "Event validated.");
           // check if number of validators required to validate event has been exceeded
           require(eventValidators[event_id].length <= events[event_id].validatorsNeeded, "Number of validators needed reached.");
           // check if eventTime has been exceeded
           require(events[event_id].startTime < block.timestamp, "Event hasn't occured.");
           // check if event end time has reached
           require(events[event_id].endTime < block.timestamp, "Event not ready for validation.");
           // check if validator has validated event before
           require(validatorValidatedEvent[validator_address][event_id] == false, "Validating event twice not allowed.");
           
           // validator validates event
           eventOccurenceValidators[event_id][occurence].push(validator_address);  // add validator to list of individuals that voted this occurence
           validatorValidatedEvent[validator_address][event_id] = true;  // mark validator as validated event
           eventValidators[event_id].push(validator_address);  // add validator to list of validators that validated event
           selectedValidationOccurrence[event_id][msg.sender][occurence] = true;
           emit ValidateEvent(event_id, occurence, validator_address);  // emit ValidateEvent evet
           
           // 5 minutes to validation elapse time - check if event has 60% of required validators
           if ((events[event_id].validatorsNeeded / 100) * 70  >= eventValidators[event_id].length) {
               // event has 60% of needed validators
               _markAsValidated(event_id);  // mark as validated
               _cummulateEventValidation(event_id);  // cumulate validators event occurence vote
               // check if event occurred occurence isn't INVALID
               if (occuredOccurrence[event_id] != Occurences.INVALID) {
                   _distributionFormular(event_id);  // calculate divs
               }
           }
           
           
           if (eventValidators[event_id].length == events[event_id].validatorsNeeded) {
           // check if validators needed is filled - validated needed filed
               _markAsValidated(event_id);  // mark as validated
               _cummulateEventValidation(event_id);  // cumulate validators event occurence vote
               // check if event occurred occurence isn't INVALID
               if (occuredOccurrence[event_id] != Occurences.INVALID) {
                   _distributionFormular(event_id);  // calculate divs
               }
           }
       
   }
   
   /**
    * @dev function checks for the event occurence which
    * validators voted the most as the occured event
    * occurence.
    * Returns 0 if occurence is WIN
    * Returns 1 if occurence is LOOSE
    * Returns 2 if occurence is LOOSE_OR_WIN
    * Returns 3 if none of the above occurences won out.
   */
   function _cummulateEventValidation(uint256 event_id) private {
       BetEvent storage event_occurrence = events[event_id];  // init betEvent instance
       
       // check the occurence that has the highest vote
       if (eventOccurenceValidators[event_id][Occurences.WIN].length > eventOccurenceValidators[event_id][Occurences.LOOSE].length 
           && eventOccurenceValidators[event_id][Occurences.WIN].length >  eventOccurenceValidators[event_id][Occurences.LOOSE_OR_WIN].length) {
           // set occured occurence
           occuredOccurrence[event_id] = Occurences.WIN;
           // set event occured occurence
           event_occurrence.occured = occuredOccurrence[event_id];
           // assign amount to be shared
           amountLostInBet[event_id] = amountLostInBet[event_id].add(eventBetOccurenceAmount[event_id][Occurences.LOOSE] + eventBetOccurenceAmount[event_id][Occurences.LOOSE_OR_WIN]);
       } else if (eventOccurenceValidators[event_id][Occurences.LOOSE].length > eventOccurenceValidators[event_id][Occurences.WIN].length
           && eventOccurenceValidators[event_id][Occurences.LOOSE].length > eventOccurenceValidators[event_id][Occurences.LOOSE_OR_WIN].length) {
           occuredOccurrence[event_id] = Occurences.LOOSE;
           // set event occured occurence
           event_occurrence.occured = occuredOccurrence[event_id];
           // assign amount to be shared
           amountLostInBet[event_id] = amountLostInBet[event_id].add(eventBetOccurenceAmount[event_id][Occurences.WIN] + eventBetOccurenceAmount[event_id][Occurences.LOOSE_OR_WIN]);
       } else if (eventOccurenceValidators[event_id][Occurences.LOOSE_OR_WIN].length > eventOccurenceValidators[event_id][Occurences.WIN].length
           && eventOccurenceValidators[event_id][Occurences.LOOSE_OR_WIN].length > eventOccurenceValidators[event_id][Occurences.LOOSE].length) {
               occuredOccurrence[event_id] = Occurences.LOOSE_OR_WIN;
               // set event occured occurence
               event_occurrence.occured = occuredOccurrence[event_id];
               // assign amount to be shared
               amountLostInBet[event_id] = amountLostInBet[event_id].add(eventBetOccurenceAmount[event_id][Occurences.LOOSE] + eventBetOccurenceAmount[event_id][Occurences.WIN]);
       } else {
           occuredOccurrence[event_id] = Occurences.INVALID;
           // set event occured occurence
           event_occurrence.occured = occuredOccurrence[event_id];
       }
   }
   
   /**
    * @dev function check if validator selected the 
    * right event occurence reached through concensus
   */
   function _isSelectedRightOccurrence(uint256 event_id) private view returns (bool) {
       // check if validator selected right event outcome
       if (selectedValidationOccurrence[event_id][msg.sender][occuredOccurrence[event_id]] == true) {
           // validator selected right event outcome
           return true;
       }
       // validator selected wrong event outcome
       return false;
   }
   
   /**
    * @dev function calculates the distribution of funds
    * after an event has been validated
   */
   function _distributionFormular(uint256 event_id) private {
       // calculate what is left after winners reward has been removed
       uint256 winners_percent = (eventBetOccurenceAmount[event_id][occuredOccurrence[event_id]] * 100) / events[event_id].poolSize;
       uint256 winners_percent_remainder = ((eventBetOccurenceAmount[event_id][occuredOccurrence[event_id]] * 100) % events[event_id].poolSize) / 100;
       uint256 winners_reward = ((amountLostInBet[event_id] / 100) * winners_percent).add(winners_percent_remainder);
       uint256 div_amount = amountLostInBet[event_id].sub(winners_reward);
       Distribution storage setDivs = divs[event_id];
       setDivs.bettorsDiv = setDivs.bettorsDiv.add(div_amount);
   }
   
   /**
    * @dev function is used in claiming reward
   */
   function claimReward(uint256 event_id) external returns (bool) {
       _claimReward(event_id, msg.sender);
       return true;
   }
   
   /**
    * @dev function helps a user claim rewards
    * 
    * Requirements:
    * [event_id] must be an event that has been validated
    * [msg.sender] must either be a bettor that participated in the event or validator
    * that validated the event
   */
   function _claimReward(uint256 event_id, address user_address) 
   private 
   hasClaimedReward(event_id) {
       // check if event exist
       require(events[event_id].poolSize > 0, "Bet event not found"); 
       // check if event occurrence is not UNKNOWN OR INVALID
       require(events[event_id].occured == Occurences.WIN || events[event_id].occured == Occurences.LOOSE || events[event_id].occured == Occurences.LOOSE_OR_WIN, "Reclaim wager instead.");
       // check if event has been validated
       require(events[event_id].validated == true, "Event not validated.");
      // check if user is a bettor of the event
      require(bets[event_id][user_address] == true, "You have no stake in this event.");
      
      BetEvent storage getEventDetails = events[event_id];
      // user betted on event - check if user selected occured occurrence
      if (userBets[event_id][user_address].occurence == occuredOccurrence[event_id]) {
          // user selected occured occurrence - calculate user reward
          uint256 winners_percent = (userBets[event_id][user_address].amount * 100) / events[event_id].poolSize;
          uint256 winners_percent_remainder = ((userBets[event_id][user_address].amount * 100) % events[event_id].poolSize) / 100;
          uint256 user_reward = ((amountLostInBet[event_id] / 100) * winners_percent).add(winners_percent_remainder);
          user_reward = user_reward.add(userBets[event_id][user_address].amount);  // refund user original bet amount
          user_reward = user_reward.add(divs[event_id].bettorsDiv / events[event_id].bettorsCount);  // divide div amount by number of bettors - add amount to user reward
          claimedReward[event_id][user_address] = true;  // user marked as collected reward
          _incrementTotalAmountClaimed(user_reward);  // increment total amount claimed on platform
          getEventDetails.noOfBettorsRewarded = getEventDetails.noOfBettorsRewarded.add(1);  // increment no. of event bettors rewarded
          getEventDetails.amountClaimed = getEventDetails.amountClaimed.add(user_reward);  // increment event winnings claimed
          BUSD_token.transfer(user_address, user_reward);  // transfer user reward to user
          emit Claim(user_address, user_reward);  // emit claim event
      } else {
          // user chose wrong occurrence - reward user from div
          uint256 user_reward = divs[event_id].bettorsDiv / events[event_id].bettorsCount;
          claimedReward[event_id][user_address] = true;  // user marked as collected reward
          _incrementTotalAmountClaimed(user_reward);  // increment total amount claimed on platform
          getEventDetails.noOfBettorsRewarded = getEventDetails.noOfBettorsRewarded.add(1);  // increment no. of event bettors rewarded
          getEventDetails.amountClaimed = getEventDetails.amountClaimed.add(user_reward);  // increment event winnings claimed
          BUSD_token.transfer(user_address, user_reward);  // transfer user reward to user
          emit Claim(user_address, user_reward);  // emit claim event
      }
       
   }
       
   /**
    * @dev function marks an event as validated
   */
   function _markAsValidated(uint256 event_id) private {
       BetEvent storage thisEvent = events[event_id];  // initialize event instance       
       
       thisEvent.validated = true;
           
       activeEvents[event_id] = false;  // set event as not active
           
       removeFromActiveEvents(event_id);  // remove event from avalaibleEvents array
       validatedEvent.push(event_id);  // add event to list of validated event
   }
   
    /**
     * @dev function increments the total winnings claimed
     * on the platform
    */
    function _incrementTotalAmountClaimed(uint256 _value) private {
        totalAmountClaimed = totalAmountClaimed.add(_value);
    }
    
    /**
     * @dev function is used to pause almost all platform activities
    */
    function pause() external onlyAdmin returns (bool) {
        // check if platform is paused
        if (platformStatus == true) {
            // platform paused - unpause
            platformStatus = false;
            return true;
        } else {
            // paltform not paused - pause
            platformStatus = true;
            return true;   
        }
    }
    
    function currenctTime() external view returns (uint256) {
        return block.timestamp;
    }
    
    /**
     * @dev function withdraws funds left in smart contract after a particular
     * event winnings distribution.
     * This ensures funds are not mistakenly locked away in the smart contract
     * 
     * REQUIREMENTS
     * [event_id] must an event that exist and is validated.
     * [event_id] must be an event in which all winnings have been distributed
     * [msg.sender] must be _owner
    */
    function _transferCrumbs(uint256 event_id, address _address) private onlyOwner {
        // check if event has been validated
        require(events[event_id].validated == true, "Event not validated.");
        // check if all winnings have been distributed
        require(events[event_id].noOfBettorsRewarded == events[event_id].bettorsCount, "Winnings not distributed completely.");
        
        BetEvent memory eventDetails = events[event_id];
        uint256 leftOverFunds = eventDetails.poolSize - eventDetails.amountClaimed;  // funds left over after Winnings distribution
        BUSD_token.transfer(_address, leftOverFunds);
    }
    
    /**
     * @dev function withdraws funds left in smart contract after a particular
     * event winnings distribution.
     * This ensures funds are not mistakenly locked away in the smart contract
     * 
     * REQUIREMENTS
     * [event_id] must an event that exist and is validated.
     * [event_id] must be an event in which all winnings have been distributed
     * [msg.sender] must be _owner
    */
    function transferCrumbs(uint256 event_id, address _address) public returns (bool) {
        _transferCrumbs(event_id, _address);
        return true;
    }
    
    /**
     * @dev function is used to change the contract address
     * of BUSD and BETS
    */
    function changeContractAddresses(address _busd, address _bet) public returns (bool) {
        BUSD_token = BUSD(address(_busd));
        BETS_token = BETS(address(_bet));
        return true;
    }
}
