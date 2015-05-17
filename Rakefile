require 'ffi'

MAZE_BASE = File.join(File.dirname(__FILE__), 'lib/maze')
MAZE_LIB = File.join(MAZE_BASE, "lib/libmaze.#{FFI::Platform::LIBSUFFIX}")
MAZE_EX  = File.join(MAZE_BASE, "bin/mz")
MAZE_ARTIFACTS = [MAZE_LIB, MAZE_EX]

task :default => :build


desc "Deletes the artifacts"
task :clean do
  MAZE_ARTIFACTS.each do |file|
    rm(file) if File.exists?(file)
  end
end

desc "Compile the maze code"
task :build  do
  sh %[
cd #{MAZE_BASE}
cmake . && make
]
end
