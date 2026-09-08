module Recourse
  module Generators
    # Reading what a host already has, always under the root the generator writes
    # to, so a `--pretend` run and a test's temporary directory both answer for
    # themselves. Private for the reason `Seeds` is.
    module Files
    private

      def exist?(path)
        File.exist? File.join(destination_root, path)
      end

      def read(path)
        File.read File.join(destination_root, path)
      end
    end
  end
end
