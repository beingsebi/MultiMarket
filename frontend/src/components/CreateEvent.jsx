import React, { useState } from 'react';
import { createEvent } from '../utils/services';

const CreateEvent = () => {
  const [eventTitle, setEventTitle] = useState('');
  const [eventDescription, setEventDescription] = useState('');

  const handleCreateEvent = async () => {
    await createEvent(eventTitle, eventDescription);
  };

  return (
    <div>
      <h1>Create Event</h1>
      <input
        type="text"
        placeholder="Event Title"
        value={eventTitle}
        onChange={(e) => setEventTitle(e.target.value)}
      />
      <textarea
        placeholder="Event Description"
        value={eventDescription}
        onChange={(e) => setEventDescription(e.target.value)}
      />
      <button onClick={handleCreateEvent}>Create Event</button>
    </div>
  );
};

export default CreateEvent;
