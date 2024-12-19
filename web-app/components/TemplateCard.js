import React from 'react';

export default function TemplateCard({ name, description, deployUrl }) {
  return (
    <div style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
      <h3>{name}</h3>
      <p>{description}</p>
      <a href={deployUrl} target="_blank" rel="noopener noreferrer">
        <button style={{ padding: '10px 20px', backgroundColor: '#0078D4', color: '#fff', border: 'none', borderRadius: '4px' }}>
          Deploy to Azure
        </button>
      </a>
    </div>
  );
}
