
def staging
  "build/staging"
end

sources = Rake::FileList["{lib,spec,locale}/**/*"]

# Create directory and file targets for everything we
# might want to copy
sources.each do |source|
  target = File.join(staging, source) 
  target_dir = File.dirname(target)
  stat = File.lstat(source)

  if stat.file?
    file target => [source, target_dir] do
      cp source, target
    end
  elsif stat.directory?
    directory target => [target_dir] do
      mkdir target
    end 
  end
end

namespace "build" do
  task "copy" => sources.collect { |s| File.join(staging, s) }
  task "all" => "copy"
end

namespace "clean" do
  task "copy" do
    sources.collect { |f| File.join(staging, f) }.select { |f| File.file?(f) }.each { |f| File.unlink(f) }
    sources.collect { |f| File.join(staging, f) }.select { |f| File.directory?(f) }.sort_by { |f| -f.bytesize }.each { |f| Dir.delete(f) }
  end

  task "all" => "copy"
end
