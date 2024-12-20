import React, { useEffect, useState, useCallback } from 'react';
import { useParams } from 'react-router-dom';
import { requestAccount, getEvent, getPositions } from '../utils/services';
import PlaceOrderForm from './PlaceOrderForm';
import PlaceSellOrderForm from './PlaceSellOrderForm';
import PlaceMarketOrderForm from './PlaceMarketOrderForm';
import EventEmitter from "../utils/EventEmitter";

const MMEvent = () => {
    const { eventIndex } = useParams();
    const [event, setEvent] = useState(null);
    const [positions, setPositions] = useState([]);

    const fetchEvent = useCallback(async () => {
        const eventDetails = await getEvent(eventIndex);
        if (eventDetails) {
            setEvent(eventDetails);
        }
    }, [eventIndex]);

    const fetchPositions = useCallback(async () => {
        const userAddress = await requestAccount();
        const positions_req = await getPositions(eventIndex, userAddress);
        setPositions(positions_req);
    }, [eventIndex]);

    useEffect(() => {
        fetchEvent();
        fetchPositions();

        const handleAccountChanged = () => {
            console.log("Account changed, fetching positions again");
            fetchPositions();
        };

        EventEmitter.on("accountChanged", handleAccountChanged);

        return () => {
            EventEmitter.off("accountChanged", handleAccountChanged);
        };
    }, [eventIndex, fetchEvent, fetchPositions]);

    if (!event) {
        return <p>Couldn't retrieve the event. Please make sure to connect your wallet to view the event."</p>
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
                            {positions.length > 0 ? (
                                <>
                                    <h3>Positions</h3>
                                    <div>
                                        <p>Free Yes Shares: {positions[index]?.freeYesShares}</p>
                                        <p>Reserved Yes Shares: {positions[index]?.reservedYesShares}</p>
                                        <p>Free No Shares: {positions[index]?.freeNoShares}</p>
                                        <p>Reserved No Shares: {positions[index]?.reservedNoShares}</p>
                                    </div>
                                </>
                            ) : (
                                <>
                                    <p>Please connect your wallet to view positions.</p>
                                </>
                            )}
                        </div>
                    </li>
                ))}
            </ul>
        </div>
    );
};

export default MMEvent;