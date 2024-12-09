// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "./01_TokenHolder.sol";

contract EventFactory is TokenHolder {
    uint public eventCreationFee; // includes first market's fee too
    uint public marketCreationFee;
    Event[] public events;
    mapping(uint => address) public eventToAdmin;
    mapping(address => uint) public adminEventCount;

    enum BetOutcome {
        Yes,
        No
    }

    enum OrderType {
        Buy,
        Sell
    }

    struct OrderIdentifier {
        uint eventIndex;
        uint marketIndex;
        BetOutcome betOutcome;
        OrderType orderType;
        uint price;
        uint orderIndex;
    }

    struct Order {
        address user;
        uint shares;
        uint timestamp;
        bool isActive;
    }

    struct OrderBook {
        OrderIdentifier[] orderIdentifiers;
        //// price 1 => 10^-decimals tokens   |   [Yes/No][Buy/Sell][Price]
        mapping(BetOutcome => mapping(OrderType => mapping(uint => Order[]))) orderBook;
        mapping(address => uint) userActiveOrdersCount;
    }

    struct Market {
        string title;
        string description;
        OrderBook orderBook;
        mapping(BetOutcome => mapping(address => uint)) shares;
        mapping(BetOutcome => mapping(address => uint)) reservedShares;
    }

    struct Event {
        string title;
        string description;
        Market[] markets;
    }

    event EventCreated(
        address indexed admin,
        uint eventIndex,
        string title,
        string description
    );

    event MarketCreated(
        address indexed admin,
        uint eventIndex,
        uint marketIndex,
        string title,
        string description
    );

    constructor(
        address _currencyToken,
        uint16 _decimals,
        uint16 _granularity,
        uint _eventCreationFee,
        uint _marketCreationFee
    ) TokenHolder(_currencyToken, _decimals, _granularity) {
        eventCreationFee = _eventCreationFee;
        marketCreationFee = _marketCreationFee;
    }

    /**
     * @notice Creates a new event with an initial market.
     * @dev Deducts the event creation fee from the sender's balance and adds it to the contract balance.
     *      Emits `EventCreated` and `MarketCreated` events.
     * @param _eventTitle The title of the new event.
     * @param _eventDescription A description of the new event.
     * @param _firstMarketTitle The title of the initial market associated with the event.
     * @param _firstMarketDescription A description of the initial market
     */
    function createEvent(
        string memory _eventTitle,
        string memory _eventDescription,
        string memory _firstMarketTitle,
        string memory _firstMarketDescription
    ) external {
        require(
            balances[msg.sender] >= eventCreationFee,
            "Insufficient balance"
        );

        Event storage event_ = events.push();
        event_.title = _eventTitle;
        event_.description = _eventDescription;

        eventToAdmin[events.length - 1] = msg.sender;
        adminEventCount[msg.sender]++;

        Market storage market = event_.markets.push();
        market.title = _firstMarketTitle;
        market.description = _firstMarketDescription;

        balances[msg.sender] -= eventCreationFee;
        contractBalance += eventCreationFee;

        emit EventCreated(
            msg.sender,
            events.length - 1,
            _eventTitle,
            _eventDescription
        );

        emit MarketCreated(
            msg.sender,
            events.length - 1,
            0,
            _firstMarketTitle,
            _firstMarketDescription
        );
    }

    /**
     * @notice Adds a new market to an existing event.
     * @dev Only the event admin can add markets. Deducts the market creation fee from the sender's balance.
     * @param _eventIndex The index of the event to which the market is added.
     * @param _marketTitle The title of the new market.
     * @param _marketDescription A description of the new market.
     */
    function addMarket(
        uint _eventIndex,
        string memory _marketTitle,
        string memory _marketDescription
    ) external {
        require(
            eventToAdmin[_eventIndex] == msg.sender,
            "Only the event admin can add markets"
        );
        require(
            balances[msg.sender] >= marketCreationFee,
            "Insufficient balance"
        );

        Market storage market = events[_eventIndex].markets.push();
        market.title = _marketTitle;
        market.description = _marketDescription;

        balances[msg.sender] -= marketCreationFee;
        contractBalance += marketCreationFee;

        emit MarketCreated(
            msg.sender,
            _eventIndex,
            events[_eventIndex].markets.length - 1,
            _marketTitle,
            _marketDescription
        );
    }

    /**
     * @notice Retrieves details of a specific event and its markets.
     * @param _eventIndex The index of the event to retrieve.
     * @return The event title, description, and arrays of market titles and descriptions.
     */
    function getEvent(
        uint _eventIndex
    )
        external
        view
        returns (string memory, string memory, string[] memory, string[] memory)
    {
        Event storage event_ = events[_eventIndex];
        uint marketsCount = event_.markets.length;
        string[] memory titles = new string[](marketsCount);
        string[] memory descriptions = new string[](marketsCount);

        for (uint i = 0; i < marketsCount; i++) {
            titles[i] = event_.markets[i].title;
            descriptions[i] = event_.markets[i].description;
        }

        return (event_.title, event_.description, titles, descriptions);
    }

    /**
     * @notice Retrieves details of a specific market.
     * @param _eventIndex The index of the event to which the market belongs.
     * @param _marketIndex The index of the market to retrieve.
     * @return The market title and description.
     */
    function getMarket(
        uint _eventIndex,
        uint _marketIndex
    ) external view returns (string memory, string memory) {
        return (
            events[_eventIndex].markets[_marketIndex].title,
            events[_eventIndex].markets[_marketIndex].description
        );
    }
}
