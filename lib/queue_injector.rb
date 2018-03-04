$LOAD_PATH << File.expand_path(File.join(*%w[../bin]), File.dirname(__FILE__))
libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'sinatra'
require 'java'
require 'jms-2_0.jar'
require 'tibjms-8.0.0.jar'
require 'tibjmsadmin.jar'
require 'activemq-all-5.11.1.jar'
require 'pry'
require 'json'
require 'nokogiri'
require 'exceptions'
require 'message_parser'
require 'custom_header_parser'

set :environment, :production

helpers do

    def establish_connection(connection_params)
      @type = connection_params[:queue_type]
      @server = connection_params[:server_endpoint]
      @queue_name = connection_params[:queue_name]
      @username = connection_params[:username]
      @password = connection_params[:password]
      @ack_mode = Java::JavaxJms::Session::AUTO_ACKNOWLEDGE
      begin
        @connection = factory_init.createConnection(@username, @password)
      rescue Exception => e
        raise DataFaker::Exceptions::ServerConnectionError, "#{e.message}"
      end
      transacted = false
      @session = @connection.createSession(transacted, @ack_mode)
      @destination = @session.createQueue(@queue_name)
      @msg_producer = @session.createProducer(nil)
    end

    def post_message (custom_headers, message)
        @connection.start
        parse_header = DataFaker::CustomHeaderParser.parse(custom_headers)
        test_message = @session.createTextMessage
        parse_header.each {|key,value| test_message.setStringProperty(key,value)}
        test_message.setText(message)
        @msg_producer.send(@destination,test_message)
        @connection.close
    end

    def factory_init
      (@type.downcase.include? 'tibco')? factory_init_tibco: factory_init_activemq
    end

    def factory_init_tibco
        @factory = Java::ComTibcoTibjms::TibjmsConnectionFactory.new @server
    end

    def factory_init_activemq
        @factory = Java::OrgApacheActivemq::ActiveMQConnectionFactory.new @server
    end

end

  post '/qinjector/tibco' do

    header_app_type = request.env['CONTENT_TYPE']
    header_server_url = request.env['HTTP_SERVER_URL']
    header_username = request.env['HTTP_USERNAME']
    header_password = request.env['HTTP_PASSWORD']
    header_queue_name = request.env['HTTP_QUEUE_NAME']
    header_custom = request.env['HTTP_CUSTOM_HEADER']
    type = 'tibco'

    connection_params = {
              queue_type: type,
              server_endpoint: header_server_url,
              username: header_username,
              password: header_password,
              queue_name: header_queue_name
    }


    begin
      establish_connection(connection_params)
    rescue Exception => e
      halt 400, "#{e.to_s}"
    end

    p "Attempting to publish #{header_app_type} message to tibco queue server #{header_server_url}"

    request.body.rewind  # in case someone already read it
    body_message = request.body.read
    if header_app_type.downcase.include? 'json'
      begin
        DataFaker::MessageParser.parse_json(body_message)
      rescue Exception => e
        halt 400, "Error in request: #{e.to_s}"
      end
    elsif header_app_type.downcase.include? 'xml'
      begin
        DataFaker::MessageParser.parse_xml(body_message)
      rescue Exception => e
        halt 400, "Error in request: #{e.to_s}"
      end
    else
      halt 400, 'Invalid content type specified. JSON and XML supported.'
    end

    post_message(header_custom,body_message)

  end


  post '/qinjector/activemq' do

    header_app_type = request.env['CONTENT_TYPE']
    header_server_url = request.env['HTTP_SERVER_URL']
    header_username = request.env['HTTP_USERNAME']
    header_password = request.env['HTTP_PASSWORD']
    header_queue_name = request.env['HTTP_QUEUE_NAME']
    header_custom = request.env['HTTP_CUSTOM_HEADER']
    type = 'activemq'

    connection_params = {
        queue_type: type,
        server_endpoint: header_server_url,
        username: header_username,
        password: header_password,
        queue_name: header_queue_name
    }

    begin
      establish_connection(connection_params)
    rescue Exception => e
      halt 400, "#{e.to_s}"
    end

    p "Attempting to publish #{header_app_type} message to tibco queue server #{header_server_url}"

    request.body.rewind  # in case someone already read it
    body_message = request.body.read
    if header_app_type.downcase.include? 'json'
      begin
        DataFaker::MessageParser.parse_json(body_message)
      rescue Exception => e
        halt 400, "Error in request: #{e.to_s}"
      end
    elsif header_app_type.downcase.include? 'xml'
      begin
        DataFaker::MessageParser.parse_xml(body_message)
      rescue Exception => e
        halt 400, "Error in request: #{e.to_s}"
      end
    else
      halt 400, 'Invalid content type specified. JSON and XML supported.'
    end

    post_message(header_custom,body_message)

  end
