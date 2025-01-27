import React, { useState, useEffect, useCallback } from 'react';
import { useParams } from 'react-router-dom';
import { requestAccount, getActiveOrders, getCurrentPrice, cancelOrder } from '../utils/services';

const ActiveOrders = ({ marketIndex }) => {
  const { eventIndex } = useParams();
  const [orders, setOrders] = useState([]);
  const [orderType, setOrderType] = useState(0); // 'buy' or 'sell'
  const [betOutcome, setBetOutcome] = useState(0); // 0 for Yes, 1 for No
  const [currentPrice, setCurrentPrice] = useState(null);

  const fetchOrders = useCallback(async () => {
    const userAddress = await requestAccount();
    const activeOrders = await getActiveOrders(eventIndex, marketIndex, betOutcome, orderType, userAddress);
    setOrders(activeOrders);
  }, [eventIndex, marketIndex, orderType, betOutcome]);

  const fetchCurrentPrice = useCallback(async () => {
    const price = await getCurrentPrice(eventIndex, marketIndex, betOutcome);
    setCurrentPrice(price);
  }, [eventIndex, marketIndex, betOutcome]);

  useEffect(() => {
    fetchOrders();
  }, [fetchOrders]);

  useEffect(() => {
    fetchCurrentPrice();
  }, [betOutcome, fetchCurrentPrice]);

  const handleCancelOrder = async (order, index) => {
    await cancelOrder(eventIndex, marketIndex, betOutcome, orderType, order.price, index);
    fetchOrders();
    fetchCurrentPrice();
  };

  return (
    <div>
      <h2>Active Orders</h2>
      <div>
        <label>
          Order Type:
          <select value={orderType} onChange={(e) => setOrderType(e.target.value)}>
            <option value={0}>Buy</option>
            <option value={1}>Sell</option>
          </select>
        </label>
        <label>
          Bet Outcome:
          <select value={betOutcome} onChange={(e) => setBetOutcome(Number(e.target.value))}>
            <option value={0}>Yes</option>
            <option value={1}>No</option>
          </select>
        </label>
        <button onClick={fetchOrders}>Fetch Orders</button>
      </div>
      {currentPrice && (
        <div>
          <h3>Current Price</h3>
          <p>Buy price: {currentPrice.priceNumerator} | Sell price: {currentPrice.priceDenominator}</p>
        </div>
      )}
      <ul>
        {orders.map((order, index) => (
          <li key={index}>
            <p>Price: {order.price}</p>
            <p>Initial Shares: {order.initialShares}</p>
            <p>Remaining Shares: {order.remainingShares}</p>
            <p>Total cost of filled shares: {order.totalCostOfFilledShares}</p>
            <p>Timestamp: {order.timestamp}</p>
            <button onClick={() => handleCancelOrder(order, order.indexInOrderBook)}>Cancel Order</button>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default ActiveOrders;
