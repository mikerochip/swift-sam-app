import AWSLambdaEvents
import AWSLambdaRuntime

print("""
{
    "Message" = "I'm alive!"
}
""")

Lambda.run(APIGatewayProxyLambda())
