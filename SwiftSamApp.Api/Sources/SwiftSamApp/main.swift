import AWSLambdaEvents
import AWSLambdaRuntime

printJson("""
{
    "Message": "I'm alive!"
}
""")

Lambda.run(APIGatewayProxyLambda())
