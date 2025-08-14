import json
import urllib3
import os
from datetime import datetime

def handler(event, context):
    """
    Lambda function to send CloudWatch alarm notifications to Slack
    """
    
    # Get environment variables
    webhook_url = os.environ.get('SLACK_WEBHOOK_URL')
    project_name = os.environ.get('PROJECT_NAME', 'Unknown')
    environment = os.environ.get('ENVIRONMENT', 'Unknown')
    
    if not webhook_url:
        print("ERROR: SLACK_WEBHOOK_URL environment variable not set")
        return {'statusCode': 400, 'body': 'Webhook URL not configured'}
    
    try:
        # Parse SNS message
        sns_message = json.loads(event['Records'][0]['Sns']['Message'])
        
        # Extract alarm information
        alarm_name = sns_message.get('AlarmName', 'Unknown Alarm')
        alarm_description = sns_message.get('AlarmDescription', 'No description')
        new_state = sns_message.get('NewStateValue', 'UNKNOWN')
        old_state = sns_message.get('OldStateValue', 'UNKNOWN')
        region = sns_message.get('Region', 'Unknown')
        timestamp = sns_message.get('StateChangeTime', datetime.utcnow().isoformat())
        
        # Parse alarm name to extract components
        alarm_parts = alarm_name.split('-')
        service_type = 'Unknown'
        if 'ec2' in alarm_name:
            service_type = 'EC2 Instance'
        elif 'rds' in alarm_name:
            service_type = 'RDS Database'
        elif 'alb' in alarm_name:
            service_type = 'Load Balancer'
        
        # Determine message color and emoji based on state
        color_map = {
            'ALARM': '#ff0000',      # Red
            'OK': '#00ff00',         # Green
            'INSUFFICIENT_DATA': '#ffaa00'  # Orange
        }
        
        emoji_map = {
            'ALARM': '🚨',
            'OK': '✅',
            'INSUFFICIENT_DATA': '⚠️'
        }
        
        color = color_map.get(new_state, '#888888')
        emoji = emoji_map.get(new_state, '❓')
        
        # Create Slack message
        slack_message = {
            "username": f"{project_name} Monitoring",
            "icon_emoji": ":warning:",
            "attachments": [
                {
                    "color": color,
                    "title": f"{emoji} {service_type} Alert - {environment.upper()}",
                    "title_link": f"https://console.aws.amazon.com/cloudwatch/home?region={region}#alarmsV2:alarm/{alarm_name}",
                    "fields": [
                        {
                            "title": "Alarm Name",
                            "value": alarm_name,
                            "short": True
                        },
                        {
                            "title": "Status",
                            "value": f"{old_state} → {new_state}",
                            "short": True
                        },
                        {
                            "title": "Project",
                            "value": project_name,
                            "short": True
                        },
                        {
                            "title": "Environment",
                            "value": environment.upper(),
                            "short": True
                        },
                        {
                            "title": "Description",
                            "value": alarm_description,
                            "short": False
                        },
                        {
                            "title": "Time",
                            "value": timestamp,
                            "short": True
                        },
                        {
                            "title": "Region",
                            "value": region,
                            "short": True
                        }
                    ],
                    "footer": "AWS CloudWatch",
                    "footer_icon": "https://a0.awsstatic.com/libra-css/images/logos/aws_logo_smile_1200x630.png",
                    "ts": int(datetime.utcnow().timestamp())
                }
            ]
        }
        
        # Add action buttons for critical alarms
        if new_state == 'ALARM':
            slack_message["attachments"][0]["actions"] = [
                {
                    "type": "button",
                    "text": "View in CloudWatch",
                    "url": f"https://console.aws.amazon.com/cloudwatch/home?region={region}#alarmsV2:alarm/{alarm_name}",
                    "style": "primary"
                },
                {
                    "type": "button",
                    "text": "View EC2 Instances",
                    "url": f"https://console.aws.amazon.com/ec2/v2/home?region={region}#Instances:",
                    "style": "default"
                }
            ]
            
            # Add suggested actions based on alarm type
            suggested_actions = []
            if 'cpu' in alarm_name.lower():
                suggested_actions.append("• Check CPU usage and consider scaling")
                suggested_actions.append("• Review application performance")
            elif 'memory' in alarm_name.lower():
                suggested_actions.append("• Check for memory leaks")
                suggested_actions.append("• Consider instance resize")
            elif 'disk' in alarm_name.lower():
                suggested_actions.append("• Clean up disk space")
                suggested_actions.append("• Expand storage if needed")
            elif 'connection' in alarm_name.lower():
                suggested_actions.append("• Check database connection pools")
                suggested_actions.append("• Review application connection handling")
            
            if suggested_actions:
                slack_message["attachments"][0]["fields"].append({
                    "title": "Suggested Actions",
                    "value": "\\n".join(suggested_actions),
                    "short": False
                })
        
        # Send to Slack
        http = urllib3.PoolManager()
        response = http.request(
            'POST',
            webhook_url,
            body=json.dumps(slack_message).encode('utf-8'),
            headers={'Content-Type': 'application/json'}
        )
        
        print(f"Slack notification sent. Response status: {response.status}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Slack notification sent successfully',
                'alarm_name': alarm_name,
                'state': new_state
            })
        }
        
    except Exception as e:
        print(f"ERROR: Failed to send Slack notification: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'message': 'Failed to send Slack notification'
            })
        }