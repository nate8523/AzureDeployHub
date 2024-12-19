import React from 'react';

export default function TemplateCard({ name, description, deployUrl }) {
  return (
    <div className="card mb-4 shadow-sm">
      <div className="card-body">
        <h5 className="card-title">{name}</h5>
        <p className="card-text">{description}</p>
        <a href={deployUrl} className="btn btn-primary" target="_blank" rel="noopener noreferrer">
          Deploy to Azure
        </a>
      </div>
    </div>
  );
}
