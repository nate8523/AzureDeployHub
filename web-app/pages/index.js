import React from 'react';
import TemplateCard from '../components/TemplateCard';

const templates = [
  {
    name: "Test Resource Group",
    description: "Deploy a test resource group in Azure.",
    deployUrl: "https://portal.azure.com/#create/Microsoft.Template/uri/https://raw.githubusercontent.com/nate8523/AzureDeployHub/refs/heads/main/deployment-templates/dummy/test-template.json"
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
