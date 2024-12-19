import React from 'react';
import TemplateCard from '../components/TemplateCard';

const templates = [
  {
    name: "Virtual Network",
    description: "Deploy a VNet with subnets.",
    deployUrl: "https://portal.azure.com/#create/Microsoft.Template/uri/<raw-github-url>"
  },
  {
    name: "Web App",
    description: "Deploy an App Service with an App Plan.",
    deployUrl: "https://portal.azure.com/#create/Microsoft.Template/uri/<raw-github-url>"
  }
];

export default function Home() {
  return (
    <div>
      <h1>AzureDeployHub</h1>
      <p>One-click deployment templates for Azure</p>
      <div style={{ display: 'flex', gap: '20px' }}>
        {templates.map((template) => (
          <TemplateCard
            key={template.name}
            name={template.name}
            description={template.description}
            deployUrl={template.deployUrl}
          />
        ))}
      </div>
    </div>
  );
}
