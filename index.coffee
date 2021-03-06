# Description:
#   List ec2 instances info
#   Show detail about an instance if specified an instance id
#   Filter ec2 instances info if specified an instance name
#
# Commands:
#   hubot ec2 ls - Displays Instances
#
# Author:
#   John Naegle
#
# Heavily borrowed from https://github.com/yoheimuta/hubot-aws
#

moment = require 'moment'

getParams = (arg) ->
  params = null

  instanceCapture = /^\s*(i-\w+)$/.exec(arg);
  if instanceCapture
    params = {
      InstanceIds: [instanceCapture[1]]
    }
  else
    ipCapture = /^\s*(\d+\.\d+\.\d+\.\d+)\s*$/.exec(arg)
    if ipCapture
        params = {
          Filters: [
            Name: 'private-ip-address',
            Values: [
              ipCapture[1]
            ]
          ]
        }
    else
      nameCapture = /^\s*(\S+)\s*$/.exec(arg)
      if nameCapture
        params = {
          Filters: [
            Name: 'tag:Name',
            Values: [
              nameCapture[1]
            ]
          ]
        }
  return params

# https://stackoverflow.com/questions/9796764/how-do-i-sort-an-array-with-coffeescript
sortBy = (key, a, b, r) ->
    r = if r then 1 else -1
    return -1*r if a[key] > b[key]
    return +1*r if a[key] < b[key]
    return 0

padRight = (s,l,c) ->
  return (s||'')+Array(l-(s||'').length+1).join(c||" ")

module.exports = (robot) ->
  robot.respond /ec2 ls(.*)$/i, (msg) ->

    AWS = require 'aws-sdk'
    AWS.config.accessKeyId     = process.env.HUBOT_AWS_ACCESS_KEY_ID
    AWS.config.secretAccessKey = process.env.HUBOT_AWS_SECRET_ACCESS_KEY
    AWS.config.region          = process.env.HUBOT_AWS_REGION

    ec2 = new AWS.EC2({apiVersion: '2014-10-01'})
    ec2.describeInstances (getParams(msg.match[1])), (err, res) ->
      if err
        msg.send "DescribeInstancesError: #{err}"
      else
        servers = []
        for data in res.Reservations

          for instance in data.Instances

            continue unless instance.State.Name in ['pending', 'running', 'shutting-down', 'stopping']

            name = '[NoName]'
            environment = ''
            for tag in instance.Tags
              if tag.Key == 'Name'
                name = tag.Value
              if tag.Key == 'environment'
                environment = tag.Value

            servers.push {
              name: name,
              environment: environment,
              state: instance.State.Name,
              instance_id: instance.InstanceId,
              launch_time: moment(instance.LaunchTime).format('YYYY-MM-DD HH:mm:ssZ'),
              private_ip: instance.PrivateIpAddress,
              instance_type: instance.InstanceType
            }

        servers.sort (a,b) ->
          sortBy('environment', a, b, true) or
          sortBy('state', a, b) or
          sortBy('name', a, b) or
          sortBy('instance_id', a, b)


        if servers.length == 0
          msg.send "No matching servers"
        else
          text =   "#{padRight('Environment', 20)} #{padRight('Name', 32)} #{padRight('State', 16)} #{padRight('Instance Id', 20)} #{padRight('Instance Type', 16)} #{padRight('Private IP', 16)}\n"
          text +=  "----------------------------------------------------------------------------------------------------------------------------------------\n"
          text += ("#{padRight(s.environment, 20)} #{padRight(s.name, 32)} #{padRight(s.state, 16)} #{padRight(s.instance_id, 20)} #{padRight(s.instance_type, 16)} #{padRight(s.private_ip, 16)}" for s in servers).join("\n")
          msg.send "```#{text}```"
