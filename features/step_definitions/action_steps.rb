require 'tef/development/step_definitions/action_steps'

And(/^tasks are sent to the manager$/) do
  # Need something hooked up before things start working that will capture output messages
  out_message_exchange = "tef.#{@tef_env}.generic.keeper_generated_messages"
  @capture_message_queue = @bunny_channel.queue('test_message_capture_queue')
  @capture_message_queue.bind(out_message_exchange, routing_key: '#')

  # Manager needs to be ready
  task_queue_name = "tef.#{@tef_env}.manager"
  wait_for { @bunny_connection.queue_exists?(task_queue_name) }.to be true

  @explicit_test_tasks = []

  # A little work to do
  3.times do |count|
    request = @base_task.dup
    request[:guid] = "123456-#{count}"
    request[:type] = 'task'
    request[:task_type] = 'generic'
    request[:task_data] = {}
    request[:task_data][:root_location] = "#{@test_work_location}"
    request[:task_data][:command] = "echo Task #{request[:guid]} did a thing!"

    @explicit_test_tasks << request[:guid]

    get_queue(task_queue_name).publish(request.to_json)
  end

end
