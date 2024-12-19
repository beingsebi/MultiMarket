import React, { useState } from 'react';
import { placeLimitBuyOrder } from '../utils/services';

const PlaceOrderForm = ({ eventIndex, marketIndex }) => {
    const [orderData, setOrderData] = useState({ betOutcome: 0, price: "", shares: "" });

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setOrderData({ ...orderData, [name]: value });
    };

    const handlePlaceOrder = async () => {
        const { betOutcome, price, shares } = orderData;
        await placeLimitBuyOrder(eventIndex, marketIndex, betOutcome, price, shares);
    };

    return (
        <div>
            <label>
                Bet Outcome:
                <input
                    type="number"
                    min="0"
                    max="1"
                    name="betOutcome"
                    value={orderData.betOutcome}
                    onChange={handleInputChange}
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
            <button onClick={handlePlaceOrder}>Place Buy Order</button>
        </div>
    );
};

export default PlaceOrderForm;
