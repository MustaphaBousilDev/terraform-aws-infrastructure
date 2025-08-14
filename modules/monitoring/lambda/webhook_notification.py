import json
import urllib3
import os
from datetime import datetime
import base64

def handler(event, context):
    """
    Lambda function to send CloudWatch alarm notifications to custom webhook endpoints
    """
    
    # Get environment variables
    webhook_endpoints_str = os.environ.get('WEBHOOK_ENDPOINTS', '[]')
    project_name = os.environ.get('PROJECT_NAME', 'Unknown')
    environment = os.environ.get('ENVIRONMENT', 'Unknown')
    
    try:
        webhook_endpoints = json.loads(webhook_endpoints_str)
    except json.JSONDecodeError:
        print("ERROR: Invalid WEBHOOK_ENDPOINTS environment variable")
        return {'statusCode': 400, 'body': 'Invalid webhook endpoints configuration'}
    
    if not webhook_endpoints:
        print("INFO: No webhook endpoints configured")
        return {'statusCode': 200, 'body': 'No webhook endpoints to notify'}
    
    try:
        # Parse SNS message
        sns_message = json.loads(event['Records'][0]['Sns']['Message'])
        
        # Extract alarm information
        alarm_name = sns_message.get('AlarmName', 'Unknown Alarm')
        alarm_description = sns_message.get('AlarmDescription', 'No description')
        new_state = sns_message.get('NewStateValue', 'UNKNOWN')
        old_state = sns_message.get('OldStateValue', 'UNKNOWN')
        reason = sns_message.get('NewStateReason', 'No reason provided')
        region = sns_message.get('Region', 'Unknown')
        timestamp = sns_message.get('StateChangeTime', datetime.utcnow().isoformat())
        
        # Create standardized webhook payload
        webhook_payload = {
            "version": "1.0",
            "source": "aws-cloudwatch",
            "project": {
                "name": project_name,
                "environment": environment
            },
            "alarm": {
                "name": alarm_name,
                "description": alarm_description,
                "current_state": new_state,
                "previous_state": old_state,
                "reason": reason,
                "timestamp": timestamp,
                "region": region
            },
            "severity": determine_severity(alarm_name, new_state),
            "category": determine_category(alarm_name),
            "aws_console_url": f"https://console.aws.amazon.com/cloudwatch/home?region={region}#alarmsV2:alarm/{alarm_name}",
            "metadata": {
                "sns_topic": event['Records'][0]['Sns']['TopicArn'],
                "message_id": event['Records'][0]['Sns']['MessageId']
            }
        }
        
        # Send to each configured webhook endpoint
        http = urllib3.PoolManager()
        results = []
        
        for endpoint in webhook_endpoints:
            try:
                endpoint_name = endpoint.get('name', 'Unknown')
                endpoint_url = endpoint.get('url')
                auth_header = endpoint.get('auth_header', '')
                
                if not endpoint_url:
                    print(f"WARNING: Endpoint '{endpoint_name}' has no URL configured")
                    continue
                
                # Prepare headers
                headers = {
                    'Content-Type': 'application/json',
                    'User-Agent': f'{project_name}-monitoring/{environment}'
                }
                
                # Add authentication header if provided
                if auth_header:
                    # Support for Bearer tokens and custom headers
                    if auth_header.startswith('Bearer '):
                        headers['Authorization'] = auth_header
                    elif auth_header.startswith('Basic '):
                        headers['Authorization'] = auth_header
                    elif ':' in auth_header:
                        # Custom header format "Header-Name: Header-Value"
                        header_parts = auth_header.split(':', 1)
                        headers[header_parts[0].strip()] = header_parts[1].strip()
                
                # Create endpoint-specific payload
                endpoint_payload = {
                    **webhook_payload,
                    "endpoint": {
                        "name": endpoint_name,
                        "delivery_timestamp": datetime.utcnow().isoformat()
                    }
                }
                
                # Send webhook request
                response = http.request(
                    'POST',
                    endpoint_url,
                    body=json.dumps(endpoint_payload).encode('utf-8'),
                    headers=headers,
                    timeout=10  # 10 second timeout
                )
                
                result = {
                    'endpoint': endpoint_name,
                    'url': endpoint_url,
                    'status_code': response.status,
                    'success': 200 <= response.status < 300
                }
                
                if result['success']:
                    print(f"SUCCESS: Webhook sent to '{endpoint_name}' - Status: {response.status}")
                else:
                    print(f"WARNING: Webhook to '{endpoint_name}' returned status: {response.status}")
                    print(f"Response: {response.data.decode('utf-8')[:500]}")
                
                results.append(result)
                
            except Exception as e:
                print(f"ERROR: Failed to send webhook to '{endpoint_name}': {str(e)}")
                results.append({
                    'endpoint': endpoint_name,
                    'url': endpoint_url,
                    'error': str(e),
                    'success': False
                })
        
        # Calculate success rate
        successful_deliveries = sum(1 for r in results if r.get('success', False))
        total_endpoints = len(results)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Webhook notifications processed: {successful_deliveries}/{total_endpoints} successful',
                'alarm_name': alarm_name,
                'state': new_state,
                'results': results
            })
        }
        
    except Exception as e:
        print(f"ERROR: Failed to process webhook notifications: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'message': 'Failed to process webhook notifications'
            })
        }

def determine_severity(alarm_name, state):
    """Determine alarm severity based on name and state"""
    if state != 'ALARM':
        return 'info'
    
    alarm_lower = alarm_name.lower()
    
    if 'critical' in alarm_lower:
        return 'critical'
    elif any(keyword in alarm_lower for keyword in ['high', 'error', '5xx', 'unhealthy']):
        return 'high'
    elif any(keyword in alarm_lower for keyword in ['medium', '4xx', 'latency']):
        return 'medium'
    else:
        return 'low'

def determine_category(alarm_name):
    """Determine alarm category based on name"""
    alarm_lower = alarm_name.lower()
    
    if any(keyword in alarm_lower for keyword in ['ec2', 'cpu', 'memory', 'disk']):
        return 'compute'
    elif any(keyword in alarm_lower for keyword in ['rds', 'database', 'connection']):
        return 'database'
    elif any(keyword in alarm_lower for keyword in ['alb', 'load-balancer', 'response-time']):
        return 'load-balancer'
    elif any(keyword in alarm_lower for keyword in ['network', 'traffic']):
        return 'network'
    elif 'cost' in alarm_lower:
        return 'cost-optimization'
    else:
        return 'general'