import React, { useState, useEffect } from 'react';
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

  useEffect(() => {
    document.body.classList.toggle('light-mode', !isDarkMode);
  }, [isDarkMode]);

  const toggleTheme = () => setIsDarkMode(!isDarkMode);

  return (
    <div className="page-container">
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
        <TemplateCard
          name={templates[0].name}
          description={templates[0].description}
          deployUrl={templates[0].deployUrl}
        />
      </main>
      <footer>
        © 2024 AzureDeployHub - All Rights Reserved.
      </footer>
    </div>
  );
}
