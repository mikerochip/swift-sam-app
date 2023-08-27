using Pulumi;
using Pulumi.Aws.Route53;

namespace SwiftSamApp.Infra
{
    internal class DomainResources
    {
        #region Properties
        private InfraStack Stack { get; }
        #endregion
        
        #region Initialization
        public DomainResources(InfraStack stack)
        {
            Stack = stack;
        }

        public void CreateResources()
        {
            ImportZone();
        }
        #endregion
        
        #region HostedZone
        private void ImportZone()
        {
            Zone zone = Zone.Get("DomainZone", Stack.DomainZoneId);
            Output<string> domainName = zone.Name.Apply(n => n.TrimEnd('.'));
            Stack.DomainName = Output.Format($"{Stack.Subdomain}.{domainName}");
        }
        #endregion
    }
}