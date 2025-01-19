import React, { useState } from 'react';
import { placeLimitSellOrder } from '../utils/services';

const PlaceSellOrderForm = ({ eventIndex, marketIndex }) => {
    const [orderData, setOrderData] = useState({ betOutcome: 1, price: "", shares: "" });

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setOrderData({ ...orderData, [name]: value });
    };

    const handleBetOutcomeChange = (e) => {
        const { value } = e.target;
        setOrderData({ ...orderData, betOutcome: parseInt(value, 10) });
    };

    const handlePlaceOrder = async () => {
        const { betOutcome, price, shares } = orderData;
        await placeLimitSellOrder(eventIndex, marketIndex, betOutcome, price, shares);
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
                Price:
                <input
                    type="number"
                    min="0"
                    max="1"
                    name="price"
                    value={orderData.price}
                    onChange={handleInputChange}
                    placeholder="0.1"
                />
            </label>
            <label>
                Shares:
                <input
                    type="number"
                    min="0"
                    name="shares"
                    value={orderData.shares}
                    onChange={handleInputChange}
                />
            </label>
            <button onClick={handlePlaceOrder}>Place Sell Order</button>
        </div>
    );
};

export default PlaceSellOrderForm;
