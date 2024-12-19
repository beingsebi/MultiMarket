import React, { useState } from 'react';
import { placeLimitSellOrder } from '../utils/services';

const PlaceSellOrderForm = ({ eventIndex, marketIndex }) => {
    const [orderData, setOrderData] = useState({ betOutcome: 1, price: "", shares: "" });

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

    const handlePlaceOrder = async () => {
        const { betOutcome, price, shares } = orderData;
        await placeLimitSellOrder(eventIndex, marketIndex, betOutcome, price, shares);
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
                Price:
                <input
                    type="number"
                    min="0"
                    max="1"
                    name="price"
                    value={orderData.price}
                    onChange={handleInputChange}
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
            <button onClick={handlePlaceOrder}>Place Sell Order</button>
        </div>
    );
};

export default PlaceSellOrderForm;
