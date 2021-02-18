require 'spec_helper'

module Pod

  describe Podfile::TargetDefinition do

    before do
      @podfile = Podfile.new
      @root = Podfile::TargetDefinition.new('Pods', @podfile)
      @parent = Podfile::TargetDefinition.new('MyApp', @root)
      @child = Podfile::TargetDefinition.new('MyAppTests', @parent)
    end

    describe "#store_pod" do

      context 'when the target does not have a parent' do

        it "doesn't set an explicit linkage by default" do
          @parent.store_pod('MyPod')
          expect(@parent.explicit_pod_linkage['MyPod']).to be_nil
        end

        it 'allows configuring an explicit linkage for a pod' do
          @parent.store_pod('MyPod', :linkage => :static)
          expect(@parent.explicit_pod_linkage['MyPod']).to eq(:static)
        end

      end

      context 'when the target has a parent' do

        it "doesn't set an explicit linkage by default" do
          @child.store_pod('MyPod')
          expect(@child.explicit_pod_linkage['MyPod']).to be_nil
        end

        it 'allows configuring an explicit linkage for a pod' do
          @child.store_pod('MyPod', :linkage => :static)
          expect(@child.explicit_pod_linkage['MyPod']).to eq(:static)
        end

        it 'inherits the explicit linkage for a pod from the parent' do
          @parent.store_pod('MyPod', :linkage => :static)
          expect(@child.explicit_pod_linkage['MyPod']).to eq(:static)
        end

        it 'allows to override the explicit linkage for a pod from the parent' do
          @parent.store_pod('MyPod', :linkage => :static)
          @child.store_pod('MyPod', :linkage => :dynamic)
          expect(@child.explicit_pod_linkage['MyPod']).to eq(:dynamic)
        end

      end

    end

  end

end
