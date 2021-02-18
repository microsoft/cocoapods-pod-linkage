require 'cocoapods'

class Pod::Installer::Analyzer

    alias_method :original_generate_pod_targets, :generate_pod_targets

    def generate_pod_targets(resolver_specs_by_target, target_inspections)
        targets = original_generate_pod_targets(resolver_specs_by_target, target_inspections)

        pod_targets = []
        targets.each { |target|
            explicit_linkage = target.target_definitions.map { |t| t.explicit_pod_linkage[target.pod_name] }.compact.first

            # We need to update the target only if we specified an explicit linkage
            if explicit_linkage
                override_target = ((explicit_linkage == :static && target.build_as_dynamic?) || (explicit_linkage == :dynamic && target.build_as_static?))

                # Create the correct Pod::BuildType because Pod::PodTarget doesn't expose it
                if target.build_as_framework?
                    build_type = Pod::BuildType.new(:linkage => explicit_linkage, :packaging => :framework)
                else
                    build_type = Pod::BuildType.new(:linkage => explicit_linkage, :packaging => :library)
                end

                # Pods are de-duplicated before this function, we need to merge them remove the scope suffix
                scope_suffix = target.scope_suffix
                if scope_suffix == 'static' || scope_suffix == 'dynamic'
                    override_target = true
                    scope_suffix = nil
                end

                if override_target
                    # Create the new target
                    target = Pod::PodTarget.new(
                        target.sandbox,
                        build_type,
                        target.user_build_configurations,
                        target.archs,
                        target.platform,
                        target.specs,
                        target.target_definitions,
                        target.file_accessors,
                        scope_suffix,
                        target.swift_version
                    )

                    # If we already have a target with the same name we just merge the target defitions
                    # TODO: Check that all the other properties are really the same!
                    existing_target = pod_targets.find { |t| t.label == target.label }
                    if existing_target
                        Pod::UserInterface.message "- Merging #{target.pod_name} target definitions"

                        target = Pod::PodTarget.new(
                            existing_target.sandbox,
                            build_type,
                            existing_target.user_build_configurations,
                            existing_target.archs,
                            existing_target.platform,
                            existing_target.specs,
                            existing_target.target_definitions + target.target_definitions,
                            existing_target.file_accessors,
                            existing_target.scope_suffix,
                            existing_target.swift_version
                        )

                        pod_targets.delete existing_target
                    else
                        Pod::UserInterface.message "- Updating #{target.pod_name}"
                    end
                end
            end

            pod_targets.append target
        }

        all_specs = resolver_specs_by_target.values.flatten.map(&:spec).uniq.group_by(&:name)
        compute_pod_target_dependencies(pod_targets, all_specs)
    end

end

module Pod
    class Podfile
        class TargetDefinition

            def detect_explicit_pod_linkage(name, requirements)
                @explicit_pod_linkage ||= {}
                options = requirements.last || {}
                @explicit_pod_linkage[Specification.root_name(name)] = options[:linkage] if options.is_a?(Hash) && options[:linkage]
                options.delete(:linkage) if options.is_a?(Hash)
                requirements.pop if options.empty?
            end

            def explicit_pod_linkage
                pod_linkage = @explicit_pod_linkage || {}
                pod_linkage.merge!(parent.explicit_pod_linkage) { |key, v1, v2| v1 } if !parent.nil? && parent.is_a?(TargetDefinition)
                pod_linkage
            end

            original_parse_inhibit_warnings = instance_method(:parse_inhibit_warnings)
            define_method(:parse_inhibit_warnings) do |name, requirements|
                detect_explicit_pod_linkage(name, requirements)
                original_parse_inhibit_warnings.bind(self).call(name, requirements)
            end

        end
    end
end
