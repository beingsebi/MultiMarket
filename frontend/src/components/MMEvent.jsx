import React, { useEffect, useState, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { requestAccount, getEvent, getPositions, resolveMarket } from '../utils/services';
import PlaceOrderForm from './PlaceOrderForm';
import PlaceSellOrderForm from './PlaceSellOrderForm';
import PlaceMarketOrderForm from './PlaceMarketOrderForm';
import ActiveOrders from './ActiveOrders';
import EventEmitter from "../utils/EventEmitter";
import AddMarketForm from './AddMarketForm';

const MMEvent = () => {
    const { eventIndex } = useParams();
    const navigate = useNavigate();
    const [event, setEvent] = useState(null);
    const [positions, setPositions] = useState([]);
    const [showAddMarketForm, setShowAddMarketForm] = useState(false);

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

    const handleToggleAddMarketForm = () => {
        setShowAddMarketForm(!showAddMarketForm);
    };

    const handleMarketAdded = () => {
        fetchEvent();
    };

    const handleResolveMarket = async (marketIndex) => {
        const winningOutcome = prompt("Enter the winning outcome (Yes or No):");
        
        if (winningOutcome !== null) {
            const outcomeValue = winningOutcome.toLowerCase() === "yes" ? 0 : winningOutcome.toLowerCase() === "no" ? 1 : null;
            
            if (outcomeValue !== null) {
                try {
                    await resolveMarket(eventIndex, marketIndex, outcomeValue);
                    fetchEvent();
                } catch (error) {
                    console.error("Error resolving market:", error);
                }
            } else {
                alert("Invalid input. Please enter 'Yes' or 'No'.");
            }
        } else {
            alert("Input cannot be null. Please enter 'Yes' or 'No'.");
        }
    };

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
        return <p>Couldn't retrieve the event. Please make sure to connect your wallet to view the event.</p>
    }

    return (
        <div>
            <button onClick={() => navigate('/')}>Back to Events</button>
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
                        <br />
                        <ActiveOrders eventIndex={eventIndex} marketIndex={index} />
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
                                    <p>No positions availalbile.</p>
                                </>
                            )}
                        </div>
                        <br />
                        <strong>Resolved:</strong> {event.marketResolved[index] ? "Yes" : "Not yet"}
                        <br />
                        {!event.marketResolved[index] && (
                            <button onClick={() => handleResolveMarket(index)}>Resolve Market</button>
                        )}
                        <hr /> {/* Separator between markets */}
                    </li>
                ))}
            </ul>
            <button onClick={handleToggleAddMarketForm}>
                {showAddMarketForm ? 'Hide Add Market Form' : 'Show Add Market Form'}
            </button>
            {showAddMarketForm && (
                <AddMarketForm eventIndex={eventIndex} onMarketAdded={handleMarketAdded} />
            )}
        </div>
    );
};

export default MMEvent;