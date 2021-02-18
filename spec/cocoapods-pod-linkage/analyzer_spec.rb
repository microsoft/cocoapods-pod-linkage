require 'spec_helper'

module Pod

  describe Installer::Analyzer do

    before do
      @podfile = Podfile.new
      @root = Podfile::TargetDefinition.new('Pods', @podfile)
      @parent = Podfile::TargetDefinition.new('MyApp', @root)
      @sandbox = mock()
      @analyzer = Installer::Analyzer.new(@sandbox, @podfile, nil, [], true, false, mock())
      def @analyzer.compute_pod_target_dependencies(pod_targets, all_specs)
        pod_targets
      end
    end

    describe "#generate_pod_targets" do

      let(:specification) { Specification.new(nil, 'MyPod') }

      [
        [:library, :static],
        [:library, :dynamic],
        [:framework, :static],
        [:framework, :dynamic],
      ].each do |params|
        it "updates a PodTarget with #{params[1]} linkage and #{params[0]} packaging" do
          packaging = params[0]
          linkage = params[1] == :static ? :dynamic : :static
          original_pod_target = PodTarget.new(
            @sandbox,
            BuildType.new(:linkage => params[1], :packaging => packaging),
            {},
            [],
            Platform.ios,
            [specification],
            [@parent]
          )
          updated_pod_target = PodTarget.new(
            @sandbox,
            BuildType.new(:linkage => linkage, :packaging => packaging),
            {},
            [],
            Platform.ios,
            [specification],
            [@parent]
          )

          @parent.store_pod('MyPod', :linkage => linkage)
          @analyzer.stubs(:original_generate_pod_targets).returns([original_pod_target])

          expect(@analyzer.generate_pod_targets({}, {})).to include(lambda { |target|
            target.pod_name == 'MyPod' &&
            (
              (packaging == :library && target.build_as_library?) ||
              (packaging == :framework && target.build_as_framework?)
            ) &&
            (
              (linkage == :static && target.build_as_static?) ||
              (linkage == :dynamic && target.build_as_dynamic?)
            ) &&
            target.scope_suffix.nil? &&
            target.target_definitions.include?(@parent)
          })
        end
      end

    end

  end

end
