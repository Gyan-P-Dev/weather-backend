require 'httparty'

class ForecastController < ApplicationController
  def index
    city = params[:city]
    country = params[:country]
    days = 10

    # Validate required parameters
    if city.blank? || country.blank?
      return render json: { error: 'City and country parameters are required' }, status: :bad_request
    end

    # Validate API key presence
    api_key = ENV['WEATHERBIT_API_KEY']
    if api_key.blank?
      return render json: { error: 'API key is missing or invalid' }, status: :unauthorized
    end

    # Fetch forecast data
    response = fetch_forecast(city, country, days, api_key)
    return if performed?

    # Parse and validate the response
    forecast_data = parse_forecast_data(response)
    return if performed?

    # Calculate average temperature and seven-day forecast
    average_temp = calculate_average_temp(forecast_data)
    seven_day_forecast = format_seven_day_forecast(forecast_data)

    render json: {
      average_temp: average_temp.to_i,
      seven_day_forecast: seven_day_forecast
    }
  end

  private

  def fetch_forecast(city, country, days, api_key)
    HTTParty.get("https://api.weatherbit.io/v2.0/forecast/daily", {
      query: {
        city: city,
        country: country,
        days: days,
        key: api_key
      }
    })
  rescue Net::ReadTimeout
    render json: { error: 'Weather service is unavailable. Please try again later.' }, status: :service_unavailable
    nil
  rescue StandardError => e
    Rails.logger.error("Unexpected error: #{e.message}")
    render json: { error: 'An unexpected error occurred. Please try again.' }, status: :internal_server_error
    nil
  end

  def parse_forecast_data(response)
    unless response.success?
      render json: { error: 'City not found or API error' }, status: :not_found
      return nil
    end

    data = response.parsed_response
    forecast_data = data['data']

    if forecast_data.blank? || !forecast_data.is_a?(Array)
      render json: { error: 'Malformed response from weather service' }, status: :unprocessable_entity
      return nil
    end

    forecast_data
  end

  def calculate_average_temp(forecast_data)
    temps = forecast_data.map { |day| day['temp'] }
    temps.sum / temps.size.to_f
  end

  def format_seven_day_forecast(forecast_data)
    forecast_data.first(7).map do |day|
      {
        date: Date.parse(day['datetime']).strftime('%A'),
        temp: day['temp'].to_i
      }
    end
  end
end
