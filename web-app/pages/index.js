import React, { useState } from 'react';
import TemplateCard from '../components/TemplateCard';

const templates = [
  {
    name: "Test Resource Group",
    description: "Deploy a test resource group in Azure.",
    deployUrl: "https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnate8523%2FAzureDeployHub%2Frefs%2Fheads%2Fmain%2Fdeployment-templates%2Fdummy%2Ftest-template.json",
  },
];

export default function Home() {
  const [isDarkMode, setIsDarkMode] = useState(true);

  const toggleTheme = () => {
    document.body.classList.toggle('light-mode');
    setIsDarkMode(!isDarkMode);
  };

  return (
    <>
      <header>
        <div>
          <h1>AzureDeployHub</h1>
          <p>One-click deployment templates for Azure</p>
        </div>
        <button onClick={toggleTheme}>
          {isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
        </button>
      </header>
      <main>
        <div className="container">
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
      </main>
      <footer>
        © Nathan Carroll 2024 AzureDeployHub - All Rights Reserved.
      </footer>
    </>
  );
}
