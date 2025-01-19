import React, { useState } from 'react';
import { placeMarketOrder } from '../utils/services';

const PlaceMarketOrderForm = ({ eventIndex, marketIndex }) => {
    const [orderData, setOrderData] = useState({ betOutcome: 0, orderSide: 0, shares: "" });

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setOrderData({ ...orderData, [name]: value });
    };

    const handleBetOutcomeChange = (e) => {
        const { value } = e.target;
        setOrderData({ ...orderData, betOutcome: parseInt(value, 10) });
    };

    const handleOrderSideChange = (e) => {
        const { value } = e.target;
        setOrderData({ ...orderData, orderSide: parseInt(value, 10) });
    };

    const handlePlaceOrder = async () => {
        const { betOutcome, orderSide, shares } = orderData;
        await placeMarketOrder(eventIndex, marketIndex, betOutcome, orderSide, shares);
    };

    return (
        <div>
            <label>
                Bet Outcome:
                <select
                    name="betOutcome"
                    value={orderData.betOutcome}
                    onChange={handleBetOutcomeChange}
                >
                    <option value={0}>Yes</option>
                    <option value={1}>No</option>
                </select>
            </label>
            <label>
                Order Side:
                <select
                    name="orderSide"
                    value={orderData.orderSide}
                    onChange={handleOrderSideChange}
                >
                    <option value={0}>Buy</option>
                    <option value={1}>Sell</option>
                </select>
            </label>
            <label>
                Shares:
                <input
                    type="number"
                    name="shares"
                    value={orderData.shares}
                    onChange={handleInputChange}
                />
            </label>
            <button onClick={handlePlaceOrder}>Place Market Order</button>
        </div>
    );
};

export default PlaceMarketOrderForm;
