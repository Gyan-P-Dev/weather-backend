require 'rails_helper'

RSpec.describe ForecastController, type: :controller do
  describe 'GET #index' do
    context 'when valid city and country are provided' do
      it 'returns the average temperature and seven-day forecast' do
        allow(HTTParty).to receive(:get).and_return(
          instance_double(HTTParty::Response, success?: true, parsed_response: {
            'data' => Array.new(10) { |i| { 'datetime' => (Date.today + i).to_s, 'temp' => 20 + i } }
          })
        )

        get :index, params: { city: 'Delhi', country: 'IN' }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['average_temp']).to eq(24)
        expect(json_response['seven_day_forecast'].size).to eq(7)
      end
    end

    context 'when an invalid city is provided' do
      it 'returns an error message' do
        allow(HTTParty).to receive(:get).and_return(
          instance_double(HTTParty::Response, success?: false)
        )

        get :index, params: { city: 'InvalidCity', country: 'XX' }

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('City not found or API error')
      end
    end

    context 'when city or country parameter is missing' do
      it 'returns an error message for missing city' do
        get :index, params: { country: 'IN' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('City and country parameters are required')
      end

      it 'returns an error message for missing country' do
        get :index, params: { city: 'Delhi' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('City and country parameters are required')
      end
    end

    context 'when the external API is down or unresponsive' do
      it 'handles timeouts gracefully' do
        allow(HTTParty).to receive(:get).and_raise(Net::ReadTimeout)

        get :index, params: { city: 'Delhi', country: 'IN' }

        expect(response).to have_http_status(:service_unavailable)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Weather service is unavailable. Please try again later.') # updated
      end
    end

    context 'when the response contains incomplete or malformed data' do
      it 'returns an error message' do
        allow(HTTParty).to receive(:get).and_return(
          instance_double(HTTParty::Response, success?: true, parsed_response: {})
        )

        get :index, params: { city: 'Delhi', country: 'IN' }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Malformed response from weather service')
      end
    end

    context 'when fewer than 7 days of data are returned' do
      it 'adjusts the seven-day forecast accordingly' do
        allow(HTTParty).to receive(:get).and_return(
          instance_double(HTTParty::Response, success?: true, parsed_response: {
            'data' => Array.new(5) { |i| { 'datetime' => (Date.today + i).to_s, 'temp' => 20 + i } }
          })
        )

        get :index, params: { city: 'Delhi', country: 'IN' }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['seven_day_forecast'].size).to eq(5)
      end
    end
  end
end
