def handler(event, _):
    """Trigger to automatically confirm user signups"""
    event["response"]["autoConfirmUser"] = True
    return event
