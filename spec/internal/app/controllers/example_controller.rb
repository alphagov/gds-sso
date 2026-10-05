class ExampleController < ApplicationController
  before_action :authenticate_user!, except: %i[not_restricted stuff_session]
  before_action -> { authorise_user!("execute") }, only: :this_requires_execute_permission
  def not_restricted
    render body: "jabberwocky"
  end

  def restricted
    render body: "restricted kablooie"
  end

  def this_requires_execute_permission
    render body: "you have execute permission"
  end

  def constraint_restricted
    render body: "constraint restricted"
  end

  def stuff_session
    session["app_data"] = "A" * params.fetch(:size, 6000).to_i
    render body: "ok"
  end
end
