# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts "Parameters: #{params}" }                                               #
after { puts; }                                                                       #
#######################################################################################

events_table = DB.from(:events)
rsvps_table = DB.from(:rsvps)

get "/" do
  @events = events_table.all
  puts @events.inspect
  view "events"
end

get "/events/:id" do
    # SELECT * FROM events WHERE id=:id
    @event = events_table.where(:id => params["id"]).to_a[0]
    # SELECT * FROM rsvps WHERE event_id=:id
    @rsvps = rsvps_table.where(:event_id => params["id"]).to_a[0]
    # SELECT * FROM rsvps WHERE event_id=:id
    @count = rsvp_table.where(:event_id => params["id"], :going => true).count

    puts @event.inspect
    puts @rsvps.inspect
    view "event"
end

get "/events/:id/rsvps/new" do
    @event = events_table.where(:id => params["id"]).to_a[0]
    puts @event.inspect
    view "new_rsvp.erb"
end

get "/events/:id/rsvps/create" do
    puts params.inspect
    rsvps_table.insert(:event_id => params["id"], 
                       :going => params["going"], 
                       :name => params["name"], 
                       :email => params ["emails"], 
                       :comments => params ["comments"])
    view "create_rsvp"
end


# get "/tacos" do
#    puts params.inspect
#    view "tacos"
# end

# get "/123/123/123/123" do
#    view "tacos"
# end