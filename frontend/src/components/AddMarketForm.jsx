import React, { useState } from 'react';
import { addMarket } from '../utils/services';

const AddMarketForm = ({ eventIndex, onMarketAdded }) => {
  const [marketTitle, setMarketTitle] = useState('');
  const [marketDescription, setMarketDescription] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    await addMarket(eventIndex, marketTitle, marketDescription);
    setIsSubmitting(false);
    setMarketTitle('');
    setMarketDescription('');
    onMarketAdded();
  };

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label>Market Title:</label>
        <input
          type="text"
          value={marketTitle}
          onChange={(e) => setMarketTitle(e.target.value)}
          required
        />
      </div>
      <div>
        <label>Market Description:</label>
        <input
          type="text"
          value={marketDescription}
          onChange={(e) => setMarketDescription(e.target.value)}
          required
        />
      </div>
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Adding Market...' : 'Add Market'}
      </button>
    </form>
  );
};

export default AddMarketForm;
