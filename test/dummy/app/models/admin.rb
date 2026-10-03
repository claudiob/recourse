# The module the admin's controllers live in, and one model too (Admin::Badge). Named
# relative to it, so a badge's routes, params and partials say `badge` as a top-level
# model's would, rather than `admin_badge`.
module Admin
  def self.use_relative_model_naming? = true
end
