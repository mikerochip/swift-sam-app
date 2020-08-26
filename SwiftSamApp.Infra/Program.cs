using System.Threading.Tasks;
using Pulumi;

namespace SwiftSamApp.Infra
{
    internal static class Program
    {
        static Task<int> Main() => Deployment.RunAsync<InfraStack>();
    }
}
