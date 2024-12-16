// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

import "./01_TokenHolder.sol";
import "./event/IEvent.sol";
import "./external/IEventFactory.sol";
import "./external/IMarketFactory.sol";
import "./utils/OrderDefinitions.sol";

contract EventHelper is TokenHolder {
    IEventFactory internal eventFactory;

    // Use the address because it's cheaper than using the interface
    address internal marketFactoryAddress;

    uint public eventCreationFee;
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
        address _marketFactoryAddress,
        uint16 _decimals,
        uint16 _granularity,
        uint _eventCreationFee,
        uint _marketCreationFee
    ) TokenHolder(_currencyToken, _decimals, _granularity) {
        eventFactory = IEventFactory(_eventFactoryAddress);
        marketFactoryAddress = _marketFactoryAddress;
        eventCreationFee = _eventCreationFee;
        marketCreationFee = _marketCreationFee;
    }

    function createEvent(
        string memory _eventTitle,
        string memory _eventDescription
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

        freeBalances[msg.sender] -= eventCreationFee;
        contractBalance += eventCreationFee;

        address eventAddress = eventFactory.createEvent(
            address(this),
            marketFactoryAddress,
            decimals,
            granularity,
            _eventTitle,
            _eventDescription
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

        address marketAddress = _event.addMarket(
            _marketTitle,
            _marketDescription
        );

        if (marketAddress == address(0)) {
            freeBalances[msg.sender] += marketCreationFee;
            contractBalance -= marketCreationFee;
            return false;
        }

        isMarket[marketAddress] = true;

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

    function getMarket(
        uint _eventIndex,
        uint _marketIndex
    ) external view returns (string memory, string memory) {
        require(_eventIndex < events.length, "Invalid event index");
        IEvent _event = IEvent(events[_eventIndex]);
        return _event.getMarket(_marketIndex);
    }

    /**
     * @notice Retrieves the positions of a user in a specific event.
     * @param _eventIndex The index of the event to retrieve.
     * @param _user The address of the user.
     * @return The user's positions in the event:
     * free YES shares, reserved YES shares, free NO shares, reserved NO shares.
     */
    function getPositions(
        uint _eventIndex,
        address _user
    )
        external
        view
        returns (uint[] memory, uint[] memory, uint[] memory, uint[] memory)
    {
        require(_eventIndex < events.length, "Invalid event index");
        return IEvent(events[_eventIndex]).getPositions(_user);
    }

    function placeLimitOrder(
        uint _eventIndex,
        uint _marketIndex,
        BetOutcome _betOutcome,
        OrderSide _orderSide,
        uint _price,
        uint _shares
    ) external {
        require(
            _betOutcome == BetOutcome.Yes || _betOutcome == BetOutcome.No,
            "Invalid bet outcome"
        );
        require(
            _orderSide == OrderSide.Buy || _orderSide == OrderSide.Sell,
            "Invalid order side"
        );
        require(_eventIndex < events.length, "Invalid event index");
        require(
            _price >= 0 && _price <= 10 ** decimals,
            "Price must be between 0 and 1 (* 10^decimals)"
        );
        require(
            _price % (10 ** (decimals - granularity)) == 0,
            "Price must be a multiple of 10^(decimals - granularity)"
        );
        require(_shares > 0, "Shares must be greater than 0");

        IEvent _event = IEvent(events[_eventIndex]);

        require(_marketIndex < _event.getMarketCount(), "Invalid market index");

        if (_orderSide == OrderSide.Buy) {
            require(
                freeBalances[msg.sender] >= _price * _shares,
                "Insufficient free funds"
            );
            freeBalances[msg.sender] -= _price * _shares;
            reservedBalances[msg.sender] += _price * _shares;

            _event.placeLimitBuyOrder(
                msg.sender,
                _marketIndex,
                _betOutcome,
                _price,
                _shares
            );
        } else {
            _event.placeLimitSellOrder(
                msg.sender,
                _marketIndex,
                _betOutcome,
                _price,
                _shares
            );
        }
    }
}
