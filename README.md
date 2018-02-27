# hubot-ec2

List EC2 instances in Hubot

## Installation

Add **hubot-ec2** to your `package.json` file:

```
npm install --save hubot-ec2
```

Add **hubot-ec2** to your `external-scripts.json`:

```json
["hubot-ec2"]
```

Run `npm install`

## Commands

```
hubot ec2 ls - Displays all Instances
hubot ec2 ls i-abcd1234 - Details an Instance
hubot ec2 ls *production* - Instances that contain production in their name tag
hubot ec2 ls 10.10.10.10 - queries by private-ip address
```

## Configurations

Set environment variables like an example below.

```
export HUBOT_AWS_ACCESS_KEY_ID="ACCESS_KEY"
export HUBOT_AWS_SECRET_ACCESS_KEY="SECRET_ACCESS_KEY"
export HUBOT_AWS_REGION="us-east-1"
```

## Examples

### EC2

hubot ec2 ls - Displays all Instances

```
Environment          Name                             State            InstanceId       Launch Time
-----------------------------------------------------------------------------------------------------------------
production-vpc       production-application-1         running          i-abcd0123       2016-07-07 12:15:47-04:00
staging-vpc          staging-application-1            running          i-abcd0124       2016-07-12 08:40:35-04:00
```


hubot ec2 ls production* - Displays all Instances with a name starting with production-

```
Environment          Name                             State            InstanceId       Launch Time
-----------------------------------------------------------------------------------------------------------------
production-vpc       production-application-1         running          i-abcd0123       2016-07-07 12:15:47-04:00
production-vpc       production-application-2         running          i-abcd0124       2016-07-12 08:40:35-04:00
production-vpc       production-application-3         running          i-abcd0125       2016-06-02 05:36:12-04:00
production-vpc       production-db-master             running          i-abcd0126       2015-12-08 13:13:48-05:00
production-vpc       production-db-slave              running          i-abcd0127       2016-01-07 07:36:32-04:00
```

## Credits

Based on https://github.com/yoheimuta/hubot-aws
