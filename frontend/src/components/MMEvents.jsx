import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getAllEvents } from '../utils/services';
import CreateEvent from './CreateEvent';

const MMEvents = () => {
    const [events, setEvents] = useState([]);
    const [showCreateEvent, setShowCreateEvent] = useState(false);
    const navigate = useNavigate();

    useEffect(() => {
        const fetchEvents = async () => {
            const allEvents = await getAllEvents();
            if (allEvents) {
                setEvents(allEvents);
            }
        };
        fetchEvents();
    }, []);

    const handleEventClick = (index) => {
        navigate(`/event/${index}`);
    };

    const toggleCreateEvent = () => {
        setShowCreateEvent(!showCreateEvent);
    };

    return (
        <div>
            <h1>Events List</h1>
            <button onClick={toggleCreateEvent}>
                {showCreateEvent ? 'Hide Create Event' : 'Create New Event'}
            </button>
            {showCreateEvent && <CreateEvent />}
            <ul>
                {events.map((event, index) => (
                    <li key={index} onClick={() => handleEventClick(index)}>
                        <strong>Event id: {index}:</strong>
                        <div>Title: {event.title}</div>
                        <div>Description: {event.description}</div>
                    </li>
                ))}
            </ul>
        </div>
    );
};

export default MMEvents;