// pages/_app.js

// Import global styles
import '../styles/styles.css'; // Replace with your actual path to styles.css

// The main App component
export default function MyApp({ Component, pageProps }) {
    // Render the current page component with its props
    return <Component {...pageProps} />;
}
