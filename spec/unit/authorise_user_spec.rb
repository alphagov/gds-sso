require "spec_helper"
require "gds-sso/authorise_user"

describe GDS::SSO::AuthoriseUser do
  describe "#call" do
    let(:current_user) { double }

    context "with a single string permission argument" do
      let(:permissions) { "admin" }
      let(:expected_error) { GDS::SSO::PermissionDeniedError }

      it "permits users with the required permission" do
        allow(current_user).to receive(:has_permission?).with("admin").and_return(true)

        expect { described_class.call(current_user, permissions) }.not_to raise_error
      end

      it "does not permit the users without the required permission" do
        allow(current_user).to receive(:has_permission?).with("admin").and_return(false)

        expect { described_class.call(current_user, permissions) }.to raise_error(expected_error)
      end
    end

    context "with the `all_of` option" do
      let(:permissions) { { all_of: %w[admin editor] } }
      let(:expected_error) { GDS::SSO::PermissionDeniedError }

      it "permits users with all of the required permissions" do
        allow(current_user).to receive(:has_permission?).with("admin").and_return(true)
        allow(current_user).to receive(:has_permission?).with("editor").and_return(true)

        expect { described_class.call(current_user, permissions) }.not_to raise_error
      end

      it "does not permit users without all of the required permissions" do
        allow(current_user).to receive(:has_permission?).with("admin").and_return(false)
        allow(current_user).to receive(:has_permission?).with("editor").and_return(true)

        expect { described_class.call(current_user, permissions) }.to raise_error(expected_error)
      end
    end

    context "with the `any_of` option" do
      let(:permissions) { { any_of: %w[admin editor] } }
      let(:expected_error) { GDS::SSO::PermissionDeniedError }

      it "permits users with any of the required permissions" do
        allow(current_user).to receive(:has_permission?).with("admin").and_return(true)
        allow(current_user).to receive(:has_permission?).with("editor").and_return(false)

        expect { described_class.call(current_user, permissions) }.not_to raise_error
      end

      it "does not permit users without any of the required permissions" do
        allow(current_user).to receive(:has_permission?).and_return(false)

        expect { described_class.call(current_user, permissions) }.to raise_error(expected_error)
      end
    end

    context "with none of `any_of` or `all_of`" do
      it "raises an `ArgumentError`" do
        expect { described_class.call(current_user, { admin: true }) }
          .to raise_error(ArgumentError)
      end
    end
  end
end
