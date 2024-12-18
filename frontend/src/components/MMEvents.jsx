import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getAllEvents } from '../utils/services';


const MMEvents = () => {
    const [events, setEvents] = useState([]);
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

    return (
        <div>
            <h1>Events List</h1>
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