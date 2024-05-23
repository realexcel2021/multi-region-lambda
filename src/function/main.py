def lambda_handler(event, context):
    print("testing lambda code....")
    return {
        "message": "Hello from lambda function",
        "function_arn": f"invoked {context.invoked_function_arn}"
    }