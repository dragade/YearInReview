# The main controller for the Year in Review app
# it only has two main actions (intro and yir_plain)
class YirController < ApplicationController

  before_filter :set_locale

  #makes sure we have a locale set
  def set_locale
    I18n.locale = params[:locale]
    @locale = params[:locale]

    if (@locale == nil or @locale == "") then
      @locale = "en"
    end

  end

  # TODO: Go to https://www.linkedin.com/secure/developer, request a developer key and fill it in here!
  apiKeys = ApiKeys.new()
  CONSUMER_KEY = apiKeys.CONSUMER_KEY
  CONSUMER_SECRET = apiKeys.CONSUMER_SECRET

  NUM_FACES=56
  #NUM_FACES= 25  #useful to reduce to play with testing the pagination

  # Handles the oauth authentication dance
  def authenticate

    if CONSUMER_KEY && CONSUMER_SECRET
      @client = LinkedIn::Client.new(CONSUMER_KEY, CONSUMER_SECRET)
      if is_logged_in
        @client.authorize_from_access(session[:access_token], session[:access_token_secret])
      elsif has_request_token
        session[:access_token], session[:access_token_secret] = @client.authorize_from_request(session[:request_token], session[:request_token_secret], params[:oauth_verifier])
      else
        request_token = @client.request_token({:oauth_callback => request.url})
        session[:request_token] = request_token.token
        session[:request_token_secret] = request_token.secret
        redirect_to request_token.authorize_url
      end
    else
      raise "You must specify a consumer key and consumer secret in api_keys.rb!"
    end
  end

  def has_request_token
    session[:request_token] && session[:request_token_secret]
  end

  def is_logged_in
    session[:access_token] && session[:access_token_secret]
  end

  # The intro view shows the login screen and doesn't need any data
  def intro

  end

  # This is the main logic for the app
  def yir_plain
    #You can comment this line out and then the controller will
    #a) not try to authenticate against LinkedIn
    #b) read a canned JSON string from the SAVED_JSON.json file (which you can generate by setting save_json_data to true)
    @in_test_mode = false
    @save_json_data = false

    if (! @in_test_mode) then
      authenticate
    end

    @page_num = params['page_num']
    if @page_num == nil or @page_num.to_i < 1 then
      @page_num = 1
    else
      @page_num = @page_num.to_i
    end

    @year = params['year']

    begin
      @year = @year.to_i
      if (@year < 1972) then
        #let the user enter in almost any year directly if he wants, but not before 1972 (arbitrary)
        @year = 2010
      end
    rescue
      #if the uesr didn't even enter an int then just go with 2010
      @year = 2010
    end

    json_text = nil
    if (! @in_test_mode) then
      @rest_url = "/v1/people/~:(first-name,last-name,connections:(id,first-name,last-name,picture-url,site-standard-profile-request,positions:(title,start-date,end-date,is-current)))"
      json_txt = @client.access_token.get(@rest_url, 'x-li-format' => 'json').body
      if (@save_json_data) then
        puts "DEBUG-- storing saved json to SAVED_JSON.dump"
        File.open('SAVED_JSON.dump', 'w') do |f|
          Marshal.dump(json_txt, f)
          f.close
        end
      end
    else
      puts "DEBUG-- reading saved json from SAVED_JSON.dump"
      File.open('SAVED_JSON.dump') do |f|
      json_txt = Marshal.load(f)
      end
    end


    @parsed_data = JSON.parse(json_txt)

    # build up the user array
    @yir_users = []
    conns = @parsed_data['connections']
    if (conns != nil) then
      conns['values'].each do |v|
        pic_id = v['pictureUrl']
        if (pic_id != "" and pic_id != nil) then
          fname = v['firstName']
          lname = v['lastName']
          profile_url = v['siteStandardProfileRequest']['url']
          if (v['positions'] != nil and v['positions'] != "") then
            pv = v['positions']['values']
            if (pv != nil) then
              pv.each do |job|
                if job['isCurrent'] == true then
                  if (job['startDate'] != nil) then
                    #Get people who started a job in the year (2009-2011) and are still there!
                    if (job['startDate']['year'] == @year and job['endDate'] == nil) then
                      month = job['startDate']['month'].to_i
                      @yir_users << ApplicationHelper::YirUser.new(fname, lname, pic_id, profile_url, month)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    @first_name = @parsed_data['firstName']
    @yir_users = @yir_users.to_set.to_a
    @total_num_job_changers = @yir_users.size

    @has_next = false
    @has_prev = false
    if (@total_num_job_changers > 0) then
      @yir_users.sort! {|a,b| b.month <=> a.month }

      total_possible_pages = (@total_num_job_changers / NUM_FACES) +1

      startidx = (@page_num - 1) * NUM_FACES
      endidx = startidx + NUM_FACES - 1

      @yir_users = @yir_users[startidx..endidx]
      @num_job_changers = @yir_users.size
      @has_prev = startidx > 0
      @has_next = endidx < @total_num_job_changers
    end


  end

end
