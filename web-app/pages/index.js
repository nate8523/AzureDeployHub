import React from 'react';
import TemplateCard from '../components/TemplateCard';
import 'bootstrap/dist/css/bootstrap.min.css';

const templates = [
  {
    name: "Test Resource Group",
    description: "Deploy a test resource group in Azure.",
    deployUrl: "https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnate8523%2FAzureDeployHub%2Frefs%2Fheads%2Fmain%2Fdeployment-templates%2Fdummy%2Ftest-template.json"
  },
  // Add more templates here
];

export default function Home() {
  return (
    <div className="container">
      <header className="text-center my-5">
        <h1>AzureDeployHub</h1>
        <p>One-click deployment templates for Azure</p>
      </header>
      
      <div className="row">
        {templates.map((template) => (
          <div className="col-md-4" key={template.name}>
            <TemplateCard
              name={template.name}
              description={template.description}
              deployUrl={template.deployUrl}
            />
          </div>
        ))}
      </div>
    </div>
  );
}
