using Pulumi;
using Pulumi.Aws.Route53;

namespace SwiftSamApp.Infra
{
    internal class DomainResources
    {
        #region Properties
        private InfraStack Stack { get; }
        private Config Config { get; } = new Config();
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
            Stack.DomainName = Output.Format($"{Stack.Subdomain}.{zone.Name}");
        }
        #endregion
    }
}