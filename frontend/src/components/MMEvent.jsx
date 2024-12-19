import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { getEvent, getPositions } from '../utils/services';
import PlaceOrderForm from './PlaceOrderForm';
import PlaceSellOrderForm from './PlaceSellOrderForm';
import PlaceMarketOrderForm from './PlaceMarketOrderForm';

const MMEvent = () => {
    const { eventIndex } = useParams();
    const [event, setEvent] = useState(null);
    const [positions, setPositions] = useState([]);

    useEffect(() => {
        const fetchEvent = async () => {
            const eventDetails = await getEvent(eventIndex);
            if (eventDetails) {
                setEvent(eventDetails);
            }
        };
        fetchEvent();
    }, [eventIndex]);

    useEffect(() => {
        const fetchPositions = async () => {
            const userAddress = await window.ethereum.request({ method: 'eth_accounts' }).then(accounts => accounts[0]);
            const positions = await getPositions(eventIndex, userAddress);
            setPositions(positions);
        };
        fetchPositions();
    }, [eventIndex]);

    if (!event) {
        return <div>Loading...</div>;
    }

    return (
        <div>
            <h1>{event.eventTitle}</h1>
            <p>{event.eventDescription}</p>
            <h2>Markets</h2>
            <ul>
                {event.marketTitles.map((title, index) => (
                    <li key={index}>
                        <strong>{title}</strong>: {event.marketDescriptions[index]}
                        <br />
                        <PlaceOrderForm eventIndex={eventIndex} marketIndex={index} />
                        <br />
                        <PlaceSellOrderForm eventIndex={eventIndex} marketIndex={index} />
                        <br />
                        <PlaceMarketOrderForm eventIndex={eventIndex} marketIndex={index} />
                        <div>
                            <h3>Positions</h3>
                            {positions.length > 0 && (
                                <div>
                                    <p>Free Yes Shares: {positions[index]?.freeYesShares}</p>
                                    <p>Reserved Yes Shares: {positions[index]?.reservedYesShares}</p>
                                    <p>Free No Shares: {positions[index]?.freeNoShares}</p>
                                    <p>Reserved No Shares: {positions[index]?.reservedNoShares}</p>
                                </div>
                            )}
                        </div>
                    </li>
                ))}
            </ul>
        </div>
    );
};

export default MMEvent;