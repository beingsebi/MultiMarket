import React, { useState } from 'react';
import { placeMarketOrder } from '../utils/services';

const PlaceMarketOrderForm = ({ eventIndex, marketIndex }) => {
    const [orderData, setOrderData] = useState({ betOutcome: 0, orderSide: 0, shares: "" });

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setOrderData({ ...orderData, [name]: value });
    };

    const handleBetOutcomeChange = (e) => {
        const value = parseInt(e.target.value, 10);
        if (value === 0 || value === 1) {
            setOrderData({ ...orderData, betOutcome: value });
        }
    };

    const handleOrderSideChange = (e) => {
        const value = parseInt(e.target.value, 10);
        if (value === 0 || value === 1) {
            setOrderData({ ...orderData, orderSide: value });
        }
    };

    const handlePlaceOrder = async () => {
        const { betOutcome, orderSide, shares } = orderData;
        await placeMarketOrder(eventIndex, marketIndex, betOutcome, orderSide, shares);
    };

    return (
        <div>
            <label>
                Bet Outcome:
                <input
                    type="number"
                    name="betOutcome"
                    value={orderData.betOutcome}
                    onChange={handleBetOutcomeChange}
                    min="0"
                    max="1"
                />
            </label>
            <label>
                Order Side:
                <input
                    type="number"
                    name="orderSide"
                    value={orderData.orderSide}
                    onChange={handleOrderSideChange}
                    min="0"
                    max="1"
                />
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
