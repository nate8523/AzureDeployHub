import React from 'react';

export default function TemplateCard({ name, description, deployUrl }) {
  return (
    <div
      className="card text-center d-flex justify-content-center align-items-center"
      style={{ width: '18rem', padding: '20px', margin: '10px', boxShadow: '0px 4px 6px rgba(0, 0, 0, 0.1)' }}
    >
      <div className="card-body">
        <h5 className="card-title">{name}</h5>
        <p className="card-text">{description}</p>
        <a href={deployUrl} target="_blank" rel="noopener noreferrer">
          <img
            src="https://aka.ms/deploytoazurebutton"
            alt="Deploy to Azure"
            style={{ maxWidth: '100%', height: 'auto' }}
          />
        </a>
      </div>
    </div>
  );
}
