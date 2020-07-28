require "spec_helper"

RSpec.describe GDS::SSO::ControllerMethods, "#authorise_user!" do
  class ControllerSpy < ApplicationController
    include GDS::SSO::ControllerMethods

    def initialize(current_user)
      @current_user = current_user
    end

    def authenticate_user!
      true
    end

    attr_reader :current_user
  end

  let(:current_user) { double }
  let(:expected_error) { GDS::SSO::ControllerMethods::PermissionDeniedException }

  context "with a single string permission argument" do
    it "permits users with the required permission" do
      allow(current_user).to receive(:has_permission?).with("good").and_return(true)

      expect { ControllerSpy.new(current_user).authorise_user!("good") }.not_to raise_error
    end

    it "does not permit the users without the required permission" do
      allow(current_user).to receive(:has_permission?).with("good").and_return(false)

      expect { ControllerSpy.new(current_user).authorise_user!("good") }.to raise_error(expected_error)
    end
  end

  context "with the `all_of` option" do
    it "permits users with all of the required permissions" do
      allow(current_user).to receive(:has_permission?).with("good").and_return(true)
      allow(current_user).to receive(:has_permission?).with("bad").and_return(true)

      expect { ControllerSpy.new(current_user).authorise_user!(all_of: %w[good bad]) }.not_to raise_error
    end

    it "does not permit users without all of the required permissions" do
      allow(current_user).to receive(:has_permission?).with("good").and_return(false)
      allow(current_user).to receive(:has_permission?).with("bad").and_return(true)

      expect { ControllerSpy.new(current_user).authorise_user!(all_of: %w[good bad]) }.to raise_error(expected_error)
    end
  end

  context "with the `any_of` option" do
    it "permits users with any of the required permissions" do
      allow(current_user).to receive(:has_permission?).with("good").and_return(true)
      allow(current_user).to receive(:has_permission?).with("bad").and_return(false)

      expect { ControllerSpy.new(current_user).authorise_user!(any_of: %w[good bad]) }.not_to raise_error
    end

    it "does not permit users without any of the required permissions" do
      allow(current_user).to receive(:has_permission?).and_return(false)

      expect { ControllerSpy.new(current_user).authorise_user!(any_of: %w[good bad]) }.to raise_error(expected_error)
    end
  end

  context "with none of `any_of` or `all_of`" do
    it "raises an `ArgumentError`" do
      expect { ControllerSpy.new(current_user).authorise_user!(whoops: "bad") }.to raise_error(ArgumentError)
    end
  end
end
