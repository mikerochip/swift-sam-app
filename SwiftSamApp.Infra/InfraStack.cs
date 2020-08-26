using Pulumi;

namespace SwiftSamApp.Infra
{
    internal class InfraStack : Stack
    {
        [Output]
        public Output<string>? PipelineWebhookUrl { get; set; }
        
        public InfraStack()
        {
            PipelineResources pipelineResources = new PipelineResources(this);
            pipelineResources.CreateResources();
        }
    }
}
