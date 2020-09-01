using Pulumi;
using Pulumi.Aws.Iam;
using Pulumi.Aws.Iam.Inputs;
using Pulumi.Aws.CloudWatch;
using Pulumi.Aws.CodeBuild;
using Pulumi.Aws.CodeBuild.Inputs;
using Pulumi.Aws.CodePipeline;
using Pulumi.Aws.CodePipeline.Inputs;
using Pulumi.Aws.S3;
using Pulumi.Aws.S3.Inputs;
using Pulumi.Github;
using Pulumi.Github.Inputs;

using Config = Pulumi.Config;
using PipelineWebhook = Pulumi.Aws.CodePipeline.Webhook;
using PipelineWebhookArgs = Pulumi.Aws.CodePipeline.WebhookArgs;

namespace SwiftSamApp.Infra
{
    internal class PipelineResources
    {
        #region Properties
        private InfraStack Stack { get; }
        private Config Config { get; } = new Config();
        private Config GitHubConfig { get; } = new Config("github");
        #endregion
        
        #region Initialization
        public PipelineResources(InfraStack stack)
        {
            Stack = stack;
        }

        public void CreateResources()
        {
            Bucket bucket = CreateArtifactBucket();
            Role pipelineRole = CreatePipelineRole();
            Project buildProject = CreateBuildProject(bucket);
            Role cloudFormationRole = CreateCloudFormationRole();
            Pipeline pipeline = CreatePipeline(bucket, pipelineRole, buildProject, cloudFormationRole);
            PipelineWebhook webhook = CreatePipelineWebhook(pipeline);
            CreateRepoWebhook(webhook);
        }
        #endregion

        #region Artifacts
        private Bucket CreateArtifactBucket()
        {
            Bucket bucket = new Bucket("swift-sam-app-artifacts", new BucketArgs
            {
                LifecycleRules = new BucketLifecycleRuleArgs
                {
                    Enabled = true,
                    Expiration = new BucketLifecycleRuleExpirationArgs
                    {
                        Days = 1,
                    },
                },
            });
            return bucket;
        }
        #endregion

        #region Roles
        private Role CreatePipelineRole()
        {
            return IamUtil.CreateRole(
                "SwiftSamAppPipeline",
                "codepipeline.amazonaws.com",
                "arn:aws:iam::aws:policy/AdministratorAccess");
        }

        private Role CreateCloudFormationRole()
        {
            return IamUtil.CreateRole(
                "SwiftSamAppCloudFormation",
                "cloudformation.amazonaws.com",
                "arn:aws:iam::aws:policy/AdministratorAccess");
        }
        #endregion

        #region BuildProject
        private Project CreateBuildProject(Bucket bucket)
        {
            Role role = CreateBuildRole();
            
            Project project = new Project("SwiftSamApp", new ProjectArgs
            {
                ServiceRole = role.Arn,
                Artifacts = new ProjectArtifactsArgs
                {
                    Type = "CODEPIPELINE",
                },
                Source = new ProjectSourceArgs
                {
                    Type = "CODEPIPELINE",
                    Buildspec = "SwiftSamApp.Infra/Api.buildspec.yml",
                },
                Environment = new ProjectEnvironmentArgs
                {
                    ComputeType = "BUILD_GENERAL1_SMALL",
                    Type = "LINUX_CONTAINER",
                    Image = "aws/codebuild/amazonlinux2-x86_64-standard:3.0",
                    EnvironmentVariables =
                    {
                        new ProjectEnvironmentEnvironmentVariableArgs
                        {
                            Name = "ArtifactBucket",
                            Value = bucket.BucketName,
                        },
                        new ProjectEnvironmentEnvironmentVariableArgs
                        {
                            Name = "ArtifactBucketPrefix",
                            Value = "SwiftSamApp/Builds",
                        },
                        new ProjectEnvironmentEnvironmentVariableArgs
                        {
                            Name = "TemplateFileName",
                            Value = "template.json",
                        },
                        new ProjectEnvironmentEnvironmentVariableArgs
                        {
                            Name = "OutputTemplateFileName",
                            Value = "output-template.json",
                        },
                    }
                }
            });
            
            LogGroup logGroup = new LogGroup("SwiftSamAppBuilder",
                new LogGroupArgs
                {
                    Name = Output.Format($"/aws/codebuild/{project.Name}"),
                    RetentionInDays = 1,
                },
                new CustomResourceOptions
                {
                    Parent = project,
                });
            
            return project;
        }

        private Role CreateBuildRole()
        {
            Role role = IamUtil.CreateRole(
                "SwiftSamAppBuild",
                "codebuild.amazonaws.com",
                "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess");
            
            // add permissions not covered by the managed policies
            Output<GetPolicyDocumentResult> policyDocument = Output.Create(GetPolicyDocument.InvokeAsync(new GetPolicyDocumentArgs
            {
                Statements =
                {
                    new GetPolicyDocumentStatementArgs
                    {
                        Resources = { "*" },
                        Actions =
                        {
                            "logs:CreateLogGroup",
                            "logs:CreateLogStream",
                            "logs:PutLogEvents",
                            "s3:GetObject",
                            "s3:GetObjectVersion",
                            "s3:PutObject",
                        },
                    }
                }
            }));
            RolePolicy policy = new RolePolicy("SwiftSamAppBuilder", new RolePolicyArgs
            {
                Role = role.Id,
                Policy = policyDocument.Apply(p => p.Json),
            });

            return role;
        }
        #endregion

        #region Pipeline
        private Pipeline CreatePipeline(Bucket bucket, Role pipelineRole, Project buildProject, Role cloudFormationRole)
        {
            Pipeline pipeline = new Pipeline("SwiftSamApp", new PipelineArgs
            {
                ArtifactStore = new PipelineArtifactStoreArgs
                {
                    Type = "S3",
                    Location = bucket.BucketName,
                },
                RoleArn = pipelineRole.Arn,
                Stages =
                {
                    new PipelineStageArgs
                    {
                        Name = "Source",
                        Actions =
                        {
                            new PipelineStageActionArgs
                            {
                                Name = "Source",
                                Category = "Source",
                                Owner = "ThirdParty",
                                Provider = "GitHub",
                                Version = "1",
                                Configuration =
                                {
                                    { "Owner", Config.Require("githubOwner") },
                                    { "Repo", Config.Require("githubRepo") },
                                    { "Branch", Config.Require("githubBranch") },
                                    { "OAuthToken", GitHubConfig.RequireSecret("token") },
                                    { "PollForSourceChanges", "false" },
                                },
                                OutputArtifacts = { "SourceArtifact" },
                            },
                        },
                    },
                    new PipelineStageArgs
                    {
                        Name = "Build",
                        Actions =
                        {
                            new PipelineStageActionArgs
                            {
                                Name = "Build",
                                Category = "Build",
                                Owner = "AWS",
                                Provider = "CodeBuild",
                                Version = "1",
                                InputArtifacts = { "SourceArtifact" },
                                Configuration =
                                {
                                    { "ProjectName", buildProject.Name },
                                    {
                                        "EnvironmentVariables",
                                        "[ { \"name\": \"ProjectPath\", \"value\": \"SwiftSamApp.Api\" } ]"
                                    },
                                },
                                OutputArtifacts = { "BuildArtifact" },
                                RunOrder = 1,
                            },
                        },
                    },
                    new PipelineStageArgs
                    {
                        Name = "Deploy",
                        Actions =
                        {
                            new PipelineStageActionArgs
                            {
                                Name = "CreateChangeSet",
                                Category = "Deploy",
                                Owner = "AWS",
                                Provider = "CloudFormation",
                                Version = "1",
                                InputArtifacts = { "BuildArtifact" },
                                Configuration =
                                {
                                    { "ActionMode", "CHANGE_SET_REPLACE" },
                                    { "StackName", "SwiftSamApp" },
                                    { "ChangeSetName", "CodePipelineChangeSet" },
                                    { "TemplatePath", "BuildArtifact::output-template.json" },
                                    { "Capabilities", "CAPABILITY_NAMED_IAM" },
                                    { "RoleArn", cloudFormationRole.Arn },
                                },
                                RunOrder = 1,
                            },
                            new PipelineStageActionArgs
                            {
                                Name = "ExecuteChangeSet",
                                Category = "Deploy",
                                Owner = "AWS",
                                Provider = "CloudFormation",
                                Version = "1",
                                Configuration =
                                {
                                    { "ActionMode", "CHANGE_SET_EXECUTE" },
                                    { "StackName", "SwiftSamApp" },
                                    { "ChangeSetName", "CodePipelineChangeSet" },
                                    { "RoleArn", cloudFormationRole.Arn },
                                },
                                RunOrder = 2,
                            },
                        },
                    },
                },
            });
            return pipeline;
        }
        #endregion

        #region Webhooks
        private PipelineWebhook CreatePipelineWebhook(Pipeline pipeline)
        {
            string branch = Config.Require("githubBranch");
            
            PipelineWebhook webhook = new PipelineWebhook("SwiftSamApp", new PipelineWebhookArgs
            {
                Authentication = "GITHUB_HMAC",
                AuthenticationConfiguration = new WebhookAuthenticationConfigurationArgs
                {
                    SecretToken = Config.RequireSecret("webhookSecret"),
                },
                Filters = new WebhookFilterArgs
                {
                    JsonPath = "$.ref",
                    MatchEquals = $"refs/heads/{branch}",
                },
                TargetAction = "Source",
                TargetPipeline = pipeline.Name,
            });
            
            Stack.PipelineWebhookUrl = webhook.Url;
            
            return webhook;
        }

        private void CreateRepoWebhook(PipelineWebhook pipelineWebhook)
        {
            RepositoryWebhook repoWebhook = new RepositoryWebhook($"SwiftSamApp-CodePipeline", new RepositoryWebhookArgs
            {
                Repository = Config.Require("githubRepo"),
                Events = "push",
                Configuration = new RepositoryWebhookConfigurationArgs
                {
                    ContentType = "json",
                    InsecureSsl = false,
                    Secret = Config.RequireSecret("webhookSecret"),
                    Url = pipelineWebhook.Url,
                }
            });
        }
        #endregion
    }
}
