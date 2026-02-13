/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
        "./App.{js,jsx,ts,tsx}",
        "./src/**/*.{js,jsx,ts,tsx}"
    ],
    theme: {
        extend: {
            colors: {
                // Light theme (Green primary)
                light: {
                    primary: '#10b981',       // green-500
                    primaryDark: '#059669',   // green-600
                    background: '#ffffff',
                    surface: '#f9fafb',       // gray-50
                    surfaceVariant: '#f3f4f6', // gray-100
                    text: '#111827',          // gray-900
                    textSecondary: '#6b7280', // gray-500
                    border: '#d1d5db',        // gray-300
                },
                // Dark theme
                dark: {
                    primary: '#10b981',       // green-500
                    primaryDark: '#059669',   // green-600
                    background: '#111827',    // gray-900
                    surface: '#1f2937',       // gray-800
                    surfaceVariant: '#374151', // gray-700
                    text: '#f9fafb',          // gray-50
                    textSecondary: '#9ca3af', // gray-400
                    border: '#374151',        // gray-700
                },
                // Dark Pink theme (Simplified)
                pink: {
                    primary: '#ec4899',       // pink-500
                    primaryDark: '#db2777',   // pink-600
                    background: '#18181b',    // zinc-900
                    surface: '#27272a',       // zinc-800
                    surfaceVariant: '#3f3f46', // zinc-700
                    text: '#fafafa',          // gray-50
                    textSecondary: '#a1a1aa', // zinc-400
                    accent: '#f472b6',        // pink-400
                    border: '#3f3f46',        // zinc-700
                },
            },
        },
    },
    plugins: [],
}
