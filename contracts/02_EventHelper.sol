// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "./01_TokenHolder.sol";
import "./event/IEvent.sol";
import "./external/IEventFactory.sol";

contract EventHelper is TokenHolder {
    IEventFactory internal eventFactory;

    uint public eventCreationFee; // includes the fees for the first market
    uint public marketCreationFee;
    address[] public events;
    mapping(address => address) public eventToOwner;
    mapping(address => uint) public ownerEventCount;

    event EventCreated(
        address indexed admin,
        uint indexed eventIndex,
        string title,
        string description
    );

    event MarketCreated(
        address indexed admin,
        uint indexed eventIndex,
        uint marketIndex,
        string title,
        string description
    );

    constructor(
        address _currencyToken,
        address _eventFactoryAddress,
        uint16 _decimals,
        uint16 _granularity,
        uint _eventCreationFee,
        uint _marketCreationFee
    ) TokenHolder(_currencyToken, _decimals, _granularity) {
        eventFactory = IEventFactory(_eventFactoryAddress);
        eventCreationFee = _eventCreationFee;
        marketCreationFee = _marketCreationFee;
    }

    function createEvent(
        string memory _eventTitle,
        string memory _eventDescription,
        string memory _firstMarketTitle,
        string memory _firstMarketDescription
    ) external returns (bool) {
        require(
            freeBalances[msg.sender] >= eventCreationFee,
            "Insufficient balance"
        );

        //TODO: add these as params
        require(
            bytes(_eventTitle).length >= 5,
            "Event title must be at least 5 characters long"
        );
        require(
            bytes(_eventDescription).length >= 15,
            "Event description must be at least 15 characters long"
        );
        require(
            bytes(_firstMarketTitle).length >= 5,
            "Market title must be at least 5 characters long"
        );
        require(
            bytes(_firstMarketDescription).length >= 15,
            "Market description must be at least 15 characters long"
        );

        freeBalances[msg.sender] -= eventCreationFee;
        contractBalance += eventCreationFee;

        address eventAddress = eventFactory.createEvent(
            address(this),
            decimals,
            granularity,
            _eventTitle,
            _eventDescription,
            _firstMarketTitle,
            _firstMarketDescription
        );

        if (eventAddress == address(0)) {
            freeBalances[msg.sender] += eventCreationFee;
            contractBalance -= eventCreationFee;
            return false;
        }

        events.push(eventAddress);
        eventToOwner[eventAddress] = msg.sender;
        ownerEventCount[msg.sender]++;

        emit EventCreated(
            msg.sender,
            events.length - 1,
            _eventTitle,
            _eventDescription
        );

        return true;
    }

    /**
     * @notice Adds a new market to an existing event.
     * @dev Only the event admin can add markets. Deducts the market creation fee from the sender's balance.
     * @param _eventIndex The index of the event to add the market to.
     * @param _marketTitle The title of the new market.
     * @param _marketDescription A description of the new market.
     */
    function createMarket(
        uint _eventIndex,
        string memory _marketTitle,
        string memory _marketDescription
    ) external returns (bool) {
        require(_eventIndex < events.length, "Invalid event index");
        require(
            eventToOwner[events[_eventIndex]] == msg.sender,
            "Only the event owner can add markets"
        );
        require(
            freeBalances[msg.sender] >= marketCreationFee,
            "Insufficient balance"
        );
        require(
            bytes(_marketTitle).length >= 5,
            "Market title must be at least 5 characters long"
        );
        require(
            bytes(_marketDescription).length >= 15,
            "Market description must be at least 15 characters long"
        );

        freeBalances[msg.sender] -= marketCreationFee;
        contractBalance += marketCreationFee;
        IEvent _event = IEvent(events[_eventIndex]);

        if (!_event.addMarket(_marketTitle, _marketDescription)) {
            freeBalances[msg.sender] += marketCreationFee;
            contractBalance -= marketCreationFee;
            return false;
        }

        emit MarketCreated(
            msg.sender,
            _eventIndex,
            _event.getMarketCount() - 1,
            _marketTitle,
            _marketDescription
        );

        return true;
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
        require(_eventIndex < events.length, "Invalid event index");
        IEvent _event = IEvent(events[_eventIndex]);
        return _event.getEvent();
    }
}
