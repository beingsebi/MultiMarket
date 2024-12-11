// SPDX-License-Identifier: MIT

pragma solidity >=0.8.28 <0.9.0;

// import "./02_EventFactory.sol";

// contract OrderMatcher is EventFactory {
//     mapping(BetOutcome => BetOutcome) internal oppositeBetOutcome;

//     constructor(
//         address _currencyToken,
//         uint16 _decimals,
//         uint16 _granularity,
//         uint _eventCreationFee,
//         uint _marketCreationFee
//     )
//         EventFactory(
//             _currencyToken,
//             _decimals,
//             _granularity,
//             _eventCreationFee,
//             _marketCreationFee
//         )
//     {
//         oppositeBetOutcome[BetOutcome.Yes] = BetOutcome.No;
//         oppositeBetOutcome[BetOutcome.No] = BetOutcome.Yes;
//     }

//     function _executeDirectTrade(
//         uint _eventIndex,
//         uint _marketIndex,
//         BetOutcome _betOutcome,
//         uint _buyPrice,
//         uint _buyIndexInOB,
//         uint _sellPrice,
//         uint _sellIndexInOB,
//         uint _shares,
//         uint _price
//     ) internal {
//         Order storage buyOrder = events[_eventIndex]
//             .markets[_marketIndex]
//             .orderBook
//             .ob[_betOutcome][OrderType.Buy][_buyPrice][_buyIndexInOB];
//         Order storage sellOrder = events[_eventIndex]
//             .markets[_marketIndex]
//             .orderBook
//             .ob[_betOutcome][OrderType.Sell][_sellPrice][_sellIndexInOB];

//         require(buyOrder.isActive, "Buy order is not active");
//         require(sellOrder.isActive, "Sell order is not active");
//         require(_shares > 0, "Shares must be greater than 0");
//         require(
//             buyOrder.shares >= _shares && sellOrder.shares >= _shares,
//             "Insufficient shares"
//         );
//         require(
//             buyOrder.user != sellOrder.user,
//             "Buyer and seller cannot be the same"
//         );

//         assert(reservedBalances[buyOrder.user] >= _price * _shares);
//         assert(
//             events[_eventIndex].markets[_marketIndex].reservedShares[
//                 _betOutcome
//             ][sellOrder.user] >= _shares
//         );

//         balances[buyOrder.user] -= _price * _shares;
//         events[_eventIndex].markets[_marketIndex].shares[_betOutcome][
//                 sellOrder.user
//             ] -= _shares;

//         reservedBalances[buyOrder.user] -= _price * _shares;
//         events[_eventIndex].markets[_marketIndex].reservedShares[_betOutcome][
//                 sellOrder.user
//             ] -= _shares;

//         balances[sellOrder.user] += _price * _shares;
//         events[_eventIndex].markets[_marketIndex].reservedShares[_betOutcome][
//                 buyOrder.user
//             ] += _shares;

//         buyOrder.shares -= _shares;
//         sellOrder.shares -= _shares;

//         _checkAndMarkOrderAsInactive(buyOrder, _eventIndex, _marketIndex);
//         _checkAndMarkOrderAsInactive(sellOrder, _eventIndex, _marketIndex);
//     }

//     function _executeGeneratingSharesTrade(
//         uint _eventIndex,
//         uint _marketIndex,
//         BetOutcome _buyBetOutcome,
//         uint _buyPrice,
//         uint _buyIndexInOB,
//         BetOutcome _sellBetOutcome,
//         uint _sellPrice,
//         uint _sellIndexInOB,
//         uint _shares
//     ) internal {
//         Order storage buyOrder = events[_eventIndex]
//             .markets[_marketIndex]
//             .orderBook
//             .ob[_buyBetOutcome][OrderType.Buy][_buyPrice][_buyIndexInOB];
//         Order storage sellOrder = events[_eventIndex]
//             .markets[_marketIndex]
//             .orderBook
//             .ob[_sellBetOutcome][OrderType.Sell][_buyPrice][_sellIndexInOB];

//         require(buyOrder.isActive, "Buy order is not active");
//         require(sellOrder.isActive, "Sell order is not active");
//         require(_shares > 0, "Shares must be greater than 0");
//         require(
//             buyOrder.shares >= _shares && sellOrder.shares >= _shares,
//             "Insufficient shares"
//         );
//         require(
//             buyOrder.user != sellOrder.user,
//             "Buyer and seller cannot be the same"
//         );

//         assert(_buyPrice + _sellPrice == 10 ** decimals);
//         assert(reservedBalances[buyOrder.user] >= _buyPrice * _shares);
//         assert(reservedBalances[sellOrder.user] >= _buyPrice * _shares);

//         balances[buyOrder.user] -= _buyPrice * _shares;
//         balances[sellOrder.user] -= _buyPrice * _shares;

//         reservedBalances[buyOrder.user] -= _buyPrice * _shares;
//         reservedBalances[sellOrder.user] -= _sellPrice * _shares;

//         events[_eventIndex].markets[_marketIndex].issuedShares += _shares;
//         events[_eventIndex].markets[_marketIndex].shares[_buyBetOutcome][
//                 buyOrder.user
//             ] += _shares;
//         events[_eventIndex].markets[_marketIndex].shares[_sellBetOutcome][
//                 sellOrder.user
//             ] += _shares;

//         buyOrder.shares -= _shares;
//         sellOrder.shares -= _shares;

//         _checkAndMarkOrderAsInactive(buyOrder, _eventIndex, _marketIndex);
//         _checkAndMarkOrderAsInactive(sellOrder, _eventIndex, _marketIndex);
//     }

//     function _checkAndMarkOrderAsInactive(
//         Order storage _order,
//         uint _eventIndex,
//         uint _marketIndex
//     ) internal {
//         if (_order.shares == 0) {
//             _order.isActive = false;
//             events[_eventIndex]
//                 .markets[_marketIndex]
//                 .orderBook
//                 .userActiveOrdersCount[_order.user]--;
//         }
//     }
// }
