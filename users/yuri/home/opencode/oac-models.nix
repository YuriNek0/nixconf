_: {
  flake.modules.users.yuri.home.oac-models =
    _:
    let
      proReasoningModel = "openai/gpt-6-astra";
      reasoningModel = "openai/gpt-5.6-sol";
      defaultModel = "openai/gpt-5.6-sol";
      codingModel = "openai/gpt-5.6-sol";
      fastCodingModel = "openai/gpt-5.6-terra";
      scoutModel = "openai/gpt-5.6-luna";
      contentModel = "openai/gpt-5.6-luna";
      dataModel = "openai/gpt-5.6-sol";
      utilityModel = "openai/gpt-5.6-luna";

      highReasoning = {
        model = proReasoningModel;
        reasoningEffort = "high";
        textVerbosity = "low";
      };

      reasoning = {
        model = reasoningModel;
        reasoningEffort = "medium";
        textVerbosity = "low";
      };
    in
    {
      programs.opencode.settings = {
        model = defaultModel;
        small_model = utilityModel;

        agent = {
          build.model = codingModel;
          plan = highReasoning;
          general.model = defaultModel;
          explore.model = scoutModel;
          scout.model = scoutModel;
          compaction.model = utilityModel;
          title.model = utilityModel;
          summary.model = utilityModel;

          OpenAgent.model = defaultModel;
          OpenCoder.model = codingModel;
          OpenSystemBuilder = highReasoning;
          OpenRepoManager = reasoning;
          "Eval Runner".model = utilityModel;

          OpenTechnicalWriter.model = contentModel;
          OpenCopywriter.model = contentModel;
          OpenDataAnalyst.model = dataModel;

          TaskManager = reasoning;
          DocWriter.model = contentModel;
          ContextScout.model = scoutModel;
          ExternalScout.model = scoutModel;
          "Context Retriever".model = scoutModel;

          CoderAgent.model = codingModel;
          BuildAgent.model = fastCodingModel;
          TestEngineer.model = fastCodingModel;
          CodeReviewer = reasoning;
          OpenFrontendSpecialist.model = codingModel;
          OpenDevopsSpecialist.model = codingModel;

          DomainAnalyzer = reasoning;
          AgentGenerator.model = fastCodingModel;
          ContextOrganizer.model = scoutModel;
          WorkflowDesigner = reasoning;
          CommandCreator.model = fastCodingModel;

          "Image Specialist".model = defaultModel;
        };
      };
    };
}
