import React from 'react';
import TemplateCard from '../components/TemplateCard';

const templates = [
  {
    name: "Test Resource Group",
    description: "Deploy a test resource group in Azure.",
    deployUrl: "https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnate8523%2FAzureDeployHub%2Frefs%2Fheads%2Fmain%2Fdeployment-templates%2Fdummy%2Ftest-template.json",
  },
];

export default function Home() {
  const toggleTheme = () => {
    document.body.classList.toggle('light-mode');
  };

  return (
    <div className="container">
      <header>
        <h1>AzureDeployHub</h1>
        <p>One-click deployment templates for Azure</p>
        <button onClick={toggleTheme}>Toggle Theme</button>
      </header>
      <main>
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
      </main>
      <footer>
        © 2024 AzureDeployHub - All Rights Reserved.
      </footer>
    </div>
  );
}
