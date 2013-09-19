#encoding: UTF-8
class Api::Json::GeocodingsController < Api::ApplicationController
  ssl_required :index, :show, :create

  def index
    geocodings = current_user.geocoding_jobs
    render json: { geocodings: geocodings.map(&:id), success: true }
  end

  def show
    geocoding = Geocoding[params[:id]]
    render json: geocoding
  end

  def create
    options = { 
      user_id:     current_user.id,
      table_name:  params[:table_name].presence,
      formatter:   params[:formatter].presence
    }
      
    geocoding = Geocoding.create(options)
    Resque.enqueue(Resque::GeocoderJobs, job_id: geocoding.id)

    render_jsonp(geocoding.to_json)
  rescue Sequel::ValidationFailed => e
    render_jsonp( { description: e.message }, 422)
  end
end
