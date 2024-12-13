

//     function _tryMatchBuyOrder(
//         uint _eventIndex,
//         uint _marketIndex,
//         BetOutcome _betOutcome,
//         uint _price,
//         uint _indexInOB,
//         uint _shares
//     ) private {
//         // match buy order with sell order
//         for (
//             uint _tryPrice = 1;
//             _shares > 0 && _tryPrice < _price;
//             _tryPrice++
//         ) {
//             for (
//                 uint _tryIndexInOb = 0;
//                 _shares > 0 &&
//                     _tryIndexInOb <
//                     events[_eventIndex]
//                     .markets[_marketIndex]
//                     .orderBook
//                     .ob[_betOutcome][OrderType.Sell][_tryPrice].length;
//                 _tryIndexInOb++
//             ) {
//                 Order storage order = events[_eventIndex]
//                     .markets[_marketIndex]
//                     .orderBook
//                     .ob[_betOutcome][OrderType.Sell][_tryPrice][_tryIndexInOb];

//                 if (order.isActive) {
//                     uint _matchedShares = _shares < order.shares
//                         ? _shares
//                         : order.shares;

//                     _executeDirectTrade(
//                         _eventIndex,
//                         _marketIndex,
//                         _betOutcome,
//                         _price,
//                         _indexInOB,
//                         _tryPrice,
//                         _tryIndexInOb,
//                         _matchedShares,
//                         _tryPrice
//                     );

//                     _shares -= _matchedShares;
//                 }
//             }
//         }

//         //match buy order with buy order of opposite outcome
//         BetOutcome _oppositeBetOutcome = oppositeBetOutcome[_betOutcome];
//         uint _oppositePrice = 10 ** decimals - _price;

//         for (
//             uint _tryIndexInOb = 0;
//             _shares > 0 &&
//                 _tryIndexInOb <
//                 events[_eventIndex]
//                 .markets[_marketIndex]
//                 .orderBook
//                 .ob[_oppositeBetOutcome][OrderType.Sell][_oppositePrice].length;
//             _tryIndexInOb++
//         ) {
//             Order storage order = events[_eventIndex]
//                 .markets[_marketIndex]
//                 .orderBook
//                 .ob[_oppositeBetOutcome][OrderType.Sell][_oppositePrice][
//                     _tryIndexInOb
//                 ];

//             if (order.isActive) {
//                 uint _matchedShares = _shares < order.shares
//                     ? _shares
//                     : order.shares;

//                 _executeGeneratingSharesTrade(
//                     _eventIndex,
//                     _marketIndex,
//                     _betOutcome,
//                     _price,
//                     _indexInOB,
//                     _oppositeBetOutcome,
//                     _oppositePrice,
//                     _tryIndexInOb,
//                     _matchedShares
//                 );

//                 _shares -= _matchedShares;
//             }
//         }
//     }
// }
