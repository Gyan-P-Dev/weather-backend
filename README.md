# Backend Setup Guide

This guide provides the necessary steps to set up the backend for your weather forecasting application. Follow the instructions below to get the application running, from the initial setup to running test cases.

## Prerequisites

Before you begin, ensure the following tools are installed on your machine:

- **Ruby**
- **Rails** 
- **Node.js**
- **Bundler**

## 1. Clone the Repository

1. **git clone https://github.com/Gyan-P-Dev/weather-backend.git**
2. **cd weather-app-backend**

## 2. Install Ruby and Rails Dependencies
Next, install the required Ruby gems and dependencies for the project: **bundle install**

## 3. Set Up the Weather API Key
To fetch weather data, you need a valid Weatherbit API key. Follow these steps to set it up:

1. Visit Weatherbit API and sign up for an API key.
2. Add the API key to your environment variables.

```or```

**Adding the API Key:**
Create .env file in the root directory and put the API key (WEATHERBIT_API_KEY=587dc776b0f44990a1e7cee19e098c65) 

## 4. Running the Server: rails s
This will launch the application on the default port (http://localhost:3000).

## 5. Running Test Cases: rspec


## 6. Cleaning Up
Once you're finished working with the application, you can stop the Rails server by pressing Ctrl+C in your terminal.
