# frozen_string_literal: true

require "project_types/script/test_helper"
require "project_types/script/layers/infrastructure/fake_extension_point_repository"

describe Script::Layers::Application::BuildScript do
  include TestHelpers::FakeFS
  describe '.call' do
    let(:language) { 'assemblyscript' }
    let(:extension_point_type) { 'discount' }
    let(:script_name) { 'name' }
    let(:op_failed_msg) { 'msg' }
    let(:content) { 'content' }
    let(:compiled_type) { 'wasm' }
    let(:task_runner) { stub(compiled_type: compiled_type) }

    subject do
      Script::Layers::Application::BuildScript.call(
        ctx: @context,
        task_runner: task_runner,
        script_name: script_name,
        extension_point_type: extension_point_type
      )
    end

    describe 'when build succeeds' do
      it 'should return normally' do
        CLI::UI::Frame.expects(:with_frame_color_override).never
        task_runner.expects(:build).returns(content)
        Script::Layers::Infrastructure::PushPackageRepository
          .any_instance
          .expects(:create_push_package)
          .with(extension_point_type, script_name, content, 'wasm')
        capture_io { subject }
      end
    end

    describe 'when build raises' do
      it 'should output message and raise BuildError' do
        err_msg = 'some error message'
        CLI::UI::Frame.expects(:with_frame_color_override).yields.once
        task_runner.expects(:build).returns(content)
        Script::Layers::Infrastructure::PushPackageRepository
          .any_instance
          .expects(:create_push_package)
          .raises(err_msg)

        io = capture_io do
          assert_raises(Script::Layers::Infrastructure::Errors::BuildError) { subject }
        end

        output = io.join
        assert_match(err_msg, output)
      end

      [
        Script::Layers::Infrastructure::Errors::InvalidBuildScriptError,
        Script::Layers::Infrastructure::Errors::BuildScriptNotFoundError,
        Script::Layers::Infrastructure::Errors::WebAssemblyBinaryNotFoundError,
      ].each do |e|
        it "it should re-raise #{e} when the raised error is #{e}" do
          CLI::UI::Frame.expects(:with_frame_color_override).yields.once
          task_runner.expects(:build).raises(e)
          capture_io do
            assert_raises(e) { subject }
          end
        end
      end
    end
  end
end
