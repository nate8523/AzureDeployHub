import React from 'react';
import TemplateCard from '../components/TemplateCard';

const templates = [
  {
    name: "Test Resource Group",
    description: "Deploy a test resource group in Azure.",
    deployUrl: "https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnate8523%2FAzureDeployHub%2Frefs%2Fheads%2Fmain%2Fdeployment-templates%2Fdummy%2Ftest-template.json"
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
