using Pulumi;

namespace SwiftSamApp.Infra
{
    internal class InfraStack : Stack
    {
        [Output]
        public Output<string>? DomainName { get; set; }

        public string DomainZoneId { get; set; } = "Z04585421KLVK3HTHS622";
        public string Subdomain { get; set; } = "swiftsamapp";
        
        public InfraStack()
        {
            DomainResources domainResources = new DomainResources(this);
            domainResources.CreateResources();
            
            PipelineResources pipelineResources = new PipelineResources(this);
            pipelineResources.CreateResources();
        }
    }
}
