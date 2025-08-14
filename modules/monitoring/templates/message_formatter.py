#!/usr/bin/env python3
"""
Enhanced CloudWatch Alert Message Formatter
Formats CloudWatch alarm notifications for better readability and context
"""

import json
import os
import boto3
import urllib3
from datetime import datetime
from typing import Dict, Any, Optional

# Initialize clients
cloudwatch = boto3.client('cloudwatch')
http = urllib3.PoolManager()

# Environment variables
PROJECT_NAME = os.environ.get('PROJECT_NAME', '${project_name}')
ENVIRONMENT = os.environ.get('ENVIRONMENT', '${environment}')
SLACK_WEBHOOK_URL = os.environ.get('SLACK_WEBHOOK_URL', '')
TEAMS_WEBHOOK_URL = os.environ.get('TEAMS_WEBHOOK_URL', '')

def handler(event, context):
    """
    Main Lambda handler for processing SNS notifications
    """
    try:
        # Parse SNS message
        for record in event['Records']:
            if record['EventSource'] == 'aws:sns':
                message = json.loads(record['Sns']['Message'])
                
                # Format the message based on type
                formatted_message = format_cloudwatch_alarm(message)
                
                # Send to different channels
                if SLACK_WEBHOOK_URL:
                    send_slack_notification(formatted_message, message)
                
                if TEAMS_WEBHOOK_URL:
                    send_teams_notification(formatted_message, message)
                
                print(f"Successfully processed alarm: {message.get('AlarmName', 'Unknown')}")
        
        return {
            'statusCode': 200,
            'body': json.dumps('Successfully processed notifications')
        }
    
    except Exception as e:
        print(f"Error processing notification: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }

def format_cloudwatch_alarm(alarm_data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Format CloudWatch alarm data into a structured message
    """
    alarm_name = alarm_data.get('AlarmName', 'Unknown Alarm')
    alarm_description = alarm_data.get('AlarmDescription', 'No description available')
    new_state = alarm_data.get('NewStateValue', 'UNKNOWN')
    old_state = alarm_data.get('OldStateValue', 'UNKNOWN')
    reason = alarm_data.get('NewStateReason', 'No reason provided')
    timestamp = alarm_data.get('StateChangeTime', datetime.utcnow().isoformat())
    
    # Determine severity and emoji based on alarm name and state
    severity, emoji = determine_severity_and_emoji(alarm_name, new_state)
    
    # Extract metrics information
    metric_name = alarm_data.get('MetricName', 'Unknown')
    namespace = alarm_data.get('Namespace', 'Unknown')
    dimensions = alarm_data.get('Dimensions', [])
    
    # Create formatted message
    formatted_message = {
        'severity': severity,
        'emoji': emoji,
        'alarm_name': alarm_name,
        'alarm_description': alarm_description,
        'new_state': new_state,
        'old_state': old_state,
        'reason': reason,
        'timestamp': timestamp,
        'metric_name': metric_name,
        'namespace': namespace,
        'dimensions': dimensions,
        'project': PROJECT_NAME,
        'environment': ENVIRONMENT,
        'aws_account': alarm_data.get('AWSAccountId', 'Unknown'),
        'aws_region': alarm_data.get('Region', 'Unknown')
    }
    
    return formatted_message

def determine_severity_and_emoji(alarm_name: str, state: str) -> tuple:
    """
    Determine severity level and appropriate emoji based on alarm name and state
    """
    alarm_name_lower = alarm_name.lower()
    
    if state == 'OK':
        return 'info', '✅'
    
    # Critical indicators
    if any(keyword in alarm_name_lower for keyword in [
        'critical', 'emergency', 'failure', 'unhealthy', 'down', 
        'unavailable', 'connection-failures', 'system-status'
    ]):
        return 'critical', '🚨'
    
    # High severity indicators
    if any(keyword in alarm_name_lower for keyword in [
        'high-cpu', 'high-memory', 'high-response-time', 'high-error',
        'storage', 'disk', 'target-5xx'
    ]):
        return 'high', '⚠️'
    
    # Security indicators
    if any(keyword in alarm_name_lower for keyword in [
        'security', 'ddos', 'attack', 'intrusion', 'breach'
    ]):
        return 'security', '🔐'
    
    # Default to medium severity
    return 'medium', '⚡'

def send_slack_notification(formatted_message: Dict[str, Any], raw_alarm: Dict[str, Any]):
    """
    Send formatted notification to Slack
    """
    try:
        # Create Slack message format
        color = get_slack_color(formatted_message['severity'])
        
        slack_message = {
            "username": f"{PROJECT_NAME} Monitoring",
            "icon_emoji": ":rotating_light:",
            "attachments": [
                {
                    "color": color,
                    "title": f"{formatted_message['emoji']} {formatted_message['alarm_name']}",
                    "title_link": get_cloudwatch_url(formatted_message),
                    "text": formatted_message['alarm_description'],
                    "fields": [
                        {
                            "title": "Status",
                            "value": f"{formatted_message['old_state']} → {formatted_message['new_state']}",
                            "short": True
                        },
                        {
                            "title": "Environment",
                            "value": f"{formatted_message['project']} ({formatted_message['environment']})",
                            "short": True
                        },
                        {
                            "title": "Metric",
                            "value": f"{formatted_message['metric_name']} ({formatted_message['namespace']})",
                            "short": True
                        },
                        {
                            "title": "Reason",
                            "value": formatted_message['reason'],
                            "short": False
                        }
                    ],
                    "footer": f"AWS CloudWatch | {formatted_message['aws_region']}",
                    "ts": int(datetime.fromisoformat(formatted_message['timestamp'].replace('Z', '+00:00')).timestamp())
                }
            ]
        }
        
        # Send to Slack
        response = http.request(
            'POST',
            SLACK_WEBHOOK_URL,
            body=json.dumps(slack_message),
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status != 200:
            print(f"Failed to send Slack notification: {response.status}")
        else:
            print("Successfully sent Slack notification")
    
    except Exception as e:
        print(f"Error sending Slack notification: {str(e)}")

def send_teams_notification(formatted_message: Dict[str, Any], raw_alarm: Dict[str, Any]):
    """
    Send formatted notification to Microsoft Teams
    """
    try:
        # Create Teams message format
        color = get_teams_color(formatted_message['severity'])
        
        teams_message = {
            "@type": "MessageCard",
            "@context": "https://schema.org/extensions",
            "summary": f"CloudWatch Alert: {formatted_message['alarm_name']}",
            "themeColor": color,
            "sections": [
                {
                    "activityTitle": f"{formatted_message['emoji']} CloudWatch Alert",
                    "activitySubtitle": f"{formatted_message['project']} - {formatted_message['environment']}",
                    "activityImage": "https://aws.amazon.com/favicon.ico",
                    "facts": [
                        {
                            "name": "Alarm Name",
                            "value": formatted_message['alarm_name']
                        },
                        {
                            "name": "Status Change",
                            "value": f"{formatted_message['old_state']} → {formatted_message['new_state']}"
                        },
                        {
                            "name": "Metric",
                            "value": f"{formatted_message['metric_name']} ({formatted_message['namespace']})"
                        },
                        {
                            "name": "Reason",
                            "value": formatted_message['reason']
                        },
                        {
                            "name": "Environment",
                            "value": f"{formatted_message['environment']} ({formatted_message['aws_region']})"
                        }
                    ],
                    "markdown": True
                }
            ],
            "potentialAction": [
                {
                    "@type": "OpenUri",
                    "name": "View in CloudWatch",
                    "targets": [
                        {
                            "os": "default",
                            "uri": get_cloudwatch_url(formatted_message)
                        }
                    ]
                }
            ]
        }
        
        # Send to Teams
        response = http.request(
            'POST',
            TEAMS_WEBHOOK_URL,
            body=json.dumps(teams_message),
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status != 200:
            print(f"Failed to send Teams notification: {response.status}")
        else:
            print("Successfully sent Teams notification")
    
    except Exception as e:
        print(f"Error sending Teams notification: {str(e)}")

def get_slack_color(severity: str) -> str:
    """Get appropriate color for Slack attachment based on severity"""
    color_map = {
        'critical': 'danger',
        'high': 'warning',
        'security': '#800080',  # Purple
        'medium': 'warning',
        'info': 'good'
    }
    return color_map.get(severity, '#808080')

def get_teams_color(severity: str) -> str:
    """Get appropriate color for Teams card based on severity"""
    color_map = {
        'critical': 'FF0000',  # Red
        'high': 'FFA500',      # Orange
        'security': '800080',   # Purple
        'medium': 'FFFF00',    # Yellow
        'info': '00FF00'       # Green
    }
    return color_map.get(severity, '808080')

def get_cloudwatch_url(formatted_message: Dict[str, Any]) -> str:
    """Generate CloudWatch console URL for the alarm"""
    base_url = f"https://{formatted_message['aws_region']}.console.aws.amazon.com/cloudwatch/home"
    alarm_name = formatted_message['alarm_name'].replace(' ', '%20')
    return f"{base_url}?region={formatted_message['aws_region']}#alarmsV2:alarm/{alarm_name}"