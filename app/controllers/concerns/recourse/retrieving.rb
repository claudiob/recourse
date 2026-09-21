module Recourse
  # Whether a page offers to fetch its rows again from wherever they came.
  module Retrieving
    extend ActiveSupport::Concern

    included { helper_method :recourse_retrievable? }

  private

    # Whether this page offers to fetch its rows again, where the routes said it may.
    # True unless the host says otherwise, since a provider with no CRM connected has
    # nothing to fetch from and only the host knows it: `def recourse_retrievable? =
    # @provider.integrated?`. Private, so narrowing it adds no action.
    def recourse_retrievable? = true
  end
end
